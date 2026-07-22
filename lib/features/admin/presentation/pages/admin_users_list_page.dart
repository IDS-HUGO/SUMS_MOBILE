import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../../core/routes/app_routes.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import 'admin_user_form_page.dart';

class AdminUsersListPage extends ConsumerStatefulWidget {
  const AdminUsersListPage({super.key});
  @override
  ConsumerState<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends ConsumerState<AdminUsersListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUsersViewModelProvider).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(adminUsersViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: AppColors.rolAdmin,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.adminUserForm);
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
        final role = UserRole.fromId(user.rolId);
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            side: BorderSide(
              color: Theme.of(context).dividerTheme.color ?? AppColors.line,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: role.color,
              child: Icon(role.icon, color: Colors.white, size: 20),
            ),
            title: Text(
              user.nombreUsuario,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            subtitle: Text('ID: ${user.id} | Rol: ${role.displayName}'),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push(AppRoutes.adminUserForm, extra: user);
                } else if (value == 'toggle') {
                  final success = await ref
                      .read(adminUsersViewModelProvider)
                      .toggleUserStatus(user.id, user.activo);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          user.activo
                              ? 'Usuario desactivado'
                              : 'Usuario activado',
                        ),
                        backgroundColor: AppColors.green,
                      ),
                    );
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
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        user.activo ? Icons.block : Icons.check_circle_outline,
                        size: 20,
                        color: user.activo ? Colors.red : AppColors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(user.activo ? 'Desactivar' : 'Activar'),
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
