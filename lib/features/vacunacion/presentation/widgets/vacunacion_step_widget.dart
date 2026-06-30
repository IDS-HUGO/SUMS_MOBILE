import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../../../cedula_orquestador/presentation/widgets/form_helpers.dart';
import '../../../integrantes/presentation/viewmodels/integrantes_viewmodel.dart';
import '../viewmodels/vacunacion_viewmodel.dart';

class VacunacionStepWidget extends StatelessWidget {
  const VacunacionStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VacunacionViewModel>();
    final intVm = context.watch<IntegrantesViewModel>();
    final pacientesOpts = intVm.integrantes.where((i) => i.nombre.text.isNotEmpty).toList();

    // Synchronize vaccine card fields with Integrantes step
    for (final v in vm.vacunas) {
      if (v.paciente.text.isNotEmpty) {
        final match = pacientesOpts.cast<MemberForm?>().firstWhere(
          (p) => p?.nombre.text == v.paciente.text,
          orElse: () => null,
        );
        if (match != null) {
          if (v.fechaNacimiento.text != match.fechaNacimiento.text ||
              v.edad.text != match.edad.text) {
            v.fechaNacimiento.text = match.fechaNacimiento.text;
            v.edad.text = match.edad.text;
          }
        } else {
          // Patient not found in list (deleted or renamed), so clear fields
          v.paciente.text = '';
          v.fechaNacimiento.text = '';
          v.edad.text = '';
        }
      }
    }

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepPanel(
          title: 'VI. Esquema de vacunación',
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
                pacientesOpts: pacientesOpts,
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
    ));
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
  final List<MemberForm> pacientesOpts;
  final VoidCallback onChanged;

  const _VaccineCard({
    required this.index, required this.form, required this.canRemove,
    required this.onRemove, required this.vacunasOpts, required this.dosisOpts,
    required this.pacientesOpts, required this.onChanged,
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
                SizedBox(width: w, child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Identificación del paciente', prefixIcon: Icon(Icons.person_outline)),
                  value: form.paciente.text.isEmpty || !pacientesOpts.any((p) => p.nombre.text == form.paciente.text) ? null : form.paciente.text,
                  items: pacientesOpts.map((m) => DropdownMenuItem(value: m.nombre.text, child: Text(m.nombre.text, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    form.paciente.text = v;
                    final m = pacientesOpts.firstWhere((p) => p.nombre.text == v, orElse: () => pacientesOpts.first);
                    form.fechaNacimiento.text = m.fechaNacimiento.text;
                    form.edad.text = m.edad.text;
                    onChanged();
                  },
                  validator: requiredText,
                )),
                SizedBox(width: w, child: SumsTextField(
                  controller: form.fechaNacimiento,
                  label: 'Fecha de nacimiento',
                  icon: Icons.event_outlined,
                  readOnly: true,
                  validator: (v) {
                    final req = requiredText(v);
                    if (req != null) return req;
                    try {
                      final bDate = DateTime.parse(v!);
                      final age = DateTime.now().difference(bDate).inDays / 365.25;
                      if (age < 2) return 'No aplicable a menores de 2 años';
                    } catch (_) {}
                    return null;
                  },
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      form.fechaNacimiento.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      final now = DateTime.now();
                      int anos = now.year - picked.year;
                      if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) anos--;
                      form.edad.text = '$anos';
                      onChanged();
                    }
                  },
                )),
                SizedBox(width: w, child: SumsTextField(controller: form.edad, label: 'Edad', icon: Icons.cake_outlined)),
                SizedBox(width: w, child: _select(label: 'Vacuna aplicada', icon: Icons.vaccines_outlined, value: form.tipo, options: vacunasOpts, onChanged: (v) {
                  form.tipo = v;
                  if (v != 'Otra') {
                    form.otraVacuna.clear();
                  }
                  onChanged();
                }, validator: requiredText)),
                SizedBox(width: w, child: _select(label: 'Dosis', icon: Icons.medication_liquid_outlined, value: form.dosis, options: dosisOpts, onChanged: (v) { form.dosis = v; onChanged(); }, validator: requiredText)),
                if (form.tipo == 'Otra')
                  SizedBox(width: w, child: SumsTextField(controller: form.otraVacuna, label: 'Otra, especificar', icon: Icons.edit_outlined, validator: requiredText)),
              ],
            );
          }),
        ],
      ),
    );
  }



  Widget _select({
    required String label, required IconData icon,
    required String? value, required List<String> options,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) =>
      DropdownButtonFormField<String>(
        isExpanded:    true,
        initialValue:  value,
        decoration:    InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis))).toList(),
        onChanged:     onChanged,
        validator:     validator,
      );
}
