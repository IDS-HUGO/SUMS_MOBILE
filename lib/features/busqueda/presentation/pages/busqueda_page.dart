import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../di/busqueda_providers.dart';
import '../../domain/entities/resultado_busqueda.dart';
import '../viewmodels/busqueda_viewmodel.dart' show BusquedaViewModel, BusquedaStatus, ModoBusqueda;

class BusquedaPage extends ConsumerStatefulWidget {
  const BusquedaPage({super.key});

  @override
  ConsumerState<BusquedaPage> createState() => _BusquedaPageState();
}

class _BusquedaPageState extends ConsumerState<BusquedaPage> {
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _buscar() {
    FocusScope.of(context).unfocus();
    ref.read(busquedaViewModelProvider).buscar(_queryController.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(busquedaViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Búsqueda de Notas'),
        actions: [
          if (vm.hasBuscado)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Nueva búsqueda',
              onPressed: () {
                _queryController.clear();
                vm.reset();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildBuscador(vm),
            Expanded(child: _buildContenido(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildBuscador(BusquedaViewModel vm) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerTheme.color ?? AppColors.line,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<ModoBusqueda>(
            segments: const [
              ButtonSegment(
                value: ModoBusqueda.notas,
                label: Text('Notas'),
                icon: Icon(Icons.sticky_note_2_outlined, size: 16),
              ),
              ButtonSegment(
                value: ModoBusqueda.estructurado,
                label: Text('Datos estructurados'),
                icon: Icon(Icons.storage_outlined, size: 16),
              ),
            ],
            selected: {vm.modo},
            onSelectionChanged: (nuevo) {
              vm.setModo(nuevo.first);
              _queryController.clear();
            },
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _queryController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _buscar(),
            maxLength: BusquedaViewModel.maxCaracteresConsulta,
            decoration: InputDecoration(
              hintText: vm.modo == ModoBusqueda.notas
                  ? 'Buscar en notas de visita...'
                  : 'Ej. sarampión, sin vacunar, mascotas, embarazo...',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              counterText: '',
              filled: true,
              fillColor: theme.canvasColor.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: (theme.dividerTheme.color ?? AppColors.line)
                      .withOpacity(0.6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.green,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vm.modo == ModoBusqueda.estructurado)
                const Expanded(
                  child: Text(
                    'Filtra por vacunas, embarazo, nutrición, mascotas o '
                    'colonia/calle -- no es búsqueda por similitud de texto.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                )
              else
                const Expanded(
                  child: Text(
                    'Busca coincidencias en las notas de visita del personal de salud.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: vm.isLoading ? null : _buscar,
                icon: vm.isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search, size: 18),
                label: const Text('Buscar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildContenido(BusquedaViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.status == BusquedaStatus.initial) {
      return _buildEstadoVacio(
        icon: Icons.travel_explore,
        titulo: vm.modo == ModoBusqueda.notas
            ? 'Busca en las notas de visita'
            : 'Filtra cédulas por datos estructurados',
        mensaje: vm.modo == ModoBusqueda.notas
            ? 'Escribe una consulta para comenzar.'
            : 'Ej. "sarampión", "sin vacunar", "mascotas", "embarazo", '
                'o una colonia/calle conocida.',
      );
    }

    if (vm.status == BusquedaStatus.error) {
      if (vm.motorNoDisponible) {
        return _buildEstadoVacio(
          icon: Icons.cloud_off_outlined,
          titulo: 'Servicio no disponible',
          mensaje: vm.errorMessage ??
              'El servicio de búsqueda no está disponible en '
                  'este momento. Intenta más tarde.',
          color: AppColors.muted,
        );
      }
      return _buildEstadoVacio(
        icon: Icons.error_outline,
        titulo: 'No se pudo completar la búsqueda',
        mensaje: vm.errorMessage ?? 'Ocurrió un error inesperado.',
        color: AppColors.error,
      );
    }

    if (vm.modo == ModoBusqueda.estructurado) {
      return _buildContenidoEstructurado(vm);
    }

    if (vm.resultados.isEmpty) {
      return _buildEstadoVacio(
        icon: Icons.search_off,
        titulo: 'Sin resultados',
        mensaje: 'No se encontraron notas para tu búsqueda.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vm.resultados.length,
      itemBuilder: (context, index) {
        return _ResultadoCard(resultado: vm.resultados[index]);
      },
    );
  }

  Widget _buildContenidoEstructurado(BusquedaViewModel vm) {
    if (vm.mensajeSinCategoria != null) {
      return _buildEstadoVacio(
        icon: Icons.help_outline,
        titulo: 'Consulta no reconocida',
        mensaje: vm.mensajeSinCategoria!,
        color: AppColors.terracota,
      );
    }

    if (vm.resultadosEstructurados.isEmpty) {
      return _buildEstadoVacio(
        icon: Icons.search_off,
        titulo: 'Ninguna cédula coincide',
        mensaje: 'No hay cédulas que cumplan este filtro.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${vm.totalCoincidencias} coincidencia(s)'
              '${vm.categoriaEncontrada != null ? " · categoría ${vm.categoriaEncontrada}" : ""}'
              '${vm.categoriaEncontrada == "direccion" ? " (misma colonia/calle, no distancia real)" : ""}',
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            itemCount: vm.resultadosEstructurados.length,
            itemBuilder: (context, index) {
              return _ResultadoEstructuradoCard(
                resultado: vm.resultadosEstructurados[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoVacio({
    required IconData icon,
    required String titulo,
    required String mensaje,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color ?? AppColors.muted),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color ?? AppColors.ink,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultadoCard extends StatelessWidget {
  final ResultadoBusqueda resultado;
  const _ResultadoCard({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snippet = resultado.texto.length > 220
        ? '${resultado.texto.substring(0, 220)}...'
        : resultado.texto;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${resultado.posicion}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenDark,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resultado.titulo.isNotEmpty
                      ? resultado.titulo
                      : resultado.id,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  resultado.score.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.terracota,
                  ),
                ),
              ),
            ],
          ),
          if (snippet.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              snippet,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultadoEstructuradoCard extends StatelessWidget {
  final ResultadoBusquedaEstructurada resultado;
  const _ResultadoEstructuradoCard({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  resultado.nombreInformante ?? 'Familia #${resultado.familiaId}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  resultado.coincidencia,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenDark,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  [resultado.domicilio, resultado.localidad]
                      .where((s) => s != null && s.isNotEmpty)
                      .join(', '),
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
