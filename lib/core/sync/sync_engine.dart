import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../storage/local_database.dart';

class SyncEngine {
  final CedulaLocalDataSource localDataSource;
  final CedulaRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  SyncEngine({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  /// Ejecuta el proceso de sincronización masiva
  Future<void> syncPendingCedulas() async {
    // 1. Verificar conectividad
    final result = await connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)) {
      print('SyncEngine: Sin conexión a internet. Abortando sincronización.');
      return;
    }

    // 2. Obtener registros pendientes (sync_status = 1)
    final pendingRecords = await localDataSource.getCedulasByStatus(1);
    
    if (pendingRecords.isEmpty) {
      print('SyncEngine: No hay registros pendientes por sincronizar.');
      // Purgar antiguos por si acaso
      await localDataSource.deleteOldSynced(7);
      return;
    }

    print('SyncEngine: Sincronizando ${pendingRecords.length} registros...');

    try {
      // Remover _localId temporalmente para el request, pero guardarlo para actualizar el estado
      final payloadsForApi = pendingRecords.map((r) {
        final payload = Map<String, dynamic>.from(r);
        payload.remove('_localId');
        return payload;
      }).toList();

      // 3. Enviar lote al backend
      // El backend debe tener un endpoint que acepte un array de cédulas
      // En la API recién creada, el endpoint es POST /sums/sync
      // Como CedulaRemoteDataSource tiene un mētodo post genérico:
      final response = await remoteDataSource.post('/sums/sync', {'payloads': payloadsForApi});
      
      // Si llegamos aquí, asumimos éxito HTTP 200/201.
      print('SyncEngine: Sincronización exitosa.');

      // 4. Actualizar estado local a SYNCED (2)
      for (final r in pendingRecords) {
        final localId = r['_localId'] as int;
        await localDataSource.updateSyncStatus(localId, 2);
      }

      // 5. Purgar registros antiguos ya sincronizados (> 7 días)
      await localDataSource.deleteOldSynced(7);

    } catch (e) {
      print('SyncEngine: Error durante la sincronización: $e');
    }
  }
}
