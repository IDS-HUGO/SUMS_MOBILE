import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/storage/token_storage.dart';
import 'package:sums/core/network/app_logger.dart';
import '../../domain/entities/catalog_item.dart';
import '../../domain/repositories/cedula_repository.dart';
import '../datasources/remote/cedula_remote_datasource.dart';
import '../datasources/local/cedula_local_datasource.dart';
import '../../../../core/storage/local_database.dart';

class CedulaRepositoryImpl implements CedulaRepository {
  final CedulaRemoteDataSource remoteDataSource;
  final CedulaLocalDataSource? localDataSource;
  final TokenStorage tokenStorage;
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
      return [
        'parentesco',
        'estado-civil',
        'lengua',
        'escolaridad',
        'ingreso-salarial',
        'atencion-embarazo',
        'frecuencia-servicio-salud',
        'toxicomania',
        'enfermedad-cronica',
        'material',
        'manejo-excretas',
        'animal',
      ];
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
      if (localDataSource != null) {
        final jsonStr = jsonEncode(
          list
              .map(
                (e) => {
                  'id': e.id,
                  'nombre': e.nombre,
                  'descripcion': e.descripcion,
                },
              )
              .toList(),
        );
        await (localDataSource!.db.delete(
          localDataSource!.db.catalogosLocal,
        )..where((tbl) => tbl.tipo.equals(key))).go();
        await localDataSource!.db
            .into(localDataSource!.db.catalogosLocal)
            .insert(
              CatalogosLocalCompanion.insert(
                tipo: key,
                jsonList: jsonStr,
                updatedAt: DateTime.now(),
              ),
              mode: InsertMode.insertOrReplace,
            );
      }
      return list;
    } catch (e) {
      if (localDataSource != null) {
        final localResult = await (localDataSource!.db.select(
          localDataSource!.db.catalogosLocal,
        )..where((tbl) => tbl.tipo.equals(key))).getSingleOrNull();
        if (localResult != null) {
          final decoded = jsonDecode(localResult.jsonList) as List;
          return decoded
              .map((e) => CatalogItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return [];
    }
  }

  /// Lee el ID del usuario autenticado actualmente. Devuelve 0 si no hay
  /// sesión activa, lo que resultará en consultas vacías (sin fuga de datos).
  Future<int> _currentUserId() async {
    final session = await tokenStorage.readSession();
    return session?.user.id ?? 0;
  }

  @override
  Future<Map<String, dynamic>> submitCapturaCompleta(
    Map<String, dynamic> body, {
    bool isDraft = false,
  }) async {
    if (isDraft) {
      if (localDataSource != null) {
        final userId = await _currentUserId();
        final localId = await localDataSource!.saveCedula(
          body,
          0,
          userId: userId,
        );
        return {
          'cedula_id': null,
          '_local_id': localId,
          'status': 'draft',
          'warnings': ['Guardado como borrador localmente'],
        };
      }
      throw Exception('Almacenamiento local no configurado');
    }
    final token = await tokenStorage.readToken();
    try {
      return await remoteDataSource.postCapturaCompleta(body, token: token);
    } catch (e) {
      AppLogger.warn(
        'Fallo red, guardando localmente. (OWASP MASVS-STORAGE-3)',
      );
      if (localDataSource != null) {
        final userId = await _currentUserId();
        final localId = await localDataSource!.saveCedula(
          body,
          1,
          userId: userId,
        );
        return {
          'cedula_id': null,
          '_local_id': localId,
          'status': 'pending_sync',
          'warnings': [
            'Sin conexión. Cédula guardada localmente para sincronizar después.',
          ],
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
      final userId = await _currentUserId();
      return await localDataSource!.countCedulasByStatus(1, userId: userId);
    }
    return 0;
  }

  @override
  Future<int> getDraftCount() async {
    if (localDataSource != null) {
      final userId = await _currentUserId();
      return await localDataSource!.countCedulasByStatus(0, userId: userId);
    }
    return 0;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllLocalCedulas() async {
    if (localDataSource != null) {
      final userId = await _currentUserId();
      return await localDataSource!.getAllCedulas(userId: userId);
    }
    return [];
  }

  @override
  Future<SyncResult> syncPendingCedulas() async {
    if (localDataSource == null) {
      return const SyncResult(error: 'Sin almacenamiento local');
    }
    final userId = await _currentUserId();
    final pending = await localDataSource!.getCedulasByStatus(
      1,
      userId: userId,
    );
    if (pending.isEmpty) return const SyncResult(synced: 0, failed: 0);
    final token = await tokenStorage.readToken();
    int synced = 0;
    int failed = 0;
    for (final record in pending) {
      final localId = record['_localId'] as int;
      final payload = Map<String, dynamic>.from(record)..remove('_localId');
      try {
        await remoteDataSource.postCapturaCompleta(payload, token: token);
        await localDataSource!.updateSyncStatus(localId, 2);
        synced++;
      } catch (e) {
        failed++;
        await localDataSource!.updateSyncStatus(
          localId,
          1,
          error: e.toString(),
        );
      }
    }
    await localDataSource!.deleteOldSynced(7);
    return SyncResult(synced: synced, failed: failed);
  }

  @override
  Future<SyncResult> syncSingleCedula(int localId) async {
    if (localDataSource == null)
      return const SyncResult(error: 'Sin almacenamiento local');
    final userId = await _currentUserId();
    final allPending = await localDataSource!.getCedulasByStatus(
      1,
      userId: userId,
    );
    final record = allPending.firstWhere(
      (r) => r['_localId'] == localId,
      orElse: () => {},
    );
    if (record.isEmpty)
      return const SyncResult(
        error: 'Registro no encontrado o no está pendiente',
      );
    final token = await tokenStorage.readToken();
    final payload = Map<String, dynamic>.from(record)..remove('_localId');
    try {
      await remoteDataSource.postCapturaCompleta(payload, token: token);
      await localDataSource!.updateSyncStatus(localId, 2);
      return const SyncResult(synced: 1);
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('409') ||
          errorMsg.toLowerCase().contains('duplicado')) {
        errorMsg =
            'Conflicto: Este registro ya existe en el servidor o contiene datos duplicados.';
      }
      await localDataSource!.updateSyncStatus(localId, 1, error: errorMsg);
      return SyncResult(failed: 1, error: errorMsg);
    }
  }

  /// Descarga y persiste los catálogos de sistema (`entrevistador` y
  /// `unidad-salud`) necesarios para que el SyncEngine pueda validar las
  /// referencias de cada cédula pendiente antes de subirla.
  ///
  /// Falla silenciosamente ante errores de red para no bloquear al usuario.
  @override
  Future<bool> refreshUserCatalogs() async {
    if (localDataSource == null) return false;
    const systemCatalogs = ['entrevistador', 'unidad-salud'];
    try {
      final token = await tokenStorage.readToken();
      for (final catalogKey in systemCatalogs) {
        try {
          final response = await remoteDataSource.getCatalog(
            catalogKey,
            token: token,
          );
          final list = response
              .whereType<Map<String, dynamic>>()
              .map(CatalogItem.fromJson)
              .toList();
          final jsonStr = jsonEncode(
            list
                .map(
                  (e) => {
                    'id': e.id,
                    'nombre': e.nombre,
                    'descripcion': e.descripcion,
                  },
                )
                .toList(),
          );
          await (localDataSource!.db.delete(
            localDataSource!.db.catalogosLocal,
          )..where((tbl) => tbl.tipo.equals(catalogKey))).go();
          await localDataSource!.db
              .into(localDataSource!.db.catalogosLocal)
              .insert(
                CatalogosLocalCompanion.insert(
                  tipo: catalogKey,
                  jsonList: jsonStr,
                  updatedAt: DateTime.now(),
                ),
                mode: InsertMode.insertOrReplace,
              );
          AppLogger.info(
            'CedulaRepository: catálogo "$catalogKey" refrescado '
            '(${list.length} entradas).',
          );
        } catch (e) {
          // Fallo en un catálogo individual: se registra pero no detiene los demás.
          AppLogger.warn(
            'CedulaRepository: no se pudo refrescar catálogo "$catalogKey": $e',
          );
        }
      }
      return true;
    } catch (e) {
      AppLogger.warn('CedulaRepository: refreshUserCatalogs falló: $e');
      return false;
    }
  }
}
