import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../../features/cedula_orquestador/domain/repositories/cedula_repository.dart';
import '../network/app_logger.dart';
import '../storage/token_storage.dart';

class SyncEngine {
  final CedulaLocalDataSource localDataSource;
  final CedulaRemoteDataSource remoteDataSource;
  final Connectivity connectivity;
  final TokenStorage tokenStorage;

  /// Repositorio de cédulas usado para refrescar los catálogos de sistema
  /// (`entrevistador`, `unidad-salud`) antes de cada ciclo de sincronización.
  /// Puede ser null en entornos de prueba donde no se desea la llamada al servidor.
  final CedulaRepository? cedulaRepository;

  SyncEngine({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
    required this.tokenStorage,
    this.cedulaRepository,
  });

  Future<void> syncPendingCedulas() async {
    final result = await connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      AppLogger.info(
        'SyncEngine: Sin conexión a internet. Abortando sincronización.',
      );
      return;
    }

    // -- BUG 2/3 FIX: Refrescar catálogos de sistema antes de validar --
    // Garantiza que `entrevistador` y `unidad-salud` estén actualizados en
    // SQLite, evitando que usuarios recién creados sean rechazados por el
    // filtro _hasValidCatalogReferences().
    if (cedulaRepository != null) {
      AppLogger.info(
        'SyncEngine: Refrescando catálogos de sistema (entrevistador, '
        'unidad-salud) previo a sincronización...',
      );
      await cedulaRepository!.refreshUserCatalogs();
    }

    // -- BUG 4 FIX: leer userId para filtrar cédulas por propietario --
    // El token ya fue verificado más abajo; aquí solo necesitamos el ID
    // del usuario activo para que la consulta local devuelva únicamente
    // sus registros (aislamiento de sesión offline).
    final session = await tokenStorage.readSession();
    final userId = session?.user.id ?? 0;

    final pendingRecords = await localDataSource.getCedulasByStatus(
      1,
      userId: userId,
    );
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
      if (await _hasValidCatalogReferences(record, authenticatedUserId: userId)) {
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

  /// Valida que [record] tenga referencias de catálogo consistentes antes de
  /// intentar sincronizarlo con el servidor.
  ///
  /// **Regla de rescate (TAREA 2):** si el `entrevistador_id` del registro
  /// coincide con el ID del usuario autenticado ([authenticatedUserId]), la
  /// validación del catálogo de entrevistadores se aprueba automáticamente.
  /// Un brigadista con JWT válido jamás debe ser bloqueado por SQLite al subir
  /// sus propios registros, incluso si el catálogo local aún no se actualizó.
  Future<bool> _hasValidCatalogReferences(
    Map<String, dynamic> record, {
    required int authenticatedUserId,
  }) async {
    final unidadId = _asInt(record['unidad_salud_id']);
    final entrevistadorId = _asInt(record['entrevistador_id']);
    if (unidadId == null || unidadId <= 0) return false;
    // Si entrevistadorId <= 0 pero coincide con authenticatedUserId, lo dejamos pasar.
    if (entrevistadorId == null) return false;
    if (entrevistadorId <= 0 && entrevistadorId != authenticatedUserId) return false;
    final unidadOk = await _existsInLocalCatalog('unidad-salud', unidadId);

    // --- REGLA DE RESCATE ---
    // Si el entrevistador_id del registro coincide con el ID del usuario
    // autenticado, se considera válido sin consultar SQLite. Esto previene
    // el bloqueo de usuarios recién creados cuyo ID aún no está en el
    // catálogo local, siempre que tengan un token JWT activo.
    final bool entrevistadorOk;
    if (entrevistadorId == authenticatedUserId) {
      AppLogger.info(
        'SyncEngine: entrevistador_id=$entrevistadorId coincide con el usuario '
        'autenticado; validación de catálogo omitida (regla de rescate).',
      );
      entrevistadorOk = true;
    } else {
      entrevistadorOk = await _existsInLocalCatalog(
        'entrevistador',
        entrevistadorId,
      );
    }

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
