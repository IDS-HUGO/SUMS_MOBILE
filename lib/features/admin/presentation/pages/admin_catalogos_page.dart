import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/admin_catalogos_viewmodel.dart';
import '../../../cedula_orquestador/domain/entities/catalog_item.dart';

class AdminCatalogosPage extends StatefulWidget {
  const AdminCatalogosPage({super.key});

  @override
  State<AdminCatalogosPage> createState() => _AdminCatalogosPageState();
}

class _AdminCatalogosPageState extends State<AdminCatalogosPage> {
  String? _selectedCatalog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AdminCatalogosViewModel>();
      vm.fetchAllCatalogs();
      if (vm.catalogKeys.isNotEmpty) {
        setState(() {
          _selectedCatalog = vm.catalogKeys.first;
        });
      }
    });
  }

  void _showAddDialog(BuildContext context, AdminCatalogosViewModel vm) {
    if (_selectedCatalog == null) return;
    
    final nombreController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Añadir a $_selectedCatalog'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre / Valor'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción (Opcional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();
                if (nombre.isEmpty) return;
                
                Navigator.pop(ctx); // close dialog
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                final success = await vm.createCatalogItem(
                  _selectedCatalog!,
                  nombre,
                  descController.text.trim(),
                );
                
                if (!mounted) return;
                Navigator.pop(context); // close loader
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Añadido exitosamente' : (vm.errorMessage ?? 'Error')),
                    backgroundColor: success ? AppColors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminCatalogosViewModel>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Gestión de Catálogos'),
        backgroundColor: AppColors.terracota,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar y Actualizar todos',
            onPressed: () => vm.fetchAllCatalogs(),
          ),
        ],
      ),
      floatingActionButton: _selectedCatalog != null
          ? FloatingActionButton(
              onPressed: () => _showAddDialog(context, vm),
              backgroundColor: AppColors.terracota,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: DropdownButtonFormField<String>(
              value: _selectedCatalog,
              decoration: const InputDecoration(
                labelText: 'Selecciona un catálogo',
                border: OutlineInputBorder(),
              ),
              items: vm.catalogKeys.map((k) {
                return DropdownMenuItem(value: k, child: Text(k.toUpperCase()));
              }).toList(),
              onChanged: (v) => setState(() => _selectedCatalog = v),
            ),
          ),
          Expanded(
            child: _buildList(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildList(AdminCatalogosViewModel vm) {
    if (vm.status == AdminCatalogosStatus.loading && vm.catalogos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedCatalog == null) {
      return const Center(child: Text('Selecciona un catálogo arriba'));
    }

    final list = vm.catalogos[_selectedCatalog!] ?? [];

    if (list.isEmpty) {
      return const Center(child: Text('El catálogo está vacío.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
            side: const BorderSide(color: AppColors.line),
          ),
          child: ListTile(
            leading: const Icon(Icons.label_important, color: AppColors.terracota),
            title: Text(item.nombre),
            subtitle: Text('ID: ${item.id}'),
          ),
        );
      },
    );
  }
}
