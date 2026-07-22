import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../network/app_logger.dart';
import '../storage/token_storage.dart';

class SyncEngine {
  final CedulaLocalDataSource localDataSource;
  final CedulaRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final TokenStorage tokenStorage;
  SyncEngine({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
    required this.tokenStorage,
  });
  Future<void> syncPendingCedulas() async {
    final result = await connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      AppLogger.info(
        'SyncEngine: Sin conexión a internet. Abortando sincronización.',
      );
      return;
    }
    final pendingRecords = await localDataSource.getCedulasByStatus(1);
    if (pendingRecords.isEmpty) {
      AppLogger.info(
        'SyncEngine: No hay registros pendientes por sincronizar.',
      );
      await localDataSource.deleteOldSynced(7);
      return;
    }
    final validRecords = <Map<String, dynamic>>[];
    for (final record in pendingRecords) {
      final localId = record['_localId'] as int;
      if (await _hasValidCatalogReferences(record)) {
        validRecords.add(record);
      } else {
        AppLogger.warn(
          'SyncEngine: registro $localId con unidad_salud_id/entrevistador_id '
          'inválido o no encontrado en el catálogo local; se omite del reenvío.',
        );
        await localDataSource.updateSyncStatus(
          localId,
          1,
          error:
              'unidad_salud_id o entrevistador_id inválido/no encontrado en '
              'el catálogo local. Revisa el registro antes de reintentar.',
        );
      }
    }
    if (validRecords.isEmpty) {
      AppLogger.info(
        'SyncEngine: Ningún registro pendiente pasó la revalidación de catálogo.',
      );
      return;
    }
    AppLogger.info(
      'SyncEngine: Sincronizando ${validRecords.length} registros...',
    );
    try {
      final payloadsForApi = validRecords.map((r) {
        final payload = Map<String, dynamic>.from(r);
        payload.remove('_localId');
        return payload;
      }).toList();
      final token = await tokenStorage.readToken();
      if (token == null || token.isEmpty) {
        AppLogger.warn(
          'SyncEngine: no hay token de autenticación guardado; se aborta la '
          'sincronización para no enviar la petición sin credenciales.',
        );
        return;
      }
      await remoteDataSource.post('/sums/sync', {
        'payloads': payloadsForApi,
      }, token: token);
      AppLogger.info('SyncEngine: Sincronización exitosa.');
      for (final r in validRecords) {
        final localId = r['_localId'] as int;
        await localDataSource.updateSyncStatus(localId, 2);
      }
      await localDataSource.deleteOldSynced(7);
    } catch (e) {
      AppLogger.error('SyncEngine: Error durante la sincronización', e);
    }
  }

  Future<bool> _hasValidCatalogReferences(Map<String, dynamic> record) async {
    final unidadId = _asInt(record['unidad_salud_id']);
    final entrevistadorId = _asInt(record['entrevistador_id']);
    if (unidadId == null || unidadId <= 0) return false;
    if (entrevistadorId == null || entrevistadorId <= 0) return false;
    final unidadOk = await _existsInLocalCatalog('unidad-salud', unidadId);
    final entrevistadorOk = await _existsInLocalCatalog(
      'entrevistador',
      entrevistadorId,
    );
    return unidadOk && entrevistadorOk;
  }

  Future<bool> _existsInLocalCatalog(String tipo, int id) async {
    try {
      final cached = await (localDataSource.db.select(
        localDataSource.db.catalogosLocal,
      )..where((tbl) => tbl.tipo.equals(tipo))).getSingleOrNull();
      if (cached == null) {
        return true;
      }
      final list = jsonDecode(cached.jsonList) as List;
      return list.any((e) => e is Map && _asInt(e['id']) == id);
    } catch (_) {
      return true;
    }
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
