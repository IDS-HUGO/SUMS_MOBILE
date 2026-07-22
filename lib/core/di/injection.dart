import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../storage/local_database.dart';
import '../storage/local_db_encryption.dart';
import '../../features/auth/di/auth_injection.dart';
import '../../features/cedula_orquestador/di/cedula_injection.dart';
import '../../features/familia/di/familia_injection.dart';
import '../../features/vivienda/di/vivienda_injection.dart';
import '../../features/vacunacion/di/vacunacion_injection.dart';
import '../../features/integrantes/di/integrantes_injection.dart';
import '../../features/admin/di/admin_injection.dart';
import '../../features/estadisticas/di/estadisticas_injection.dart';
import '../../features/mineria/di/mineria_injection.dart';
import '../../features/busqueda/di/busqueda_injection.dart';

final sl = GetIt.instance;
Future<void> initInjection(SharedPreferences prefs) async {
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(client: sl(), baseUrl: ApiEndpoints.baseUrl),
  );
  LocalDbKeyHolder.cipher = LocalFieldCipher(
    await loadOrCreateLocalDbKey(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    ),
  );
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  registerCedulaDependencies(sl);
  registerAuthDependencies(sl);
  registerFamiliaDependencies(sl);
  registerViviendaDependencies(sl);
  registerVacunacionDependencies(sl);
  registerIntegrantesDependencies(sl);
  registerAdminDependencies(sl);
  registerEstadisticasDependencies(sl);
  registerMineriaDependencies(sl);
  registerBusquedaDependencies(sl);
}

Future<void> disposeInjection() async {
  if (sl.isRegistered<http.Client>()) {
    sl<http.Client>().close();
  }
  await sl.reset();
}
