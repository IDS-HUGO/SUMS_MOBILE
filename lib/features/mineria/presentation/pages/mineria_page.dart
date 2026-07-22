import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/vacuna_aplicada.dart';
import '../utils/mineria_validators.dart';
import '../viewmodels/mineria_viewmodel.dart';

class MineriaPage extends ConsumerStatefulWidget {
  const MineriaPage({super.key});
  @override
  ConsumerState<MineriaPage> createState() => _MineriaPageState();
}

class _MineriaPageState extends ConsumerState<MineriaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mineriaViewModelProvider).init();
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      await ref
          .read(mineriaViewModelProvider)
          .setFile(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(mineriaViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Captura de Cédula (PDF)'),
        actions: [
          if (vm.result != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: vm.reset,
              tooltip: 'Escanear otra',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHealthStatus(vm.healthOk),
          Expanded(
            child: vm.result != null
                ? Form(key: vm.formKey, child: _buildResults(vm))
                : _buildUploadZone(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatus(bool ok) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: ok
          ? AppColors.green.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: ok ? AppColors.green : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            ok
                ? 'Conexión establecida con el servidor'
                : 'Sin conexión con el servidor de escaneo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ok ? AppColors.green : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone(MineriaViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 80,
              color: vm.selectedFile != null
                  ? AppColors.green
                  : AppColors.muted,
            ),
            const SizedBox(height: 16),
            if (vm.selectedFile != null) ...[
              Text(
                vm.selectedFile!.path.split('/').last,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Archivo listo para procesar',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ] else
              const Text(
                'Selecciona el PDF de la cédula',
                style: TextStyle(fontSize: 16, color: AppColors.ink),
              ),
            const SizedBox(height: 32),
            if (vm.isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.file_open),
                label: const Text('Seleccionar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 12),
              if (vm.selectedFile != null)
                ElevatedButton.icon(
                  onPressed: vm.healthOk ? vm.procesar : null,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Comenzar Escaneo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                ),
            ],
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(MineriaViewModel vm) {
    final res = vm.result!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.dividerTheme.color ?? AppColors.line,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen de Extracción',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.greenDark,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow('ID Documento', res.docId),
                          _buildInfoRow('Archivo', res.archivoOriginal),
                          _buildInfoRow('Páginas', res.nPaginas.toString()),
                          _buildInfoRow(
                            'Total Campos',
                            res.resumen.totalCampos.toString(),
                          ),
                          _buildInfoRow(
                            'Requieren Revisión',
                            res.resumen.necesitanRevision.toString(),
                            color: res.resumen.necesitanRevision > 0
                                ? AppColors.error
                                : AppColors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'CAMPOS EXTRAÍDOS (EDITE SI ES NECESARIO)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final key = vm.controllers.keys.elementAt(index);
                    final controller = vm.controllers[key];
                    return _FieldCard(fieldKey: key, controller: controller);
                  }, childCount: vm.controllers.length),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'ESQUEMA DE VACUNACIÓN (MANUAL)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _ManualVaccineCard(
                      index: index,
                      vacuna: vm.vacunasSeleccionadas[index],
                      vacunasOpts: vm.vacunasOpts,
                      dosisOpts: vm.dosisOpts,
                      onRemove: () => vm.removeVacuna(index),
                      onChanged: (v, d) =>
                          vm.updateVacuna(index, vacuna: v, dosis: d),
                    );
                  }, childCount: vm.vacunasSeleccionadas.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: vm.addVacuna,
                    icon: const Icon(Icons.add),
                    label: const Text('AGREGAR VACUNA'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        _buildBottomActions(vm),
      ],
    );
  }

  Widget _buildBottomActions(MineriaViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: vm.isSaving ? null : () => _handleSave(vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: vm.isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'GUARDAR DATOS EXTRAÍDOS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
        ),
      ),
    );
  }

  Future<void> _handleSave(MineriaViewModel vm) async {
    final success = await vm.guardarCambios();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Datos guardados correctamente.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al intentar guardar los datos.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color ?? AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String fieldKey;
  final TextEditingController? controller;
  const _FieldCard({required this.fieldKey, this.controller});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? Colors.grey[400] : AppColors.muted;
    final label = fieldKey
        .toUpperCase()
        .replaceAll('.', ' > ')
        .replaceAll('_', ' ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: mutedColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            validator: (value) => MineriaValidators.validate(fieldKey, value),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              filled: true,
              fillColor: theme.canvasColor.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color:
                      theme.dividerTheme.color?.withOpacity(0.5) ??
                      AppColors.line.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.green,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.error,
                  width: 1.5,
                ),
              ),
              hintText: 'Pendiente de capturar...',
              hintStyle: const TextStyle(color: AppColors.subtle, fontSize: 13),
            ),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyLarge?.color ?? AppColors.ink,
            ),
            maxLines: null,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }
}

class _ManualVaccineCard extends StatelessWidget {
  final int index;
  final VacunaAplicada vacuna;
  final List<String> vacunasOpts;
  final List<String> dosisOpts;
  final VoidCallback onRemove;
  final Function(String?, String?) onChanged;
  const _ManualVaccineCard({
    required this.index,
    required this.vacuna,
    required this.vacunasOpts,
    required this.dosisOpts,
    required this.onRemove,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VACUNA ${index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.burgundy,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.error,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: vacuna.vacuna,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Vacuna',
              isDense: true,
            ),
            items: vacunasOpts
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => onChanged(v, vacuna.dosis),
            validator: (v) => v == null ? 'Seleccione vacuna' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: vacuna.dosis,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Dosis',
              isDense: true,
            ),
            items: dosisOpts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (d) => onChanged(vacuna.vacuna, d),
            validator: (v) => v == null ? 'Seleccione dosis' : null,
          ),
        ],
      ),
    );
  }
}
