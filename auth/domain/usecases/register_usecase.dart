import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: registrar nuevo usuario y autenticarlo de inmediato.
class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<AuthSession> call({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) =>
      repository.register(
        nombreUsuario:    nombreUsuario,
        contrasena:       contrasena,
        rolId:            rolId,
        unidadSaludId:    unidadSaludId,
        datosLaboralesId: datosLaboralesId,
      );
}
