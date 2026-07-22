import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../../../cedula_orquestador/presentation/widgets/form_helpers.dart';
import '../viewmodels/familia_viewmodel.dart';
import '../../../integrantes/presentation/viewmodels/integrantes_viewmodel.dart';

/// Categorías rápidas de observaciones de la visita. Cada frase base es la
/// misma usada en todo el sistema (móvil y demás consumidores del backend);
/// al tocar el chip correspondiente se anexa tal cual a las observaciones,
/// sin usar ninguna variante.
class _ObservacionCategoria {
  final String label;
  final IconData icon;
  final String frase;
  const _ObservacionCategoria(this.label, this.icon, this.frase);
}

const _observacionCategorias = [
  _ObservacionCategoria(
    'Seguimiento',
    Icons.event_repeat_outlined,
    'Se requiere visita de seguimiento la próxima semana.',
  ),
  _ObservacionCategoria(
    'Enfermedad rara',
    Icons.health_and_safety_outlined,
    'Se observó un padecimiento inusual que requiere valoración médica.',
  ),
  _ObservacionCategoria(
    'Embarazo',
    Icons.pregnant_woman_outlined,
    'Hay una integrante embarazada, dar seguimiento prenatal.',
  ),
  _ObservacionCategoria(
    'Vacunas pendientes',
    Icons.vaccines_outlined,
    'Faltan dosis de vacunación, llevar cartilla la próxima visita.',
  ),
  _ObservacionCategoria(
    'Vivienda en mal estado',
    Icons.house_outlined,
    'Vivienda con materiales precarios, requiere atención.',
  ),
  _ObservacionCategoria(
    'Mascota sin vacunar',
    Icons.pets_outlined,
    'Hay mascotas sin vacunación al corriente en el hogar.',
  ),
];

String? _observacionesValidator(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty || v.length < 15) {
    return 'Describe algo específico de la visita (mínimo 15 caracteres).';
  }
  return null;
}

class FamiliaStepWidget extends ConsumerWidget {
  const FamiliaStepWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(familiaViewModelProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepPanel(
            title: 'III. Identificación de la familia',
            icon: Icons.groups_outlined,
            color: AppColors.green,
            children: [
              _fieldGrid([
                SumsTextField(
                  controller: vm.informanteNombre,
                  label: 'Nombre del informante',
                  icon: Icons.person_outline,
                  validator: requiredText,
                  maxLength: 100,
                  inputFormatters: nameInputFormatters,
                  onChanged: (v) {
                    final intVm = ref.read(integrantesViewModelProvider);
                    if (intVm.integrantes.isNotEmpty) {
                      intVm.integrantes[0].nombre.text = v;
                      intVm.updateForm();
                    }
                  },
                ),
                _select(
                  label: 'Sexo del informante',
                  icon: Icons.wc_outlined,
                  value: vm.informanteSexo,
                  options: const ['Masculino', 'Femenino'],
                  onChanged: (v) {
                    vm.setSexo(v);
                    final intVm = ref.read(integrantesViewModelProvider);
                    if (intVm.integrantes.isNotEmpty) {
                      intVm.integrantes[0].sexo = v;
                      intVm.updateForm();
                    }
                  },
                  validator: requiredText,
                ),
                _select(
                  label: 'Rol familiar',
                  icon: Icons.diversity_3_outlined,
                  value: vm.rolInformante,
                  options: vm.roles,
                  onChanged: (v) {
                    vm.setRol(v);
                    final intVm = ref.read(integrantesViewModelProvider);
                    if (intVm.integrantes.isNotEmpty) {
                      intVm.integrantes[0].parentesco = v;
                      intVm.updateForm();
                    }
                  },
                  isLoading: vm.isLoadingRoles,
                  validator: requiredText,
                ),
                SumsTextField(
                  controller: vm.domicilio,
                  label: 'Domicilio',
                  icon: Icons.location_on_outlined,
                  validator: requiredText,
                  maxLength: 120,
                  inputFormatters: freeTextInputFormatters,
                ),
                SumsTextField(
                  controller: vm.localidad,
                  label: 'Localidad',
                  icon: Icons.location_city_outlined,
                  maxLength: 80,
                  inputFormatters: freeTextInputFormatters,
                ),
                SumsTextField(
                  controller: vm.manzana,
                  label: 'Manzana',
                  icon: Icons.grid_view_outlined,
                  maxLength: 20,
                  inputFormatters: freeTextInputFormatters,
                ),
                SumsTextField(
                  controller: vm.viviendaRef,
                  label: 'Vivienda',
                  icon: Icons.home_work_outlined,
                  maxLength: 60,
                  inputFormatters: freeTextInputFormatters,
                ),
              ]),
            ],
          ),
          const SizedBox(height: 14),
          _StepPanel(
            title: 'Observaciones de la Visita',
            icon: Icons.notes_outlined,
            color: AppColors.gold,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in _observacionCategorias)
                    Tooltip(
                      message: cat.frase,
                      child: ActionChip(
                        avatar: Icon(cat.icon, size: 16),
                        label: Text(cat.label),
                        onPressed: () => vm.appendObservacion(cat.frase),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SumsTextField(
                controller: vm.observaciones,
                label: 'Observaciones de la Visita',
                icon: Icons.notes_outlined,
                minLines: 3,
                maxLines: 6,
                maxLength: 300,
                inputFormatters: freeTextInputFormatters,
                validator: _observacionesValidator,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (_, c) {
        if (c.maxWidth < 720) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }
        final w = (c.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children) SizedBox(width: w, child: child),
          ],
        );
      },
    );
  }

  Widget _select({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
    String? Function(String?)? validator,
  }) => DropdownButtonFormField<String>(
    isExpanded: true,
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: isLoading
          ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Icon(icon),
    ),
    items: options
        .map(
          (o) => DropdownMenuItem(
            value: o,
            child: Text(o, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: onChanged,
    validator: validator,
  );
}

class _StepPanel extends ConsumerWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const _StepPanel({
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: color == AppColors.green
                          ? AppColors.greenDark
                          : color,
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
