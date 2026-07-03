import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import '../viewmodels/admin_unidades_viewmodel.dart';

class AdminUserFormPage extends StatefulWidget {
  final AdminUserEntity? user;
  
  const AdminUserFormPage({super.key, this.user});

  @override
  State<AdminUserFormPage> createState() => _AdminUserFormPageState();
}

class _AdminUserFormPageState extends State<AdminUserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();
  
  int _selectedRol = 3; // Encuestador por defecto
  int? _selectedUnidadId;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nombreController.text = widget.user!.nombreUsuario;
      _selectedRol = widget.user!.rolId;
      _selectedUnidadId = widget.user!.unidadSaludId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUnidadesViewModel>().fetchUnidades();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final vm = context.read<AdminUsersViewModel>();
    
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

    // Mostrar loader
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
    Navigator.pop(context); // Cerrar loader
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Usuario actualizado exitosamente' : 'Usuario creado exitosamente'),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.pop(context); // Regresar a la lista
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
    final unidadesVm = context.watch<AdminUnidadesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
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
                const Text('Datos de Acceso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    labelText: widget.user != null ? 'Contraseña (Opcional si no cambia)' : 'Contraseña (min 6 caracteres)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (widget.user != null && (v == null || v.isEmpty)) return null;
                    if (v == null || v.length < 6) return 'Minimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                const Text('Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedRol,
                  decoration: const InputDecoration(
                    labelText: 'Rol del Sistema',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Administrador')),
                    DropdownMenuItem(value: 2, child: Text('Médico')),
                    DropdownMenuItem(value: 4, child: Text('Encuestador')),
                    DropdownMenuItem(value: 3, child: Text('Analista')),
                  ],
                  onChanged: (v) => setState(() => _selectedRol = v!),
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
                    widget.user != null ? 'Actualizar Usuario' : 'Crear Usuario',
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
