import 'package:workmanager/workmanager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'sync_engine.dart';
import '../storage/local_database.dart';
import '../storage/token_storage.dart';
import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

const syncTaskName = "syncPendingCedulasTask";

/// Claves de SharedPreferences usadas para avisar a la UI (ver
/// [CedulaViewModel]) que la sincronización en segundo plano lleva varios
/// intentos fallidos consecutivos, en vez de solo dejar constancia en el
/// log (print) donde el usuario nunca lo ve.
const syncConsecutiveFailuresKey = 'sync_consecutive_failures';
const syncNeedsUserAttentionKey = 'sync_needs_user_attention';
const syncLastErrorKey = 'sync_last_error';

/// Número de fallos consecutivos a partir del cual se considera que la
/// sincronización está fallando "repetidamente" y se debe avisar al usuario.
const syncFailureThreshold = 3;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    AppLogger.info('Workmanager: Ejecutando tarea $task');
    if (task == syncTaskName) {
      final prefs = await SharedPreferences.getInstance();
      try {
        // Misma URL base que usa el resto de la app (siempre https en
        // release; ver ApiEndpoints y ApiClient._uri/enforceSecureScheme).
        final apiUrl = ApiEndpoints.baseUrl;

        final db = AppDatabase();
        final localDataSource = CedulaLocalDataSource(db);
        final httpClient = http.Client();
        final apiClient = ApiClient(client: httpClient, baseUrl: apiUrl);
        final remoteDataSource = CedulaRemoteDataSource(apiClient: apiClient);
        // Esta tarea corre en un isolate en segundo plano (Workmanager), fuera
        // del árbol de GetIt de la app en primer plano, por lo que se
        // construye su propia instancia de TokenStorage apuntando al mismo
        // almacenamiento seguro (misma configuración que core/di/injection.dart)
        // para poder leer el token guardado por el login y adjuntarlo al sync.
        final tokenStorage = SecureTokenStorage();

        final syncEngine = SyncEngine(
          localDataSource: localDataSource,
          remoteDataSource: remoteDataSource,
          connectivity: Connectivity(),
          tokenStorage: tokenStorage,
        );

        await syncEngine.syncPendingCedulas();
        // Éxito: reiniciar el contador de fallos y limpiar cualquier aviso
        // pendiente para el usuario.
        await prefs.setInt(syncConsecutiveFailuresKey, 0);
        await prefs.setBool(syncNeedsUserAttentionKey, false);
        return Future.value(true);
      } catch (e) {
        AppLogger.error('Workmanager: error en sincronización', e);
        final failures = (prefs.getInt(syncConsecutiveFailuresKey) ?? 0) + 1;
        await prefs.setInt(syncConsecutiveFailuresKey, failures);
        await prefs.setString(syncLastErrorKey, e.toString());
        if (failures >= syncFailureThreshold) {
          // Marcar que se necesita avisar visiblemente al usuario (ver
          // CedulaViewModel.syncFailureWarning), en vez de que el fallo
          // quede solo en el log.
          await prefs.setBool(syncNeedsUserAttentionKey, true);
        }
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
  Connectivity().onConnectivityChanged.listen((
    List<ConnectivityResult> result,
  ) async {
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
