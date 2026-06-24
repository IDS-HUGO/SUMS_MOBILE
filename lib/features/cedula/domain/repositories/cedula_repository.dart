import '../entities/catalog_item.dart';
import '../entities/pending_cedula.dart';

abstract class CedulaRepository {
  Future<List<String>> getCatalogKeys();
  Future<List<CatalogItem>> getCatalog(String key);
  
  Future<Map<String, dynamic>> createRecord(
    String path,
    Map<String, dynamic> body,
  );
  
  Future<Map<String, dynamic>> patchRecord(
    String path,
    Map<String, dynamic> body,
  );

  // ── Local (Offline) ──────────────────────────────────────────────────
  Future<List<PendingCedula>> getPendingRecords();
  Future<int> saveLocalRecord(PendingCedula record);
  Future<void> deleteLocalRecord(int id);
}
