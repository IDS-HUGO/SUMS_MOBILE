import 'package:http/http.dart' as http;

import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/cedula/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula/data/datasources/remote/cedula_remote_datasource.dart';
import '../../features/cedula/data/repositories/cedula_repository_impl.dart';
import '../../features/cedula/domain/repositories/cedula_repository.dart';
import '../../features/cedula/domain/usecases/load_catalogs_usecase.dart';
import '../../features/cedula/domain/usecases/submit_record_usecase.dart';
import '../../features/cedula/domain/usecases/local_storage_usecases.dart';
import '../../features/cedula/presentation/viewmodels/cedula_viewmodel.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../storage/database_helper.dart';
import '../storage/token_storage.dart';

class AppDependencies {
  AppDependencies() {
    // ── infraestructura compartida ────────────────────────────────────────
    httpClient   = http.Client();
    tokenStorage = InMemoryTokenStorage();
    apiClient    = ApiClient(client: httpClient, baseUrl: ApiEndpoints.baseUrl);
    dbHelper     = DatabaseHelper.instance;

    // ── feature: auth ─────────────────────────────────────────────────────
    authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      tokenStorage:     tokenStorage,
    );
    authViewModel = AuthViewModel(
      loginUseCase:    LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase:   LogoutUseCase(authRepository),
    );

    // ── feature: cedula ───────────────────────────────────────────────────
    cedulaRemoteDataSource = CedulaRemoteDataSource(apiClient: apiClient);
    cedulaLocalDataSource  = CedulaLocalDataSource(dbHelper: dbHelper);
    cedulaRepository = CedulaRepositoryImpl(
      remoteDataSource: cedulaRemoteDataSource,
      localDataSource:  cedulaLocalDataSource,
      tokenStorage:     tokenStorage,
    );
    cedulaViewModel = CedulaViewModel(
      loadCatalogsUseCase:      LoadCatalogsUseCase(cedulaRepository),
      submitRecordUseCase:      SubmitRecordUseCase(cedulaRepository),
      getPendingRecordsUseCase: GetPendingRecordsUseCase(cedulaRepository),
      saveLocalRecordUseCase:   SaveLocalRecordUseCase(cedulaRepository),
      deleteLocalRecordUseCase: DeleteLocalRecordUseCase(cedulaRepository),
    );
  }

  // ── infraestructura ───────────────────────────────────────────────────────
  late final http.Client          httpClient;
  late final TokenStorage         tokenStorage;
  late final ApiClient            apiClient;
  late final DatabaseHelper       dbHelper;

  // ── auth ──────────────────────────────────────────────────────────────────
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository       authRepository;
  late final AuthViewModel        authViewModel;

  // ── cedula ────────────────────────────────────────────────────────────────
  late final CedulaRemoteDataSource cedulaRemoteDataSource;
  late final CedulaLocalDataSource  cedulaLocalDataSource;
  late final CedulaRepository       cedulaRepository;
  late final CedulaViewModel        cedulaViewModel;

  /// Libera ViewModels y cierra el cliente HTTP.
  void dispose() {
    authViewModel.dispose();
    cedulaViewModel.dispose();
    httpClient.close();
    dbHelper.close();
  }
}
