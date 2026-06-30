import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_dependencies.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/pages/home_admin_page.dart';
import 'features/auth/presentation/pages/home_analista_page.dart';
import 'features/auth/presentation/pages/home_encuestador_page.dart';
import 'features/auth/presentation/pages/home_medico_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/admin/presentation/pages/admin_users_list_page.dart';
import 'features/admin/presentation/pages/admin_unidades_list_page.dart';
import 'features/admin/presentation/pages/admin_catalogos_page.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';

// Importaciones actualizadas a la nueva carpeta cedula_orquestador
import 'features/cedula_orquestador/presentation/pages/cedula_form_page.dart';
import 'features/cedula_orquestador/presentation/pages/pending_captures_page.dart';
import 'features/cedula_orquestador/presentation/pages/cedula_history_page.dart';
import 'features/cedula_orquestador/presentation/viewmodels/cedula_viewmodel.dart';

import 'features/familia/presentation/viewmodels/familia_viewmodel.dart';
import 'features/vivienda/presentation/viewmodels/vivienda_viewmodel.dart';
import 'features/vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';
import 'features/integrantes/presentation/viewmodels/integrantes_viewmodel.dart';
import 'features/admin/presentation/viewmodels/admin_users_viewmodel.dart';
import 'features/admin/presentation/viewmodels/admin_unidades_viewmodel.dart';
import 'features/admin/presentation/viewmodels/admin_catalogos_viewmodel.dart';
import 'shared/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies();
  }

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(
          value: _dependencies.authViewModel,
        ),
        ChangeNotifierProvider<CedulaViewModel>.value(
          value: _dependencies.cedulaViewModel,
        ),
        ChangeNotifierProvider<FamiliaViewModel>.value(
          value: _dependencies.familiaViewModel,
        ),
        ChangeNotifierProvider<ViviendaViewModel>.value(
          value: _dependencies.viviendaViewModel,
        ),
        ChangeNotifierProvider<VacunacionViewModel>.value(
          value: _dependencies.vacunacionViewModel,
        ),
        ChangeNotifierProvider<IntegrantesViewModel>.value(
          value: _dependencies.integrantesViewModel,
        ),
        ChangeNotifierProvider<AdminUsersViewModel>.value(
          value: _dependencies.adminUsersViewModel,
        ),
        ChangeNotifierProvider<AdminUnidadesViewModel>.value(
          value: _dependencies.adminUnidadesViewModel,
        ),
        ChangeNotifierProvider<AdminCatalogosViewModel>.value(
          value: _dependencies.adminCatalogosViewModel,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title:        'SUMS IMSS Bienestar',
        theme:        AppTheme.light(),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login:             (_) => const LoginPage(),
          // ── Homes por rol ──────────────────────────────────────────────
          AppRoutes.homeAdmin:         (_) => const HomeAdminPage(),
          AppRoutes.homeMedico:        (_) => const HomeMedicoPage(),
          AppRoutes.homeEncuestador:   (_) => const HomeEncuestadorPage(),
          AppRoutes.homeAnalista:      (_) => const HomeAnalistaPage(),
          // ── Features ────────────────────────────────────────────────────────────
          AppRoutes.cedula:            (_) => const CedulaFormPage(),
          AppRoutes.pending:           (_) => const PendingCapturesPage(),
          AppRoutes.cedulaHistorial:   (_) => const CedulaHistoryPage(),
          AppRoutes.adminUsers:        (_) => const AdminUsersListPage(),
          AppRoutes.adminUnidades:     (_) => const AdminUnidadesListPage(),
          AppRoutes.adminCatalogos:    (_) => const AdminCatalogosPage(),
        },
        // Guarda de ruta: si el usuario no está autenticado, va a login.
        onGenerateRoute: (settings) {
          // Cualquier ruta no definida arriba cae aquí; redirige a login.
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
          );
        },
      ),
    );
  }
}