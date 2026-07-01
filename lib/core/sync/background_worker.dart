import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'sync_engine.dart';
import '../storage/local_database.dart';
import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';

const syncTaskName = "syncPendingCedulasTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Workmanager: Ejecutando tarea $task");
    if (task == syncTaskName) {
      try {
        final db = AppDatabase();
        final localDataSource = CedulaLocalDataSource(db);
        final httpClient = http.Client();
        final apiClient = ApiClient(client: httpClient, baseUrl: ApiEndpoints.baseUrl);
        final remoteDataSource = CedulaRemoteDataSource(apiClient: apiClient);
        
        final syncEngine = SyncEngine(
          localDataSource: localDataSource,
          remoteDataSource: remoteDataSource,
          connectivity: Connectivity(),
        );

        await syncEngine.syncPendingCedulas();
        return Future.value(true);
      } catch (e) {
        print("Workmanager error: $e");
        return Future.value(false); // Retrying logic handled by OS if false
      }
    }
    return Future.value(true);
  });
}

void initializeBackgroundSync() {
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Cambiar a false en prod
  );

  Workmanager().registerPeriodicTask(
    "1",
    syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
      networkType: NetworkType.connected, // Solo ejecutar cuando hay red
    ),
  );

  // Escuchar activamente cuando la app esta abierta
  Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) async {
    if (!result.contains(ConnectivityResult.none)) {
      // Intentar sincronizar cuando vuelve el internet estando la app abierta
      // NOTA: Para producción, ideal no inicializar la base de datos tantas veces,
      // pero para este alcance, lanzaremos un workmanager request inmediato.
      Workmanager().registerOneOffTask(
        "sync_now", 
        syncTaskName,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  });
}
