import 'package:get_it/get_it.dart';
import '../data/datasources/remote/vivienda_remote_datasource.dart';
import '../data/repositories/vivienda_repository_impl.dart';
import '../domain/repositories/vivienda_repository.dart';
import '../presentation/viewmodels/vivienda_viewmodel.dart';

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
