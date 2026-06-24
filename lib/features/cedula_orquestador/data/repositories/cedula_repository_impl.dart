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
      return ['roles', 'vacunas', 'material_techo', 'material_pared', 'material_piso']; // Fallback keys
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
}
