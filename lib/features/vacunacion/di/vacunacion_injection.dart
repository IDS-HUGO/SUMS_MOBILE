import 'package:get_it/get_it.dart';
import '../data/datasources/remote/vacunacion_remote_datasource.dart';
import '../data/repositories/vacunacion_repository_impl.dart';
import '../domain/repositories/vacunacion_repository.dart';
import '../presentation/viewmodels/vacunacion_viewmodel.dart';

void registerVacunacionDependencies(GetIt sl) {
  sl.registerLazySingleton<VacunacionRemoteDataSource>(
    () => VacunacionRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<VacunacionRepository>(
    () => VacunacionRepositoryImpl(
      remoteDataSource: sl(),
      tokenStorage: sl(),
      cedulaRepository: sl(),
    ),
  );
  sl.registerFactory<VacunacionViewModel>(
    () => VacunacionViewModel(repository: sl()),
  );
}
