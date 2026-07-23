import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'local_db_encryption.dart';
part 'local_database.g.dart';

class Cedulas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get syncStatus => integer()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get informanteNombre =>
      text().nullable().map(nullableEncryptedTextConverter)();
  TextColumn get familiaData => text().map(const EncryptedTextConverter())();

  /// ID del usuario dueño de este registro (BUG 4 — aislamiento de sesión).
  /// Valor 0 = registros legados migrados desde schema v1 sin propietario
  /// asignado; serán ignorados por las consultas filtradas de cada sesión.
  IntColumn get ownerUserId => integer().withDefault(const Constant(0))();
}

class Viviendas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId =>
      integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  TextColumn get viviendaData => text().map(const EncryptedTextConverter())();
}

class Vacunas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId =>
      integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  TextColumn get vacunaData => text().map(const EncryptedTextConverter())();
}

class Integrantes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId =>
      integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  TextColumn get integranteData => text().map(const EncryptedTextConverter())();
}

class CatalogosLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text()();
  TextColumn get jsonList => text()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(
  tables: [Cedulas, Viviendas, Vacunas, Integrantes, CatalogosLocal],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override
  int get schemaVersion => 2;
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Migración v1 → v2: añadir columna ownerUserId a Cedulas.
          // Los registros existentes quedan con ownerUserId = 0 (sin dueño).
          await m.addColumn(cedulas, cedulas.ownerUserId);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sums_offline.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
