import '../../../cedula_orquestador/domain/entities/catalog_item.dart';

abstract class FamiliaRepository {
  Future<List<CatalogItem>> getCatalog(String key);
}
