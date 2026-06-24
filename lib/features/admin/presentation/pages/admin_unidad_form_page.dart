import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/admin_unidades_viewmodel.dart';

class AdminUnidadFormPage extends StatefulWidget {
  const AdminUnidadFormPage({super.key});

  @override
  State<AdminUnidadFormPage> createState() => _AdminUnidadFormPageState();
}

class _AdminUnidadFormPageState extends State<AdminUnidadFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cluesController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _cluesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final vm = context.read<AdminUnidadesViewModel>();
    
    final body = {
      'nombre': _nombreController.text.trim(),
      'clues': _cluesController.text.trim().toUpperCase(),
    };

    // Mostrar loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await vm.createUnidad(body);
    
    if (!mounted) return;
    Navigator.pop(context); // Cerrar loader
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unidad creada exitosamente'), backgroundColor: AppColors.green),
      );
      Navigator.pop(context); // Regresar a la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage ?? 'Error al crear unidad'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Nueva Unidad'),
        backgroundColor: AppColors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Datos de la Institución', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la Unidad',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _cluesController,
                  decoration: const InputDecoration(
                    labelText: 'Clave CLUES',
                    hintText: 'Ej. CSSMA000001',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'Requerido';
                    // Validación básica de clues
                    if (v.length < 11) return 'Debe tener 11 caracteres (ej. CSSMA000001)';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Crear Unidad de Salud', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
