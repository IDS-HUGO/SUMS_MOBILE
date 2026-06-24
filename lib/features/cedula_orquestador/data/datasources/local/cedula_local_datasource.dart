import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../../core/storage/local_database.dart';

class CedulaLocalDataSource {
  final AppDatabase db;

  CedulaLocalDataSource(this.db);

  /// Guarda una cédula localmente desglosándola en tablas relacionales
  Future<int> saveCedula(Map<String, dynamic> payload, int syncStatus) async {
    return await db.transaction(() async {
      // 1. Extraer datos principales (familia y metadatos)
      final familiaData = payload['familia'] ?? {};
      final informante = familiaData['informante_nombre']?.toString();
      
      // Crear payload de la tabla Cedulas
      final cedulaPayload = {
        'familia': familiaData,
        'unidad_salud_id': payload['unidad_salud_id'],
        'entrevistador_id': payload['entrevistador_id'],
      };

      // Insertar en Cedulas
      final cedulaId = await db.into(db.cedulas).insert(CedulasCompanion(
        syncStatus: Value(syncStatus),
        createdAt: Value(DateTime.now()),
        informanteNombre: Value(informante),
        familiaData: Value(jsonEncode(cedulaPayload)),
      ));

      // 2. Insertar Vivienda
      final vivienda = payload['vivienda'];
      if (vivienda != null) {
        await db.into(db.viviendas).insert(ViviendasCompanion(
          cedulaId: Value(cedulaId),
          viviendaData: Value(jsonEncode(vivienda)),
        ));
      }

      // 3. Insertar Vacunas
      final vacunacion = payload['vacunacion'];
      if (vacunacion != null && vacunacion['vacunas'] != null) {
        final List vacunas = vacunacion['vacunas'];
        for (var vac in vacunas) {
          await db.into(db.vacunas).insert(VacunasCompanion(
            cedulaId: Value(cedulaId),
            vacunaData: Value(jsonEncode(vac)),
          ));
        }
      }

      // 4. Insertar Integrantes
      final integrantes = payload['integrantes'];
      if (integrantes != null) {
        for (var integ in integrantes) {
          await db.into(db.integrantes).insert(IntegrantesCompanion(
            cedulaId: Value(cedulaId),
            integranteData: Value(jsonEncode(integ)),
          ));
        }
      }

      return cedulaId;
    });
  }

  /// Recupera todas las cédulas con un `syncStatus` específico y reconstruye el JSON
  Future<List<Map<String, dynamic>>> getCedulasByStatus(int syncStatus) async {
    final results = <Map<String, dynamic>>[];
    
    final cedulasList = await (db.select(db.cedulas)..where((tbl) => tbl.syncStatus.equals(syncStatus))).get();
    
    for (final c in cedulasList) {
      final cedulaPayload = jsonDecode(c.familiaData) as Map<String, dynamic>;
      
      // Obtener Vivienda
      final viviendaQuery = await (db.select(db.viviendas)..where((tbl) => tbl.cedulaId.equals(c.id))).getSingleOrNull();
      if (viviendaQuery != null) {
        cedulaPayload['vivienda'] = jsonDecode(viviendaQuery.viviendaData);
      }

      // Obtener Vacunacion
      final vacunasQuery = await (db.select(db.vacunas)..where((tbl) => tbl.cedulaId.equals(c.id))).get();
      final vacunasList = vacunasQuery.map((vq) => jsonDecode(vq.vacunaData)).toList();
      // Ojo: asumiendo se_aplico_vacuna = true si hay vacunas, false si no. 
      cedulaPayload['vacunacion'] = {
        'se_aplico_vacuna': vacunasList.isNotEmpty,
        'vacunas': vacunasList,
      };

      // Obtener Integrantes
      final integrantesQuery = await (db.select(db.integrantes)..where((tbl) => tbl.cedulaId.equals(c.id))).get();
      cedulaPayload['integrantes'] = integrantesQuery.map((iq) => jsonDecode(iq.integranteData)).toList();

      // Agregar ID local para control
      cedulaPayload['_localId'] = c.id;

      results.add(cedulaPayload);
    }

    return results;
  }

  /// Actualiza el estado de sincronización
  Future<void> updateSyncStatus(int localId, int newStatus) async {
    await (db.update(db.cedulas)..where((tbl) => tbl.id.equals(localId)))
        .write(CedulasCompanion(syncStatus: Value(newStatus)));
  }

  /// Elimina registros sincronizados más antiguos que los días especificados
  Future<void> deleteOldSynced(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    await (db.delete(db.cedulas)
          ..where((tbl) => tbl.syncStatus.equals(2) & tbl.createdAt.isSmallerThanValue(cutoff)))
        .go();
  }

  Future<int> countCedulasByStatus(int syncStatus) async {
    final countExp = db.cedulas.id.count();
    final query = db.selectOnly(db.cedulas)..addColumns([countExp])..where(db.cedulas.syncStatus.equals(syncStatus));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
