import 'package:get_it/get_it.dart';

import '../../../core/network/api_endpoints.dart';
import '../data/datasources/remote/mineria_remote_datasource.dart';
import '../data/repositories/mineria_repository_impl.dart';
import '../domain/repositories/mineria_repository.dart';
import '../domain/usecases/check_salud_usecase.dart';
import '../domain/usecases/procesar_pdf_usecase.dart';
import '../presentation/viewmodels/mineria_viewmodel.dart';

/// Registra las dependencias propias de la feature `mineria`.
/// No depende de ninguna otra feature.
void registerMineriaDependencies(GetIt sl) {
  sl.registerLazySingleton<MineriaRemoteDataSource>(
    () => MineriaRemoteDataSource(baseUrl: ApiEndpoints.mineriaBaseUrl),
  );

  sl.registerLazySingleton<MineriaRepository>(
    () => MineriaRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProcesarPdfUseCase>(() => ProcesarPdfUseCase(sl()));
  sl.registerLazySingleton<CheckSaludUseCase>(() => CheckSaludUseCase(sl()));

  sl.registerFactory<MineriaViewModel>(
    () => MineriaViewModel(procesarPdfUseCase: sl(), checkSaludUseCase: sl()),
  );
}
