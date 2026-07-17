import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

import 'features/estadisticas/presentation/pages/productividad_admin_page.dart';
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
import 'features/estadisticas/presentation/viewmodels/estadisticas_viewmodel.dart';
import 'shared/theme/app_theme.dart';

class App extends ConsumerStatefulWidget {
  final bool isSecureDevice;

  const App({
    super.key,
    this.isSecureDevice = true,
  });

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
      _showOverlay = state == AppLifecycleState.paused || state == AppLifecycleState.inactive;
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
      _navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);

      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada por inactividad (OWASP MASVS-PLATFORM-1)'),
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
        title:        'SUMS IMSS Bienestar',
        theme:        AppTheme.light(),
        darkTheme:    AppTheme.dark(),
        themeMode:    ThemeMode.system,
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
          AppRoutes.adminReportes:     (_) => const AdminReportesPage(),
          AppRoutes.adminProductividad:(_) => const AdminProductividadPage(),
          AppRoutes.adminCedulas:      (_) => const AdminCedulasListPage(),
          AppRoutes.productividadAdmin: (_) => const ProductividadAdminPage(),

        },
        // Guarda de ruta: si el usuario no está autenticado, va a login.
        onGenerateRoute: (settings) {
          // Cualquier ruta no definida arriba cae aquí; redirige a login.
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
          );
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
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