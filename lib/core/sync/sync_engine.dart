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

  /// Ejecuta el proceso de sincronización masiva
  Future<void> syncPendingCedulas() async {
    // 1. Verificar conectividad
    final result = await connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      AppLogger.info(
        'SyncEngine: Sin conexión a internet. Abortando sincronización.',
      );
      return;
    }

    // 2. Obtener registros pendientes (sync_status = 1)
    final pendingRecords = await localDataSource.getCedulasByStatus(1);

    if (pendingRecords.isEmpty) {
      AppLogger.info('SyncEngine: No hay registros pendientes por sincronizar.');
      // Purgar antiguos por si acaso
      await localDataSource.deleteOldSynced(7);
      return;
    }

    // 2.1 Revalidar unidad_salud_id / entrevistador_id contra el catálogo/
    // caché local ANTES de reenviar. Un registro guardado offline hace
    // tiempo pudo quedar con un ID que ya no es válido (ej. la unidad de
    // salud fue borrada) — reenviarlo a ciegas solo produciría un error del
    // backend en el mejor caso, o una asociación incorrecta en el peor.
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

    AppLogger.info('SyncEngine: Sincronizando ${validRecords.length} registros...');

    try {
      // Remover _localId temporalmente para el request, pero guardarlo para actualizar el estado
      final payloadsForApi = validRecords.map((r) {
        final payload = Map<String, dynamic>.from(r);
        payload.remove('_localId');
        return payload;
      }).toList();

      // 2.2 Leer el token de autenticación guardado en el login. Sin esto el
      // request viajaba sin Authorization y el backend lo rechazaba (o, peor,
      // lo aceptaba si el endpoint no validaba el token).
      final token = await tokenStorage.readToken();
      if (token == null || token.isEmpty) {
        AppLogger.warn(
          'SyncEngine: no hay token de autenticación guardado; se aborta la '
          'sincronización para no enviar la petición sin credenciales.',
        );
        return;
      }

      // 3. Enviar lote al backend
      // El backend debe tener un endpoint que acepte un array de cédulas
      // En la API recién creada, el endpoint es POST /sums/sync
      // Como CedulaRemoteDataSource tiene un mētodo post genérico:
      await remoteDataSource.post(
        '/sums/sync',
        {'payloads': payloadsForApi},
        token: token,
      );

      // Si llegamos aquí, asumimos éxito HTTP 200/201.
      AppLogger.info('SyncEngine: Sincronización exitosa.');

      // 4. Actualizar estado local a SYNCED (2)
      for (final r in validRecords) {
        final localId = r['_localId'] as int;
        await localDataSource.updateSyncStatus(localId, 2);
      }

      // 5. Purgar registros antiguos ya sincronizados (> 7 días)
      await localDataSource.deleteOldSynced(7);
    } catch (e) {
      AppLogger.error('SyncEngine: Error durante la sincronización', e);
    }
  }

  /// Valida que `unidad_salud_id` y `entrevistador_id` sean enteros
  /// positivos y, si hay un catálogo cacheado localmente para ese tipo
  /// (tabla `CatalogosLocal`), que el ID exista dentro de él. Si no hay
  /// caché disponible para ese catálogo (no se descarga hoy en día), no se
  /// bloquea el reenvío solo por falta de caché — ya pasó la validación de
  /// formato/sanidad.
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
      final cached =
          await (localDataSource.db.select(localDataSource.db.catalogosLocal)
                ..where((tbl) => tbl.tipo.equals(tipo)))
              .getSingleOrNull();
      if (cached == null) {
        // No tenemos catálogo cacheado de este tipo: no bloqueamos solo por
        // eso, dado que ya se validó formato/sanidad del ID.
        return true;
      }
      final list = jsonDecode(cached.jsonList) as List;
      return list.any((e) => e is Map && _asInt(e['id']) == id);
    } catch (_) {
      // Si el catálogo cacheado está corrupto, no bloqueamos el reenvío por
      // eso (evita falsos negativos por un problema de caché ajeno al ID).
      return true;
    }
  }

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
