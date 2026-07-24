import '../entities/catalog_item.dart';

class CedulaListItem {
  final int id;
  final String? informanteNombre;
  final DateTime? fechaRegistro;
  final String estado;
  final int? entrevistadorId;
  final int? unidadSaludId;

  const CedulaListItem({
    required this.id,
    this.informanteNombre,
    this.fechaRegistro,
    required this.estado,
    this.entrevistadorId,
    this.unidadSaludId,
  });

  factory CedulaListItem.fromJson(Map<String, dynamic> json) {
    return CedulaListItem(
      id: json['id'],
      informanteNombre: json['informante_nombre'],
      fechaRegistro: json['fecha_registro'] != null ? DateTime.tryParse(json['fecha_registro']) : null,
      estado: json['estado'] ?? 'desconocido',
      entrevistadorId: json['entrevistador_id'],
      unidadSaludId: json['unidad_salud_id'],
    );
  }
}

class PaginatedCedulas {
  final List<CedulaListItem> data;
  final int total;
  final int page;
  final int totalPages;

  const PaginatedCedulas({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

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
  Future<PaginatedCedulas> getRemoteCedulas({int page = 1, int limit = 50, String search = ''});
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
