import 'package:get_it/get_it.dart';

import '../../../core/network/api_endpoints.dart';
import '../data/datasources/remote/busqueda_remote_datasource.dart';
import '../data/repositories/busqueda_repository_impl.dart';
import '../domain/repositories/busqueda_repository.dart';
import '../domain/usecases/buscar_estructurado_usecase.dart';
import '../domain/usecases/buscar_notas_usecase.dart';
import '../presentation/viewmodels/busqueda_viewmodel.dart';

/// Registra las dependencias propias de la feature `busqueda`.
/// Reutiliza el mismo host y API Key que `mineria` (mismo microservicio
/// Python), pero no depende de esa feature: cada una arma su propio
/// datasource.
void registerBusquedaDependencies(GetIt sl) {
  sl.registerLazySingleton<BusquedaRemoteDataSource>(
    () => BusquedaRemoteDataSource(baseUrl: ApiEndpoints.mineriaBaseUrl),
  );

  sl.registerLazySingleton<BusquedaRepository>(
    () => BusquedaRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<BuscarNotasUseCase>(() => BuscarNotasUseCase(sl()));
  sl.registerLazySingleton<BuscarEstructuradoUseCase>(
    () => BuscarEstructuradoUseCase(sl()),
  );

  sl.registerFactory<BusquedaViewModel>(
    () => BusquedaViewModel(
      buscarNotasUseCase: sl(),
      buscarEstructuradoUseCase: sl(),
    ),
  );
}
