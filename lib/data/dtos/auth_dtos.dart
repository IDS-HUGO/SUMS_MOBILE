import 'user_dto.dart';

class LoginRequestDto {
  final String nombreUsuario;
  final String contrasena;

  LoginRequestDto({required this.nombreUsuario, required this.contrasena});

  Map<String, dynamic> toJson() {
    return {
      'nombre_usuario': nombreUsuario,
      'contrasena': contrasena,
    };
  }
}

class RegisterRequestDto {
  final String nombreUsuario;
  final String contrasena;
  final int rolId;
  final int? unidadSaludId;
  final int? datosLaboralesId;

  RegisterRequestDto({
    required this.nombreUsuario,
    required this.contrasena,
    required this.rolId,
    this.unidadSaludId,
    this.datosLaboralesId,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_usuario': nombreUsuario,
      'contrasena': contrasena,
      'rol_id': rolId,
      if (unidadSaludId != null) 'unidad_salud_id': unidadSaludId,
      if (datosLaboralesId != null) 'datos_laborales_id': datosLaboralesId,
    };
  }
}

class AuthResponseDto {
  final String token;
  final UserDto user;

  AuthResponseDto({required this.token, required this.user});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String? ?? '',
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
