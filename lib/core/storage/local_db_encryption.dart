import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:drift/drift.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _localDbKeyStorageKey = 'local_db_encryption_key';
Future<enc.Key> loadOrCreateLocalDbKey(
  FlutterSecureStorage secureStorage,
) async {
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

class LocalDbKeyHolder {
  static LocalFieldCipher? cipher;
}

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

const NullAwareTypeConverter<String, String> nullableEncryptedTextConverter =
    NullAwareTypeConverter.wrap(EncryptedTextConverter());
