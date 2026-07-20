import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

/// Cliente HTTP genérico para la API SUMS.
/// Base URL: https://api-sums.troy.engineer/sums
class ApiClient {
  final http.Client client;
  final String baseUrl;

  const ApiClient({required this.client, required this.baseUrl});

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final uri = _uri(path);
    final response = await _sendRequest(
      () => client.get(uri, headers: _headers(token)),
      uri,
    );
    return _decodeMap(response);
  }

  Future<List<dynamic>> getList(String path, {String? token}) async {
    final uri = _uri(path);
    final response = await _sendRequest(
      () => client.get(uri, headers: _headers(token)),
      uri,
    );
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final uri = _uri(path);
    final response = await _sendRequest(
      () => client.post(uri, headers: _headers(token), body: jsonEncode(body)),
      uri,
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final uri = _uri(path);
    final response = await _sendRequest(
      () => client.put(uri, headers: _headers(token), body: jsonEncode(body)),
      uri,
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final uri = _uri(path);
    final response = await _sendRequest(
      () => client.patch(uri, headers: _headers(token), body: jsonEncode(body)),
      uri,
    );
    return _decodeMap(response);
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) {
    final clean = baseUrl.trim();
    if (clean.isEmpty) throw const ApiException('Configura API_BASE_URL.');
    final normalized =
        clean.endsWith('/') ? clean.substring(0, clean.length - 1) : clean;
    final uri = Uri.parse('$normalized$path');
    if (uri.scheme != 'https') {
      throw const ApiException('La comunicación no segura (HTTP) está bloqueada por políticas de seguridad (OWASP MASVS-NETWORK-1).');
    }
    return uri;
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
    Uri uri,
  ) async {
    if (uri.scheme == 'https') {
      try {
        await HttpCertificatePinning.check(
          serverURL: '${uri.scheme}://${uri.host}',
          headerHttp: <String, String>{},
          sha: SHA.SHA256,
          allowedSHAFingerprints: [
            '21:D2:97:B0:BF:47:B9:6C:D6:13:B4:E1:EC:52:3A:E1:76:6C:88:7A:A6:D0:10:94:4A:64:39:77:C8:97:22:B3',
            // Agregamos sin los dos puntos por si el paquete lo normaliza de forma distinta
            '21D297B0BF47B96CD613B4E1EC523AE1766C887AA6D010944A643977C89722B3'
          ],
          timeout: 15,
        );
      } catch (e) {
        throw ApiException('Posible ataque MitM. Certificado de ${uri.host} es inválido.');
      }
    }
    try {
      return await request().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('No se pudo conectar con la API.');
    }
  }

  Map<String, dynamic> _decodeMap(http.Response response) {
    final body = _decodeBody(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) return body;
      return <String, dynamic>{'data': body};
    }
    _throwError(response, body);
  }

  List<dynamic> _decodeList(http.Response response) {
    final body = _decodeBody(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is List<dynamic>) return body;
      throw const ApiException('Respuesta inesperada del servidor.');
    }
    _throwError(response, body);
  }

  dynamic _decodeBody(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      return jsonDecode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  Never _throwError(http.Response response, dynamic body) {
    if (body is Map<String, dynamic>) {
      final error = body['error'] ?? body['message'] ?? body['detail'];
      if (error != null) throw ApiException(error.toString());
    } else if (body is String && body.isNotEmpty) {
      // Si la respuesta fue un texto plano en lugar de JSON
      throw ApiException(body);
    }
    throw ApiException('Error HTTP ${response.statusCode}.');
  }
}