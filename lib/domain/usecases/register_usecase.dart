import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> execute({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) {
    final String cleanUsername = nombreUsuario.trim();
    
    if (cleanUsername.isEmpty) {
      return Future.error('El nombre de usuario no puede estar vacío');
    }
    if (cleanUsername.length < 3) {
      return Future.error('El nombre de usuario debe tener al menos 3 caracteres');
    }
    if (contrasena.isEmpty) {
      return Future.error('La contraseña no puede estar vacía');
    }
    if (contrasena.length < 6) {
      return Future.error('La contraseña debe tener al menos 6 caracteres');
    }
    if (rolId < 1 || rolId > 3) {
      return Future.error('Por favor, seleccione un rol institucional válido');
    }
    if (unidadSaludId == null) {
      return Future.error('Por favor, asigne una Unidad de Salud de adscripción');
    }
    if (datosLaboralesId == null) {
      return Future.error('Por favor, ingrese sus Datos Laborales de validación');
    }
    
    return repository.register(
      nombreUsuario: cleanUsername,
      contrasena: contrasena,
      rolId: rolId,
      unidadSaludId: unidadSaludId,
      datosLaboralesId: datosLaboralesId,
    );
  }
}
