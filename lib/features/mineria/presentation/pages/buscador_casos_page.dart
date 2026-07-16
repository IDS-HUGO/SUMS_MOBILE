import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../viewmodels/mineria_viewmodel.dart';

class BuscadorCasosPage extends StatefulWidget {
  const BuscadorCasosPage({super.key});

  @override
  State<BuscadorCasosPage> createState() => _BuscadorCasosPageState();
}

class _BuscadorCasosPageState extends State<BuscadorCasosPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<MineriaViewModel>().buscar(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MineriaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de Casos'),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Ej. "familias con desnutrición"',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: vm.isLoading ? null : _onSearch,
                  icon: vm.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.rolAnalista,
                    minimumSize: const Size(50, 50),
                  ),
                ),
              ],
            ),
          ),

          // Resultados
          Expanded(
            child: _buildBody(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MineriaViewModel vm) {
    if (vm.state == MineriaState.initial) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.subtle),
            SizedBox(height: 16),
            Text('Escribe una consulta para comenzar', style: TextStyle(color: AppColors.muted)),
          ],
        ),
      );
    }

    if (vm.isLoading && vm.searchResults.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(vm.errorMessage ?? 'Error desconocido', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _onSearch, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    if (vm.searchResults.isEmpty) {
      return const Center(child: Text('No se encontraron resultados relevantes.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.searchResults.length,
      itemBuilder: (context, index) {
        final result = vm.searchResults[index];
        final score = result.score.toStringAsFixed(3);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        result.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.greenDark),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.soft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Score: $score', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  result.texto,
                  style: const TextStyle(fontSize: 13, color: AppColors.ink),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
