import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/pinned_http_client.dart';
import '../storage/token_storage.dart';
import '../storage/local_database.dart';

import '../../features/auth/data/datasources/remote/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/viewmodels/auth_viewmodel.dart';

import '../../features/cedula_orquestador/data/datasources/local/cedula_local_datasource.dart';
import '../../features/cedula_orquestador/data/datasources/remote/cedula_remote_datasource.dart';
import '../../features/cedula_orquestador/data/repositories/cedula_repository_impl.dart';
import '../../features/cedula_orquestador/domain/repositories/cedula_repository.dart';
import '../../features/cedula_orquestador/domain/usecases/load_catalogs_usecase.dart';
import '../../features/cedula_orquestador/domain/usecases/submit_record_usecase.dart';
import '../../features/cedula_orquestador/presentation/viewmodels/cedula_viewmodel.dart';

import '../../features/familia/data/datasources/remote/familia_remote_datasource.dart';
import '../../features/familia/data/repositories/familia_repository_impl.dart';
import '../../features/familia/domain/repositories/familia_repository.dart';
import '../../features/familia/presentation/viewmodels/familia_viewmodel.dart';

import '../../features/vivienda/data/datasources/remote/vivienda_remote_datasource.dart';
import '../../features/vivienda/data/repositories/vivienda_repository_impl.dart';
import '../../features/vivienda/domain/repositories/vivienda_repository.dart';
import '../../features/vivienda/presentation/viewmodels/vivienda_viewmodel.dart';

import '../../features/vacunacion/data/datasources/remote/vacunacion_remote_datasource.dart';
import '../../features/vacunacion/data/repositories/vacunacion_repository_impl.dart';
import '../../features/vacunacion/domain/repositories/vacunacion_repository.dart';
import '../../features/vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';

import '../../features/integrantes/data/datasources/remote/integrantes_remote_datasource.dart';
import '../../features/integrantes/data/repositories/integrantes_repository_impl.dart';
import '../../features/integrantes/domain/repositories/integrantes_repository.dart';
import '../../features/integrantes/presentation/viewmodels/integrantes_viewmodel.dart';

import '../../features/admin/data/datasources/remote/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/presentation/viewmodels/admin_users_viewmodel.dart';
import '../../features/admin/presentation/viewmodels/admin_unidades_viewmodel.dart';
import '../../features/admin/presentation/viewmodels/admin_catalogos_viewmodel.dart';

import '../../features/estadisticas/data/datasources/remote/estadisticas_remote_datasource.dart';
import '../../features/estadisticas/data/repositories/estadisticas_repository_impl.dart';
import '../../features/estadisticas/domain/repositories/estadisticas_repository.dart';
import '../../features/estadisticas/presentation/viewmodels/estadisticas_viewmodel.dart';

/// Contenedor de dependencias manual para toda la app.
/// Se crea una única vez en [_AppState.initState] y se destruye en [dispose].
class AppDependencies {
  AppDependencies(SharedPreferences prefs, {Uint8List? pinnedCertBytes}) {
    // ── infraestructura compartida ────────────────────────────────────────
    // Certificate pinning: si no se cargaron los bytes del certificado
    // anclado (ej. en tests), cae a un http.Client normal en vez de fallar.
    httpClient   = pinnedCertBytes != null
        ? createPinnedHttpClient(pinnedCertBytes)
        : http.Client();
    tokenStorage = SecureTokenStorage();
    apiClient    = ApiClient(client: httpClient, baseUrl: ApiEndpoints.baseUrl);

    // ── feature: cedula_orquestador ───────────────────────────────────────────
    cedulaRemoteDataSource = CedulaRemoteDataSource(apiClient: apiClient);
    // Cambiado para usar AppDatabase directamente en lugar de dbHelper que usa sqflite
    final appDb = AppDatabase();
    cedulaLocalDataSource  = CedulaLocalDataSource(appDb);

    cedulaRepository = CedulaRepositoryImpl(
      remoteDataSource: cedulaRemoteDataSource,
      localDataSource:  cedulaLocalDataSource,
      tokenStorage:     tokenStorage,
    );

    cedulaViewModel = CedulaViewModel(
      loadCatalogsUseCase:      LoadCatalogsUseCase(cedulaRepository),
      submitRecordUseCase:      SubmitRecordUseCase(cedulaRepository),
      cedulaRepository:         cedulaRepository,
    );

    // ── feature: auth ──────────────────────────────────────────────────────────
    authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      tokenStorage:     tokenStorage,
    );

    authViewModel = AuthViewModel(
      loginUseCase:        LoginUseCase(authRepository),
      registerUseCase:     RegisterUseCase(authRepository),
      logoutUseCase:       LogoutUseCase(authRepository),
      loadCatalogsUseCase: LoadCatalogsUseCase(cedulaRepository),
    );

    // ── features de dominios ──────────────────────────────────────────────────
    familiaRemoteDataSource = FamiliaRemoteDataSource(apiClient: apiClient);
    familiaRepository = FamiliaRepositoryImpl(
      remoteDataSource: familiaRemoteDataSource,
      tokenStorage:     tokenStorage,
      cedulaRepository: cedulaRepository,
    );
    familiaViewModel = FamiliaViewModel(repository: familiaRepository);

    viviendaRemoteDataSource = ViviendaRemoteDataSource(apiClient: apiClient);
    viviendaRepository = ViviendaRepositoryImpl(
      remoteDataSource: viviendaRemoteDataSource,
      tokenStorage:     tokenStorage,
      cedulaRepository: cedulaRepository,
    );
    viviendaViewModel = ViviendaViewModel(repository: viviendaRepository);

    vacunacionRemoteDataSource = VacunacionRemoteDataSource(apiClient: apiClient);
    vacunacionRepository = VacunacionRepositoryImpl(
      remoteDataSource: vacunacionRemoteDataSource,
      tokenStorage:     tokenStorage,
      cedulaRepository: cedulaRepository,
    );
    vacunacionViewModel = VacunacionViewModel(repository: vacunacionRepository);

    integrantesRemoteDataSource = IntegrantesRemoteDataSource(apiClient: apiClient);
    integrantesRepository = IntegrantesRepositoryImpl(
      remoteDataSource: integrantesRemoteDataSource,
      tokenStorage:     tokenStorage,
      cedulaRepository: cedulaRepository,
    );
    integrantesViewModel = IntegrantesViewModel(repository: integrantesRepository);

    // ── feature: admin ────────────────────────────────────────────────────────
    adminRemoteDataSource = AdminRemoteDataSource(apiClient: apiClient);
    adminRepository = AdminRepositoryImpl(
      remoteDataSource: adminRemoteDataSource,
      tokenStorage:     tokenStorage,
    );
    adminUsersViewModel = AdminUsersViewModel(repository: adminRepository);
    adminUnidadesViewModel = AdminUnidadesViewModel(repository: adminRepository);
    adminCatalogosViewModel = AdminCatalogosViewModel(
      repository: adminRepository,
      loadCatalogsUseCase: LoadCatalogsUseCase(cedulaRepository),
    );

    // ── feature: estadisticas ────────────────────────────────────────────────
    estadisticasRemoteDataSource = EstadisticasRemoteDataSource(apiClient: apiClient);
    estadisticasRepository = EstadisticasRepositoryImpl(
      remoteDataSource: estadisticasRemoteDataSource,
      tokenStorage:     tokenStorage,
    );
    estadisticasViewModel = EstadisticasViewModel(repository: estadisticasRepository);
  }

  // ── infraestructura ───────────────────────────────────────────────────────
  late final http.Client          httpClient;
  late final TokenStorage         tokenStorage;
  late final ApiClient            apiClient;

  // ── auth ──────────────────────────────────────────────────────────────────
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository       authRepository;
  late final AuthViewModel        authViewModel;

  // ── cedula_orquestador ────────────────────────────────────────────────────
  late final CedulaRemoteDataSource cedulaRemoteDataSource;
  late final CedulaLocalDataSource  cedulaLocalDataSource;
  late final CedulaRepository       cedulaRepository;
  late final CedulaViewModel        cedulaViewModel;

  // ── dominios ──────────────────────────────────────────────────────────────
  late final FamiliaRemoteDataSource familiaRemoteDataSource;
  late final FamiliaRepository       familiaRepository;
  late final FamiliaViewModel        familiaViewModel;

  late final ViviendaRemoteDataSource viviendaRemoteDataSource;
  late final ViviendaRepository       viviendaRepository;
  late final ViviendaViewModel        viviendaViewModel;

  late final VacunacionRemoteDataSource vacunacionRemoteDataSource;
  late final VacunacionRepository       vacunacionRepository;
  late final VacunacionViewModel        vacunacionViewModel;

  late final IntegrantesRemoteDataSource integrantesRemoteDataSource;
  late final IntegrantesRepository       integrantesRepository;
  late final IntegrantesViewModel        integrantesViewModel;

  // ── admin ─────────────────────────────────────────────────────────────────
  late final AdminRemoteDataSource       adminRemoteDataSource;
  late final AdminRepository             adminRepository;
  late final AdminUsersViewModel         adminUsersViewModel;
  late final AdminUnidadesViewModel      adminUnidadesViewModel;
  late final AdminCatalogosViewModel     adminCatalogosViewModel;

  // ── estadisticas ──────────────────────────────────────────────────────────
  late final EstadisticasRemoteDataSource estadisticasRemoteDataSource;
  late final EstadisticasRepository       estadisticasRepository;
  late final EstadisticasViewModel        estadisticasViewModel;

  /// Libera ViewModels y cierra el cliente HTTP y BD local.
  void dispose() {
    authViewModel.dispose();
    cedulaViewModel.dispose();
    familiaViewModel.dispose();
    viviendaViewModel.dispose();
    vacunacionViewModel.dispose();
    integrantesViewModel.dispose();
    adminUsersViewModel.dispose();
    adminUnidadesViewModel.dispose();
    adminCatalogosViewModel.dispose();
    estadisticasViewModel.dispose();
    httpClient.close();
  }
}