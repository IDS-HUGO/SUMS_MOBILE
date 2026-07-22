import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);
  Future<AuthSession> call({
    required String nombreUsuario,
    required String contrasena,
  }) => repository.login(nombreUsuario: nombreUsuario, contrasena: contrasena);
}
