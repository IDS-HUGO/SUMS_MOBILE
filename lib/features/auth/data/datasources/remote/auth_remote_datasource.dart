import '../../../../../core/network/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  const AuthRemoteDataSource({required this.apiClient});

  Future<Map<String, dynamic>> login({
    required String nombreUsuario,
    required String contrasena,
  }) {
    return apiClient.post(
      '/login',
      body: {
        'nombre_usuario': nombreUsuario,
        'contrasena': contrasena,
      },
    );
  }

  Future<Map<String, dynamic>> register({
    required String nombreUsuario,
    required String contrasena,
    required int rolId,
    int? unidadSaludId,
    int? datosLaboralesId,
  }) {
    final body = <String, dynamic>{
      'nombre_usuario': nombreUsuario,
      'contrasena': contrasena,
      'rol_id': rolId,
      'activo': true,
    };
    if (unidadSaludId != null) body['unidad_salud_id'] = unidadSaludId;
    if (datosLaboralesId != null) {
      body['datos_laborales_id'] = datosLaboralesId;
    }

    return apiClient.post(
      '/register',
      body: body,
    );
  }
}
