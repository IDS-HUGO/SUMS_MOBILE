import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_database.g.dart';

// Definición de la tabla Cedulas
class Cedulas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get syncStatus => integer()(); // 0=DRAFT, 1=PENDING_SYNC, 2=SYNCED
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get informanteNombre => text().nullable()();
  TextColumn get familiaData => text()(); // JSON con los datos de familia e IDs base
}

// Definición de la tabla Viviendas
class Viviendas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId => integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  TextColumn get viviendaData => text()(); // JSON con datos de vivienda
}

// Definición de la tabla Vacunas
class Vacunas extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId => integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  TextColumn get vacunaData => text()(); // JSON con datos de la vacuna/inmunizacion
}

// Definición de la tabla Integrantes
class Integrantes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cedulaId => integer().references(Cedulas, #id, onDelete: KeyAction.cascade)();
  TextColumn get integranteData => text()(); // JSON con datos del integrante
}

// Definición de la tabla CatalogosLocal
class CatalogosLocal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tipo => text()(); // 'vacunas', 'roles', 'material_techo', etc.
  TextColumn get jsonList => text()(); // La lista de CatalogItem serializada
  DateTimeColumn get updatedAt => dateTime()();
}

@DriftDatabase(tables: [Cedulas, Viviendas, Vacunas, Integrantes, CatalogosLocal])
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
