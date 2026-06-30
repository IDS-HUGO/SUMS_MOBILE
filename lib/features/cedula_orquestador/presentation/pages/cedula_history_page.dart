import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/cedula_viewmodel.dart';

class CedulaHistoryPage extends StatefulWidget {
  const CedulaHistoryPage({super.key});

  @override
  State<CedulaHistoryPage> createState() => _CedulaHistoryPageState();
}

class _CedulaHistoryPageState extends State<CedulaHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CedulaViewModel>().refreshSyncCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Capturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CedulaViewModel>().refreshSyncCounts(),
          ),
        ],
      ),
      body: Consumer<CedulaViewModel>(
        builder: (context, vm, child) {
          if (vm.allLocalRecords.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_edu_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay registros locales aún', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.allLocalRecords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = vm.allLocalRecords[index];
              return _CedulaHistoryCard(record: record);
            },
          );
        },
      ),
    );
  }
}

class _CedulaHistoryCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _CedulaHistoryCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final status = record['_syncStatus'] as int; // 0=DRAFT, 1=PENDING, 2=SYNCED
    final informante = record['_informante'] ?? 'Sin nombre';
    final fechaStr = record['_createdAt'] ?? '';
    final error = record['_lastSyncError'] as String?;
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 0:
        statusColor = Colors.orange;
        statusText = 'Borrador';
        statusIcon = Icons.edit_note;
        break;
      case 1:
        statusColor = error != null ? Colors.red : AppColors.terracota;
        statusText = error != null ? 'Error de Sinc.' : 'Pendiente';
        statusIcon = error != null ? Icons.error_outline : Icons.sync_problem;
        break;
      case 2:
        statusColor = AppColors.green;
        statusText = 'Sincronizado';
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
        statusIcon = Icons.help_outline;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  fechaStr.substring(0, 10),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              informante,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (error != null && status == 1) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
            ],
            if (status == 1) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    final vm = context.read<CedulaViewModel>();
                    final result = await vm.retrySyncSingle(record['_localId']);
                    if (!context.mounted) return;
                    if (result.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sincronizado correctamente'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${result.error}'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Reintentar Sincronización'),
                  style: FilledButton.styleFrom(
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
