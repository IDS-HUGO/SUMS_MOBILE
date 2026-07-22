import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../../core/storage/local_database.dart';
import '../../../../../core/network/app_logger.dart';

class CedulaLocalDataSource {
  final AppDatabase db;
  CedulaLocalDataSource(this.db);
  Future<int> saveCedula(Map<String, dynamic> payload, int syncStatus) async {
    return await db.transaction(() async {
      final familiaData = payload['familia'] ?? {};
      final informante = familiaData['informante_nombre']?.toString();
      final cedulaPayload = {
        'familia': familiaData,
        'unidad_salud_id': payload['unidad_salud_id'],
        'entrevistador_id': payload['entrevistador_id'],
      };
      final cedulaId = await db
          .into(db.cedulas)
          .insert(
            CedulasCompanion(
              syncStatus: Value(syncStatus),
              createdAt: Value(DateTime.now()),
              informanteNombre: Value(informante),
              familiaData: Value(jsonEncode(cedulaPayload)),
            ),
          );
      final vivienda = payload['vivienda'];
      if (vivienda != null) {
        await db
            .into(db.viviendas)
            .insert(
              ViviendasCompanion(
                cedulaId: Value(cedulaId),
                viviendaData: Value(jsonEncode(vivienda)),
              ),
            );
      }
      final vacunacion = payload['vacunacion'];
      if (vacunacion != null && vacunacion['vacunas'] != null) {
        final List vacunas = vacunacion['vacunas'];
        for (var vac in vacunas) {
          await db
              .into(db.vacunas)
              .insert(
                VacunasCompanion(
                  cedulaId: Value(cedulaId),
                  vacunaData: Value(jsonEncode(vac)),
                ),
              );
        }
      }
      final integrantes = payload['integrantes'];
      if (integrantes != null) {
        for (var integ in integrantes) {
          await db
              .into(db.integrantes)
              .insert(
                IntegrantesCompanion(
                  cedulaId: Value(cedulaId),
                  integranteData: Value(jsonEncode(integ)),
                ),
              );
        }
      }
      return cedulaId;
    });
  }

  Future<List<Map<String, dynamic>>> getCedulasByStatus(int syncStatus) async {
    final results = <Map<String, dynamic>>[];
    final cedulasList = await (db.select(
      db.cedulas,
    )..where((tbl) => tbl.syncStatus.equals(syncStatus))).get();
    for (final c in cedulasList) {
      try {
        final cedulaPayload = jsonDecode(c.familiaData) as Map<String, dynamic>;
        final viviendaQuery = await (db.select(
          db.viviendas,
        )..where((tbl) => tbl.cedulaId.equals(c.id))).getSingleOrNull();
        if (viviendaQuery != null) {
          cedulaPayload['vivienda'] = jsonDecode(viviendaQuery.viviendaData);
        }
        final vacunasQuery = await (db.select(
          db.vacunas,
        )..where((tbl) => tbl.cedulaId.equals(c.id))).get();
        final vacunasList = vacunasQuery
            .map((vq) => jsonDecode(vq.vacunaData))
            .toList();
        cedulaPayload['vacunacion'] = {
          'se_aplico_vacuna': vacunasList.isNotEmpty,
          'vacunas': vacunasList,
        };
        final integrantesQuery = await (db.select(
          db.integrantes,
        )..where((tbl) => tbl.cedulaId.equals(c.id))).get();
        cedulaPayload['integrantes'] = integrantesQuery
            .map((iq) => jsonDecode(iq.integranteData))
            .toList();
        cedulaPayload['_localId'] = c.id;
        results.add(cedulaPayload);
      } catch (e, st) {
        AppLogger.error(
          'CedulaLocalDataSource: registro ${c.id} con JSON corrupto/no '
          'decodificable; se omite de este lote (sync_status=$syncStatus).',
          e,
          st,
        );
      }
    }
    return results;
  }

  Future<void> updateSyncStatus(
    int localId,
    int newStatus, {
    String? error,
  }) async {
    if (error != null) {
      final current = await (db.select(
        db.cedulas,
      )..where((tbl) => tbl.id.equals(localId))).getSingle();
      try {
        final decoded = jsonDecode(current.familiaData) as Map<String, dynamic>;
        decoded['_lastSyncError'] = error;
        decoded['_lastSyncAttempt'] = DateTime.now().toIso8601String();
        await (db.update(
          db.cedulas,
        )..where((tbl) => tbl.id.equals(localId))).write(
          CedulasCompanion(
            syncStatus: Value(newStatus),
            familiaData: Value(jsonEncode(decoded)),
          ),
        );
      } catch (e, st) {
        AppLogger.error(
          'CedulaLocalDataSource: registro $localId con JSON corrupto al '
          'intentar anexar el error de sincronización; se marca solo el '
          'syncStatus, sin guardar el detalle del error.',
          e,
          st,
        );
        await (db.update(db.cedulas)..where((tbl) => tbl.id.equals(localId)))
            .write(CedulasCompanion(syncStatus: Value(newStatus)));
      }
    } else {
      await (db.update(db.cedulas)..where((tbl) => tbl.id.equals(localId)))
          .write(CedulasCompanion(syncStatus: Value(newStatus)));
    }
  }

  Future<List<Map<String, dynamic>>> getAllCedulas() async {
    final results = <Map<String, dynamic>>[];
    final cedulasList = await (db.select(
      db.cedulas,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    for (final c in cedulasList) {
      try {
        final cedulaPayload = jsonDecode(c.familiaData) as Map<String, dynamic>;
        cedulaPayload['_localId'] = c.id;
        cedulaPayload['_syncStatus'] = c.syncStatus;
        cedulaPayload['_createdAt'] = c.createdAt.toIso8601String();
        cedulaPayload['_informante'] = c.informanteNombre;
        results.add(cedulaPayload);
      } catch (e, st) {
        AppLogger.error(
          'CedulaLocalDataSource: registro ${c.id} con JSON corrupto/no '
          'decodificable en getAllCedulas; se marca como corrupto.',
          e,
          st,
        );
        results.add({
          '_localId': c.id,
          '_syncStatus': c.syncStatus,
          '_createdAt': c.createdAt.toIso8601String(),
          '_informante': c.informanteNombre,
          '_corrupted': true,
        });
      }
    }
    return results;
  }

  Future<void> deleteOldSynced(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    await (db.delete(db.cedulas)..where(
          (tbl) =>
              tbl.syncStatus.equals(2) &
              tbl.createdAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  Future<int> countCedulasByStatus(int syncStatus) async {
    final countExp = db.cedulas.id.count();
    final query = db.selectOnly(db.cedulas)
      ..addColumns([countExp])
      ..where(db.cedulas.syncStatus.equals(syncStatus));
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
