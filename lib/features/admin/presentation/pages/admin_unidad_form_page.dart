import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/unidad_salud_entity.dart';
import '../viewmodels/admin_unidades_viewmodel.dart';

class AdminUnidadFormPage extends StatefulWidget {
  final UnidadSaludEntity? unidad;
  const AdminUnidadFormPage({super.key, this.unidad});

  @override
  State<AdminUnidadFormPage> createState() => _AdminUnidadFormPageState();
}

class _AdminUnidadFormPageState extends State<AdminUnidadFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cluesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.unidad != null) {
      _nombreController.text = widget.unidad!.nombre;
      _cluesController.text = widget.unidad!.clues;
    }
  }

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

    final isEditing = widget.unidad != null;
    final success = isEditing
        ? await vm.updateUnidad(widget.unidad!.id, body)
        : await vm.createUnidad(body);
    
    if (!mounted) return;
    Navigator.pop(context); // Cerrar loader
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Unidad actualizada exitosamente' : 'Unidad creada exitosamente'),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.pop(context); // Regresar a la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al guardar unidad'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(widget.unidad != null ? 'Editar Unidad' : 'Nueva Unidad'),
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
                  child: Text(
                    widget.unidad != null ? 'Actualizar Unidad de Salud' : 'Crear Unidad de Salud',
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
