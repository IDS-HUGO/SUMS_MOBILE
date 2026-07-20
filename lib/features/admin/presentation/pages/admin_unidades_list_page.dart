import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';

import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/admin_unidades_viewmodel.dart';
import 'admin_unidad_form_page.dart';

class AdminUnidadesListPage extends ConsumerStatefulWidget {
  const AdminUnidadesListPage({super.key});

  @override
  ConsumerState<AdminUnidadesListPage> createState() =>
      _AdminUnidadesListPageState();
}

class _AdminUnidadesListPageState extends ConsumerState<AdminUnidadesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUnidadesViewModelProvider).fetchUnidades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(adminUnidadesViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unidades de Salud'),
        backgroundColor: AppColors.green,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUnidadFormPage()),
          );
        },
        backgroundColor: AppColors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(AdminUnidadesViewModel vm) {
    if (vm.status == AdminUnidadesStatus.loading && vm.unidades.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.status == AdminUnidadesStatus.error && vm.unidades.isEmpty) {
      return Center(
        child: Text(
          'Error: ${vm.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (vm.unidades.isEmpty) {
      return const Center(child: Text('No hay unidades registradas'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.unidades.length,
      itemBuilder: (context, index) {
        final unidad = vm.unidades[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            side: const BorderSide(color: AppColors.line),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.greenLight,
              child: Icon(
                Icons.local_hospital,
                color: AppColors.greenDark,
                size: 20,
              ),
            ),
            title: Text(
              unidad.nombre,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            subtitle: Text('CLUES: ${unidad.clues}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminUnidadFormPage(unidad: unidad),
                    ),
                  );
                } else if (value == 'delete') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar Unidad'),
                      content: Text(
                        '¿Estás seguro de eliminar ${unidad.nombre}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final success = await ref
                        .read(adminUnidadesViewModelProvider)
                        .deleteUnidad(unidad.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Unidad eliminada'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                    }
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: AppColors.ink),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
