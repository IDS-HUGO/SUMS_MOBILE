import 'package:get_it/get_it.dart';
import '../data/datasources/remote/familia_remote_datasource.dart';
import '../data/repositories/familia_repository_impl.dart';
import '../domain/repositories/familia_repository.dart';
import '../presentation/viewmodels/familia_viewmodel.dart';

void registerFamiliaDependencies(GetIt sl) {
  sl.registerLazySingleton<FamiliaRemoteDataSource>(
    () => FamiliaRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<FamiliaRepository>(
    () => FamiliaRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );
  sl.registerFactory<FamiliaViewModel>(
    () => FamiliaViewModel(repository: sl()),
  );
}
