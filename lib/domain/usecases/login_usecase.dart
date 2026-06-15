import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> execute(String nombreUsuario, String contrasena) {
    if (nombreUsuario.trim().isEmpty) {
      return Future.error('El nombre de usuario no puede estar vacío');
    }
    if (contrasena.isEmpty) {
      return Future.error('La contraseña no puede estar vacía');
    }
    return repository.login(nombreUsuario.trim(), contrasena);
  }
}
