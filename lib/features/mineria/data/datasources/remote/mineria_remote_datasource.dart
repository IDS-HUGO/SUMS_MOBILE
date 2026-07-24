import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/app_logger.dart';
import '../../models/ocr_models.dart';

class MineriaRemoteDataSource {
  final String baseUrl;
  final http.Client _client;
  MineriaRemoteDataSource({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();
  Map<String, String> _headers() => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-API-Key': ApiEndpoints.mineriaApiKey,
  };
  Future<OcrResultModel> procesarPdf(File archivo) async {
    final uri = Uri.parse('$baseUrl/ocr/procesar-cedula');
    AppLogger.info('MineriaOCR: Subiendo ${archivo.path} a $uri');

    try {
      final request = http.MultipartRequest('POST', uri);
      
      // Headers requeridos por producción
      request.headers.addAll({
        'X-API-Key': ApiEndpoints.mineriaApiKey,
        'Accept': 'application/json',
      });

      // Probamos con 'file' que es el estándar de FastAPI para UploadFile
      final multipartFile = await http.MultipartFile.fromPath(
        'file', 
        archivo.path,
        filename: archivo.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Usamos el cliente interno para mayor estabilidad
      final streamedResponse = await _client.send(request).timeout(
        const Duration(minutes: 3),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      AppLogger.info('MineriaOCR: Respuesta [${response.statusCode}]');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return OcrResultModel.fromJson(jsonDecode(response.body));
      } else {
        // Si falla con 'file', intentamos con 'archivo' (fallback)
        if (response.statusCode == 422) {
           return _procesarPdfLegacy(archivo);
        }
        _handleError(response);
      }
    } catch (e) {
      AppLogger.error('MineriaOCR: Error de conexión', e);
      throw ApiException('Error de conexión con el servidor OCR: $e');
    }
  }

  /// Método de respaldo usando el campo 'archivo'
  Future<OcrResultModel> _procesarPdfLegacy(File archivo) async {
    final uri = Uri.parse('$baseUrl/ocr/procesar-cedula');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'X-API-Key': ApiEndpoints.mineriaApiKey,
      'Accept': 'application/json',
    });
    
    final multipartFile = await http.MultipartFile.fromPath('archivo', archivo.path);
    request.files.add(multipartFile);

    final streamedResponse = await _client.send(request).timeout(const Duration(minutes: 2));
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return OcrResultModel.fromJson(jsonDecode(response.body));
    }
    _handleError(response);
  }

  Future<bool> checkSalud() async {
    final uri = enforceSecureScheme(Uri.parse('$baseUrl/salud'));
    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.warn('MineriaOCR: Falló health check en $uri');
      return false;
    }
  }

  Future<Map<String, List<String>>> getCatalogos() async {
    final uri = Uri.parse('$baseUrl/catalogos');
    try {
      final response = await _client
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return {
          'vacunas': List<String>.from(json['vacunas'] ?? []),
          'dosis': List<String>.from(json['dosis'] ?? []),
        };
      }
      throw ApiException('Error al obtener catálogos (${response.statusCode})');
    } catch (e) {
      AppLogger.error('MineriaOCR: Error en getCatalogos', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> predecirRiesgo(
    Map<String, dynamic> payload,
  ) async {
    final uri = Uri.parse('$baseUrl/riesgo/predecir');
    try {
      final response = await _client
          .post(uri, headers: _headers(), body: jsonEncode(payload))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        _handleError(response);
      }
    } catch (e) {
      AppLogger.error('MineriaOCR: Error en predecirRiesgo', e);
      rethrow;
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
