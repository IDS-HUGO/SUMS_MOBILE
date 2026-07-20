import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/ocr_field.dart';
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
      ref
          .read(mineriaViewModelProvider)
          .setFile(File(result.files.single.path!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(mineriaViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minería OCR'),
        actions: [
          if (vm.result != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: vm.reset,
              tooltip: 'Procesar otro',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHealthStatus(vm.healthOk),
          Expanded(
            child: vm.result != null ? _buildResults(vm) : _buildUploadZone(vm),
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
                ? 'Microservicio OCR disponible'
                : 'Microservicio OCR no disponible',
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
                  label: const Text('Procesar OCR'),
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.line),
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
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final key = res.campos.keys.elementAt(index);
              final field = res.campos[key]!;
              return _FieldCard(field: field);
            }, childCount: res.campos.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
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
  final OcrField field;
  const _FieldCard({required this.field});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = field.needsReview
        ? AppColors.error
        : (field.confidence < 0.8 ? AppColors.gold : AppColors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  field.key.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.muted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      field.needsReview
                          ? Icons.warning_amber
                          : Icons.check_circle_outline,
                      size: 10,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(field.confidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            field.value.isEmpty ? '[Vacío]' : field.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: field.value.isEmpty ? AppColors.muted : AppColors.ink,
            ),
          ),
          if (field.needsReview)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '⚠ Requiere revisión manual',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
