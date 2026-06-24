class UnidadSaludEntity {
  final int id;
  final String clues;
  final String nombre;
  final String? distrito;
  final int? municipioId;
  final int? numeroNucleos;

  const UnidadSaludEntity({
    required this.id,
    required this.clues,
    required this.nombre,
    this.distrito,
    this.municipioId,
    this.numeroNucleos,
  });

  factory UnidadSaludEntity.fromJson(Map<String, dynamic> json) {
    return UnidadSaludEntity(
      id: json['id'] as int,
      clues: json['clues'] as String,
      nombre: json['nombre'] as String,
      distrito: json['distrito'] as String?,
      municipioId: json['municipio_id'] as int?,
      numeroNucleos: json['numero_nucleos'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'clues': clues,
        'nombre': nombre,
        'distrito': distrito,
        'municipio_id': municipioId,
        'numero_nucleos': numeroNucleos,
      };
}
