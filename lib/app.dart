import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/pages/home_admin_page.dart';
import 'features/auth/presentation/pages/home_analista_page.dart';
import 'features/auth/presentation/pages/home_encuestador_page.dart';
import 'features/auth/presentation/pages/home_medico_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/admin/presentation/pages/admin_users_list_page.dart';
import 'features/admin/presentation/pages/admin_unidades_list_page.dart';
import 'features/admin/presentation/pages/admin_catalogos_page.dart';
import 'features/admin/presentation/pages/admin_reportes_page.dart';
import 'features/admin/presentation/pages/admin_productividad_page.dart';
import 'features/admin/presentation/pages/admin_cedulas_list_page.dart';
import 'features/mineria/presentation/pages/mineria_page.dart';
import 'features/busqueda/presentation/pages/busqueda_page.dart';

import 'features/estadisticas/presentation/pages/productividad_admin_page.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/auth/domain/entities/user_role.dart';

// Importaciones actualizadas a la nueva carpeta cedula_orquestador
import 'features/cedula_orquestador/presentation/pages/cedula_form_page.dart';
import 'features/cedula_orquestador/presentation/pages/pending_captures_page.dart';
import 'features/cedula_orquestador/presentation/pages/cedula_history_page.dart';

import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_mode_controller.dart';

/// Envuelve una página administrativa verificando, en el momento de
/// construirla, que el usuario autenticado tenga el rol `admin`. Si no hay
/// sesión o el rol no corresponde, no se construye la página real: se agenda
/// una redirección a home/login (según corresponda) y mientras tanto se
/// muestra un loader vacío. Evita que quien navegue directamente a una ruta
/// `/admin/*` (deep link, back-stack manipulado, etc.) llegue a ver contenido
/// administrativo sin el rol correcto.
Widget _guardedAdminRoute(Widget Function() pageBuilder) {
  return Builder(
    builder: (context) {
      final authViewModel = sl<AuthViewModel>();
      final isAdmin =
          authViewModel.isAuthenticated && authViewModel.role == UserRole.admin;
      if (isAdmin) {
        return pageBuilder();
      }
      final redirectRoute = authViewModel.isAuthenticated
          ? authViewModel.homeRoute
          : AppRoutes.login;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(redirectRoute, (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  );
}

class App extends ConsumerStatefulWidget {
  final bool isSecureDevice;

  const App({super.key, this.isSecureDevice = true});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Timer? _idleTimer;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetIdleTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    disposeInjection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      _showOverlay =
          state == AppLifecycleState.paused ||
          state == AppLifecycleState.inactive;
    });
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    // 15 minutos de inactividad
    _idleTimer = Timer(const Duration(minutes: 15), _onIdleTimeout);
  }

  void _onIdleTimeout() {
    final authViewModel = sl<AuthViewModel>();
    if (authViewModel.isAuthenticated) {
      authViewModel.logout();
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );

      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text(
            'Sesión cerrada por inactividad (OWASP MASVS-PLATFORM-1)',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'SUMS IMSS Bienestar',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        // ── Homes por rol ──────────────────────────────────────────────
        AppRoutes.homeAdmin: (_) => const HomeAdminPage(),
        AppRoutes.homeMedico: (_) => const HomeMedicoPage(),
        AppRoutes.homeEncuestador: (_) => const HomeEncuestadorPage(),
        AppRoutes.homeAnalista: (_) => const HomeAnalistaPage(),
        // ── Features ────────────────────────────────────────────────────────────
        AppRoutes.cedula: (_) => const CedulaFormPage(),
        AppRoutes.pending: (_) => const PendingCapturesPage(),
        AppRoutes.cedulaHistorial: (_) => const CedulaHistoryPage(),
        AppRoutes.adminUsers: (_) =>
            _guardedAdminRoute(() => const AdminUsersListPage()),
        AppRoutes.adminUnidades: (_) =>
            _guardedAdminRoute(() => const AdminUnidadesListPage()),
        AppRoutes.adminCatalogos: (_) =>
            _guardedAdminRoute(() => const AdminCatalogosPage()),
        AppRoutes.adminReportes: (_) =>
            _guardedAdminRoute(() => const AdminReportesPage()),
        AppRoutes.adminProductividad: (_) =>
            _guardedAdminRoute(() => const AdminProductividadPage()),
        AppRoutes.adminCedulas: (_) =>
            _guardedAdminRoute(() => const AdminCedulasListPage()),
        AppRoutes.productividadAdmin: (_) =>
            _guardedAdminRoute(() => const ProductividadAdminPage()),
        AppRoutes.adminMineria: (_) =>
            _guardedAdminRoute(() => const MineriaPage()),
        AppRoutes.adminBusqueda: (_) =>
            _guardedAdminRoute(() => const BusquedaPage()),
      },
      // Guarda de ruta: si el usuario no está autenticado, va a login.
      onGenerateRoute: (settings) {
        // Cualquier ruta no definida arriba cae aquí; redirige a login.
        return MaterialPageRoute(builder: (_) => const LoginPage());
      },
      builder: (context, child) {
        return Listener(
          onPointerDown: (_) => _resetIdleTimer(),
          onPointerMove: (_) => _resetIdleTimer(),
          child: Stack(
            children: [
              if (child != null) child,
              if (_showOverlay)
                Positioned.fill(
                  child: Container(
                    color: AppColors.greenDark,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock, size: 64, color: AppColors.gold),
                          SizedBox(height: 16),
                          Text(
                            'Sesión Protegida',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!widget.isSecureDevice)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.security, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Entorno no seguro detectado (Root/Jailbreak). Ejecutando bajo su propio riesgo.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
