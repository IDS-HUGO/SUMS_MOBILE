import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _dbKeyStorageKey = 'local_db_encryption_key';

const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

/// Clave de cifrado de la base de datos local (Drift/SQLite, vía SQLCipher).
/// Se genera una vez (256 bits aleatorios) y se guarda en el mismo
/// almacenamiento cifrado del dispositivo que ya protege el token de sesión.
/// Si el dispositivo se restablece o se borra la app, la clave se pierde
/// junto con el resto del contenido de flutter_secure_storage — igual que
/// pasaría con el token, la BD local queda irrecuperable, lo cual es
/// aceptable: es una caché offline, no la fuente de verdad (esa es la API).
Future<String> getOrCreateDbEncryptionKey() async {
  final existing = await _secureStorage.read(key: _dbKeyStorageKey);
  if (existing != null && existing.isNotEmpty) return existing;

  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  final key = base64Url.encode(bytes);
  await _secureStorage.write(key: _dbKeyStorageKey, value: key);
  return key;
}
