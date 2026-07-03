import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../cedula_orquestador/presentation/viewmodels/cedula_viewmodel.dart';

class AdminCedulasListPage extends StatefulWidget {
  const AdminCedulasListPage({super.key});

  @override
  State<AdminCedulasListPage> createState() => _AdminCedulasListPageState();
}

class _AdminCedulasListPageState extends State<AdminCedulasListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CedulaViewModel>().refreshSyncCounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Cédulas Registradas'),
        backgroundColor: AppColors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Mostrar opciones de filtro
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filtros próximamente')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre del informante...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusM),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer<CedulaViewModel>(
              builder: (context, vm, child) {
                final records = vm.allLocalRecords.where((r) {
                  final informante = (r['_informante'] ?? '').toString().toLowerCase();
                  return informante.contains(_searchQuery);
                }).toList();

                if (records.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron cédulas.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final informante = record['_informante'] ?? 'Sin nombre';
                    final fechaStr = record['_createdAt'] ?? '';
                    final status = record['_syncStatus'] as int;

                    String statusText;
                    Color statusColor;

                    if (status == 0) {
                      statusText = 'Borrador';
                      statusColor = Colors.orange;
                    } else if (status == 1) {
                      statusText = 'Pendiente';
                      statusColor = AppColors.terracota;
                    } else {
                      statusText = 'Sincronizado';
                      statusColor = AppColors.green;
                    }

                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusM),
                        side: const BorderSide(color: AppColors.line),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.1),
                          child: Icon(Icons.assignment, color: statusColor),
                        ),
                        title: Text(informante, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Fecha: ${fechaStr.length >= 10 ? fechaStr.substring(0, 10) : fechaStr}\nEstado: $statusText'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              // Cargar cédula y navegar al formulario
                              // TODO: Implementar lógica de carga en el ViewModel si es necesario
                              Navigator.pushNamed(context, AppRoutes.cedula);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20, color: AppColors.ink),
                                  SizedBox(width: 8),
                                  Text('Editar Cédula'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
