import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/entities/auth_session.dart';

abstract class TokenStorage {
  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> deleteToken();
  
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> readSession();
}

class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'auth_session_data';

  SecureTokenStorage([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> readToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _sessionKey);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await saveToken(session.token);
    await _secureStorage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  @override
  Future<AuthSession?> readSession() async {
    final sessionJson = await _secureStorage.read(key: _sessionKey);
    if (sessionJson != null && sessionJson.isNotEmpty) {
      try {
        final data = jsonDecode(sessionJson) as Map<String, dynamic>;
        return AuthSession.fromJson(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class SharedPreferencesTokenStorage implements TokenStorage {
  final SharedPreferences prefs;
  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'auth_session_data';

  SharedPreferencesTokenStorage(this.prefs);

  @override
  Future<void> saveToken(String token) async {
    await prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> readToken() async {
    return prefs.getString(_tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_sessionKey);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await saveToken(session.token);
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<AuthSession?> readSession() async {
    final sessionJson = prefs.getString(_sessionKey);
    if (sessionJson != null && sessionJson.isNotEmpty) {
      try {
        final data = jsonDecode(sessionJson) as Map<String, dynamic>;
        return AuthSession.fromJson(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

/// Implementacion en memoria. Usada antes, ahora mantenida por compatibilidad.
class InMemoryTokenStorage implements TokenStorage {
  String? _token;
  AuthSession? _session;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> deleteToken() async {
    _token = null;
    _session = null;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _token = session.token;
    _session = session;
  }

  @override
  Future<AuthSession?> readSession() async => _session;
}
