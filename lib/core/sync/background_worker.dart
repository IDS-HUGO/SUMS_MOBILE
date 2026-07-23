import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'sync_engine.dart';
import '../storage/local_database.dart';
import '../storage/token_storage.dart';
import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../../features/cedula_orquestador/data/repositories/cedula_repository_impl.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const syncTaskName = "syncPendingCedulasTask";
const syncConsecutiveFailuresKey = 'sync_consecutive_failures';
const syncNeedsUserAttentionKey = 'sync_needs_user_attention';
const syncLastErrorKey = 'sync_last_error';
const syncFailureThreshold = 3;
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppLogger.info('Workmanager: Ejecutando tarea $task');
    if (task == syncTaskName) {
      final prefs = await SharedPreferences.getInstance();
      try {
        final apiUrl = ApiEndpoints.baseUrl;
        final db = AppDatabase();
        final localDataSource = CedulaLocalDataSource(db);
        final httpClient = http.Client();
        final apiClient = ApiClient(client: httpClient, baseUrl: apiUrl);
        final remoteDataSource = CedulaRemoteDataSource(apiClient: apiClient);
        final tokenStorage = SecureTokenStorage();
        // Instanciar el repositorio para que el SyncEngine pueda refrescar
        // los catálogos de sistema antes de validar registros (Bug 2/3).
        final cedulaRepository = CedulaRepositoryImpl(
          remoteDataSource: remoteDataSource,
          localDataSource: localDataSource,
          tokenStorage: tokenStorage,
        );
        final syncEngine = SyncEngine(
          localDataSource: localDataSource,
          remoteDataSource: remoteDataSource,
          connectivity: Connectivity(),
          tokenStorage: tokenStorage,
          cedulaRepository: cedulaRepository,
        );
        await syncEngine.syncPendingCedulas();
        await prefs.setInt(syncConsecutiveFailuresKey, 0);
        await prefs.setBool(syncNeedsUserAttentionKey, false);
        return Future.value(true);
      } catch (e) {
        AppLogger.error('Workmanager: error en sincronización', e);
        final failures = (prefs.getInt(syncConsecutiveFailuresKey) ?? 0) + 1;
        await prefs.setInt(syncConsecutiveFailuresKey, failures);
        await prefs.setString(syncLastErrorKey, e.toString());
        if (failures >= syncFailureThreshold) {
          await prefs.setBool(syncNeedsUserAttentionKey, true);
        }
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

void initializeBackgroundSync() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    syncTaskName,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
  );
  Connectivity().onConnectivityChanged.listen((
    List<ConnectivityResult> result,
  ) async {
    if (!result.contains(ConnectivityResult.none)) {
      Workmanager().registerOneOffTask(
        "sync_now",
        syncTaskName,
        constraints: Constraints(networkType: NetworkType.connected),
      );
    }
  });
}
