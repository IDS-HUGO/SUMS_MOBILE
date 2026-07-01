import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Certificado raíz al que se ancla la validación TLS (Google Trust Services
/// "GTS Root R4", que hoy emite la cadena de sums-api.troy.engineer, válido
/// hasta 2028). Sin esto, un dispositivo con una CA raíz maliciosa/comprometida
/// instalada como "de confianza" (proxy corporativo, CA falsa) podría
/// interceptar el tráfico en silencio pese al HTTPS obligatorio.
///
/// ⚠️ Riesgo operativo si el hosting de la API cambia de proveedor/CA: la app
/// dejaría de poder conectarse por completo hasta actualizar este certificado
/// y publicar una nueva versión. Si eso pasa, reemplaza el archivo
/// `assets/certs/gts_root_r4.pem` con la nueva cadena
/// (`openssl s_client -connect <host>:443 -showcerts`) y decide si conviene
/// anclar a la raíz o a un nivel intermedio.
const pinnedRootCertAsset = 'assets/certs/gts_root_r4.pem';

/// Carga los bytes del certificado anclado. Debe llamarse una vez en `main()`
/// (requiere el binding de Flutter ya inicializado) antes de construir
/// [AppDependencies], para no volver async su constructor.
Future<Uint8List> loadPinnedCertBytes() async {
  final data = await rootBundle.load(pinnedRootCertAsset);
  return data.buffer.asUint8List();
}

/// Crea un [http.Client] que solo confía en [certBytes] — reemplaza el
/// almacén de confianza del sistema en vez de complementarlo.
http.Client createPinnedHttpClient(Uint8List certBytes) {
  final securityContext = SecurityContext(withTrustedRoots: false);
  securityContext.setTrustedCertificatesBytes(certBytes);
  final httpClient = HttpClient(context: securityContext);
  return IOClient(httpClient);
}
