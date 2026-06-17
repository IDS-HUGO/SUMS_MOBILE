import '../repositories/auth_repository.dart';

/// Caso de uso: cerrar sesion y eliminar el token almacenado.
class LogoutUseCase {
  final AuthRepository repository;
  const LogoutUseCase(this.repository);

  Future<void> call() => repository.logout();
}
