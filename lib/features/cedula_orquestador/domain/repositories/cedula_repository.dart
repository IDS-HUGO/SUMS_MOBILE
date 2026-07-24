import '../entities/catalog_item.dart';

abstract class CedulaRepository {
  Future<List<String>> getCatalogKeys();
  Future<List<CatalogItem>> getCatalog(String key);
  Future<Map<String, dynamic>> submitCapturaCompleta(
    Map<String, dynamic> body, {
    bool isDraft = false,
  });
  Future<Map<String, dynamic>> createRecord(
    String path,
    Map<String, dynamic> body,
  );
  Future<Map<String, dynamic>> patchRecord(
    String path,
    Map<String, dynamic> body,
  );
  Future<int> getPendingSyncCount();
  Future<int> getDraftCount();
  Future<List<Map<String, dynamic>>> getAllLocalCedulas();
  Future<SyncResult> syncPendingCedulas();
  Future<SyncResult> syncSingleCedula(int localId);

  /// Descarga y persiste en SQLite los catálogos de sistema que el
  /// SyncEngine necesita para validar referencias antes de sincronizar
  /// (actualmente `entrevistador` y `unidad-salud`).
  /// Es silencioso ante fallos de red: devuelve false si no pudo refrescar,
  /// true si completó exitosamente.
  Future<bool> refreshUserCatalogs();
}

class SyncResult {
  final int synced;
  final int failed;
  final String? error;
  const SyncResult({this.synced = 0, this.failed = 0, this.error});
  bool get success => error == null;
}
