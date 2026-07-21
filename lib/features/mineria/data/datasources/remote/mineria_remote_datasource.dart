import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../../core/network/api_client.dart'; // Para ApiException
import '../../../../../core/network/app_logger.dart';
import '../../models/ocr_models.dart';

/// Fuente de datos remota para el servicio de Minería OCR.
/// Implementa su propio cliente HTTP para permitir conexiones a localhost (HTTP)
/// solo en modo debug (ver [enforceSecureScheme]) sin comprometer la
/// seguridad global del ApiClient principal.
class MineriaRemoteDataSource {
  final String baseUrl;
  final http.Client _client;

  MineriaRemoteDataSource({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  /// POST /ocr/procesar
  /// Envía un archivo PDF para extracción OCR.
  Future<OcrResultModel> procesarPdf(File archivo) async {
    final uri = enforceSecureScheme(Uri.parse('$baseUrl/ocr/procesar'));
    AppLogger.info(
      'MineriaOCR: Iniciando procesamiento de ${archivo.path} en $uri',
    );

    try {
      final request = http.MultipartRequest('POST', uri);

      // El campo obligatorio es 'archivo' según requerimiento
      final stream = http.ByteStream(archivo.openRead());
      final length = await archivo.length();

      final multipartFile = http.MultipartFile(
        'archivo',
        stream,
        length,
        filename: archivo.path.split('/').last,
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 2),
      );
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.info('MineriaOCR: Respuesta recibida [${response.statusCode}]');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return OcrResultModel.fromJson(json);
      } else {
        _handleError(response);
      }
    } on TimeoutException {
      throw const ApiException('El servicio OCR tardó demasiado en responder.');
    } on SocketException {
      throw const ApiException(
        'No se pudo conectar con el microservicio OCR. Verifica que esté activo.',
      );
    } catch (e) {
      AppLogger.error('MineriaOCR: Error inesperado', e);
      if (e is ApiException) rethrow;
      throw ApiException('Error al procesar el documento: $e');
    }
  }

  /// GET /salud
  /// Verifica si el microservicio está en línea.
  Future<bool> checkSalud() async {
    final uri = enforceSecureScheme(Uri.parse('$baseUrl/salud'));
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.warn('MineriaOCR: Falló health check en $uri');
      return false;
    }
  }

  Never _handleError(http.Response response) {
    String? message;
    try {
      final body = jsonDecode(response.body);
      message = body['detail'] ?? body['message'] ?? body['error'];
    } catch (_) {}

    throw ApiException(
      message ?? 'Error del servidor OCR (${response.statusCode})',
    );
  }

  void dispose() {
    _client.close();
  }
}
