import 'user_entity.dart';
import 'unidad_salud_entity.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';

abstract class AdminRepository {
  // Users
  Future<List<AdminUserEntity>> getUsers();
  Future<AdminUserEntity> createUser(Map<String, dynamic> body);

  // Unidades de Salud
  Future<List<UnidadSaludEntity>> getUnidadesSalud();
  Future<UnidadSaludEntity> createUnidadSalud(Map<String, dynamic> body);

  // Catálogos
  Future<List<CatalogItem>> getCatalog(String key);
  Future<bool> createCatalogItem(String catalogName, Map<String, dynamic> body);
}
