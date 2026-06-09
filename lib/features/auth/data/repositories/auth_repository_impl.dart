import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<AuthSession> login({
    required String nombreUsuario,
    required String contrasena,
  }) async {
    final response = await remoteDataSource.login(
      nombreUsuario: nombreUsuario,
      contrasena: contrasena,
    );
    final session = _parseSession(response);
    await tokenStorage.saveToken(session.token);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) async {
    await remoteDataSource.register(
      nombreUsuario: nombreUsuario,
      contrasena: contrasena,
      rolId: rolId,
      unidadSaludId: unidadSaludId,
      datosLaboralesId: datosLaboralesId,
    );
    return login(nombreUsuario: nombreUsuario, contrasena: contrasena);
  }

  @override
  Future<void> logout() => tokenStorage.deleteToken();

  AuthSession _parseSession(Map<String, dynamic> response) {
    final token = response['token']?.toString() ?? '';
    final userJson = response['user'];
    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de autenticacion invalida.');
    }
    return AuthSession(token: token, user: User.fromJson(userJson));
  }
}
