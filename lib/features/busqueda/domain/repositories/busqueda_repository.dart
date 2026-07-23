import '../../../../core/network/api_client.dart' show ApiException;
import '../entities/resultado_busqueda.dart';

/// Excepción específica para cuando el motor de búsqueda solicitado
/// (por ejemplo `semantico`) no está disponible en el servidor (HTTP 503).
/// Se distingue de [ApiException] para que la capa de presentación la trate
/// como un estado normal de "motor no disponible", no como un error fatal.
class MotorNoDisponibleException extends ApiException {
  const MotorNoDisponibleException(super.message);
}

abstract class BusquedaRepository {
  /// Busca notas de visita mediante el microservicio de búsqueda
  /// (subcomponente C: búsqueda semántica de notas).
  ///
  /// [motor] puede ser `bm25`, `tfidf` o `semantico`. Si el motor solicitado
  /// no está disponible en el servidor, lanza [MotorNoDisponibleException].
  Future<RespuestaBusqueda> buscar(
    String consulta, {
    String motor = 'bm25',
    int k = 5,
  });

  /// Filtro sobre datos ESTRUCTURADOS de la cédula (vacunas, embarazo,
  /// nutrición, mascotas, dirección) -- complementa a [buscar], que opera
  /// sobre notas de texto libre a menudo escasas o inexistentes.
  Future<RespuestaBusquedaEstructurada> buscarEstructurado(
    String consulta, {
    int k = 20,
  });
}
