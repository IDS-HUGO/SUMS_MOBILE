import '../../domain/entities/mineria_result.dart';

class MineriaResultModel extends MineriaResult {
  const MineriaResultModel({
    required super.posicion,
    required super.id,
    required super.titulo,
    required super.score,
    required super.texto,
  });

  factory MineriaResultModel.fromJson(Map<String, dynamic> json) {
    return MineriaResultModel(
      posicion: json['posicion'] as int,
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? 'Sin nombre',
      score: (json['score'] as num).toDouble(),
      texto: json['texto']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posicion': posicion,
      'id': id,
      'titulo': titulo,
      'score': score,
      'texto': texto,
    };
  }
}
