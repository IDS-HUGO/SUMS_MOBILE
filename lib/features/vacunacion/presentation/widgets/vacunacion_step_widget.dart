import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../../../cedula_orquestador/presentation/widgets/form_helpers.dart';
import '../viewmodels/vacunacion_viewmodel.dart';

class VacunacionStepWidget extends StatelessWidget {
  const VacunacionStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacunacionViewModel>();

    if (vm.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          'Error cargando catálogos: ${vm.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepPanel(
          title: 'V. Esquema de vacunación',
          icon: Icons.vaccines_outlined,
          color: AppColors.burgundy,
          children: [
            _yesNo('Se aplicó vacuna durante la visita', vm.seAplicoVacuna, (v) => vm.seAplicoVacuna = v),
          ],
        ),
        if (vm.seAplicoVacuna) ...[
          const SizedBox(height: 14),
          for (var i = 0; i < vm.vacunas.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _VaccineCard(
                index: i,
                form: vm.vacunas[i],
                canRemove: vm.vacunas.length > 1,
                onRemove: () => vm.removeVaccineForm(i),
                vacunasOpts: vm.vacunasOpts,
                dosisOpts: vm.dosisOpts,
                onChanged: () => vm.updateForm(),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => vm.addVaccineForm(),
            icon: const Icon(Icons.add_outlined),
            label: const Text('Agregar otra vacuna'),
          ),
        ],
      ],
    );
  }

  Widget _yesNo(String label, bool value, ValueChanged<bool> onChanged) =>
      InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: true,  label: Text('Sí')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected:          {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      );
}

class _StepPanel extends StatelessWidget {
  final String        title;
  final IconData      icon;
  final Color         color;
  final List<Widget>  children;

  const _StepPanel({
    required this.title, required this.icon,
    required this.color, required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: color.withOpacity(0.06),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: color == AppColors.green ? AppColors.greenDark : color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  final int index;
  final VaccineForm form;
  final bool canRemove;
  final VoidCallback onRemove;
  final List<String> vacunasOpts;
  final List<String> dosisOpts;
  final VoidCallback onChanged;

  const _VaccineCard({
    required this.index, required this.form, required this.canRemove,
    required this.onRemove, required this.vacunasOpts, required this.dosisOpts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Vacuna ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.burgundy,
                  ),
                ),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed:   onRemove,
                  icon:        const Icon(Icons.delete_outline, size: 18),
                  color:       AppColors.muted,
                  style:       IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceAlt,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (_, con) {
            final w = con.maxWidth < 720 ? con.maxWidth : (con.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                SizedBox(width: w, child: SumsTextField(controller: form.paciente, label: 'Identificación del paciente', icon: Icons.person_outline)),
                SizedBox(width: w, child: SumsTextField(controller: form.fechaNacimiento, label: 'Fecha de nacimiento', icon: Icons.event_outlined, readOnly: true, onTap: () => _selectDate(context, form.fechaNacimiento))),
                SizedBox(width: w, child: _numberField(form.edad, 'Edad', Icons.cake_outlined)),
                SizedBox(width: w, child: _select(label: 'Vacuna aplicada', icon: Icons.vaccines_outlined, value: form.tipo, options: vacunasOpts, onChanged: (v) { form.tipo = v; onChanged(); })),
                SizedBox(width: w, child: _select(label: 'Dosis', icon: Icons.medication_liquid_outlined, value: form.dosis, options: dosisOpts, onChanged: (v) { form.dosis = v; onChanged(); })),
                SizedBox(width: w, child: SumsTextField(controller: form.otraVacuna, label: 'Otra, especificar', icon: Icons.edit_outlined)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Widget _numberField(TextEditingController c, String label, IconData icon) =>
      SumsTextField(
        controller: c, label: label, icon: icon,
        keyboardType: TextInputType.number,
        validator: nonNegativeIntText,
      );

  Widget _select({
    required String label, required IconData icon,
    required String? value, required List<String> options,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        isExpanded:    true,
        initialValue:  value,
        decoration:    InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis))).toList(),
        onChanged:     onChanged,
      );
}
