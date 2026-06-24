class AdminUserEntity {
  final int id;
  final String nombreUsuario;
  final int rolId;
  final bool activo;
  final int? unidadSaludId;
  final int? entrevistadorId;
  final int? datosLaboralesId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUserEntity({
    required this.id,
    required this.nombreUsuario,
    required this.rolId,
    this.activo = true,
    this.unidadSaludId,
    this.entrevistadorId,
    this.datosLaboralesId,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminUserEntity.fromJson(Map<String, dynamic> json) {
    return AdminUserEntity(
      id: json['id'] as int,
      nombreUsuario: json['nombre_usuario'] as String,
      rolId: json['rol_id'] as int,
      activo: json['activo'] == true || json['activo'] == 1,
      unidadSaludId: json['unidad_salud_id'] as int?,
      entrevistadorId: json['entrevistador_id'] as int?,
      datosLaboralesId: json['datos_laborales_id'] as int?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre_usuario': nombreUsuario,
        'rol_id': rolId,
        'activo': activo,
        'unidad_salud_id': unidadSaludId,
        'entrevistador_id': entrevistadorId,
        'datos_laborales_id': datosLaboralesId,
      };
}
