import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/domain/entities/auth_session.dart';

abstract class TokenStorage {
  Future<void> saveToken(String token);
  Future<String?> readToken();
  Future<void> deleteToken();
  Future<void> saveSession(AuthSession session);
  Future<AuthSession?> readSession();
  Future<void> saveOfflinePasswordHash(String contrasena);
  Future<bool> verifyOfflinePassword(String contrasena);
}

String hashOfflinePassword(String contrasena, {String? existingSalt}) {
  final salt =
      existingSalt ??
      base64Encode(List<int>.generate(16, (_) => Random.secure().nextInt(256)));
  final hash = sha256.convert(utf8.encode('$salt:$contrasena')).toString();
  return '$salt:$hash';
}

bool _constantTimeStringEquals(String a, String b) {
  final maxLen = a.length > b.length ? a.length : b.length;
  var diff = a.length ^ b.length;
  for (var i = 0; i < maxLen; i++) {
    final codeA = i < a.length ? a.codeUnitAt(i) : 0;
    final codeB = i < b.length ? b.codeUnitAt(i) : 0;
    diff |= codeA ^ codeB;
  }
  return diff == 0;
}

bool verifyOfflinePasswordHash(String? stored, String contrasena) {
  if (stored == null || !stored.contains(':')) return false;
  final salt = stored.substring(0, stored.indexOf(':'));
  final expected = hashOfflinePassword(contrasena, existingSalt: salt);
  return _constantTimeStringEquals(expected, stored);
}

class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'auth_session_data';
  static const _offlinePasswordHashKey = 'auth_offline_password_hash';
  SecureTokenStorage([FlutterSecureStorage? secureStorage])
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
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
    await _secureStorage.delete(key: _offlinePasswordHashKey);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await saveToken(session.token);
    await _secureStorage.write(
      key: _sessionKey,
      value: jsonEncode(session.toJson()),
    );
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

  @override
  Future<void> saveOfflinePasswordHash(String contrasena) async {
    await _secureStorage.write(
      key: _offlinePasswordHashKey,
      value: hashOfflinePassword(contrasena),
    );
  }

  @override
  Future<bool> verifyOfflinePassword(String contrasena) async {
    final stored = await _secureStorage.read(key: _offlinePasswordHashKey);
    return verifyOfflinePasswordHash(stored, contrasena);
  }
}

class SharedPreferencesTokenStorage implements TokenStorage {
  final SharedPreferences prefs;
  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'auth_session_data';
  static const _offlinePasswordHashKey = 'auth_offline_password_hash';
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
    await prefs.remove(_offlinePasswordHashKey);
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

  @override
  Future<void> saveOfflinePasswordHash(String contrasena) async {
    await prefs.setString(
      _offlinePasswordHashKey,
      hashOfflinePassword(contrasena),
    );
  }

  @override
  Future<bool> verifyOfflinePassword(String contrasena) async {
    final stored = prefs.getString(_offlinePasswordHashKey);
    return verifyOfflinePasswordHash(stored, contrasena);
  }
}

class InMemoryTokenStorage implements TokenStorage {
  String? _token;
  AuthSession? _session;
  String? _offlinePasswordHash;
  @override
  Future<void> saveToken(String token) async => _token = token;
  @override
  Future<String?> readToken() async => _token;
  @override
  Future<void> deleteToken() async {
    _token = null;
    _session = null;
    _offlinePasswordHash = null;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _token = session.token;
    _session = session;
  }

  @override
  Future<AuthSession?> readSession() async => _session;
  @override
  Future<void> saveOfflinePasswordHash(String contrasena) async {
    _offlinePasswordHash = hashOfflinePassword(contrasena);
  }

  @override
  Future<bool> verifyOfflinePassword(String contrasena) async {
    return verifyOfflinePasswordHash(_offlinePasswordHash, contrasena);
  }
}
