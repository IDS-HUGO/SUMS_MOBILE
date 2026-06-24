import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/unidad_salud_entity.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';
import '../datasources/remote/admin_remote_datasource.dart';
import '../../../../core/storage/token_storage.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<List<AdminUserEntity>> getUsers() async {
    final token = await tokenStorage.readToken();
    final data = await remoteDataSource.getUsers(token: token);
    return data.map((json) => AdminUserEntity.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<AdminUserEntity> createUser(Map<String, dynamic> body) async {
    final token = await tokenStorage.readToken();
    final response = await remoteDataSource.createUser(body, token: token);
    return AdminUserEntity.fromJson(response['data'] ?? response);
  }

  @override
  Future<List<UnidadSaludEntity>> getUnidadesSalud() async {
    final token = await tokenStorage.readToken();
    final data = await remoteDataSource.getUnidadesSalud(token: token);
    return data.map((json) => UnidadSaludEntity.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<UnidadSaludEntity> createUnidadSalud(Map<String, dynamic> body) async {
    final token = await tokenStorage.readToken();
    final response = await remoteDataSource.createUnidadSalud(body, token: token);
    return UnidadSaludEntity.fromJson(response['data'] ?? response);
  }

  @override
  Future<List<CatalogItem>> getCatalog(String key) async {
    final token = await tokenStorage.readToken();
    final data = await remoteDataSource.getCatalog(key, token: token);
    return data.map((json) => CatalogItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<bool> createCatalogItem(String catalogName, Map<String, dynamic> body) async {
    final token = await tokenStorage.readToken();
    try {
      await remoteDataSource.createCatalogItem(catalogName, body, token: token);
      return true;
    } catch (e) {
      return false;
    }
  }
}
