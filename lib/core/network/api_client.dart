import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

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

  Map<String, String> _headers(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
  };

  Uri _uri(String path) {
    final clean = baseUrl.trim();
    if (clean.isEmpty) {
      throw const ApiException('Configura API_BASE_URL.');
    }
    final normalized = clean.endsWith('/')
        ? clean.substring(0, clean.length - 1)
        : clean;
    return Uri.parse('$normalized$path');
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 20));
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
    return jsonDecode(response.body);
  }

  Never _throwError(http.Response response, dynamic body) {
    if (body is Map<String, dynamic>) {
      final error = body['error'] ?? body['message'] ?? body['detail'];
      if (error != null) throw ApiException(error.toString());
    }
    throw ApiException('Error HTTP ${response.statusCode}.');
  }
}
