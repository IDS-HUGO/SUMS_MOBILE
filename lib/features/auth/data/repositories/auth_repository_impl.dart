import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

/// Implementacion concreta de [AuthRepository].
/// Orquesta la fuente remota y el almacen de tokens.
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
    try {
      final response = await remoteDataSource.login(
        nombreUsuario: nombreUsuario,
        contrasena:    contrasena,
      );
      final session = _parseSession(response);
      await tokenStorage.saveSession(session);
      // Guarda un verificador de esta contraseña para poder validar el
      // fallback offline la próxima vez que no haya red.
      await tokenStorage.saveOfflineCredentialCheck(nombreUsuario, contrasena);
      return session;
    } catch (e) {
      // Intento de login offline: solo se acepta si además de coincidir el
      // usuario, la contraseña coincide con la del último login remoto
      // exitoso (si no, cualquiera que supiera el nombre de usuario podría
      // entrar sin conexión con cualquier contraseña).
      final localSession = await tokenStorage.readSession();
      if (localSession != null && localSession.user.nombreUsuario == nombreUsuario) {
        final passwordValid = await tokenStorage.verifyOfflineCredential(nombreUsuario, contrasena);
        if (passwordValid) {
          return localSession;
        }
      }
      rethrow; // Sin sesión local, otro usuario, o contraseña incorrecta.
    }
  }

  @override
  Future<AuthSession> register({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) async {
    // El backend devuelve el usuario creado pero sin token; hacemos login justo despues.
    await remoteDataSource.register(
      nombreUsuario:    nombreUsuario,
      contrasena:       contrasena,
      rolId:            rolId,
      unidadSaludId:    unidadSaludId,
      datosLaboralesId: datosLaboralesId,
    );
    return login(nombreUsuario: nombreUsuario, contrasena: contrasena);
  }

  @override
  Future<void> logout() => tokenStorage.deleteToken();

  // ── helpers ───────────────────────────────────────────────────────────────

  /// Parsea la respuesta de /login: { token: string, user: { ... } }
  AuthSession _parseSession(Map<String, dynamic> response) {
    final token    = response['token']?.toString() ?? '';
    final userJson = response['user'];
    if (token.isEmpty || userJson is! Map<String, dynamic>) {
      throw const FormatException('Respuesta de autenticacion invalida.');
    }
    return AuthSession(token: token, user: User.fromJson(userJson));
  }
}
