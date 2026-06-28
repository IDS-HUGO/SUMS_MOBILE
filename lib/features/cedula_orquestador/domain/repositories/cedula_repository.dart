import '../entities/catalog_item.dart';

abstract class CedulaRepository {
  Future<List<String>>          getCatalogKeys();
  Future<List<CatalogItem>>     getCatalog(String key);

  /// Envía toda la cédula al endpoint /sums/cedulas/captura-completa.
  Future<Map<String, dynamic>> submitCapturaCompleta(
    Map<String, dynamic> body, {
    bool isDraft = false,
  });

  /// Endpoints individuales (opcionales, para flujos paso a paso).
  Future<Map<String, dynamic>>  createRecord(String path, Map<String, dynamic> body);
  Future<Map<String, dynamic>>  patchRecord(String path, Map<String, dynamic> body);
  
  /// Métodos locales para sincronización
  Future<int> getPendingSyncCount();
  Future<int> getDraftCount();
  Future<List<Map<String, dynamic>>> getAllLocalCedulas();
  Future<SyncResult> syncPendingCedulas();
  Future<SyncResult> syncSingleCedula(int localId);
}

/// Resultado de una sincronización
class SyncResult {
  final int synced;
  final int failed;
  final String? error;

  const SyncResult({this.synced = 0, this.failed = 0, this.error});

  bool get success => error == null;
}
