import 'package:get_it/get_it.dart';

import '../data/datasources/remote/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import '../presentation/viewmodels/auth_viewmodel.dart';

/// Registra las dependencias propias de la feature `auth`.
/// Depende de infraestructura compartida ya registrada por `core/di/injection.dart`
/// (ApiClient, TokenStorage) y de LoadCatalogsUseCase (feature `cedula_orquestador`).
void registerAuthDependencies(GetIt sl) {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(apiClient: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );

  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));

  sl.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      loadCatalogsUseCase: sl(),
    ),
  );
}
