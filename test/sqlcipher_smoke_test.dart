import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('sqlite3 build is SQLCipher-enabled and PRAGMA key actually encrypts', () {
    final dir = Directory.systemTemp.createTempSync('sqlcipher_smoke');
    final file = File('${dir.path}/test.sqlite');
    addTearDown(() => dir.deleteSync(recursive: true));

    // 1) Confirm this is really a SQLCipher build, not plain sqlite3.
    final probe = sqlite3.openInMemory();
    final cipherVersion = probe.select('PRAGMA cipher_version;');
    expect(cipherVersion, isNotEmpty, reason: 'PRAGMA cipher_version returned nothing — this is a plain sqlite3 build, not SQLCipher.');
    probe.close();

    // 2) Write encrypted data with a key.
    final db1 = sqlite3.open(file.path);
    db1.execute("PRAGMA key = 'correct-horse-battery-staple';");
    db1.execute('CREATE TABLE t (v TEXT);');
    db1.execute("INSERT INTO t (v) VALUES ('secret-pii-value');");
    db1.close();

    // 3) Reopening with the SAME key must read the data back.
    final db2 = sqlite3.open(file.path);
    db2.execute("PRAGMA key = 'correct-horse-battery-staple';");
    final rows = db2.select('SELECT v FROM t;');
    expect(rows.single['v'], 'secret-pii-value');
    db2.close();

    // 4) Reopening with the WRONG key must NOT be able to read the table.
    final db3 = sqlite3.open(file.path);
    db3.execute("PRAGMA key = 'totally-wrong-key';");
    expect(
      () => db3.select('SELECT v FROM t;'),
      throwsA(anything),
      reason: 'Wrong key was able to read the table — the file is not actually encrypted.',
    );
    db3.close();
  });
}
