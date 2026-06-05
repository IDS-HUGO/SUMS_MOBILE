import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  });

  AuthStatus _status = AuthStatus.initial;
  AuthSession? _session;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _session?.isAuthenticated ?? false;

  Future<bool> login({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    _setLoading();
    try {
      _session = await loginUseCase(
        nombreUsuario: nombreUsuario,
        contrasena: contrasena,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  Future<bool> register({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) async {
    _setLoading();
    try {
      _session = await registerUseCase(
        nombreUsuario: nombreUsuario,
        contrasena: contrasena,
        rolId: rolId,
        unidadSaludId: unidadSaludId,
        datosLaboralesId: datosLaboralesId,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading();
    try {
      await logoutUseCase();
      _session = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _setError(error);
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.initial;
    }
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _status = AuthStatus.error;
    _errorMessage = error.toString();
    notifyListeners();
  }
}
