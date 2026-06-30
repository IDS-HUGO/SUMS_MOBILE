import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/cedula_repository.dart';
import '../datasources/remote/cedula_remote_datasource.dart';
import '../datasources/local/cedula_local_datasource.dart';
import '../../../../core/storage/local_database.dart';

class CedulaRepositoryImpl implements CedulaRepository {
  final CedulaRemoteDataSource remoteDataSource;
  final CedulaLocalDataSource? localDataSource;
  final TokenStorage           tokenStorage;

  const CedulaRepositoryImpl({
    required this.remoteDataSource,
    this.localDataSource,
    required this.tokenStorage,
  });

  @override
  Future<List<String>> getCatalogKeys() async {
    try {
      final token = await tokenStorage.readToken();
      return await remoteDataSource.getCatalogKeys(token: token);
    } catch (e) {
      return ['parentesco', 'estado-civil', 'lengua', 'escolaridad', 'ingreso-salarial', 'atencion-embarazo', 'frecuencia-servicio-salud', 'toxicomania', 'enfermedad-cronica', 'material', 'manejo-excretas', 'animal']; // Fallback keys
    }
  }

  @override
  Future<List<CatalogItem>> getCatalog(String key) async {
    try {
      final token = await tokenStorage.readToken();
      final response = await remoteDataSource.getCatalog(key, token: token);
      final list = response
          .whereType<Map<String, dynamic>>()
          .map(CatalogItem.fromJson)
          .toList();
          
      // Caching
      if (localDataSource != null) {
        final jsonStr = jsonEncode(list.map((e) => {'id': e.id, 'nombre': e.nombre, 'descripcion': e.descripcion}).toList());
        await (localDataSource!.db.delete(localDataSource!.db.catalogosLocal)..where((tbl) => tbl.tipo.equals(key))).go();
        await localDataSource!.db.into(localDataSource!.db.catalogosLocal).insert(
          CatalogosLocalCompanion.insert(
            tipo: key,
            jsonList: jsonStr,
            updatedAt: DateTime.now(),
          ),
          mode: InsertMode.insertOrReplace
        );
      }
      return list;
    } catch (e) {
      if (localDataSource != null) {
        final localResult = await (localDataSource!.db.select(localDataSource!.db.catalogosLocal)..where((tbl) => tbl.tipo.equals(key))).getSingleOrNull();
        if (localResult != null) {
          final decoded = jsonDecode(localResult.jsonList) as List;
          return decoded.map((e) => CatalogItem.fromJson(Map<String,dynamic>.from(e))).toList();
        }
      }
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> submitCapturaCompleta(
    Map<String, dynamic> body, {
    bool isDraft = false,
  }) async {
    // Si es explícitamente un borrador, guardar directamente en BD local y retornar éxito simulado
    if (isDraft) {
      if (localDataSource != null) {
        final localId = await localDataSource!.saveCedula(body, 0); // 0 = DRAFT
        return {
          'cedula_id': null,
          '_local_id': localId,
          'status': 'draft',
          'warnings': ['Guardado como borrador localmente']
        };
      }
      throw Exception('Almacenamiento local no configurado');
    }

    final token = await tokenStorage.readToken();
    try {
      // Intentar enviar al servidor
      return await remoteDataSource.postCapturaCompleta(body, token: token);
    } catch (e) {
      // Si falla por red u otro error, hacer fallback a SQLite
      print('Fallo red, guardando localmente. Error: $e');
      if (localDataSource != null) {
        final localId = await localDataSource!.saveCedula(body, 1); // 1 = PENDING_SYNC
        return {
          'cedula_id': null,
          '_local_id': localId,
          'status': 'pending_sync',
          'warnings': ['Sin conexión. Cédula guardada localmente para sincronizar después.']
        };
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createRecord(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.post(path, body, token: token);
  }

  @override
  Future<Map<String, dynamic>> patchRecord(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await tokenStorage.readToken();
    return remoteDataSource.patch(path, body, token: token);
  }

  @override
  Future<int> getPendingSyncCount() async {
    if (localDataSource != null) {
      return await localDataSource!.countCedulasByStatus(1); // 1 = PENDING_SYNC
    }
    return 0;
  }

  @override
  Future<int> getDraftCount() async {
    if (localDataSource != null) {
      return await localDataSource!.countCedulasByStatus(0); // 0 = DRAFT
    }
    return 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllLocalCedulas() async {
    if (localDataSource != null) {
      return await localDataSource!.getAllCedulas();
    }
    return [];
  }

  @override
  Future<SyncResult> syncPendingCedulas() async {
    if (localDataSource == null) {
      return const SyncResult(error: 'Sin almacenamiento local');
    }

    final pending = await localDataSource!.getCedulasByStatus(1); // 1 = PENDING_SYNC
    if (pending.isEmpty) return const SyncResult(synced: 0, failed: 0);

    final token = await tokenStorage.readToken();
    int synced = 0;
    int failed = 0;

    for (final record in pending) {
      final localId = record['_localId'] as int;
      final payload = Map<String, dynamic>.from(record)..remove('_localId');
      try {
        await remoteDataSource.postCapturaCompleta(payload, token: token);
        await localDataSource!.updateSyncStatus(localId, 2); // 2 = SYNCED
        synced++;
      } catch (e) {
        failed++;
        await localDataSource!.updateSyncStatus(localId, 1, error: e.toString());
      }
    }

    // Purgar antiguos sincronizados (>7 días)
    await localDataSource!.deleteOldSynced(7);

    return SyncResult(synced: synced, failed: failed);
  }

  @override
  Future<SyncResult> syncSingleCedula(int localId) async {
    if (localDataSource == null) return const SyncResult(error: 'Sin almacenamiento local');
    
    // Obtener la cédula específica reconstruyendo el payload
    final allPending = await localDataSource!.getCedulasByStatus(1);
    final record = allPending.firstWhere((r) => r['_localId'] == localId, orElse: () => {});
    
    if (record.isEmpty) return const SyncResult(error: 'Registro no encontrado o no está pendiente');

    final token = await tokenStorage.readToken();
    final payload = Map<String, dynamic>.from(record)..remove('_localId');
    
    try {
      await remoteDataSource.postCapturaCompleta(payload, token: token);
      await localDataSource!.updateSyncStatus(localId, 2); // 2 = SYNCED
      return const SyncResult(synced: 1);
    } catch (e) {
      String errorMsg = e.toString();
      // Estrategia mínima para duplicados (409 Conflict o similar)
      if (errorMsg.contains('409') || errorMsg.toLowerCase().contains('duplicado')) {
        errorMsg = 'Conflicto: Este registro ya existe en el servidor o contiene datos duplicados.';
      }
      await localDataSource!.updateSyncStatus(localId, 1, error: errorMsg);
      return SyncResult(failed: 1, error: errorMsg);
    }
  }
}
