import 'package:get_it/get_it.dart';

import '../data/datasources/remote/vivienda_remote_datasource.dart';
import '../data/repositories/vivienda_repository_impl.dart';
import '../domain/repositories/vivienda_repository.dart';
import '../presentation/viewmodels/vivienda_viewmodel.dart';

/// Registra las dependencias propias de la feature `vivienda`.
/// Depende de infraestructura compartida (ApiClient, TokenStorage) y de
/// `CedulaRepository` (feature `cedula_orquestador`), ya registrados antes de esta llamada.
void registerViviendaDependencies(GetIt sl) {
  sl.registerLazySingleton<ViviendaRemoteDataSource>(
    () => ViviendaRemoteDataSource(apiClient: sl()),
  );

  sl.registerLazySingleton<ViviendaRepository>(
    () => ViviendaRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );

  sl.registerFactory<ViviendaViewModel>(
    () => ViviendaViewModel(repository: sl()),
  );
}
