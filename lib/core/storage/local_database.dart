import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'local_db_encryption.dart';

part 'local_database.g.dart';

// Definición de la tabla Cedulas
class Cedulas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get syncStatus => integer()(); // 0=DRAFT, 1=PENDING_SYNC, 2=SYNCED
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get informanteNombre => text().nullable()();
  // JSON con los datos de familia e IDs base — cifrado en reposo (AES-256-GCM,
  // ver local_db_encryption.dart). Contiene nombres/domicilio de la familia.
  TextColumn get familiaData => text().map(const EncryptedTextConverter())();
}

// Definición de la tabla Viviendas
class Viviendas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId =>
      integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  // JSON con datos de vivienda — cifrado en reposo.
  TextColumn get viviendaData => text().map(const EncryptedTextConverter())();
}

// Definición de la tabla Vacunas
class Vacunas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId =>
      integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  // JSON con datos de la vacuna/inmunizacion — cifrado en reposo.
  TextColumn get vacunaData => text().map(const EncryptedTextConverter())();
}

// Definición de la tabla Integrantes
class Integrantes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId =>
      integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  // JSON con datos del integrante (salud, escolaridad, etc.) — cifrado en reposo.
  TextColumn get integranteData =>
      text().map(const EncryptedTextConverter())();
}

// Definición de la tabla CatalogosLocal
class CatalogosLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text()(); // 'vacunas', 'roles', 'material_techo', etc.
  TextColumn get jsonList => text()(); // La lista de CatalogItem serializada
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(
  tables: [Cedulas, Viviendas, Vacunas, Integrantes, CatalogosLocal],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Habilitar claves foráneas
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
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
