import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<AuthSession> call({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) {
    return repository.register(
      nombreUsuario: nombreUsuario,
      contrasena: contrasena,
      rolId: rolId,
      unidadSaludId: unidadSaludId,
      datosLaboralesId: datosLaboralesId,
    );
  }
}
