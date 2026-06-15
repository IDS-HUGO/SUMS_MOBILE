import '../../domain/entities/user_entity.dart';

class UserDto {
  final int id;
  final String nombreUsuario;
  final int rolId;
  final String? fechaRegistro;
  final bool activo;
  final int? unidadSaludId;
  final int? datosLaboralesId;

  UserDto({
    required this.id,
    required this.nombreUsuario,
    required this.rolId,
    this.fechaRegistro,
    required this.activo,
    this.unidadSaludId,
    this.datosLaboralesId,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      nombreUsuario: json['nombre_usuario'] as String,
      rolId: json['rol_id'] as int,
      fechaRegistro: json['fecha_registro'] as String?,
      activo: json['activo'] as bool? ?? true,
      unidadSaludId: json['unidad_salud_id'] as int?,
      datosLaboralesId: json['datos_laborales_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_usuario': nombreUsuario,
      'rol_id': rolId,
      'fecha_registro': fechaRegistro,
      'activo': activo,
      'unidad_salud_id': unidadSaludId,
      'datos_laborales_id': datosLaboralesId,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      nombreUsuario: nombreUsuario,
      rolId: rolId,
      fechaRegistro: fechaRegistro != null ? DateTime.tryParse(fechaRegistro!) : null,
      activo: activo,
      unidadSaludId: unidadSaludId,
      datosLaboralesId: datosLaboralesId,
    );
  }
}
