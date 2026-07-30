import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import 'package:flutter/services.dart';
import '../../../familia/presentation/widgets/familia_step_widget.dart';
import '../../../vivienda/presentation/widgets/vivienda_step_widget.dart';
import '../../../vacunacion/presentation/widgets/vacunacion_step_widget.dart';
import '../../../integrantes/presentation/widgets/integrantes_step_widget.dart';
import '../viewmodels/cedula_viewmodel.dart';
import '../../../familia/presentation/viewmodels/familia_viewmodel.dart';
import '../../../vivienda/presentation/viewmodels/vivienda_viewmodel.dart';
import '../../../vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';
import '../../../integrantes/presentation/viewmodels/integrantes_viewmodel.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../utils/cedula_dummy_data.dart';
import '../widgets/cedula_success_sheet.dart';
import '../../../../core/security/device_security.dart';

class CedulaFormPage extends ConsumerStatefulWidget {
  const CedulaFormPage({super.key});
  @override
  ConsumerState<CedulaFormPage> createState() => _CedulaFormPageState();
}

class _WizardStep {
  final String label;
  final IconData icon;
  final Color color;
  const _WizardStep(this.label, this.icon, this.color);
}

class _CedulaFormPageState extends ConsumerState<CedulaFormPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  late List<_WizardStep> _steps;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    _steps = [
      _WizardStep('Familia', Icons.groups_outlined, theme.colorScheme.primary),
      _WizardStep('Vivienda', Icons.home_outlined, theme.colorScheme.tertiary),
      _WizardStep(
        'Integrantes',
        Icons.people_alt_outlined,
        theme.colorScheme.secondary,
      ),
      _WizardStep(
        'Vacunación',
        Icons.vaccines_outlined,
        theme.colorScheme.error,
      ),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _nextStep() {
    if (!_formKeys[_currentStep].currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor corrige los errores antes de continuar',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => CedulaSuccessSheet(formKeys: _formKeys),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveDraft() async {
    if (!DeviceSecurityStatus.isSecure) {
      await showInsecureDeviceDialog(context);
      return;
    }
    final authVm = ref.read(authViewModelProvider);
    final user = authVm.session?.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'ID de entrevistador inválido. No se puede guardar borrador.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (user.unidadSaludId == null || user.unidadSaludId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'ID de unidad de salud inválido. No se puede guardar borrador.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    if (user.entrevistadorId == null || user.entrevistadorId! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'ID de entrevistador inválido. No se puede guardar borrador.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    bool isValid = true;
    for (var key in _formKeys) {
      if (!key.currentState!.validate()) isValid = false;
    }
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Corrige los errores antes de guardar el borrador',
            style: TextStyle(color: Colors.white),
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
      "estado": "borrador",
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
    final success = await vm.saveDraft(payload);
    if (!mounted) return;
    context.pop();
    if (success) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.successMessage ?? 'Borrador guardado')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al guardar borrador'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Microdiagnóstico Familiar'),
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () => CedulaDummyData.apply(ref),
              icon: Icon(Icons.bug_report, color: theme.colorScheme.onPrimary),
              tooltip: 'Llenar datos de prueba',
            ),
          TextButton.icon(
            onPressed: _saveDraft,
            icon: Icon(Icons.save_outlined, color: theme.colorScheme.onPrimary),
            label: Text(
              'Guardar Borrador',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                Form(
                  key: _formKeys[0],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: const FamiliaStepWidget(),
                ),
                Form(
                  key: _formKeys[1],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: const ViviendaStepWidget(),
                ),
                Form(
                  key: _formKeys[2],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: const IntegrantesStepWidget(),
                ),
                Form(
                  key: _formKeys[3],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: const VacunacionStepWidget(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      child: const Text('Anterior'),
                    ),
                  )
                else
                  const Spacer(),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _nextStep,
                    child: Text(
                      _currentStep == _steps.length - 1
                          ? 'Finalizar'
                          : 'Siguiente',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
