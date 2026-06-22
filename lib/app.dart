import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/app_dependencies.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/pages/home_admin_page.dart';
import 'features/auth/presentation/pages/home_analista_page.dart';
import 'features/auth/presentation/pages/home_encuestador_page.dart';
import 'features/auth/presentation/pages/home_medico_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/cedula/presentation/pages/cedula_form_page.dart';
import 'features/cedula/presentation/viewmodels/cedula_viewmodel.dart';
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
          // ── Features ──────────────────────────────────────────────────
          AppRoutes.cedula:            (_) => const CedulaFormPage(),
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