import 'package:equatable/equatable.dart';

class RiesgoFamiliar extends Equatable {
  final int index;
  final String informanteNombre;
  final String colonia;
  final double probabilidadAlto;

  const RiesgoFamiliar({
    required this.index,
    required this.informanteNombre,
    required this.colonia,
    required this.probabilidadAlto,
  });

  @override
  List<Object?> get props => [index, informanteNombre, colonia, probabilidadAlto];
}
