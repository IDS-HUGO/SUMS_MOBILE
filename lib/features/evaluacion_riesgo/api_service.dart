import 'dart:io';
import 'package:dio/dio.dart';
import '../../core/network/api_endpoints.dart';
import 'datos_riesgo.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.mineriaBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Envía el archivo PDF al endpoint /ocr/procesar
  Future<DatosRiesgo> procesarOCR(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "archivo": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post('/ocr/procesar', data: formData);

      if (response.statusCode == 200) {
        return DatosRiesgo.fromOCR(response.data);
      } else {
        throw Exception("Error en el servidor: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Error de conexión OCR: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  /// Envía los datos validados al endpoint /riesgo/predecir
  Future<ResultadoPrediccion> obtenerPrediccion(DatosRiesgo datos) async {
    try {
      final response = await _dio.post(
        '/riesgo/predecir',
        data: datos.toJson(),
      );

      if (response.statusCode == 200) {
        return ResultadoPrediccion.fromJson(response.data);
      } else {
        throw Exception("Error en predicción: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Error de red en predicción: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }
}
