import 'package:equatable/equatable.dart';

class RiesgoFamiliar extends Equatable {
  final int prioridad;
  final String informanteNombre;
  final String colonia;
  final double probabilidadAlto;

  const RiesgoFamiliar({
    required this.prioridad,
    required this.informanteNombre,
    required this.colonia,
    required this.probabilidadAlto,
  });

  @override
  List<Object?> get props => [prioridad, informanteNombre, colonia, probabilidadAlto];
}
