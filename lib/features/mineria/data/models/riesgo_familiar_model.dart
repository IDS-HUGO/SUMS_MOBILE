import '../../domain/entities/riesgo_familiar.dart';

class RiesgoFamiliarModel extends RiesgoFamiliar {
  const RiesgoFamiliarModel({
    required super.prioridad,
    required super.informanteNombre,
    required super.colonia,
    required super.probabilidadAlto,
  });

  factory RiesgoFamiliarModel.fromJson(Map<String, dynamic> json) {
    return RiesgoFamiliarModel(
      prioridad: json['prioridad'] as int? ?? 0,
      informanteNombre: json['nombre_informante']?.toString() ?? 'Sin nombre',
      colonia: json['colonia']?.toString() ?? 'Sin colonia',
      probabilidadAlto: (json['probabilidad_alto'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prioridad': prioridad,
      'nombre_informante': informanteNombre,
      'colonia': colonia,
      'probabilidad_alto': probabilidadAlto,
    };
  }
}
