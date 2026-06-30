import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../viewmodels/integrantes_viewmodel.dart';
import '../../../cedula_orquestador/presentation/widgets/form_helpers.dart';
import '../../../familia/presentation/viewmodels/familia_viewmodel.dart';

class IntegrantesStepWidget extends StatelessWidget {
  const IntegrantesStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<IntegrantesViewModel>();

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
        for (var i = 0; i < vm.integrantes.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _MemberCard(
              index: i,
              form: vm.integrantes[i],
              canRemove: vm.integrantes.length > 1,
              onRemove: () => vm.removeMemberForm(i),
              onChanged: () => vm.updateForm(),
              roles: vm.rolesOpts,
              sexoOpts: vm.sexoOpts,
              edoCivilOpts: vm.edoCivilOpts,
              lenguaOpts: vm.lenguaOpts,
              escolaridadOpts: vm.escolaridadOpts,
              ingresoOpts: vm.ingresoOpts,
              embarazoOpts: vm.embarazoOpts,
              tamizajeOpts: vm.tamizajeOpts,
              freqSaludOpts: vm.freqSaludOpts,
              toxicomaniasOpts: vm.toxicomaniasOpts,
              cronicasOpts: vm.cronicasOpts,
              toggleSet: vm.toggleSet,
            ),
          ),
        OutlinedButton.icon(
          onPressed: () => vm.addMemberForm(),
          icon: const Icon(Icons.person_add_alt_outlined),
          label: const Text('Agregar integrante'),
        ),
        const SizedBox(height: 80),
      ],
    ));
  }
}

class _MemberCard extends StatelessWidget {
  final int index;
  final MemberForm form;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  final List<String> roles, sexoOpts, edoCivilOpts, lenguaOpts,
      escolaridadOpts, ingresoOpts, embarazoOpts, tamizajeOpts,
      freqSaludOpts, toxicomaniasOpts, cronicasOpts;

  final void Function(Set<String>, String) toggleSet;

  const _MemberCard({
    required this.index, required this.form, required this.canRemove,
    required this.onRemove, required this.onChanged,
    required this.roles, required this.sexoOpts, required this.edoCivilOpts,
    required this.lenguaOpts, required this.escolaridadOpts,
    required this.ingresoOpts, required this.embarazoOpts,
    required this.tamizajeOpts, required this.freqSaludOpts,
    required this.toxicomaniasOpts, required this.cronicasOpts,
    required this.toggleSet,
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
            color: AppColors.gold.withOpacity(0.07),
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'V. Integrante ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15,
                    color: AppColors.greenDark,
                  ),
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: AppColors.muted,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (_, con) {
              final familiaVm = context.read<FamiliaViewModel>();
              final w = con.maxWidth < 720 ? con.maxWidth : (con.maxWidth - 12) / 2;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: w, child: SumsTextField(controller: form.nombre, label: 'Nombre completo', icon: Icons.person_outline, validator: requiredText, onChanged: (v) {
                      if (index == 0) {
                        familiaVm.informanteNombre.text = v;
                      }
                      onChanged();
                    })),
                    SizedBox(width: w, child: _select(label: 'Sexo', icon: Icons.wc_outlined, value: form.sexo, options: sexoOpts, onChanged: (v) {
                      form.sexo = v;
                      if (index == 0) {
                        familiaVm.setSexo(v);
                      }
                      if (v != 'Femenino') {
                        form.embarazo = null;
                        form.tamizajeCervico = null;
                        form.fechaCervico.clear();
                        form.tamizajeMama = null;
                        form.fechaMama.clear();
                      }
                      onChanged();
                    }, validator: requiredText)),
                    SizedBox(width: w, child: SumsTextField(controller: form.fechaNacimiento, label: 'Fecha de nacimiento', icon: Icons.event_outlined, readOnly: true, validator: requiredText, onTap: () => _selectBirthDate(context, form.fechaNacimiento, form.edad, onChanged))),
                    SizedBox(width: w, child: SumsTextField(controller: form.edad, label: 'Edad', icon: Icons.cake_outlined, readOnly: true)),
                    SizedBox(width: w, child: _select(label: 'Estado civil', icon: Icons.favorite_border, value: form.estadoCivil, options: edoCivilOpts, onChanged: (v) { form.estadoCivil = v; onChanged(); })),
                    SizedBox(width: w, child: _select(label: 'Parentesco/rol familiar', icon: Icons.diversity_3_outlined, value: form.parentesco, options: roles, onChanged: (v) { 
                      form.parentesco = v; 
                      if (index == 0) {
                        familiaVm.setRol(v);
                      }
                      onChanged(); 
                    }, validator: requiredText)),
                    SizedBox(width: w, child: _select(label: 'Lengua', icon: Icons.record_voice_over_outlined, value: form.lengua, options: lenguaOpts, onChanged: (v) {
                      form.lengua = v;
                      if (v != 'Lengua indígena') {
                        form.lenguaEsp.clear();
                      }
                      onChanged();
                    })),
                    if (form.lengua == 'Lengua indígena')
                      SizedBox(width: w, child: SumsTextField(controller: form.lenguaEsp, label: 'Lengua indígena, especificar', icon: Icons.edit_outlined, validator: requiredText)),
                    SizedBox(width: w, child: _select(label: 'Escolaridad', icon: Icons.school_outlined, value: form.escolaridad, options: escolaridadOpts, onChanged: (v) { form.escolaridad = v; onChanged(); })),
                    SizedBox(width: w, child: SumsTextField(controller: form.ocupacion, label: 'Ocupación', icon: Icons.work_outline)),
                    SizedBox(width: w, child: _select(label: 'Ingreso - salario mínimo', icon: Icons.payments_outlined, value: form.ingreso, options: ingresoOpts, onChanged: (v) { form.ingreso = v; onChanged(); })),
                  ]),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Condiciones de salud'),
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: w, child: _buildYesNo(context, 'Alfabetización', form.alfabetizacion, (v) { form.alfabetizacion = v; onChanged(); })),
                    SizedBox(width: w, child: _buildYesNo(context, 'Seguridad social', form.seguridadSocial, (v) { form.seguridadSocial = v; onChanged(); })),
                    SizedBox(width: w, child: _buildYesNo(context, 'Higiene buco-dental diaria', form.higiene, (v) { form.higiene = v; onChanged(); })),
                    SizedBox(width: w, child: _buildYesNo(context, 'Presenta discapacidad', form.discapacidad, (v) {
                      form.discapacidad = v;
                      if (!v) {
                        form.tipoDisc.clear();
                      }
                      onChanged();
                    })),
                    if (form.discapacidad)
                      SizedBox(width: w, child: SumsTextField(controller: form.tipoDisc, label: 'Tipo de discapacidad', icon: Icons.accessible_forward_outlined, validator: requiredText)),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: w, child: _daysField(form.proteina, 'Carne, pescado y pollo')),
                    SizedBox(width: w, child: _daysField(form.frutasVerd, 'Frutas y verduras')),
                    SizedBox(width: w, child: _daysField(form.cereales, 'Cereales, granos y leguminosas')),
                  ]),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Toxicomanías'),
                  const SizedBox(height: 10),
                  _chipGroup(context, toxicomaniasOpts, form.toxicomanias),
                  const SizedBox(height: 12),
                  if (form.toxicomanias.contains('Otras sustancias'))
                    SumsTextField(controller: form.otraSust, label: 'Otra sustancia, especificar', icon: Icons.edit_outlined, validator: requiredText),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Enfermedades crónico-degenerativas'),
                  const SizedBox(height: 10),
                  _chipGroup(context, cronicasOpts, form.cronicas),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Seguimiento preventivo'),
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    if (form.sexo == 'Femenino') ...[
                      SizedBox(width: w, child: _select(label: 'Atención de embarazo', icon: Icons.pregnant_woman_outlined, value: form.embarazo, options: embarazoOpts, onChanged: (v) { form.embarazo = v; onChanged(); })),
                      SizedBox(width: w, child: _select(label: 'Tamizaje cérvico-uterino', icon: Icons.health_and_safety_outlined, value: form.tamizajeCervico, options: tamizajeOpts, onChanged: (v) {
                        form.tamizajeCervico = v;
                        if (v != 'Sí') {
                          form.fechaCervico.clear();
                        }
                        onChanged();
                      })),
                      if (form.tamizajeCervico == 'Sí')
                        SizedBox(width: w, child: SumsTextField(
                          controller: form.fechaCervico,
                          label: 'Fecha cérvico-uterino',
                          icon: Icons.event_outlined,
                          readOnly: true,
                          validator: (v) => _validateTamizajeDate(v, form.fechaNacimiento.text),
                          onTap: () => _selectDateSimple(context, form.fechaCervico, form.fechaNacimiento.text, onChanged),
                        )),
                      SizedBox(width: w, child: _select(label: 'Tamizaje cáncer de mama', icon: Icons.medical_services_outlined, value: form.tamizajeMama, options: tamizajeOpts, onChanged: (v) {
                        form.tamizajeMama = v;
                        if (v != 'Sí') {
                          form.fechaMama.clear();
                        }
                        onChanged();
                      })),
                      if (form.tamizajeMama == 'Sí')
                        SizedBox(width: w, child: SumsTextField(
                          controller: form.fechaMama,
                          label: 'Fecha cáncer de mama',
                          icon: Icons.event_outlined,
                          readOnly: true,
                          validator: (v) => _validateTamizajeDate(v, form.fechaNacimiento.text),
                          onTap: () => _selectDateSimple(context, form.fechaMama, form.fechaNacimiento.text, onChanged),
                        )),
                    ],
                    SizedBox(width: w, child: _select(label: 'Frecuencia de uso de servicios', icon: Icons.schedule_outlined, value: form.frecuenciaSalud, options: freqSaludOpts, onChanged: (v) { form.frecuenciaSalud = v; onChanged(); }, validator: requiredText)),
                    SizedBox(width: w, child: SumsTextField(controller: form.motivoSalud, label: 'Motivo de uso de servicios', icon: Icons.notes_outlined)),
                  ]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  String? _validateTamizajeDate(String? value, String birthDateStr) {
    final req = requiredText(value);
    if (req != null) return req;
    if (birthDateStr.trim().isEmpty) return null;
    try {
      final birthDate = DateTime.parse(birthDateStr);
      final tamizajeDate = DateTime.parse(value!);
      if (tamizajeDate.isBefore(birthDate)) {
        return 'No puede ser anterior al nacimiento';
      }
    } catch (_) {
      return 'Fecha inválida';
    }
    return null;
  }

  Future<void> _selectBirthDate(BuildContext context, TextEditingController controller, TextEditingController edadController, VoidCallback onChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      
      final now = DateTime.now();
      int anos = now.year - picked.year;
      if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) anos--;
      if (anos < 2) {
        int meses = (now.year - picked.year) * 12 + now.month - picked.month;
        if (now.day < picked.day) meses--;
        if (meses < 0) meses = 0;
        edadController.text = '$meses meses';
      } else {
        edadController.text = '$anos';
      }
      onChanged();
    }
  }

  Future<void> _selectDateSimple(BuildContext context, TextEditingController controller, String birthDateStr, VoidCallback onChanged) async {
    DateTime firstDate = DateTime(1900);
    if (birthDateStr.isNotEmpty) {
      try {
        firstDate = DateTime.parse(birthDateStr);
      } catch (_) {}
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().isBefore(firstDate) ? firstDate : DateTime.now(),
      firstDate: firstDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      onChanged();
    }
  }

  Widget _select({
    required String label, required IconData icon, required String? value,
    required List<String> options, required ValueChanged<String?> onChanged,
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

  Widget _daysField(TextEditingController c, String label) =>
      SumsTextField(
        controller: c, label: label,
        icon: Icons.calendar_view_week_outlined,
        helperText: '0 a 7 días', keyboardType: TextInputType.number,
        inputFormatters: digitsOnly,
        validator: (v) => requiredText(v) ?? intRange(0, 7)(v),
      );

  Widget _buildYesNo(BuildContext context, String label, bool value, ValueChanged<bool> onChange) =>
      InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: true,  label: Text('Sí')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected:           {value},
          onSelectionChanged: (s) => onChange(s.first),
        ),
      );

  Widget _chipGroup(BuildContext context, List<String> options, Set<String> selected) =>
      FormField<Set<String>>(
        initialValue: selected,
        validator: (val) => selected.isEmpty ? 'Seleccione una opción' : null,
        builder: (state) => InputDecorator(
          decoration: InputDecoration(
            labelText: '',
            errorText: state.errorText,
          ),
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              for (final o in options)
                FilterChip(
                  label:      Text(o),
                  selected:   selected.contains(o),
                  onSelected: (_) {
                    toggleSet(selected, o);
                    state.didChange(selected);
                  },
                ),
            ],
          ),
        ),
      );
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: AppColors.muted, letterSpacing: 1.0,
    ),
  );
}
