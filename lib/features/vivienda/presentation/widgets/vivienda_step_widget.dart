import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../../../cedula_orquestador/presentation/widgets/form_helpers.dart';
import '../viewmodels/vivienda_viewmodel.dart';

class ViviendaStepWidget extends StatelessWidget {
  const ViviendaStepWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ViviendaViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepPanel(
          title: 'IV. Características de la vivienda',
          icon: Icons.home_outlined,
          color: AppColors.terracota,
          children: [
            _fieldGrid([
              _select(
                label: 'Techo',
                icon: Icons.roofing_outlined,
                value: vm.techo,
                options: vm.matTechoParedesOpts,
                onChanged: vm.setTecho,
                isLoading: vm.isLoadingCatalogs,
              ),
              _select(
                label: 'Paredes',
                icon: Icons.foundation_outlined,
                value: vm.paredes,
                options: vm.matTechoParedesOpts,
                onChanged: vm.setParedes,
                isLoading: vm.isLoadingCatalogs,
              ),
              _select(
                label: 'Piso',
                icon: Icons.square_foot_outlined,
                value: vm.piso,
                options: vm.matPisoOpts,
                onChanged: vm.setPiso,
                isLoading: vm.isLoadingCatalogs,
              ),
              SumsTextField(
                controller: vm.materialOtros,
                label: 'Otros materiales, especificar',
                icon: Icons.edit_outlined,
              ),
              _numberField(
                vm.cuartos,
                'Número de cuartos',
                Icons.meeting_room_outlined,
              ),
              _numberField(
                vm.habitantes,
                'Número de habitantes',
                Icons.people_outline,
              ),
            ]),
            const SizedBox(height: 14),
            _sectionDivider('Servicios básicos'),
            const SizedBox(height: 12),
            _toggleGrid([
              _yesNo('Agua entubada', vm.aguaEntubada, vm.setAguaEntubada),
              _yesNo('Energía eléctrica', vm.energiaElect, vm.setEnergiaElect),
              _yesNo('Cocción con leña', vm.coccionLena, vm.setCoccionLena),
            ]),
            const SizedBox(height: 14),
            _fieldGrid([
              _select(
                label: 'Ubicación de cocina',
                icon: Icons.restaurant_outlined,
                value: vm.cocina,
                options: vm.cocinasOpts,
                onChanged: vm.setCocina,
                isLoading: vm.isLoadingCatalogs,
              ),
              _select(
                label: 'Manejo de excretas',
                icon: Icons.wc_outlined,
                value: vm.excretas,
                options: vm.excretasOpts,
                onChanged: vm.setExcretas,
                isLoading: vm.isLoadingCatalogs,
              ),
            ]),
            const SizedBox(height: 14),
            _toggleGrid([
              _yesNo('Red de alcantarillado', vm.alcantarillado, vm.setAlcantarillado),
              _yesNo('Fosa séptica', vm.fosaSeptica, vm.setFosaSeptica),
            ]),
          ],
        ),
        const SizedBox(height: 14),
        _StepPanel(
          title: 'Convivencia con animales',
          icon: Icons.pets_outlined,
          color: AppColors.gold,
          children: [
            _toggleGrid([
              _yesNo('Perros y/o gatos dentro', vm.perrosGatos, vm.setPerrosGatos),
              _yesNo('Vacunas corrientes', vm.animVacunas, vm.setAnimVacunas),
              _yesNo('Mascotas esterilizadas', vm.esterilizados, vm.setEsterilizados),
            ]),
            const SizedBox(height: 14),
            if (vm.isLoadingCatalogs)
              const Center(child: CircularProgressIndicator())
            else
              _chipGroup(
                label: 'Otros animales',
                options: vm.otrosAnimalesOpts,
                selected: vm.otrosAnimales,
                onToggle: vm.toggleOtroAnimal,
              ),
            const SizedBox(height: 12),
            _fieldGrid([
              SumsTextField(
                controller: vm.animalOtro,
                label: 'Otros, especificar',
                icon: Icons.edit_outlined,
              ),
              SumsTextField(
                controller: vm.animalObs,
                label: 'Observaciones',
                icon: Icons.notes_outlined,
                minLines: 2,
                maxLines: 4,
              ),
            ]),
          ],
        ),
      ],
    ));
  }

  // ── Helpers locales ─────────────────────────────────────────────────────────

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
        spacing: 12, runSpacing: 12,
        children: [for (final child in children) SizedBox(width: w, child: child)],
      );
    });
  }

  Widget _toggleGrid(List<Widget> children) {
    return LayoutBuilder(builder: (_, c) {
      final cols = c.maxWidth >= 900 ? 3 : c.maxWidth >= 560 ? 2 : 1;
      final w = (c.maxWidth - 12 * (cols - 1)) / cols;
      return Wrap(
        spacing: 12, runSpacing: 12,
        children: [for (final child in children) SizedBox(width: w, child: child)],
      );
    });
  }

  Widget _sectionDivider(String label) => Row(
        children: [
          Expanded(child: Divider(color: AppColors.line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.muted, letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.line)),
        ],
      );

  Widget _select({
    required String label, required IconData icon,
    required String? value, required List<String> options,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
  }) =>
      DropdownButtonFormField<String>(
        isExpanded:    true,
        initialValue:  value,
        decoration:    InputDecoration(
          labelText: label, 
          prefixIcon: isLoading 
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                      width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : Icon(icon)
        ),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis))).toList(),
        onChanged:     onChanged,
      );

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

  Widget _chipGroup({
    required String label, required List<String> options,
    required Set<String> selected, required ValueChanged<String> onToggle,
  }) =>
      InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (final o in options)
              FilterChip(
                label:    Text(o),
                selected: selected.contains(o),
                onSelected: (_) => onToggle(o),
              ),
          ],
        ),
      );

  Widget _numberField(TextEditingController c, String label, IconData icon) =>
      SumsTextField(
        controller: c, label: label, icon: icon,
        keyboardType: TextInputType.number,
        validator: nonNegativeIntText,
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
