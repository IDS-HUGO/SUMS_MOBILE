import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../familia/presentation/widgets/familia_step_widget.dart';
import '../../../vivienda/presentation/widgets/vivienda_step_widget.dart';
import '../../../vacunacion/presentation/widgets/vacunacion_step_widget.dart';
import '../../../integrantes/presentation/widgets/integrantes_step_widget.dart';
import '../viewmodels/cedula_viewmodel.dart';
import '../../../familia/presentation/viewmodels/familia_viewmodel.dart';
import '../../../vivienda/presentation/viewmodels/vivienda_viewmodel.dart';
import '../../../vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';
import '../../../integrantes/presentation/viewmodels/integrantes_viewmodel.dart';

class CedulaFormPage extends StatefulWidget {
  const CedulaFormPage({super.key});

  @override
  State<CedulaFormPage> createState() => _CedulaFormPageState();
}

class _WizardStep {
  final String   label;
  final IconData icon;
  final Color    color;
  const _WizardStep(this.label, this.icon, this.color);
}

class _CedulaFormPageState extends State<CedulaFormPage> with TickerProviderStateMixin {
  int _currentStep = 0;
  late final AnimationController _animController;

  static const _steps = [
    _WizardStep('Familia',     Icons.groups_outlined,      AppColors.green),
    _WizardStep('Vivienda',    Icons.home_outlined,        AppColors.terracota),
    _WizardStep('Vacunación',  Icons.vaccines_outlined,    AppColors.burgundy),
    _WizardStep('Integrantes', Icons.people_alt_outlined,  AppColors.gold),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _showSuccessSheet();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context:     context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.green, size: 64),
            const SizedBox(height: 16),
            const Text('¿Guardar Cédula?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            const Text('Revisa que todos los datos estén correctos antes de enviarlos.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Revisar'))),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      // Orquestación del Payload Final
                      final familiaVm = context.read<FamiliaViewModel>();
                      final viviendaVm = context.read<ViviendaViewModel>();
                      final vacunasVm = context.read<VacunacionViewModel>();
                      final integrantesVm = context.read<IntegrantesViewModel>();
                      
                      // Construir el JSON consolidado
                      final payload = {
                        "familia": familiaVm.toPayload(),
                        "vivienda": viviendaVm.toPayload(),
                        "vacunacion": vacunasVm.toPayload(),
                        "integrantes": integrantesVm.toPayload()
                      }; 

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      final vm = context.read<CedulaViewModel>();
                      final success = await vm.submitCapturaCompleta(payload);

                      if (!mounted) return;
                      Navigator.pop(context); // Cierra loader

                      if (success) {
                        Navigator.pop(context); // Cierra modal
                        Navigator.pop(context); // Regresa
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.successMessage ?? 'Cédula guardada')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage ?? 'Error al guardar la cédula'), backgroundColor: Colors.red));
                      }
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text('Microdiagnóstico Familiar')),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: const [
                FamiliaStepWidget(),
                ViviendaStepWidget(),
                VacunacionStepWidget(),
                IntegrantesStepWidget(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(child: OutlinedButton(onPressed: _prevStep, child: const Text('Anterior')))
                else
                  const Spacer(),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == _steps.length - 1 ? 'Finalizar' : 'Siguiente'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
