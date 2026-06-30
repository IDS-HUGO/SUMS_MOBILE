import 'package:sums/core/storage/database_helper.dart';
import 'package:sums/features/cedula/domain/entities/pending_cedula.dart';

class CedulaLocalDataSource {
  final DatabaseHelper dbHelper;

  const CedulaLocalDataSource({required this.dbHelper});

  Future<int> insert(PendingCedula record) async {
    final db = await dbHelper.database;
    return await db.insert('pending_cedulas', record.toMap());
  }

  Future<int> update(PendingCedula record) async {
    final db = await dbHelper.database;
    return await db.update(
      'pending_cedulas',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<List<PendingCedula>> getAll() async {
    final db = await dbHelper.database;
    final maps = await db.query('pending_cedulas', orderBy: 'updated_at DESC');
    return maps.map(PendingCedula.fromMap).toList();
  }

  Future<int> delete(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'pending_cedulas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
