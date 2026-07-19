import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';

import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/cedula_viewmodel.dart';

class PendingCapturesPage extends ConsumerStatefulWidget {
  const PendingCapturesPage({super.key});

  @override
  ConsumerState<PendingCapturesPage> createState() =>
      _PendingCapturesPageState();
}

class _PendingCapturesPageState extends ConsumerState<PendingCapturesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cedulaViewModelProvider).refreshSyncCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturas pendientes')),
      body: Consumer(
        builder: (context, ref, child) {
          final vm = ref.watch(cedulaViewModelProvider);
          final pending = vm.allLocalRecords
              .where((r) => r['_syncStatus'] == 1)
              .toList();

          if (pending.isEmpty) {
            return const Center(
              child: Text('No hay capturas pendientes por sincronizar.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final record = pending[index];
              return Card(
                child: ListTile(
                  title: Text(record['_informante'] ?? 'Sin nombre'),
                  subtitle: Text('Guardado el: ${record['_createdAt']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sync, color: AppColors.green),
                        onPressed: () => vm.retrySyncSingle(record['_localId']),
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
