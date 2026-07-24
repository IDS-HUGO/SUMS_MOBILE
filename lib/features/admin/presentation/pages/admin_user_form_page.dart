import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import '../viewmodels/admin_unidades_viewmodel.dart';

class AdminUserFormPage extends ConsumerStatefulWidget {
  final AdminUserEntity? user;
  const AdminUserFormPage({super.key, this.user});
  @override
  ConsumerState<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends ConsumerState<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedRol = 3;
  int? _selectedUnidadId;

  List<CatalogItem> _roles = [];
  bool _isLoadingRoles = true;
  String? _rolesError;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nombreController.text = widget.user!.nombreUsuario;
      _selectedRol = widget.user!.rolId;
      _selectedUnidadId = widget.user!.unidadSaludId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminUnidadesViewModelProvider).fetchUnidades();
      _loadRoles();
    });
  }

  Future<void> _loadRoles() async {
    try {
      final catalogosVm = ref.read(adminCatalogosViewModelProvider);
      final repo = catalogosVm.repository;
      final rolesCatalog = await repo.getCatalog('roles');
      if (mounted) {
        setState(() {
          _roles = rolesCatalog;
          _isLoadingRoles = false;
          // If no user is being edited and roles loaded,
          // default to the first available role if current default not in list
          if (widget.user == null && _roles.isNotEmpty) {
            final ids = _roles.map((r) => r.id).toSet();
            if (!ids.contains(_selectedRol)) {
              _selectedRol = _roles.last.id; // default to last (lowest privilege)
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _rolesError = e.toString();
          _isLoadingRoles = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(adminUsersViewModelProvider);
    final body = <String, dynamic>{
      'nombre_usuario': _nombreController.text.trim(),
      'rol_id': _selectedRol,
    };
    if (_passwordController.text.isNotEmpty) {
      body['contrasena'] = _passwordController.text;
    }
    if (widget.user == null) {
      body['activo'] = true;
    }
    if (_selectedUnidadId != null) {
      body['unidad_salud_id'] = _selectedUnidadId!;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final isEditing = widget.user != null;
    final success = isEditing
        ? await vm.updateUser(widget.user!.id, body)
        : await vm.createUser(body);
    if (!mounted) return;
    context.pop();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Usuario actualizado exitosamente'
                : 'Usuario creado exitosamente',
          ),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al guardar usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unidadesVm = ref.watch(adminUnidadesViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user != null ? 'Editar Usuario' : 'Nuevo Usuario'),
        backgroundColor: AppColors.rolAdmin,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Datos de Acceso',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de Usuario',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: widget.user != null
                        ? 'Contraseña (Opcional si no cambia)'
                        : 'Contraseña (min 8 caracteres, mayúsculas, minúsculas y números)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (widget.user != null && (v == null || v.isEmpty))
                      return null;
                    if (v == null || v.length < 8) return 'Mínimo 8 caracteres';
                    final hasUpper = RegExp(r'[A-Z]').hasMatch(v);
                    final hasLower = RegExp(r'[a-z]').hasMatch(v);
                    final hasDigit = RegExp(r'[0-9]').hasMatch(v);
                    if (!hasUpper || !hasLower || !hasDigit) {
                      return 'Debe incluir mayúsculas, minúsculas y números';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Perfil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _isLoadingRoles
                    ? const Center(child: CircularProgressIndicator())
                    : _roles.isEmpty && _rolesError != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Error al cargar roles: $_rolesError',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _loadRoles,
                                icon: const Icon(Icons.refresh, size: 16),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          )
                        : DropdownButtonFormField<int>(
                            value: _roles.any((r) => r.id == _selectedRol) ? _selectedRol : null,
                            decoration: const InputDecoration(
                              labelText: 'Rol del Sistema',
                              border: OutlineInputBorder(),
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem<int>(
                                value: role.id,
                                child: Text(role.nombre),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedRol = v!),
                            validator: (v) => v == null ? 'Selecciona un rol' : null,
                          ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedUnidadId,
                  decoration: const InputDecoration(
                    labelText: 'Unidad de Salud (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                  items: unidadesVm.unidades.map((u) {
                    return DropdownMenuItem<int>(
                      value: u.id,
                      child: Text(u.nombre),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedUnidadId = v),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rolAdmin,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.user != null
                        ? 'Actualizar Usuario'
                        : 'Crear Usuario',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
