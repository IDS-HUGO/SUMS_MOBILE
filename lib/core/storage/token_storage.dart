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

  /// Guarda un verificador de la última contraseña válida, para el fallback
  /// de login offline (verifyOfflineCredential). Se llama tras un login
  /// remoto exitoso.
  Future<void> saveOfflineCredentialCheck(String nombreUsuario, String contrasena);

  /// Compara la contraseña dada contra el verificador guardado. Usado por el
  /// fallback offline en AuthRepositoryImpl para no aceptar cualquier
  /// contraseña con solo que el nombre de usuario coincida.
  Future<bool> verifyOfflineCredential(String nombreUsuario, String contrasena);
}

/// Deriva un verificador salteado (SHA-256) de usuario+contraseña. No es un
/// reemplazo de bcrypt del lado servidor — el valor ya vive dentro del
/// almacenamiento cifrado del dispositivo (Keystore/Keychain); esto solo
/// evita que el fallback offline acepte cualquier contraseña con solo saber
/// el nombre de usuario.
String _hashCredential(String nombreUsuario, String contrasena, String salt) {
  final bytes = utf8.encode('$salt:$nombreUsuario:$contrasena');
  return sha256.convert(bytes).toString();
}

String _generateSalt([int length = 16]) {
  final rand = Random.secure();
  final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
  return base64Url.encode(bytes);
}

class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'auth_session_data';
  static const _offlineHashKey = 'offline_credential_hash';

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
    await _secureStorage.delete(key: _offlineHashKey);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await saveToken(session.token);
    await _secureStorage.write(key: _sessionKey, value: jsonEncode(session.toJson()));
  }

  @override
  Future<void> saveOfflineCredentialCheck(String nombreUsuario, String contrasena) async {
    final salt = _generateSalt();
    final hash = _hashCredential(nombreUsuario, contrasena, salt);
    await _secureStorage.write(key: _offlineHashKey, value: '$salt:$hash');
  }

  @override
  Future<bool> verifyOfflineCredential(String nombreUsuario, String contrasena) async {
    final stored = await _secureStorage.read(key: _offlineHashKey);
    if (stored == null || !stored.contains(':')) return false;
    final separatorIndex = stored.indexOf(':');
    final salt = stored.substring(0, separatorIndex);
    final expectedHash = stored.substring(separatorIndex + 1);
    return _hashCredential(nombreUsuario, contrasena, salt) == expectedHash;
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
  static const _offlineHashKey = 'offline_credential_hash';

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
    await prefs.remove(_offlineHashKey);
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    await saveToken(session.token);
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> saveOfflineCredentialCheck(String nombreUsuario, String contrasena) async {
    final salt = _generateSalt();
    final hash = _hashCredential(nombreUsuario, contrasena, salt);
    await prefs.setString(_offlineHashKey, '$salt:$hash');
  }

  @override
  Future<bool> verifyOfflineCredential(String nombreUsuario, String contrasena) async {
    final stored = prefs.getString(_offlineHashKey);
    if (stored == null || !stored.contains(':')) return false;
    final separatorIndex = stored.indexOf(':');
    final salt = stored.substring(0, separatorIndex);
    final expectedHash = stored.substring(separatorIndex + 1);
    return _hashCredential(nombreUsuario, contrasena, salt) == expectedHash;
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
  String? _offlineHash;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> deleteToken() async {
    _token = null;
    _session = null;
    _offlineHash = null;
  }

  @override
  Future<void> saveSession(AuthSession session) async {
    _token = session.token;
    _session = session;
  }

  @override
  Future<void> saveOfflineCredentialCheck(String nombreUsuario, String contrasena) async {
    final salt = _generateSalt();
    _offlineHash = '$salt:${_hashCredential(nombreUsuario, contrasena, salt)}';
  }

  @override
  Future<bool> verifyOfflineCredential(String nombreUsuario, String contrasena) async {
    final stored = _offlineHash;
    if (stored == null || !stored.contains(':')) return false;
    final separatorIndex = stored.indexOf(':');
    final salt = stored.substring(0, separatorIndex);
    final expectedHash = stored.substring(separatorIndex + 1);
    return _hashCredential(nombreUsuario, contrasena, salt) == expectedHash;
  }

  @override
  Future<AuthSession?> readSession() async => _session;
}
