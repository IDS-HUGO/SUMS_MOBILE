import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class AdminProductividadPage extends ConsumerStatefulWidget {
  const AdminProductividadPage({super.key});

  @override
  ConsumerState<AdminProductividadPage> createState() =>
      _AdminProductividadPageState();
}

class _AdminProductividadPageState
    extends ConsumerState<AdminProductividadPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedEncuestador = 'Todos';

  // Datos mock para el UI. (Idealmente esto vendría de un ViewModel/Backend)
  final List<Map<String, dynamic>> _datosProductividad = [
    {
      'nombre': 'Juan Pérez',
      'completadas': 45,
      'en_progreso': 12,
      'tiempo_promedio': '25 min',
    },
    {
      'nombre': 'María García',
      'completadas': 62,
      'en_progreso': 5,
      'tiempo_promedio': '20 min',
    },
    {
      'nombre': 'Carlos López',
      'completadas': 30,
      'en_progreso': 20,
      'tiempo_promedio': '35 min',
    },
    {
      'nombre': 'Ana Martínez',
      'completadas': 55,
      'en_progreso': 8,
      'tiempo_promedio': '22 min',
    },
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.gold),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productividad'),
        backgroundColor: AppColors.gold,
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Fecha Inicio',
                        ),
                        onPressed: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Fecha Fin',
                        ),
                        onPressed: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedEncuestador,
                  decoration: const InputDecoration(
                    labelText: 'Encuestador',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items:
                      [
                            'Todos',
                            'Juan Pérez',
                            'María García',
                            'Carlos López',
                            'Ana Martínez',
                          ]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _selectedEncuestador = v!),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Resumen
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryBox(
                    title: 'Total Completadas',
                    value: '192',
                    icon: Icons.check_circle_outline,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryBox(
                    title: 'En Progreso',
                    value: '45',
                    icon: Icons.pending_actions,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          // Lista de resultados
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _datosProductividad.length,
              itemBuilder: (context, index) {
                final dato = _datosProductividad[index];
                if (_selectedEncuestador != 'Todos' &&
                    dato['nombre'] != _selectedEncuestador) {
                  return const SizedBox.shrink();
                }
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    side: BorderSide(
                      color:
                          Theme.of(context).dividerTheme.color ??
                          AppColors.line,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.rolEncuestador,
                              radius: 16,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dato['nombre'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _StatColumn(
                                label: 'Completadas',
                                value: dato['completadas'].toString(),
                                color: AppColors.green,
                              ),
                            ),
                            Expanded(
                              child: _StatColumn(
                                label: 'En Progreso',
                                value: dato['en_progreso'].toString(),
                                color: AppColors.gold,
                              ),
                            ),
                            Expanded(
                              child: _StatColumn(
                                label: 'Promedio',
                                value: dato['tiempo_promedio'],
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends ConsumerWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends ConsumerWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.muted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
