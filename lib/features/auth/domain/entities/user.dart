class User {
  final int     id;
  final String  nombreUsuario;
  final int     rolId;
  final bool    activo;
  final int?    unidadSaludId;
  final int?    datosLaboralesId;
  final int?    entrevistadorId;   // ← nuevo: lo usa la cédula formal

  const User({
    required this.id,
    required this.nombreUsuario,
    required this.rolId,
    required this.activo,
    this.unidadSaludId,
    this.datosLaboralesId,
    this.entrevistadorId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:               _asInt(json['id'])                    ?? 0,
      nombreUsuario:    json['nombre_usuario']?.toString()    ?? '',
      rolId:            _asInt(json['rol_id'])                ?? 0,
      activo:           json['activo'] == true,
      unidadSaludId:    _asInt(json['unidad_salud_id']),
      datosLaboralesId: _asInt(json['datos_laborales_id']),
      entrevistadorId:  _asInt(json['entrevistador_id']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_usuario': nombreUsuario,
      'rol_id': rolId,
      'activo': activo,
      'unidad_salud_id': unidadSaludId,
      'datos_laborales_id': datosLaboralesId,
      'entrevistador_id': entrevistadorId,
    };
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
