import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_test/flutter_test.dart';
import 'package:sums/core/storage/local_db_encryption.dart';

void main() {
  group('LocalFieldCipher', () {
    late LocalFieldCipher cipher;

    setUp(() {
      // Clave fija de prueba (no la real de flutter_secure_storage) — solo
      // para verificar que el algoritmo de cifrado/descifrado es correcto.
      cipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));
    });

    test('descifra exactamente lo que se cifró (round-trip)', () {
      const original =
          '{"nombre":"María Guadalupe Hernández","domicilio":"Calle Reforma 12, Suchiapa"}';

      final encrypted = cipher.encryptText(original);
      final decrypted = cipher.decryptText(encrypted);

      expect(decrypted, original);
    });

    test('el texto cifrado no es igual al texto plano', () {
      const original = '{"nombre":"Juan Pérez"}';
      final encrypted = cipher.encryptText(original);

      expect(encrypted, isNot(equals(original)));
      expect(encrypted, isNot(contains('Juan')));
    });

    test('cada cifrado usa un IV distinto (no determinista)', () {
      const original = '{"a":1}';
      final e1 = cipher.encryptText(original);
      final e2 = cipher.encryptText(original);

      expect(e1, isNot(equals(e2))); // mismo texto, cifrados distintos
      expect(cipher.decryptText(e1), original);
      expect(cipher.decryptText(e2), original);
    });

    test('una clave distinta no puede descifrar', () {
      const original = '{"secreto":true}';
      final encrypted = cipher.encryptText(original);

      final otherCipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));
      expect(() => otherCipher.decryptText(encrypted), throwsA(anything));
    });

    test('funciona con texto largo (cédula anidada completa)', () {
      final original = '{"integrantes":[' +
          List.generate(
            8,
            (i) => '{"nombre":"Integrante $i","edad":$i,"notas":"'
                '${'x' * 200}"}',
          ).join(',') +
          ']}';

      final encrypted = cipher.encryptText(original);
      expect(cipher.decryptText(encrypted), original);
    });
  });

  group('EncryptedTextConverter (integración con Drift)', () {
    tearDown(() {
      LocalDbKeyHolder.cipher = null;
    });

    test('toSql/fromSql hacen round-trip cuando el cifrador está listo', () {
      LocalDbKeyHolder.cipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));
      const converter = EncryptedTextConverter();
      const original = '{"vivienda":{"material_techo_id":2}}';

      final stored = converter.toSql(original);
      expect(stored, isNot(equals(original)));

      final restored = converter.fromSql(stored);
      expect(restored, original);
    });

    test('si el cifrador aún no está listo, no rompe (pasa el valor tal cual)', () {
      LocalDbKeyHolder.cipher = null;
      const converter = EncryptedTextConverter();
      const original = '{"sin":"cifrar"}';

      expect(converter.toSql(original), original);
      expect(converter.fromSql(original), original);
    });

    test('filas guardadas antes de activar el cifrado siguen siendo legibles', () {
      // Simula una fila vieja: JSON en claro que nunca fue cifrado.
      LocalDbKeyHolder.cipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));
      const converter = EncryptedTextConverter();
      const legacyPlainJson = '{"nombre":"Dato guardado antes del cifrado"}';

      // fromSql no debe lanzar excepción aunque el valor no esté cifrado.
      expect(converter.fromSql(legacyPlainJson), legacyPlainJson);
    });
  });

  group('nullableEncryptedTextConverter (Cedulas.informanteNombre)', () {
    tearDown(() {
      LocalDbKeyHolder.cipher = null;
    });

    test('valores no nulos hacen round-trip cifrado igual que EncryptedTextConverter', () {
      LocalDbKeyHolder.cipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));
      const original = 'María Guadalupe Hernández';

      final stored = nullableEncryptedTextConverter.toSql(original);
      expect(stored, isNotNull);
      expect(stored, isNot(equals(original)));

      final restored = nullableEncryptedTextConverter.fromSql(stored!);
      expect(restored, original);
    });

    test('null pasa directo sin invocar el cifrador (toSql)', () {
      LocalDbKeyHolder.cipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));

      expect(nullableEncryptedTextConverter.toSql(null), isNull);
    });

    test('null pasa directo sin invocar el cifrador (fromSql)', () {
      LocalDbKeyHolder.cipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));

      expect(nullableEncryptedTextConverter.fromSql(null), isNull);
    });

    test('null no lanza excepción ni cuando el cifrador aún no está listo', () {
      LocalDbKeyHolder.cipher = null;

      expect(nullableEncryptedTextConverter.toSql(null), isNull);
      expect(nullableEncryptedTextConverter.fromSql(null), isNull);
    });

    test('filas viejas en claro (legacy) siguen siendo legibles', () {
      LocalDbKeyHolder.cipher = LocalFieldCipher(enc.Key.fromSecureRandom(32));
      const legacyPlainName = 'Dato guardado antes del cifrado';

      expect(nullableEncryptedTextConverter.fromSql(legacyPlainName), legacyPlainName);
    });
  });
}
