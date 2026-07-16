import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sums/core/network/app_logger.dart';
import '../../../../../core/network/api_endpoints.dart';
import '../../models/mineria_result_model.dart';
import '../../models/riesgo_familiar_model.dart';

/// Excepciones personalizadas para un manejo de errores robusto.
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

abstract class MineriaRemoteDataSource {
  Future<List<MineriaResultModel>> buscarCasos(String query);
  Future<List<RiesgoFamiliarModel>> getRiesgoLista();
}

class MineriaRemoteDataSourceImpl implements MineriaRemoteDataSource {
  final http.Client client;
  static const Duration _timeout = Duration(seconds: 10);

  MineriaRemoteDataSourceImpl({required this.client});

  @override
  Future<List<MineriaResultModel>> buscarCasos(String query) async {
    final uri = Uri.parse('${ApiEndpoints.mineriaBaseUrl}/buscar?q=$query&motor=bm25&k=5');
    AppLogger.info('Minería: Consultando buscador en $uri');
    
    return _handleRequest<List<MineriaResultModel>>(() async {
      final response = await client.get(uri).timeout(_timeout);
      AppLogger.info('Minería: Respuesta buscador status=${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final resultados = data['resultados'] as List;
        return resultados.map((e) => MineriaResultModel.fromJson(e)).toList();
      }
      
      AppLogger.error('Minería: Error servidor buscador', response.body);
      throw ServerException('Error del servidor (${response.statusCode}): ${response.body}');
    });
  }

  @override
  Future<List<RiesgoFamiliarModel>> getRiesgoLista() async {
    final uri = Uri.parse('${ApiEndpoints.mineriaBaseUrl}/riesgo/lista?top=20');
    AppLogger.info('Minería: Consultando riesgo en $uri');
    
    return _handleRequest<List<RiesgoFamiliarModel>>(() async {
      final response = await client.get(uri).timeout(_timeout);
      AppLogger.info('Minería: Respuesta riesgo status=${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((e) => RiesgoFamiliarModel.fromJson(e)).toList();
      }
      
      AppLogger.error('Minería: Error servidor riesgo', response.body);
      throw ServerException('Error del servidor (${response.statusCode}): ${response.body}');
    });
  }

  /// Helper genérico para capturar excepciones de red comunes.
  Future<T> _handleRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      AppLogger.error('Minería: Timeout en petición');
      throw NetworkException('El servidor de minería no responde (Timeout).');
    } on SocketException {
      AppLogger.error('Minería: SocketException - ¿Servidor prendido?');
      throw NetworkException('No se pudo establecer conexión. Verifica que el microservicio de Python esté activo.');
    } on ServerException {
      rethrow;
    } catch (e) {
      AppLogger.error('Minería: Error inesperado', e);
      throw ServerException('Error inesperado: $e');
    }
  }
}
