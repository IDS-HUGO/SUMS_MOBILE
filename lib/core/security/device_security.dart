import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeviceSecurityStatus {
  DeviceSecurityStatus._();
  static bool isSecure = true;
}

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
          onPressed: () => ctx.pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
