import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class App extends StatefulWidget {
  final SharedPreferences prefs;
  final bool isSecureDevice;
  final bool isDebugModeActive;
  final Uint8List? pinnedCertBytes;

  const App({
    super.key,
    required this.prefs,
    this.isSecureDevice = true,
    this.isDebugModeActive = false,
    this.pinnedCertBytes,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AppDependencies _dependencies;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Timer? _idleTimer;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _dependencies = AppDependencies(widget.prefs, pinnedCertBytes: widget.pinnedCertBytes);
    WidgetsBinding.instance.addObserver(this);
    _resetIdleTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _idleTimer?.cancel();
    _dependencies.dispose();
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
    final authViewModel = _dependencies.authViewModel;
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
    // Modo desarrollador detectado: la app queda completamente bloqueada, sin
    // importar la pantalla — no se construyen rutas, providers ni Navigator.
    if (widget.isDebugModeActive) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SUMS IMSS Bienestar',
        home: _DebugModeBlockedScreen(),
      );
    }

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
        ChangeNotifierProvider<EstadisticasViewModel>.value(
          value: _dependencies.estadisticasViewModel,
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
      ),
    );
  }
}

/// Pantalla que reemplaza toda la app cuando se detecta modo desarrollador
/// (USB debugging / Developer Options) activo en el dispositivo. No hay
/// Navigator ni rutas detrás: no existe forma de llegar a ninguna pantalla
/// de la app mientras el dispositivo esté en este estado.
class _DebugModeBlockedScreen extends StatelessWidget {
  const _DebugModeBlockedScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greenDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.developer_mode, size: 72, color: AppColors.gold),
                const SizedBox(height: 24),
                const Text(
                  'Acceso bloqueado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Se detectó Modo Desarrollador / Depuración USB activo en este '
                  'dispositivo. Por seguridad de los datos médicos y familiares '
                  '(OWASP MASVS-RESILIENCE-2), SUMS no puede usarse mientras esta '
                  'opción esté habilitada.\n\nDesactiva las Opciones de desarrollador '
                  'en Ajustes y vuelve a abrir la aplicación.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 14,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}