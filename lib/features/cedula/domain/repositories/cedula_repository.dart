import '../entities/catalog_item.dart';

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
}
