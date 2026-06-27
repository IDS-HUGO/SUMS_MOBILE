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
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';

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
  
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  static const _steps = [
    _WizardStep('Familia',     Icons.groups_outlined,      AppColors.green),
    _WizardStep('Vivienda',    Icons.home_outlined,        AppColors.terracota),
    _WizardStep('Integrantes', Icons.people_alt_outlined,  AppColors.gold),
    _WizardStep('Vacunación',  Icons.vaccines_outlined,    AppColors.burgundy),
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
    if (!_formKeys[_currentStep].currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor corrige los errores antes de continuar', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      return;
    }
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
                      final authVm = context.read<AuthViewModel>();
                      final user = authVm.session?.user;
                      if (user == null || user.entrevistadorId == null || user.entrevistadorId! <= 0) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'ID de entrevistador inválido. No se puede guardar la cédula.',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      bool isValid = true;
                      for (var key in _formKeys) {
                        if (!key.currentState!.validate()) isValid = false;
                      }
                      if (!isValid) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revisa los errores en las diferentes secciones antes de guardar', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                        return;
                      }

                      // Orquestación del Payload Final
                      final familiaVm = context.read<FamiliaViewModel>();
                      final viviendaVm = context.read<ViviendaViewModel>();
                      final vacunasVm = context.read<VacunacionViewModel>();
                      final integrantesVm = context.read<IntegrantesViewModel>();
                      
                      // Construir el JSON consolidado
                      final payload = {
                        "unidad_salud_id": user.unidadSaludId ?? 1,
                        "entrevistador_id": user.entrevistadorId,
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

  void _applyDummyData() {
    final f = context.read<FamiliaViewModel>();
    final v = context.read<ViviendaViewModel>();
    final i = context.read<IntegrantesViewModel>();
    final vac = context.read<VacunacionViewModel>();

    f.informanteNombre.text = 'Juan Perez Dummy';
    f.setSexo('Masculino');
    f.setRol(f.roles.isNotEmpty ? f.roles.first : 'Padre');
    f.domicilio.text = 'Calle Prueba 123';

    v.setTecho(v.matTechoParedesOpts.isNotEmpty ? v.matTechoParedesOpts.first : 'Lámina');
    v.setParedes(v.matTechoParedesOpts.isNotEmpty ? v.matTechoParedesOpts.first : 'Tabique');
    v.setPiso(v.matPisoOpts.isNotEmpty ? v.matPisoOpts.first : 'Cemento');
    v.cuartos.text = '3';
    v.habitantes.text = '4';
    v.aguaEntubada = true;
    v.energiaElect = true;
    v.setCocina(v.cocinasOpts.isNotEmpty ? v.cocinasOpts.first : 'Dentro');
    v.coccionLena = false;
    v.setExcretas(v.excretasOpts.isNotEmpty ? v.excretasOpts.first : 'Drenaje');
    v.alcantarillado = true;
    v.fosaSeptica = false;
    v.perrosGatos = false;
    v.animVacunas = false;
    v.esterilizados = false;

    if (i.integrantes.isEmpty) i.addMemberForm();
    final m = i.integrantes[0];
    m.nombre.text = 'Juan Perez Dummy';
    m.sexo = 'Masculino';
    m.fechaNacimiento.text = '1980-01-01';
    m.edad.text = '46';
    m.estadoCivil = i.edoCivilOpts.isNotEmpty ? i.edoCivilOpts.first : 'Casado(a)';
    m.parentesco = i.rolesOpts.isNotEmpty ? i.rolesOpts.first : 'Padre';
    m.escolaridad = i.escolaridadOpts.isNotEmpty ? i.escolaridadOpts.first : 'Secundaria';
    m.lengua = i.lenguaOpts.isNotEmpty ? i.lenguaOpts.first : 'Español';
    m.ingreso = i.ingresoOpts.isNotEmpty ? i.ingresoOpts.first : '1 a 2 salarios';
    m.alfabetizacion = true;
    m.seguridadSocial = true;
    m.higiene = true;
    m.discapacidad = false;
    m.proteina.text = '2';
    m.frutasVerd.text = '2';
    m.cereales.text = '2';
    m.toxicomanias.clear();
    m.toxicomanias.add('Ninguna');
    m.cronicas.clear();
    m.cronicas.add('Ninguna');
    m.frecuenciaSalud = i.freqSaludOpts.isNotEmpty ? i.freqSaludOpts.first : 'Anual';
    i.updateForm();

    vac.seAplicoVacuna = false;
    vac.updateForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Microdiagnóstico Familiar'),
        actions: [
          IconButton(
            onPressed: _applyDummyData,
            icon: const Icon(Icons.bug_report, color: AppColors.green),
            tooltip: 'Llenar datos de prueba',
          ),
          TextButton.icon(
            onPressed: () async {
              final authVm = context.read<AuthViewModel>();
              final user = authVm.session?.user;
              if (user == null || user.entrevistadorId == null || user.entrevistadorId! <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'ID de entrevistador inválido. No se puede guardar borrador.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              bool isValid = true;
              for (var key in _formKeys) {
                if (!key.currentState!.validate()) isValid = false;
              }
              if (!isValid) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Corrige los errores antes de guardar el borrador', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
                return;
              }

              final familiaVm = context.read<FamiliaViewModel>();
              final viviendaVm = context.read<ViviendaViewModel>();
              final vacunasVm = context.read<VacunacionViewModel>();
              final integrantesVm = context.read<IntegrantesViewModel>();
              
              final payload = {
                "unidad_salud_id": user.unidadSaludId ?? 1,
                "entrevistador_id": user.entrevistadorId,
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
              final success = await vm.saveDraft(payload);

              if (!context.mounted) return;
              Navigator.pop(context); // Cierra loader

              if (success) {
                Navigator.pop(context); // Regresa
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.successMessage ?? 'Borrador guardado')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.errorMessage ?? 'Error al guardar borrador')));
              }
            },
            icon: const Icon(Icons.save_outlined, color: AppColors.green),
            label: const Text('Guardar Borrador', style: TextStyle(color: AppColors.green)),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                Form(key: _formKeys[0], autovalidateMode: AutovalidateMode.onUserInteraction, child: const FamiliaStepWidget()),
                Form(key: _formKeys[1], autovalidateMode: AutovalidateMode.onUserInteraction, child: const ViviendaStepWidget()),
                Form(key: _formKeys[2], autovalidateMode: AutovalidateMode.onUserInteraction, child: const IntegrantesStepWidget()),
                Form(key: _formKeys[3], autovalidateMode: AutovalidateMode.onUserInteraction, child: const VacunacionStepWidget()),
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
