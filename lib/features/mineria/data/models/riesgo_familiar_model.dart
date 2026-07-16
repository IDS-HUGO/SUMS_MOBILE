import '../../domain/entities/riesgo_familiar.dart';

class RiesgoFamiliarModel extends RiesgoFamiliar {
  const RiesgoFamiliarModel({
    required super.index,
    required super.informanteNombre,
    required super.colonia,
    required super.probabilidadAlto,
  });

  factory RiesgoFamiliarModel.fromJson(Map<String, dynamic> json) {
    return RiesgoFamiliarModel(
      index: json['index'] as int,
      informanteNombre: json['informante_nombre']?.toString() ?? 'Sin nombre',
      colonia: json['colonia']?.toString() ?? 'Sin colonia',
      probabilidadAlto: (json['probabilidad_alto'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'informante_nombre': informanteNombre,
      'colonia': colonia,
      'probabilidad_alto': probabilidadAlto,
    };
  }
}
