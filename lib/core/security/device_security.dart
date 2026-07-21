import 'package:flutter/material.dart';

/// Estado de integridad del dispositivo, calculado una única vez en `main()`
/// (ver `FlutterJailbreakDetection` en `lib/main.dart`) antes de levantar la
/// app. Se expone como valor estático simple para que cualquier punto de la
/// app (login, guardado de cédulas) pueda BLOQUEAR la acción si el
/// dispositivo no es confiable, en vez de solo mostrar una advertencia
/// pasiva (OWASP MASVS-RESILIENCE-1).
class DeviceSecurityStatus {
  DeviceSecurityStatus._();

  /// `true` mientras no se detecte jailbreak/root. Se actualiza una sola vez
  /// al arrancar la app, antes de `runApp`.
  static bool isSecure = true;
}

/// Muestra un diálogo bloqueante explicando por qué la acción (login o
/// guardado de una cédula) fue denegada por motivos de seguridad.
Future<void> showInsecureDeviceDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.gpp_bad_outlined, color: Colors.red, size: 40),
      title: const Text('Dispositivo no seguro detectado'),
      content: const Text(
        'Se detectó que este dispositivo tiene acceso root/jailbreak. Por la '
        'sensibilidad de los datos de salud que maneja SUMS, esta acción '
        'está bloqueada en dispositivos no confiables '
        '(OWASP MASVS-RESILIENCE-1). Usa un dispositivo sin root/jailbreak '
        'para continuar.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
