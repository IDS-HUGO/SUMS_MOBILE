import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/repositories/vacunacion_repository.dart';

class VaccineForm {
  final TextEditingController paciente = TextEditingController();
  final TextEditingController fechaNacimiento = TextEditingController();
  final TextEditingController edad = TextEditingController();
  final TextEditingController otraVacuna = TextEditingController();
  String? tipo;
  String? dosis;

  void dispose() {
    paciente.dispose();
    fechaNacimiento.dispose();
    edad.dispose();
    otraVacuna.dispose();
  }
}

class VacunacionViewModel extends ChangeNotifier {
  final VacunacionRepository repository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> _vacunasOpts = [];
  List<String> get vacunasOpts => _vacunasOpts;

  List<String> _dosisOpts = [];
  List<String> get dosisOpts => _dosisOpts;

  bool _seAplicoVacuna = false;
  bool get seAplicoVacuna => _seAplicoVacuna;
  set seAplicoVacuna(bool val) {
    _seAplicoVacuna = val;
    notifyListeners();
  }

  final List<VaccineForm> _vacunas = [];
  List<VaccineForm> get vacunas => _vacunas;

  VacunacionViewModel({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        repository.getVacunasOpts(),
        repository.getDosisOpts(),
      ]);

      _vacunasOpts = results[0];
      _dosisOpts = results[1];

      if (_vacunas.isEmpty) {
        addVaccineForm();
      }

      // Dummy Data
      _seAplicoVacuna = true;
      if (_vacunas.isNotEmpty) {
        _vacunas[0].paciente.text = 'María González Pérez';
        _vacunas[0].fechaNacimiento.text = '1992-05-14';
        _vacunas[0].edad.text = '34';
        _vacunas[0].tipo = 'Influenza estacional';
        _vacunas[0].dosis = 'Única';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addVaccineForm() {
    _vacunas.add(VaccineForm());
    notifyListeners();
  }

  void removeVaccineForm(int index) {
    if (_vacunas.length > 1) {
      final form = _vacunas.removeAt(index);
      form.dispose();
      notifyListeners();
    }
  }
  
  void updateForm() {
    notifyListeners();
  }

  Map<String, dynamic> toPayload() {
    return {
      "se_aplico_vacuna": _seAplicoVacuna,
      "vacunas": _seAplicoVacuna ? _vacunas.map((v) => {
        "paciente": v.paciente.text,
        "fecha_nacimiento": v.fechaNacimiento.text,
        "edad": int.tryParse(v.edad.text),
        "vacuna": v.tipo,
        "otraVacuna": v.otraVacuna.text,
        "dosis": v.dosis,
      }).toList() : [],
    };
  }

  @override
  void dispose() {
    for (final form in _vacunas) {
      form.dispose();
    }
    super.dispose();
  }
}
