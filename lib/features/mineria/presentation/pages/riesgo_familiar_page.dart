import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/mineria_viewmodel.dart';

class RiesgoFamiliarPage extends StatefulWidget {
  const RiesgoFamiliarPage({super.key});

  @override
  State<RiesgoFamiliarPage> createState() => _RiesgoFamiliarPageState();
}

class _RiesgoFamiliarPageState extends State<RiesgoFamiliarPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MineriaViewModel>().loadRiesgo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MineriaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riesgo Familiar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: vm.isLoading ? null : () => vm.loadRiesgo(),
          ),
        ],
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(MineriaViewModel vm) {
    if (vm.isLoading && vm.riesgoList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(vm.errorMessage ?? 'Error al conectar con el servidor', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () => vm.loadRiesgo(), child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    if (vm.riesgoList.isEmpty) {
      return const Center(child: Text('No hay datos de riesgo disponibles.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.riesgoList.length,
      itemBuilder: (context, index) {
        final item = vm.riesgoList[index];
        final prob = item.probabilidadAlto;
        final percentage = (prob * 100).toStringAsFixed(1);
        
        Color riskColor = AppColors.green;
        if (prob > 0.7) {
          riskColor = AppColors.error;
        } else if (prob > 0.4) {
          riskColor = AppColors.warning;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: riskColor.withValues(alpha: 0.1),
              child: Icon(Icons.family_restroom, color: riskColor),
            ),
            title: Text(
              item.informanteNombre,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.greenDark),
            ),
            subtitle: Text(
              'Localidad: ${item.colonia}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: riskColor,
                  ),
                ),
                const Text(
                  'Prob. Riesgo',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
