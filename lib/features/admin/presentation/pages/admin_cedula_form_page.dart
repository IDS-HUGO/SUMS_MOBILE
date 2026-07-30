import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';

/// Formulario de edición básica de una cédula existente.
/// Permite modificar campos de estado y observaciones a nivel de cédula,
/// y envía PUT /cedulas/:id al backend.
class AdminCedulaFormPage extends ConsumerStatefulWidget {
  final int cedulaId;
  final Map<String, dynamic> initialData;
  const AdminCedulaFormPage({
    super.key,
    required this.cedulaId,
    required this.initialData,
  });
  @override
  ConsumerState<AdminCedulaFormPage> createState() =>
      _AdminCedulaFormPageState();
}

class _AdminCedulaFormPageState extends ConsumerState<AdminCedulaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _estadoController;
  late TextEditingController _observacionesController;
  late TextEditingController _entrevistadorIdController;
  late TextEditingController _unidadSaludIdController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _estadoController = TextEditingController(
      text: widget.initialData['estado']?.toString() ?? '',
    );
    _observacionesController = TextEditingController(
      text: widget.initialData['observaciones']?.toString() ?? '',
    );
    _entrevistadorIdController = TextEditingController(
      text: widget.initialData['entrevistador_id']?.toString() ?? '',
    );
    _unidadSaludIdController = TextEditingController(
      text: widget.initialData['unidad_salud_id']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _estadoController.dispose();
    _observacionesController.dispose();
    _entrevistadorIdController.dispose();
    _unidadSaludIdController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final body = <String, dynamic>{
      'estado': _estadoController.text.trim(),
    };
    if (_observacionesController.text.trim().isNotEmpty) {
      body['observaciones'] = _observacionesController.text.trim();
    }
    final entrevistadorId = int.tryParse(_entrevistadorIdController.text.trim());
    if (entrevistadorId != null) {
      body['entrevistador_id'] = entrevistadorId;
    }
    final unidadSaludId = int.tryParse(_unidadSaludIdController.text.trim());
    if (unidadSaludId != null) {
      body['unidad_salud_id'] = unidadSaludId;
    }

    final repo = ref.read(cedulaViewModelProvider).cedulaRepository;
    final success = await repo.updateRemoteCedula(widget.cedulaId, body);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cédula actualizada correctamente'),
          backgroundColor: AppColors.green,
        ),
      );
      context.pop(true); // Signal success to detail page
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar la cédula'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Cédula #${widget.cedulaId}'),
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
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusM),
                    side: BorderSide(
                      color: Theme.of(context).dividerTheme.color ??
                          AppColors.line,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información de la Cédula',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _estadoController.text.isNotEmpty
                              ? _estadoController.text
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Estado',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem<String>(
                              value: 'abierta',
                              child: Text('Abierta'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'borrador',
                              child: Text('Borrador'),
                            ),
                            DropdownMenuItem<String>(
                              value: 'cerrada',
                              child: Text('Cerrada'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) _estadoController.text = v;
                          },
                          validator: (v) =>
                              v == null ? 'Selecciona un estado' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _entrevistadorIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID del Entrevistador',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _unidadSaludIdController,
                          decoration: const InputDecoration(
                            labelText: 'ID de Unidad de Salud',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _observacionesController,
                          decoration: const InputDecoration(
                            labelText: 'Observaciones',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Guardar Cambios',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
