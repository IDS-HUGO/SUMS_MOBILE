import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../../core/storage/local_database.dart';
import '../../../../../core/network/app_logger.dart';

class CedulaLocalDataSource {
  final AppDatabase db;
  CedulaLocalDataSource(this.db);

  /// Persiste una cédula completa en SQLite asociándola al [userId] del usuario
  /// activo. Esto garantiza el aislamiento entre sesiones (BUG 4).
  Future<int> saveCedula(
    Map<String, dynamic> payload,
    int syncStatus, {
    required int userId,
  }) async {
    return await db.transaction(() async {
      final familiaData = payload['familia'] ?? {};
      final informante = familiaData['informante_nombre']?.toString();
      final cedulaPayload = {
        'familia': familiaData,
        'unidad_salud_id': payload['unidad_salud_id'],
        'entrevistador_id': payload['entrevistador_id'],
      };

      // --- UPSERT DE RESCATE ---
      // Asegurarnos que el entrevistador exista en el catálogo local SQLite
      // antes de insertar la cédula, previniendo errores de validación.
      final entrevistadorId = payload['entrevistador_id'];
      if (entrevistadorId != null) {
        final catResult = await (db.select(db.catalogosLocal)..where((t) => t.tipo.equals('entrevistador'))).getSingleOrNull();
        if (catResult != null) {
          final list = List<dynamic>.from(jsonDecode(catResult.jsonList));
          final exists = list.any((e) {
            if (e is! Map) return false;
            final eId = e['id'];
            return eId == entrevistadorId || int.tryParse(eId.toString()) == entrevistadorId;
          });
          if (!exists) {
            list.add({"id": entrevistadorId, "nombre": "Rescate Usuario Activo"});
            await (db.update(db.catalogosLocal)..where((t) => t.id.equals(catResult.id))).write(
              CatalogosLocalCompanion(jsonList: Value(jsonEncode(list))),
            );
            AppLogger.info('CedulaLocalDataSource: Upsert de rescate ejecutado para entrevistador $entrevistadorId');
          }
        } else {
          await db.into(db.catalogosLocal).insert(
            CatalogosLocalCompanion(
              tipo: const Value('entrevistador'),
              jsonList: Value(jsonEncode([{"id": entrevistadorId, "nombre": "Rescate Usuario Activo"}])),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
      // -------------------------

      final cedulaId = await db
          .into(db.cedulas)
          .insert(
            CedulasCompanion(
              syncStatus: Value(syncStatus),
              createdAt: Value(DateTime.now()),
              informanteNombre: Value(informante),
              familiaData: Value(jsonEncode(cedulaPayload)),
              ownerUserId: Value(userId),
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

  /// Retorna cédulas con [syncStatus] que pertenezcan al usuario [userId].
  /// El filtro por [userId] garantiza el aislamiento entre sesiones (BUG 4).
  Future<List<Map<String, dynamic>>> getCedulasByStatus(
    int syncStatus, {
    required int userId,
  }) async {
    final results = <Map<String, dynamic>>[];
    final cedulasList = await (db.select(
      db.cedulas,
    )..where(
        (tbl) =>
            tbl.syncStatus.equals(syncStatus) &
            tbl.ownerUserId.equals(userId),
      )).get();
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

  /// Retorna todas las cédulas del usuario [userId] ordenadas por fecha
  /// descendente. El filtro garantiza el aislamiento entre sesiones (BUG 4).
  Future<List<Map<String, dynamic>>> getAllCedulas({
    required int userId,
  }) async {
    final results = <Map<String, dynamic>>[];
    final cedulasList = await (db.select(db.cedulas)
          ..where((tbl) => tbl.ownerUserId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
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

  /// Borra cédulas sincronizadas (syncStatus = 2) con más de [days] días
  /// de antigüedad. Opera sobre todos los usuarios (limpieza global de la DB).
  Future<void> deleteOldSynced(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    await (db.delete(db.cedulas)..where(
          (tbl) =>
              tbl.syncStatus.equals(2) &
              tbl.createdAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  /// Cuenta las cédulas con [syncStatus] del usuario [userId] (BUG 4).
  Future<int> countCedulasByStatus(
    int syncStatus, {
    required int userId,
  }) async {
    final countExp = db.cedulas.id.count();
    final query = db.selectOnly(db.cedulas)
      ..addColumns([countExp])
      ..where(
        db.cedulas.syncStatus.equals(syncStatus) &
            db.cedulas.ownerUserId.equals(userId),
      );
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
