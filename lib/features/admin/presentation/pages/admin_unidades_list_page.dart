import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/admin_unidades_viewmodel.dart';
import 'admin_unidad_form_page.dart';

class AdminUnidadesListPage extends StatefulWidget {
  const AdminUnidadesListPage({super.key});

  @override
  State<AdminUnidadesListPage> createState() => _AdminUnidadesListPageState();
}

class _AdminUnidadesListPageState extends State<AdminUnidadesListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUnidadesViewModel>().fetchUnidades();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminUnidadesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
              child: Icon(Icons.local_hospital, color: AppColors.greenDark, size: 20),
            ),
            title: Text(
              unidad.nombre,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            subtitle: Text('CLUES: ${unidad.clues}'),
          ),
        );
      },
    );
  }
}
