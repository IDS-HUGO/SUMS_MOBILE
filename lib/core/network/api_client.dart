import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({
    this.baseUrl = 'http://localhost:3000/sums',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 7));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión con el servidor: $e');
    }
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 7));

      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión con el servidor: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    
    Map<String, dynamic> responseBody = {};
    try {
      if (response.body.isNotEmpty) {
        final parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) {
          responseBody = parsed;
        } else if (parsed is List) {
          responseBody = {'data': parsed};
        }
      }
    } catch (_) {
      // Body is not JSON
    }

    if (statusCode >= 200 && statusCode < 300) {
      return responseBody;
    } else {
      final String errorMessage = responseBody['message'] ?? 
          responseBody['error'] ?? 
          'Error del servidor ($statusCode)';
      throw ApiException(errorMessage);
    }
  }
}
