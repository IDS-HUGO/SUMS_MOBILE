import 'package:get_it/get_it.dart';
import '../data/datasources/remote/integrantes_remote_datasource.dart';
import '../data/repositories/integrantes_repository_impl.dart';
import '../domain/repositories/integrantes_repository.dart';
import '../presentation/viewmodels/integrantes_viewmodel.dart';

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
