import '../../../../../core/network/api_client.dart';

/// Fuente de datos remota. Solo habla con la API REST.
/// Mapea rutas y campos exactos del backend Node/Express.
///
///  POST /sums/register  → { nombre_usuario, contrasena, rol_id, activo, ... }
///  POST /sums/login     → { nombre_usuario, contrasena }
///                       ← { token, user: { id, nombre_usuario, rol_id, ... } }
class AuthRemoteDataSource {
  final ApiClient apiClient;
  const AuthRemoteDataSource({required this.apiClient});

  /// Autentica al usuario. Devuelve { token, user }.
  Future<Map<String, dynamic>> login({
    required String nombreUsuario,
    required String contrasena,
  }) =>
      apiClient.post(
        '/login',
        body: {
          'nombre_usuario': nombreUsuario,
          'contrasena':     contrasena,
        },
      );

  /// Registra un nuevo usuario. Devuelve el usuario creado (sin token).
  Future<Map<String, dynamic>> register({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) {
    final body = <String, dynamic>{
      'nombre_usuario': nombreUsuario,
      'contrasena':     contrasena,
      'rol_id':         rolId,
      'activo':         true,
    };
    if (unidadSaludId    != null) body['unidad_salud_id']    = unidadSaludId;
    if (datosLaboralesId != null) body['datos_laborales_id'] = datosLaboralesId;

    return apiClient.post('/register', body: body);
  }
}
