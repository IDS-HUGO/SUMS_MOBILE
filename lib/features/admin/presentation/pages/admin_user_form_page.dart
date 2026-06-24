import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/admin_users_viewmodel.dart';
import '../viewmodels/admin_unidades_viewmodel.dart';

class AdminUserFormPage extends StatefulWidget {
  const AdminUserFormPage({super.key});

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
    
    final body = {
      'nombre_usuario': _nombreController.text.trim(),
      'contrasena': _passwordController.text,
      'rol_id': _selectedRol,
      'activo': true,
    };
    
    if (_selectedUnidadId != null) {
      body['unidad_salud_id'] = _selectedUnidadId!;
    }

    // Mostrar loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await vm.createUser(body);
    
    if (!mounted) return;
    Navigator.pop(context); // Cerrar loader
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado exitosamente'), backgroundColor: AppColors.green),
      );
      Navigator.pop(context); // Regresar a la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Error al crear usuario'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unidadesVm = context.watch<AdminUnidadesViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Nuevo Usuario'),
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
                  decoration: const InputDecoration(
                    labelText: 'Contraseña (min 6 caracteres)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.length < 6 ? 'Minimo 6 caracteres' : null,
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
                    DropdownMenuItem(value: 3, child: Text('Encuestador')),
                    DropdownMenuItem(value: 4, child: Text('Analista')),
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
                  child: const Text('Crear Usuario', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
