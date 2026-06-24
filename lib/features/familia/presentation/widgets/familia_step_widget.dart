import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../../../cedula_orquestador/presentation/widgets/form_helpers.dart';
import '../viewmodels/familia_viewmodel.dart';

class FamiliaStepWidget extends StatelessWidget {
  const FamiliaStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FamiliaViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _StepPanel(
      title: 'III. Identificación de la familia',
      icon: Icons.groups_outlined,
      color: AppColors.green,
      children: [
        _fieldGrid([
          SumsTextField(
            controller: vm.informanteNombre,
            label: 'Nombre del informante',
            icon: Icons.person_outline,
          ),
          _numberField(
            vm.informanteEdad,
            'Edad del informante',
            Icons.cake_outlined,
          ),
          _select(
            label: 'Rol familiar',
            icon: Icons.diversity_3_outlined,
            value: vm.rolInformante,
            options: vm.roles,
            onChanged: vm.setRol,
            isLoading: vm.isLoadingRoles,
          ),
          SumsTextField(
            controller: vm.domicilio,
            label: 'Domicilio',
            icon: Icons.location_on_outlined,
          ),
          SumsTextField(
            controller: vm.localidad,
            label: 'Localidad',
            icon: Icons.location_city_outlined,
          ),
          SumsTextField(
            controller: vm.manzana,
            label: 'Manzana',
            icon: Icons.grid_view_outlined,
          ),
          SumsTextField(
            controller: vm.viviendaRef,
            label: 'Vivienda',
            icon: Icons.home_work_outlined,
          ),
        ]),
      ],
    ));
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(builder: (_, c) {
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
        children: [for (final child in children) SizedBox(width: w, child: child)],
      );
    });
  }

  Widget _numberField(TextEditingController c, String label, IconData icon) =>
      SumsTextField(
        controller: c,
        label: label,
        icon: icon,
        keyboardType: TextInputType.number,
        validator: nonNegativeIntText,
      );

  Widget _select({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
  }) =>
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : Icon(icon),
        ),
        items: options
            .map((o) => DropdownMenuItem(
                value: o, child: Text(o, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
      );
}

class _StepPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
