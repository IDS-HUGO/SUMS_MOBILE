import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'datos_riesgo.dart';
import 'api_service.dart';

class CedulaScreen extends StatefulWidget {
  const CedulaScreen({super.key});

  @override
  State<CedulaScreen> createState() => _CedulaScreenState();
}

class _CedulaScreenState extends State<CedulaScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Estado de la UI
  bool _isLoadingOCR = false;
  bool _isLoadingPrediccion = false;
  String? _errorMessage;
  DatosRiesgo? _datos;
  ResultadoPrediccion? _resultado;

  // Controladores y valores para el formulario
  final TextEditingController _cuartosController = TextEditingController();
  final TextEditingController _habitantesController = TextEditingController();
  String _materialTecho = 'Concreto o cemento';
  bool _aguaEntubada = false;
  bool _vacunacionCompleta = false;

  final List<String> _materiales = [
    'Concreto o cemento',
    'Lámina de asbesto o metálica',
    'Madera',
    'Palma o paja',
    'Otro'
  ];

  /// Acción: Seleccionar PDF e iniciar OCR
  Future<void> _seleccionarYProcesarArchivo() async {
    setState(() {
      _isLoadingOCR = true;
      _errorMessage = null;
      _resultado = null;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final datosExtraidos = await _apiService.procesarOCR(file);
        
        setState(() {
          _datos = datosExtraidos;
          _actualizarControladores();
          _isLoadingOCR = false;
        });
      } else {
        setState(() => _isLoadingOCR = false);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingOCR = false;
      });
    }
  }

  void _actualizarControladores() {
    if (_datos != null) {
      _cuartosController.text = _datos!.numeroCuartos.toString();
      _habitantesController.text = _datos!.numeroHabitantes.toString();
      _materialTecho = _materiales.contains(_datos!.materialTecho) 
          ? _datos!.materialTecho 
          : 'Concreto o cemento';
      _aguaEntubada = _datos!.aguaEntubada;
      _vacunacionCompleta = _datos!.vacunacionCompleta;
    }
  }

  /// Acción: Enviar formulario validado para predicción
  Future<void> _enviarEvaluacion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoadingPrediccion = true;
      _errorMessage = null;
    });

    // Sincronizar UI -> Modelo
    _datos!.numeroCuartos = int.parse(_cuartosController.text);
    _datos!.numeroHabitantes = int.parse(_habitantesController.text);
    _datos!.materialTecho = _materialTecho;
    _datos!.aguaEntubada = _aguaEntubada;
    _datos!.vacunacionCompleta = _vacunacionCompleta;

    try {
      final res = await _apiService.obtenerPrediccion(_datos!);
      setState(() {
        _resultado = res;
        _isLoadingPrediccion = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingPrediccion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de Riesgo Familiar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            if (_isLoadingOCR) _buildLoadingOCR(),
            if (_datos != null && !_isLoadingOCR) _buildFormulario(),
            if (_errorMessage != null) _buildError(),
            if (_resultado != null) _buildResultadoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.picture_as_pdf, size: 48),
            const SizedBox(height: 10),
            const Text(
              'Cargue la Cédula (PDF) para iniciar la extracción automática',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _isLoadingOCR || _isLoadingPrediccion ? null : _seleccionarYProcesarArchivo,
              icon: const Icon(Icons.upload_file),
              label: const Text('Seleccionar Cédula'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOCR() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Procesando OCR y extrayendo campos...', style: TextStyle(fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Valide los datos extraídos:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _cuartosController,
            decoration: const InputDecoration(labelText: 'Número de Cuartos', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _habitantesController,
            decoration: const InputDecoration(labelText: 'Número de Habitantes', border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            validator: (value) => (value == null || value.isEmpty) ? 'Requerido' : null,
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _materialTecho,
            decoration: const InputDecoration(labelText: 'Material del Techo', border: OutlineInputBorder()),
            items: _materiales.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (val) => setState(() => _materialTecho = val!),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('¿Cuenta con Agua Entubada?'),
            value: _aguaEntubada,
            onChanged: (val) => setState(() => _aguaEntubada = val),
          ),
          SwitchListTile(
            title: const Text('¿Vacunación Completa?'),
            value: _vacunacionCompleta,
            onChanged: (val) => setState(() => _vacunacionCompleta = val),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _isLoadingPrediccion ? null : _enviarEvaluacion,
            icon: _isLoadingPrediccion 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.analytics),
            label: Text(_isLoadingPrediccion ? 'Calculando Riesgo...' : 'Calcular Nivel de Riesgo'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultadoCard() {
    Color colorSemantico;
    IconData icono;

    switch (_resultado!.nivelRiesgo) {
      case 'ALTO':
        colorSemantico = Colors.red.shade700;
        icono = Icons.warning_rounded;
        break;
      case 'MEDIO':
        colorSemantico = Colors.orange.shade800;
        icono = Icons.info_outline;
        break;
      default:
        colorSemantico = Colors.green.shade700;
        icono = Icons.check_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        color: colorSemantico.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(side: BorderSide(color: colorSemantico, width: 2), borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icono, color: colorSemantico, size: 50),
              const SizedBox(height: 10),
              Text(
                'RIESGO ${_resultado!.nivelRiesgo}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorSemantico),
              ),
              const SizedBox(height: 5),
              Text('Modelo aplicado: ${_resultado!.modelo}'),
              Text('Probabilidad de riesgo alto: ${(_resultado!.probabilidadAlto * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'Error: $_errorMessage',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
