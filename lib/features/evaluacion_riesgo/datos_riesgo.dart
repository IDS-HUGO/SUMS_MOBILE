/// Modelo de datos para la evaluación de riesgo familiar.
/// Maneja la conversión desde el JSON anidado del OCR y hacia el JSON plano para predicción.
class DatosRiesgo {
  int numeroCuartos;
  int numeroHabitantes;
  String materialTecho;
  bool aguaEntubada;
  bool vacunacionCompleta;

  DatosRiesgo({
    this.numeroCuartos = 0,
    this.numeroHabitantes = 0,
    this.materialTecho = 'Concreto o cemento',
    this.aguaEntubada = false,
    this.vacunacionCompleta = false,
  });

  /// Factory constructor para mapear de manera segura el JSON anidado del OCR.
  /// Ejemplo de llave esperada: "vivienda.numero_cuartos"
  factory DatosRiesgo.fromOCR(Map<String, dynamic> json) {
    final campos = json['campos'] as Map<String, dynamic>? ?? {};

    return DatosRiesgo(
      numeroCuartos: _parseInt(campos['vivienda.numero_cuartos']),
      numeroHabitantes: _parseInt(campos['vivienda.numero_habitantes']),
      materialTecho: _parseString(campos['vivienda.material_techo'], defaultVal: 'Concreto o cemento'),
      aguaEntubada: _parseBool(campos['vivienda.agua_entubada.si']),
      vacunacionCompleta: _parseBool(campos['salud.vacunacion_completa']),
    );
  }

  /// Calcula personas por cuarto. Evita división por cero.
  double get personasPorCuarto {
    if (numeroCuartos <= 0) return 0.0;
    return double.parse((numeroHabitantes / numeroCuartos).toStringAsFixed(2));
  }

  /// Genera el JSON plano final para el modelo predictivo.
  Map<String, dynamic> toJson() {
    return {
      'numero_cuartos': numeroCuartos,
      'numero_habitantes': numeroHabitantes,
      'personas_por_cuarto': personasPorCuarto,
      'material_techo': materialTecho,
      'agua_entubada': aguaEntubada,
      'vacunacion_completa': vacunacionCompleta,
    };
  }

  // --- Auxiliares de parsing seguro ---

  static int _parseInt(dynamic field) {
    if (field == null) return 0;
    final val = field['value'];
    if (val is int) return val;
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  static bool _parseBool(dynamic field) {
    if (field == null) return false;
    final val = field['value'];
    if (val is bool) return val;
    if (val is String) return val.toLowerCase() == 'true';
    return false;
  }

  static String _parseString(dynamic field, {String defaultVal = ''}) {
    if (field == null) return defaultVal;
    final val = field['value'];
    if (val == null) return defaultVal;
    return val.toString();
  }
}

/// Modelo para la respuesta de la predicción.
class ResultadoPrediccion {
  final String modelo;
  final String nivelRiesgo;
  final double probabilidadAlto;

  ResultadoPrediccion({
    required this.modelo,
    required this.nivelRiesgo,
    required this.probabilidadAlto,
  });

  factory ResultadoPrediccion.fromJson(Map<String, dynamic> json) {
    return ResultadoPrediccion(
      modelo: json['modelo'] ?? 'Desconocido',
      nivelRiesgo: (json['nivel_riesgo'] ?? 'BAJO').toString().toUpperCase(),
      probabilidadAlto: (json['probabilidad_alto'] ?? 0.0).toDouble(),
    );
  }
}
