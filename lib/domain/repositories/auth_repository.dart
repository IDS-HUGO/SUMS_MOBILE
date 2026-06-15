import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String nombreUsuario, String contrasena);
  
  Future<UserEntity> register({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  });

  Future<void> logout();
  
  Future<UserEntity?> getCurrentUser();
}
