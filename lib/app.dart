import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/di/injection.dart';
import 'core/routes/app_routes.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/theme_mode_controller.dart';

class App extends ConsumerStatefulWidget {
  final bool isSecureDevice;
  const App({super.key, this.isSecureDevice = true});
  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
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
    _idleTimer = Timer(const Duration(minutes: 15), _onIdleTimeout);
  }

  void _onIdleTimeout() {
    final authViewModel = sl<AuthViewModel>();
    if (authViewModel.isAuthenticated) {
      authViewModel.logout();
      appRouter.go(AppRoutes.login);

      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesión cerrada por inactividad (OWASP MASVS-PLATFORM-1)',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SUMS IMSS Bienestar',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(themeModeProvider),
      routerConfig: appRouter,
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
