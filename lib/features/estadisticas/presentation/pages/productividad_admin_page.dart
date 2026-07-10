import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/estadisticas_viewmodel.dart';

class ProductividadAdminPage extends StatefulWidget {
  const ProductividadAdminPage({super.key});

  @override
  State<ProductividadAdminPage> createState() => _ProductividadAdminPageState();
}

class _ProductividadAdminPageState extends State<ProductividadAdminPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EstadisticasViewModel>().fetchProductividad();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EstadisticasViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Productividad de Entrevistadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => vm.fetchProductividad(),
          ),
        ],
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(EstadisticasViewModel vm) {
    if (vm.isProductividadLoading && vm.productividad.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.productividadError != null && vm.productividad.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar productividad',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                vm.productividadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => vm.fetchProductividad(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchProductividad(),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.greenDark.withOpacity(0.05)),
            columns: const [
              DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Entrevistador', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Hoy', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Semana', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Mes', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Última Act.', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(vm.productividad.length, (index) {
              final p = vm.productividad[index];
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text('${p.hoy}')),
                  DataCell(Text('${p.semana}')),
                  DataCell(Text('${p.mes}')),
                  DataCell(Text('${p.total}')),
                  DataCell(Text(_formatDate(p.ultimaActividad))),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
