import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// ViewModel para toda la feature de autenticacion (MVVM).
///
/// Expone estado reactivo via [ChangeNotifier].
/// Las vistas solo llaman metodos publicos y leen propiedades; nunca tocan
/// repositorios ni fuentes de datos directamente.
class AuthViewModel extends ChangeNotifier {
  final LoginUseCase    loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase   logoutUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  });

  // ── estado ────────────────────────────────────────────────────────────────
  AuthStatus   _status       = AuthStatus.initial;
  AuthSession? _session;
  String?      _errorMessage;

  // ── getters publicos ──────────────────────────────────────────────────────
  AuthStatus   get status        => _status;
  AuthSession? get session       => _session;
  String?      get errorMessage  => _errorMessage;
  bool         get isLoading     => _status == AuthStatus.loading;
  bool         get isAuthenticated => _session?.isAuthenticated ?? false;

  // ── acciones ──────────────────────────────────────────────────────────────

  /// Inicia sesion. Retorna [true] si fue exitoso.
  Future<bool> login({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    _setLoading();
    try {
      _session      = await loginUseCase(
        nombreUsuario: nombreUsuario,
        contrasena:    contrasena,
      );
      _status       = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  /// Registra un usuario nuevo y hace login automatico. Retorna [true] si OK.
  Future<bool> register({
    required String nombreUsuario,
    required String contrasena,
    required int    rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) async {
    _setLoading();
    try {
      _session      = await registerUseCase(
        nombreUsuario:    nombreUsuario,
        contrasena:       contrasena,
        rolId:            rolId,
        unidadSaludId:    unidadSaludId,
        datosLaboralesId: datosLaboralesId,
      );
      _status       = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  /// Cierra la sesion activa y elimina el token.
  Future<void> logout() async {
    _setLoading();
    try {
      await logoutUseCase();
      _session      = null;
      _status       = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _setError(error);
    }
  }

  /// Limpia el mensaje de error (util al navegar entre pantallas).
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) _status = AuthStatus.initial;
    notifyListeners();
  }

  // ── helpers privados ──────────────────────────────────────────────────────
  void _setLoading() {
    _status       = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _status       = AuthStatus.error;
    _errorMessage = error.toString();
    notifyListeners();
  }
}
