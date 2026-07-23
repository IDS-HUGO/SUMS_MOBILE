import 'package:get_it/get_it.dart';
import '../data/datasources/remote/admin_remote_datasource.dart';
import '../data/repositories/admin_repository_impl.dart';
import '../domain/repositories/admin_repository.dart';
import '../presentation/viewmodels/admin_catalogos_viewmodel.dart';
import '../presentation/viewmodels/admin_unidades_viewmodel.dart';
import '../presentation/viewmodels/admin_users_viewmodel.dart';

void registerAdminDependencies(GetIt sl) {
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl(), tokenStorage: sl()),
  );
  sl.registerFactory<AdminUsersViewModel>(
    () => AdminUsersViewModel(repository: sl()),
  );
  sl.registerFactory<AdminUnidadesViewModel>(
    () => AdminUnidadesViewModel(repository: sl()),
  );
  sl.registerFactory<AdminCatalogosViewModel>(
    () => AdminCatalogosViewModel(repository: sl(), loadCatalogsUseCase: sl()),
  );
}
