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

/// Registra la infraestructura compartida y delega el registro de cada
/// feature a su propia carpeta `di/` (lib/features/<feature>/di/).
///
/// Agregar una feature nueva NO requiere tocar el registro de las demás:
/// solo se crea `lib/features/nombre_feature/di/nombre_feature_injection.dart`
/// con una función `registerXDependencies(GetIt sl)` y se agrega una línea aquí.
Future<void> initInjection(SharedPreferences prefs) async {
  // ── Infraestructura compartida ────────────────────────────────────
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(client: sl(), baseUrl: ApiEndpoints.baseUrl),
  );

  // Clave de cifrado de la BD local: se resuelve ANTES de registrar
  // AppDatabase para que esté lista la primera vez que se lea/escriba una
  // cédula (ver core/storage/local_db_encryption.dart).
  LocalDbKeyHolder.cipher = LocalFieldCipher(
    await loadOrCreateLocalDbKey(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ),
    ),
  );
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ── Cada feature registra lo suyo ─────────────────────────────────
  // El orden no importa: todo se registra como lazy singleton/factory,
  // así que las dependencias cruzadas (ej. FamiliaRepository -> CedulaRepository)
  // se resuelven la primera vez que alguien las use, no al registrarlas.
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
