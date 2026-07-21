import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _localDbKeyStorageKey = 'local_db_encryption_key';

/// Obtiene la clave AES-256 usada para cifrar los campos JSON de la BD local
/// (Drift/SQLite), generándola la primera vez. La clave vive en
/// flutter_secure_storage (Keystore/Keychain del dispositivo) — nunca en el
/// archivo .sqlite ni en el código fuente.
Future<enc.Key> loadOrCreateLocalDbKey(FlutterSecureStorage secureStorage) async {
  final existing = await secureStorage.read(key: _localDbKeyStorageKey);
  if (existing != null) {
    return enc.Key(base64Decode(existing));
  }
  final keyBytes = Uint8List.fromList(
    List<int>.generate(32, (_) => Random.secure().nextInt(256)),
  );
  await secureStorage.write(
    key: _localDbKeyStorageKey,
    value: base64Encode(keyBytes),
  );
  return enc.Key(keyBytes);
}

/// Cifra/descifra texto con AES-256-GCM. Formato de salida:
/// base64(iv(12 bytes) + ciphertext + tag) — mismo esquema conceptual que
/// sums-API/src/shared/security/encryption.ts, adaptado a Dart/Drift.
class LocalFieldCipher {
  LocalFieldCipher(this._key);

  final enc.Key _key;

  String encryptText(String plainText) {
    final iv = enc.IV.fromSecureRandom(12);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.gcm));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return base64Encode(iv.bytes + encrypted.bytes);
  }

  String decryptText(String stored) {
    final raw = base64Decode(stored);
    final iv = enc.IV(raw.sublist(0, 12));
    final cipherBytes = raw.sublist(12);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.gcm));
    return encrypter.decrypt(enc.Encrypted(cipherBytes), iv: iv);
  }
}

/// Punto de acceso único para el cifrado de la BD local. `initInjection`
/// (core/di/injection.dart) lo llena ANTES de que se use AppDatabase por
/// primera vez. Las tablas de Drift son declarativas (no reciben argumentos
/// de constructor), por eso [EncryptedTextConverter] lee de aquí en vez de
/// recibir el cifrador directamente.
class LocalDbKeyHolder {
  static LocalFieldCipher? cipher;
}

/// TypeConverter de Drift: cifra al escribir (toSql), descifra al leer
/// (fromSql). Si un valor no descifra (filas guardadas antes de activar el
/// cifrado, o si `cipher` aún no está listo), se devuelve tal cual en vez de
/// lanzar una excepción — evita romper la app con datos viejos.
class EncryptedTextConverter extends TypeConverter<String, String> {
  const EncryptedTextConverter();

  @override
  String fromSql(String fromDb) {
    final cipher = LocalDbKeyHolder.cipher;
    if (cipher == null) return fromDb;
    try {
      return cipher.decryptText(fromDb);
    } catch (_) {
      return fromDb;
    }
  }

  @override
  String toSql(String value) {
    final cipher = LocalDbKeyHolder.cipher;
    if (cipher == null) return value;
    return cipher.encryptText(value);
  }
}

/// Variante nullable de [EncryptedTextConverter], para columnas
/// `text().nullable()` que también guardan PII (p. ej.
/// `Cedulas.informanteNombre`, un nombre de persona usado como etiqueta en
/// listas de "capturas pendientes").
///
/// Drift 2.34 ya trae el helper `NullAwareTypeConverter.wrap` (ver
/// `package:drift/src/runtime/types/converters.dart`) que envuelve un
/// `TypeConverter<D, S>` no-nulo en uno `TypeConverter<D?, S?>`: si el valor
/// es `null`, lo devuelve tal cual en ambas direcciones SIN llamar a
/// `fromSql`/`toSql` del converter interno (por lo tanto nunca se invoca el
/// cifrador con `null`). Para valores no nulos delega en
/// [EncryptedTextConverter], que ya maneja el cifrado y el fallback de
/// texto plano heredado. No hizo falta escribir una clase custom.
const NullAwareTypeConverter<String, String> nullableEncryptedTextConverter =
    NullAwareTypeConverter.wrap(EncryptedTextConverter());
