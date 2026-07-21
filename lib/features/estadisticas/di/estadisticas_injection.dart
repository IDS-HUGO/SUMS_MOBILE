import 'package:get_it/get_it.dart';

import '../data/datasources/remote/estadisticas_remote_datasource.dart';
import '../data/repositories/estadisticas_repository_impl.dart';
import '../domain/repositories/estadisticas_repository.dart';
import '../presentation/viewmodels/estadisticas_viewmodel.dart';

/// Registra las dependencias propias de la feature `estadisticas`.
/// Depende de infraestructura compartida (ApiClient, TokenStorage), ya registrada
/// antes de esta llamada.
void registerEstadisticasDependencies(GetIt sl) {
  sl.registerLazySingleton<EstadisticasRemoteDataSource>(
    () => EstadisticasRemoteDataSource(apiClient: sl()),
  );

  sl.registerLazySingleton<EstadisticasRepository>(
    () =>
        EstadisticasRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );

  sl.registerFactory<EstadisticasViewModel>(
    () => EstadisticasViewModel(repository: sl()),
  );
}
