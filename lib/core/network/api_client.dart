import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

/// Hosts permitidos para HTTP sin cifrar solo en desarrollo.
/// Incluye loopback, emuladores y rangos de red privada para dispositivos físicos.
bool isAllowedHttpHost(String host) {
  final h = host.toLowerCase();
  if (h == 'localhost' || h == '127.0.0.1' || h == '10.0.2.2' || h == '::1') {
    return true;
  }
  // Permitir rangos de IP privada para pruebas en red local con dispositivos físicos:
  // 192.168.x.x, 172.16.x.x - 172.31.x.x, 10.x.x.x
  return h.startsWith('192.168.') ||
      h.startsWith('10.') ||
      RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(h);
}

/// Punto único de aplicación de la política de esquema seguro
/// (OWASP MASVS-NETWORK-1): bloquea cualquier esquema distinto de `https`,
/// salvo cuando el host es un host de desarrollo permitido (local/red privada)
/// Y la app corre en modo debug (`kDebugMode`). En builds de release, HTTP
/// SIEMPRE se bloquea, sin excepción.
Uri enforceSecureScheme(Uri uri) {
  if (uri.scheme == 'https') return uri;
  if (kDebugMode && isAllowedHttpHost(uri.host)) {
    return uri;
  }
  throw const ApiException(
    'La comunicación no segura (HTTP) está bloqueada por políticas de seguridad (OWASP MASVS-NETWORK-1).',
  );
}

/// Cliente HTTP genérico para la API SUMS.
/// Base URL: https://api-sums.troy.engineer/sums
class ApiClient {
  final http.Client client;
  final String baseUrl;

  const ApiClient({required this.client, required this.baseUrl});

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await _sendRequest(
      () => client.get(_uri(path), headers: _headers(token)),
    );
    return _decodeMap(response);
  }

  Future<List<dynamic>> getList(String path, {String? token}) async {
    final response = await _sendRequest(
      () => client.get(_uri(path), headers: _headers(token)),
    );
    return _decodeList(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await _sendRequest(
      () => client.post(
        _uri(path),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await _sendRequest(
      () => client.put(
        _uri(path),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await _sendRequest(
      () => client.patch(
        _uri(path),
        headers: _headers(token),
        body: jsonEncode(body),
      ),
    );
    return _decodeMap(response);
  }

  Future<Map<String, dynamic>> delete(String path, {String? token}) async {
    final response = await _sendRequest(
      () => client.delete(_uri(path), headers: _headers(token)),
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
    final normalized = clean.endsWith('/')
        ? clean.substring(0, clean.length - 1)
        : clean;
    final uri = Uri.parse('$normalized$path');
    return enforceSecureScheme(uri);
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
  ) async {
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
