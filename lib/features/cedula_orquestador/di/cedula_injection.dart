import 'package:get_it/get_it.dart';

import '../data/datasources/local/cedula_local_datasource.dart';
import '../data/datasources/remote/cedula_remote_datasource.dart';
import '../data/repositories/cedula_repository_impl.dart';
import '../domain/repositories/cedula_repository.dart';
import '../domain/usecases/load_catalogs_usecase.dart';
import '../domain/usecases/submit_record_usecase.dart';
import '../presentation/viewmodels/cedula_viewmodel.dart';

/// Registra las dependencias propias de la feature `cedula_orquestador`.
/// Depende de infraestructura compartida ya registrada por `core/di/injection.dart`
/// (ApiClient, TokenStorage, AppDatabase). `LoadCatalogsUseCase` se expone aquí
/// porque otras features (auth, admin) también lo consumen.
void registerCedulaDependencies(GetIt sl) {
  sl.registerLazySingleton<CedulaRemoteDataSource>(
    () => CedulaRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<CedulaLocalDataSource>(
    () => CedulaLocalDataSource(sl()),
  );

  sl.registerLazySingleton<CedulaRepository>(
    () => CedulaRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      tokenStorage: sl(),
    ),
  );

  sl.registerLazySingleton<LoadCatalogsUseCase>(
    () => LoadCatalogsUseCase(sl()),
  );
  sl.registerLazySingleton<SubmitRecordUseCase>(
    () => SubmitRecordUseCase(sl()),
  );

  sl.registerFactory<CedulaViewModel>(
    () => CedulaViewModel(
      loadCatalogsUseCase: sl(),
      submitRecordUseCase: sl(),
      cedulaRepository: sl(),
      prefs: sl(),
    ),
  );
}
