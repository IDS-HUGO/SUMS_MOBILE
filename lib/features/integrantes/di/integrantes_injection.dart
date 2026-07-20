import 'package:get_it/get_it.dart';

import '../data/datasources/remote/integrantes_remote_datasource.dart';
import '../data/repositories/integrantes_repository_impl.dart';
import '../domain/repositories/integrantes_repository.dart';
import '../presentation/viewmodels/integrantes_viewmodel.dart';

/// Registra las dependencias propias de la feature `integrantes`.
/// Depende de infraestructura compartida (ApiClient, TokenStorage) y de
/// `CedulaRepository` (feature `cedula_orquestador`), ya registrados antes de esta llamada.
void registerIntegrantesDependencies(GetIt sl) {
  sl.registerLazySingleton<IntegrantesRemoteDataSource>(
    () => IntegrantesRemoteDataSource(apiClient: sl()),
  );

  sl.registerLazySingleton<IntegrantesRepository>(
    () => IntegrantesRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );

  sl.registerFactory<IntegrantesViewModel>(
    () => IntegrantesViewModel(repository: sl()),
  );
}
