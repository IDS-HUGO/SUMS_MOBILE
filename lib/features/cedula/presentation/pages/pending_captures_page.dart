import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import 'package:sums/features/cedula/domain/entities/pending_cedula.dart';
import '../viewmodels/cedula_viewmodel.dart';
import 'cedula_form_page.dart';

class PendingCapturesPage extends StatefulWidget {
  const PendingCapturesPage({super.key});

  @override
  State<PendingCapturesPage> createState() => _PendingCapturesPageState();
}

class _PendingCapturesPageState extends State<PendingCapturesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CedulaViewModel>().loadPendingRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturas pendientes')),
      body: Consumer<CedulaViewModel>(
        builder: (context, vm, child) {
          if (vm.pendingRecords.isEmpty) {
            return const Center(
              child: Text('No hay capturas pendientes por sincronizar.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.pendingRecords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = vm.pendingRecords[index];
              return Card(
                child: ListTile(
                  title: Text(record.informanteNombre ?? 'Sin nombre'),
                  subtitle: Text(
                    'Estado: ${record.status.name} • Guardado el: ${record.createdAt.day}/${record.createdAt.month}/${record.createdAt.year}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.gold),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CedulaFormPage(initialRecord: record),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.sync, color: AppColors.green),
                        onPressed: () => vm.syncRecord(record, '/cedulas'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.burgundy),
                        onPressed: () => vm.deleteLocal(record.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
