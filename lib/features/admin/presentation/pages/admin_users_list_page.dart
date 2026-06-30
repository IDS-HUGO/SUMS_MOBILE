import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import 'admin_user_form_page.dart';

class AdminUsersListPage extends StatefulWidget {
  const AdminUsersListPage({super.key});

  @override
  State<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends State<AdminUsersListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersViewModel>().fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminUsersViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: AppColors.rolAdmin,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUserFormPage()),
          );
        },
        backgroundColor: AppColors.rolAdmin,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(AdminUsersViewModel vm) {
    if (vm.status == AdminUsersStatus.loading && vm.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.status == AdminUsersStatus.error && vm.users.isEmpty) {
      return Center(
        child: Text(
          'Error: ${vm.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (vm.users.isEmpty) {
      return const Center(child: Text('No hay usuarios registrados'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.users.length,
      itemBuilder: (context, index) {
        final user = vm.users[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            side: const BorderSide(color: AppColors.line),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRoleColor(user.rolId),
              child: Icon(_getRoleIcon(user.rolId), color: Colors.white, size: 20),
            ),
            title: Text(
              user.nombreUsuario,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
            subtitle: Text('ID: ${user.id} | Rol: ${_getRoleName(user.rolId)}'),
            trailing: user.activo
                ? const Icon(Icons.check_circle, color: AppColors.green, size: 20)
                : const Icon(Icons.cancel, color: Colors.red, size: 20),
          ),
        );
      },
    );
  }

  Color _getRoleColor(int rolId) {
    switch (rolId) {
      case 1: return AppColors.rolAdmin;
      case 2: return AppColors.rolMedico;
      case 3: return AppColors.rolEncuestador;
      case 4: return AppColors.rolAnalista;
      default: return AppColors.muted;
    }
  }

  IconData _getRoleIcon(int rolId) {
    switch (rolId) {
      case 1: return Icons.admin_panel_settings;
      case 2: return Icons.medical_services;
      case 3: return Icons.assignment_ind;
      case 4: return Icons.analytics;
      default: return Icons.person;
    }
  }

  String _getRoleName(int rolId) {
    switch (rolId) {
      case 1: return 'Administrador';
      case 2: return 'Médico';
      case 4: return 'Encuestador';
      case 3: return 'Analista';
      default: return 'Desconocido';
    }
  }
}
