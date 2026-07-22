/// Un resultado individual devuelto por el microservicio de búsqueda
/// (subcomponente C: búsqueda semántica de notas de visita).
class ResultadoBusqueda {
  final int posicion;
  final String id;
  final String titulo;
  final double score;
  final String texto;

  const ResultadoBusqueda({
    required this.posicion,
    required this.id,
    required this.titulo,
    required this.score,
    required this.texto,
  });

  factory ResultadoBusqueda.fromJson(Map<String, dynamic> json) {
    return ResultadoBusqueda(
      posicion: (json['posicion'] as num?)?.toInt() ?? 0,
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      texto: json['texto']?.toString() ?? '',
    );
  }
}

/// Respuesta completa de `GET /buscar`, incluye la consulta original, el
/// motor utilizado, el número de resultados solicitados (k) y la lista de
/// [ResultadoBusqueda] encontrados.
class RespuestaBusqueda {
  final String consulta;
  final String motor;
  final int k;
  final List<ResultadoBusqueda> resultados;

  const RespuestaBusqueda({
    required this.consulta,
    required this.motor,
    required this.k,
    required this.resultados,
  });

  factory RespuestaBusqueda.fromJson(Map<String, dynamic> json) {
    final rawResultados = json['resultados'] as List<dynamic>? ?? [];
    return RespuestaBusqueda(
      consulta: json['consulta']?.toString() ?? '',
      motor: json['motor']?.toString() ?? '',
      k: (json['k'] as num?)?.toInt() ?? 0,
      resultados: rawResultados
          .whereType<Map<String, dynamic>>()
          .map(ResultadoBusqueda.fromJson)
          .toList(),
    );
  }
}

/// Un resultado de `GET /buscar/estructurado` (subcomponente C: filtro sobre
/// datos de la cédula -- vacunas, embarazo, nutrición, mascotas, dirección --
/// NO similitud de texto). Ver buscador_estructurado.py en el backend.
class ResultadoBusquedaEstructurada {
  final int familiaId;
  final String? nombreInformante;
  final String domicilio;
  final String? colonia;
  final String? localidad;
  final String coincidencia;

  const ResultadoBusquedaEstructurada({
    required this.familiaId,
    required this.nombreInformante,
    required this.domicilio,
    required this.colonia,
    required this.localidad,
    required this.coincidencia,
  });

  factory ResultadoBusquedaEstructurada.fromJson(Map<String, dynamic> json) {
    return ResultadoBusquedaEstructurada(
      familiaId: (json['familia_id'] as num?)?.toInt() ?? 0,
      nombreInformante: json['nombre_informante']?.toString(),
      domicilio: json['domicilio']?.toString() ?? '',
      colonia: json['colonia']?.toString(),
      localidad: json['localidad']?.toString(),
      coincidencia: json['coincidencia']?.toString() ?? '',
    );
  }
}

/// Respuesta completa de `GET /buscar/estructurado`. `disponible=false`
/// significa que la consulta no coincidió con ninguna categoría soportada
/// (vacuna, enfermedad crónica, embarazo, menor de 1 año, adulto mayor,
/// nutrición, mascotas, dirección) -- ver [mensaje] para sugerencias.
class RespuestaBusquedaEstructurada {
  final bool disponible;
  final String? categoria;
  final int totalCoincidencias;
  final String? mensaje;
  final List<ResultadoBusquedaEstructurada> resultados;

  const RespuestaBusquedaEstructurada({
    required this.disponible,
    required this.categoria,
    required this.totalCoincidencias,
    required this.mensaje,
    required this.resultados,
  });

  factory RespuestaBusquedaEstructurada.fromJson(Map<String, dynamic> json) {
    final rawResultados = json['resultados'] as List<dynamic>? ?? [];
    return RespuestaBusquedaEstructurada(
      disponible: json['disponible'] as bool? ?? false,
      categoria: json['categoria']?.toString(),
      totalCoincidencias: (json['total_coincidencias'] as num?)?.toInt() ?? 0,
      mensaje: json['mensaje']?.toString(),
      resultados: rawResultados
          .whereType<Map<String, dynamic>>()
          .map(ResultadoBusquedaEstructurada.fromJson)
          .toList(),
    );
  }
}
