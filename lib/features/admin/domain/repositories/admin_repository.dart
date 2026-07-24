import '../entities/user_entity.dart';
import '../entities/unidad_salud_entity.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';

abstract class AdminRepository {
  Future<List<AdminUserEntity>> getUsers();
  Future<AdminUserEntity> createUser(Map<String, dynamic> body);
  Future<AdminUserEntity> updateUser(int id, Map<String, dynamic> body);
  Future<List<UnidadSaludEntity>> getUnidadesSalud();
  Future<UnidadSaludEntity> createUnidadSalud(Map<String, dynamic> body);
  Future<UnidadSaludEntity> updateUnidadSalud(
    int id,
    Map<String, dynamic> body,
  );
  Future<bool> deleteUnidadSalud(int id);
  Future<List<String>> getCatalogKeys();
  Future<List<CatalogItem>> getCatalog(String key);
  Future<bool> createCatalogItem(String catalogName, Map<String, dynamic> body);
  Future<bool> updateCatalogItem(String catalogName, int id, Map<String, dynamic> body);
  Future<bool> deleteCatalogItem(String catalogName, int id);
}
