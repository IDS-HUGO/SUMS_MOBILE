import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/token_storage.dart';
import '../storage/local_database.dart';

import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../../features/cedula_orquestador/data/repositories/cedula_repository_impl.dart';
import '../../features/cedula_orquestador/domain/repositories/cedula_repository.dart';
import '../../features/cedula_orquestador/domain/usecases/load_catalogs_usecase.dart';
import '../../features/cedula_orquestador/domain/usecases/submit_record_usecase.dart';
import '../../features/cedula_orquestador/presentation/viewmodels/cedula_viewmodel.dart';

import '../../features/familia/data/datasources/remote/familia_remote_datasource.dart';
import '../../features/familia/data/repositories/familia_repository_impl.dart';
import '../../features/familia/domain/repositories/familia_repository.dart';
import '../../features/familia/presentation/viewmodels/familia_viewmodel.dart';

import '../../features/vivienda/data/datasources/remote/vivienda_remote_datasource.dart';
import '../../features/vivienda/data/repositories/vivienda_repository_impl.dart';
import '../../features/vivienda/domain/repositories/vivienda_repository.dart';
import '../../features/vivienda/presentation/viewmodels/vivienda_viewmodel.dart';

import '../../features/vacunacion/data/datasources/remote/vacunacion_remote_datasource.dart';
import '../../features/vacunacion/data/repositories/vacunacion_repository_impl.dart';
import '../../features/vacunacion/domain/repositories/vacunacion_repository.dart';
import '../../features/vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';

import '../../features/integrantes/data/datasources/remote/integrantes_remote_datasource.dart';
import '../../features/integrantes/data/repositories/integrantes_repository_impl.dart';
import '../../features/integrantes/domain/repositories/integrantes_repository.dart';
import '../../features/integrantes/presentation/viewmodels/integrantes_viewmodel.dart';

import '../../features/admin/data/datasources/remote/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/viewmodels/admin_users_viewmodel.dart';
import '../../features/admin/presentation/viewmodels/admin_unidades_viewmodel.dart';
import '../../features/admin/presentation/viewmodels/admin_catalogos_viewmodel.dart';

import '../../features/estadisticas/data/datasources/remote/estadisticas_remote_datasource.dart';
import '../../features/estadisticas/data/repositories/estadisticas_repository_impl.dart';
import '../../features/estadisticas/domain/repositories/estadisticas_repository.dart';
import '../../features/estadisticas/presentation/viewmodels/estadisticas_viewmodel.dart';

final sl = GetIt.instance;

Future<void> initInjection(SharedPreferences prefs) async {
  // ── Infraestructura ───────────────────────────────────────────────
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(client: sl(), baseUrl: ApiEndpoints.baseUrl),
  );
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ── Data Sources ──────────────────────────────────────────────────
  sl.registerLazySingleton<CedulaRemoteDataSource>(
    () => CedulaRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<CedulaLocalDataSource>(
    () => CedulaLocalDataSource(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<FamiliaRemoteDataSource>(
    () => FamiliaRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<ViviendaRemoteDataSource>(
    () => ViviendaRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<VacunacionRemoteDataSource>(
    () => VacunacionRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<IntegrantesRemoteDataSource>(
    () => IntegrantesRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<EstadisticasRemoteDataSource>(
    () => EstadisticasRemoteDataSource(apiClient: sl()),
  );

  // ── Repositories ──────────────────────────────────────────────────
  sl.registerLazySingleton<CedulaRepository>(
    () => CedulaRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      tokenStorage: sl(),
    ),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
    ),
  );
  sl.registerLazySingleton<FamiliaRepository>(
    () => FamiliaRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );
  sl.registerLazySingleton<ViviendaRepository>(
    () => ViviendaRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );
  sl.registerLazySingleton<VacunacionRepository>(
    () => VacunacionRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );
  sl.registerLazySingleton<IntegrantesRepository>(
    () => IntegrantesRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
    ),
  );
  sl.registerLazySingleton<EstadisticasRepository>(
    () => EstadisticasRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
    ),
  );

  // ── Use Cases ─────────────────────────────────────────────────────
  sl.registerLazySingleton<LoadCatalogsUseCase>(
    () => LoadCatalogsUseCase(sl()),
  );
  sl.registerLazySingleton<SubmitRecordUseCase>(
    () => SubmitRecordUseCase(sl()),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl()),
  );

  // ── ViewModels (Factory) ──────────────────────────────────────────
  // Usamos factory para ViewModels si se necesitan instancias nuevas o lazy singleton si se quiere mantener el estado global
  // Como la app actualmente los mantiene en Provider a nivel de App, un LazySingleton sirve para emular el comportamiento actual
  sl.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      loadCatalogsUseCase: sl(),
    ),
  );
  sl.registerFactory<CedulaViewModel>(
    () => CedulaViewModel(
      loadCatalogsUseCase: sl(),
      submitRecordUseCase: sl(),
      cedulaRepository: sl(),
    ),
  );
  sl.registerFactory<FamiliaViewModel>(
    () => FamiliaViewModel(repository: sl()),
  );
  sl.registerFactory<ViviendaViewModel>(
    () => ViviendaViewModel(repository: sl()),
  );
  sl.registerFactory<VacunacionViewModel>(
    () => VacunacionViewModel(repository: sl()),
  );
  sl.registerFactory<IntegrantesViewModel>(
    () => IntegrantesViewModel(repository: sl()),
  );
  sl.registerFactory<AdminUsersViewModel>(
    () => AdminUsersViewModel(repository: sl()),
  );
  sl.registerFactory<AdminUnidadesViewModel>(
    () => AdminUnidadesViewModel(repository: sl()),
  );
  sl.registerFactory<AdminCatalogosViewModel>(
    () => AdminCatalogosViewModel(
      repository: sl(),
      loadCatalogsUseCase: sl(),
    ),
  );
  sl.registerFactory<EstadisticasViewModel>(
    () => EstadisticasViewModel(repository: sl()),
  );
}

Future<void> disposeInjection() async {
  if (sl.isRegistered<http.Client>()) {
    sl<http.Client>().close();
  }
  await sl.reset();
}
