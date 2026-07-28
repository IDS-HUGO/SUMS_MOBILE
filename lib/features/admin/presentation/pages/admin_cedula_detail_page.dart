import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';

class AdminCedulaDetailPage extends ConsumerStatefulWidget {
  final int cedulaId;
  const AdminCedulaDetailPage({super.key, required this.cedulaId});
  @override
  ConsumerState<AdminCedulaDetailPage> createState() =>
      _AdminCedulaDetailPageState();
}

class _AdminCedulaDetailPageState
    extends ConsumerState<AdminCedulaDetailPage> {
  Map<String, dynamic>? _cedulaData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCedula());
  }

  Future<void> _loadCedula() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(cedulaViewModelProvider).cedulaRepository;
      final data = await repo.getRemoteCedulaById(widget.cedulaId);
      if (mounted) {
        setState(() {
          _cedulaData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Cédula'),
        content: Text(
          '¿Estás seguro de que deseas eliminar la cédula #${widget.cedulaId}?\n\n'
          'Esta acción eliminará también todos los registros asociados '
          '(núcleo familiar, integrantes, vivienda, inmunizaciones, etc.).',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => ctx.pop(true),
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final vm = ref.read(cedulaViewModelProvider);
    final success = await vm.deleteRemoteCedula(widget.cedulaId);
    if (!mounted) return;
    context.pop(); // dismiss loading
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cédula eliminada correctamente'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop(); // go back to list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Error al eliminar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cédula #${widget.cedulaId}'),
        backgroundColor: AppColors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCedula,
          ),
          if (_cedulaData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Editar cédula',
              onPressed: () async {
                final result = await context.push<bool>(
                  AppRoutes.adminCedulaForm,
                  extra: {
                    'cedulaId': widget.cedulaId,
                    'data': _cedulaData!,
                  },
                );
                if (result == true && mounted) {
                  _loadCedula();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Eliminar cédula',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar la cédula:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCedula,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (_cedulaData == null) {
      return const Center(child: Text('Sin datos'));
    }
    return _CedulaDetailContent(data: _cedulaData!);
  }
}

class _CedulaDetailContent extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CedulaDetailContent({required this.data});

  @override
  Widget build(BuildContext context) {
    // Extract top-level cedula info
    final id = data['id'];
    final estado = data['estado'] ?? 'desconocido';
    final fechaRegistro = data['fecha_registro'];
    final entrevistadorId = data['entrevistador_id'];
    final unidadSaludId = data['unidad_salud_id'];

    // Nested objects (may or may not be present depending on backend GET /cedulas/:id response)
    final nucleoFamiliar = data['nucleo_familiar'] as Map<String, dynamic>?;
    final direccion = data['direccion'] as Map<String, dynamic>?;
    final vivienda = data['vivienda'] as Map<String, dynamic>?;
    final integrantes = data['integrantes'] as List?;
    final inmunizaciones = data['inmunizaciones'] as List?;
    final informanteNombre = data['informante_nombre'] ?? nucleoFamiliar?['informante_nombre'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: AppColors.green, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Cédula #$id',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _StatusChip(estado: estado.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (informanteNombre != null)
                    _DetailRow(label: 'Informante', value: informanteNombre.toString()),
                  if (fechaRegistro != null)
                    _DetailRow(label: 'Fecha Registro', value: fechaRegistro.toString()),
                  if (entrevistadorId != null)
                    _DetailRow(label: 'Entrevistador ID', value: entrevistadorId.toString()),
                  if (unidadSaludId != null)
                    _DetailRow(label: 'Unidad de Salud ID', value: unidadSaludId.toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dirección
          if (direccion != null) ...[
            _SectionCard(
              title: 'Dirección',
              icon: Icons.location_on,
              entries: direccion.entries
                  .where((e) => e.value != null)
                  .map((e) => _DetailRow(
                      label: _humanizeKey(e.key), value: e.value.toString()))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Vivienda
          if (vivienda != null) ...[
            _SectionCard(
              title: 'Vivienda',
              icon: Icons.home,
              entries: vivienda.entries
                  .where((e) => e.value != null)
                  .map((e) => _DetailRow(
                      label: _humanizeKey(e.key), value: e.value.toString()))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Integrantes
          if (integrantes != null && integrantes.isNotEmpty) ...[
            _SectionCard(
              title: 'Integrantes (${integrantes.length})',
              icon: Icons.people,
              entries: integrantes.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final person = entry.value as Map<String, dynamic>?;
                final nombre = person?['nombre'] ?? person?['nombre_completo'] ?? 'Integrante $idx';
                final parentesco = person?['parentesco'] ?? '';
                return _DetailRow(
                  label: '#$idx',
                  value: '$nombre ${parentesco.toString().isNotEmpty ? "($parentesco)" : ""}',
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Inmunizaciones
          if (inmunizaciones != null && inmunizaciones.isNotEmpty) ...[
            _SectionCard(
              title: 'Inmunizaciones (${inmunizaciones.length})',
              icon: Icons.vaccines,
              entries: inmunizaciones.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final vac = entry.value as Map<String, dynamic>?;
                final tipo = vac?['tipo'] ?? vac?['vacuna'] ?? 'Vacuna $idx';
                return _DetailRow(label: '#$idx', value: tipo.toString());
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Raw data fallback for any other top-level keys
          _SectionCard(
            title: 'Datos Completos',
            icon: Icons.data_object,
            entries: data.entries
                .where((e) =>
                    e.value != null &&
                    !['nucleo_familiar', 'direccion', 'vivienda', 'integrantes', 'inmunizaciones']
                        .contains(e.key))
                .map((e) => _DetailRow(
                    label: _humanizeKey(e.key), value: e.value.toString()))
                .toList(),
          ),
        ],
      ),
    );
  }

  static String _humanizeKey(String key) {
    return key.replaceAll('_', ' ').replaceFirstMapped(
        RegExp(r'^.'), (m) => m.group(0)!.toUpperCase());
  }
}

class _StatusChip extends StatelessWidget {
  final String estado;
  const _StatusChip({required this.estado});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.green;
    if (estado == 'borrador') color = Colors.orange;
    if (estado == 'cerrada') color = Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> entries;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        side: BorderSide(
          color: Theme.of(context).dividerTheme.color ?? AppColors.line,
        ),
      ),
      child: ExpansionTile(
        leading: Icon(icon, color: AppColors.terracota),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: entries.length <= 10,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: entries,
            ),
          ),
        ],
      ),
    );
  }
}
