import '../entities/auth_session.dart';

/// Contrato de la capa de dominio. Sin dependencias de Flutter ni de HTTP.
abstract class AuthRepository {
  Future<AuthSession> login({
    required String nombreUsuario,
    required String contrasena,
  });

  Future<AuthSession> register({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  });

  Future<void> logout();
}
