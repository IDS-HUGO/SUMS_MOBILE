import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodels/cedula_viewmodel.dart';
import '../../../familia/presentation/viewmodels/familia_viewmodel.dart';
import '../../../vivienda/presentation/viewmodels/vivienda_viewmodel.dart';
import '../../../vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';
import '../../../integrantes/presentation/viewmodels/integrantes_viewmodel.dart';
import '../../../../core/security/device_security.dart';

class CedulaSuccessSheet extends ConsumerWidget {
  final List<GlobalKey<FormState>> formKeys;
  const CedulaSuccessSheet({super.key, required this.formKeys});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: theme.colorScheme.primary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            '¿Guardar Cédula?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Revisa que todos los datos estén correctos antes de enviarlos.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Revisar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _submitCedula(context, ref),
                  icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitCedula(BuildContext context, WidgetRef ref) async {
    if (!DeviceSecurityStatus.isSecure) {
      context.pop();
      await showInsecureDeviceDialog(context);
      return;
    }
    final authVm = ref.read(authViewModelProvider);
    final user = authVm.session?.user;
    if (user == null ||
        user.entrevistadorId == null ||
        user.entrevistadorId! <= 0) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'ID de entrevistador inválido. No se puede guardar la cédula.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (user.unidadSaludId == null || user.unidadSaludId! <= 0) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'ID de unidad de salud inválido. No se puede guardar la cédula.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    bool isValid = true;
    for (var key in formKeys) {
      if (!key.currentState!.validate()) isValid = false;
    }
    if (!isValid) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Revisa los errores en las diferentes secciones antes de guardar',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    final familiaVm = ref.read(familiaViewModelProvider);
    final viviendaVm = ref.read(viviendaViewModelProvider);
    final vacunasVm = ref.read(vacunacionViewModelProvider);
    final integrantesVm = ref.read(integrantesViewModelProvider);
    final payload = {
      "unidad_salud_id": user.unidadSaludId,
      "entrevistador_id": user.entrevistadorId,
      "fecha_registro": DateTime.now().toIso8601String().split('T')[0],
      "estado": "sincronizada",
      "observaciones": familiaVm.observaciones.text.trim(),
      "familia": familiaVm.toPayload(),
      "vivienda": viviendaVm.toPayload(),
      "vacunacion": vacunasVm.toPayload(),
      "integrantes": integrantesVm.toPayload(),
    };
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final vm = ref.read(cedulaViewModelProvider);
    final success = await vm.submitCapturaCompleta(payload);
    if (!context.mounted) return;
    context.pop();
    if (success) {
      context.pop();
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.successMessage ?? 'Cédula guardada')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al guardar la cédula'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
