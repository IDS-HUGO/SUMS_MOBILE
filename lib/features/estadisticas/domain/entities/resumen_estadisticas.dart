class ResumenEstadisticas {
  final int hoy;
  final int semana;
  final int mes;
  final int total;

  const ResumenEstadisticas({
    required this.hoy,
    required this.semana,
    required this.mes,
    required this.total,
  });

  factory ResumenEstadisticas.fromJson(Map<String, dynamic> json) {
    return ResumenEstadisticas(
      hoy: json['hoy'] as int? ?? 0,
      semana: json['semana'] as int? ?? 0,
      mes: json['mes'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'hoy': hoy,
        'semana': semana,
        'mes': mes,
        'total': total,
      };
}
