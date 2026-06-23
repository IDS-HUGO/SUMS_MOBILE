import '../../../cedula_orquestador/domain/entities/catalog_item.dart';

abstract class ViviendaRepository {
  Future<List<CatalogItem>> getCatalog(String key);
}
