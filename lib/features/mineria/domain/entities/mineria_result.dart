import 'package:equatable/equatable.dart';

class MineriaResult extends Equatable {
  final int posicion;
  final String id;
  final String titulo;
  final double score;
  final String texto;

  const MineriaResult({
    required this.posicion,
    required this.id,
    required this.titulo,
    required this.score,
    required this.texto,
  });

  @override
  List<Object?> get props => [posicion, id, titulo, score, texto];
}
