class ProductividadEntrevistador {
  final String nombre;
  final int hoy;
  final int semana;
  final int mes;
  final int total;
  final DateTime? ultimaActividad;

  const ProductividadEntrevistador({
    required this.nombre,
    required this.hoy,
    required this.semana,
    required this.mes,
    required this.total,
    this.ultimaActividad,
  });

  factory ProductividadEntrevistador.fromJson(Map<String, dynamic> json) {
    return ProductividadEntrevistador(
      nombre: json['nombre'] as String? ?? 'N/A',
      hoy: json['hoy'] as int? ?? 0,
      semana: json['semana'] as int? ?? 0,
      mes: json['mes'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      ultimaActividad: json['ultima_actividad'] != null 
          ? DateTime.tryParse(json['ultima_actividad'].toString()) 
          : null,
    );
  }
}
