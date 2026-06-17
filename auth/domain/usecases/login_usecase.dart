import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: autenticar usuario con nombre_usuario y contrasena.
/// Retorna [AuthSession] con el token JWT y los datos del usuario.
class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<AuthSession> call({
    required String nombreUsuario,
    required String contrasena,
  }) =>
      repository.login(
        nombreUsuario: nombreUsuario,
        contrasena: contrasena,
      );
}
