import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../../core/network/api_client.dart'; // Para ApiException
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/app_logger.dart';
import '../../../domain/entities/resultado_busqueda.dart';
import '../../../domain/repositories/busqueda_repository.dart'
    show MotorNoDisponibleException;

/// Fuente de datos remota para el servicio de Búsqueda Semántica de Notas
/// (subcomponente C). Reutiliza el mismo host y API Key que el
/// microservicio de Minería OCR (ver [ApiEndpoints.mineriaBaseUrl] /
/// [ApiEndpoints.mineriaApiKey]).
class BusquedaRemoteDataSource {
  final String baseUrl;
  final http.Client _client;

  BusquedaRemoteDataSource({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'X-API-Key': ApiEndpoints.mineriaApiKey,
  };

  /// GET /buscar?q=<texto>&motor=bm25|tfidf|semantico&k=<n>
  Future<RespuestaBusqueda> buscar(
    String consulta, {
    String motor = 'bm25',
    int k = 5,
  }) async {
    final uri = enforceSecureScheme(
      Uri.parse('$baseUrl/buscar').replace(
        queryParameters: {'q': consulta, 'motor': motor, 'k': '$k'},
      ),
    );

    AppLogger.info(
      'Busqueda: Consultando "$consulta" (motor=$motor, k=$k) en $uri',
    );

    try {
      final response = await _client
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 20));

      AppLogger.info('Busqueda: Respuesta recibida [${response.statusCode}]');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return RespuestaBusqueda.fromJson(json);
      } else {
        _handleError(response, motor);
      }
    } on TimeoutException {
      throw const ApiException(
        'El servicio de búsqueda tardó demasiado en responder.',
      );
    } on SocketException {
      throw const ApiException(
        'No se pudo conectar con el microservicio de búsqueda. Verifica que esté activo.',
      );
    } catch (e) {
      AppLogger.error('Busqueda: Error inesperado', e);
      if (e is ApiException) rethrow;
      throw ApiException('Error al realizar la búsqueda: $e');
    }
  }

  /// GET /buscar/estructurado?q=<texto>&k=<n>
  /// Filtro sobre datos de la cédula (vacunas/embarazo/nutrición/mascotas/
  /// dirección) -- NO usa `motor`, no es similitud de texto.
  Future<RespuestaBusquedaEstructurada> buscarEstructurado(
    String consulta, {
    int k = 20,
  }) async {
    final uri = enforceSecureScheme(
      Uri.parse('$baseUrl/buscar/estructurado').replace(
        queryParameters: {'q': consulta, 'k': '$k'},
      ),
    );

    AppLogger.info('BusquedaEstructurada: Consultando "$consulta" en $uri');

    try {
      final response = await _client
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return RespuestaBusquedaEstructurada.fromJson(json);
      } else {
        _handleError(response, 'estructurado');
      }
    } on TimeoutException {
      throw const ApiException(
        'El servicio de búsqueda tardó demasiado en responder.',
      );
    } on SocketException {
      throw const ApiException(
        'No se pudo conectar con el microservicio de búsqueda. Verifica que esté activo.',
      );
    } catch (e) {
      AppLogger.error('BusquedaEstructurada: Error inesperado', e);
      if (e is ApiException) rethrow;
      throw ApiException('Error al realizar la búsqueda: $e');
    }
  }

  Never _handleError(http.Response response, String motor) {
    String? message;
    try {
      final body = jsonDecode(response.body);
      message = body['detail'] ?? body['message'] ?? body['error'];
    } catch (_) {}

    switch (response.statusCode) {
      case 400:
        throw ApiException(
          message ??
              'La consulta está vacía o supera los 500 caracteres permitidos.',
        );
      case 401:
        throw ApiException(
          message ??
              'La clave de API no es válida para el servicio de búsqueda.',
        );
      case 503:
        throw MotorNoDisponibleException(
          message ??
              'El motor de búsqueda "$motor" no está disponible en este momento.',
        );
      default:
        throw ApiException(
          message ?? 'Error del servidor de búsqueda (${response.statusCode})',
        );
    }
  }

  void dispose() {
    _client.close();
  }
}
