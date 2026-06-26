import 'package:flutter/material.dart';

import '../../domain/repositories/integrantes_repository.dart';

class MemberForm {
  final TextEditingController nombre = TextEditingController();
  final TextEditingController fechaNacimiento = TextEditingController();
  final TextEditingController edad = TextEditingController();
  final TextEditingController lenguaEsp = TextEditingController();
  final TextEditingController ocupacion = TextEditingController();
  final TextEditingController proteina = TextEditingController();
  final TextEditingController frutasVerd = TextEditingController();
  final TextEditingController cereales = TextEditingController();
  final TextEditingController otraSust = TextEditingController();
  final TextEditingController tipoDisc = TextEditingController();
  final TextEditingController fechaCervico = TextEditingController();
  final TextEditingController fechaMama = TextEditingController();
  final TextEditingController motivoSalud = TextEditingController();

  String? sexo, estadoCivil, lengua, parentesco, escolaridad,
          ingreso, embarazo, tamizajeCervico, tamizajeMama, frecuenciaSalud;

  bool alfabetizacion = false;
  bool seguridadSocial = false;
  bool higiene  = false;
  bool discapacidad = false;

  final toxicomanias = <String>{};
  final cronicas     = <String>{};

  void dispose() {
    nombre.dispose();
    fechaNacimiento.dispose();
    edad.dispose();
    lenguaEsp.dispose();
    ocupacion.dispose();
    proteina.dispose();
    frutasVerd.dispose();
    cereales.dispose();
    otraSust.dispose();
    tipoDisc.dispose();
    fechaCervico.dispose();
    fechaMama.dispose();
    motivoSalud.dispose();
  }
}

class IntegrantesViewModel extends ChangeNotifier {
  final IntegrantesRepository repository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<String> rolesOpts = [];
  List<String> sexoOpts = [];
  List<String> edoCivilOpts = [];
  List<String> lenguaOpts = [];
  List<String> escolaridadOpts = [];
  List<String> ingresoOpts = [];
  List<String> embarazoOpts = [];
  List<String> tamizajeOpts = [];
  List<String> freqSaludOpts = [];
  List<String> toxicomaniasOpts = [];
  List<String> cronicasOpts = [];

  final List<MemberForm> _integrantes = [];
  List<MemberForm> get integrantes => _integrantes;

  IntegrantesViewModel({required this.repository}) {
    _init();
  }

  Future<void> _init() async {
    try {
      _isLoading = true;
      notifyListeners();

      final results = await Future.wait([
        repository.getCatalogOpts('parentesco'),
        repository.getCatalogOpts('estado-civil'),
        repository.getCatalogOpts('lengua'),
        repository.getCatalogOpts('escolaridad'),
        repository.getCatalogOpts('ingreso-salarial'),
        repository.getCatalogOpts('atencion-embarazo'),
        repository.getCatalogOpts('frecuencia-servicio-salud'),
        repository.getCatalogOpts('toxicomania'),
        repository.getCatalogOpts('enfermedad-cronica'),
      ]);

      rolesOpts = results[0];
      sexoOpts = ['Masculino', 'Femenino'];
      edoCivilOpts = results[1];
      lenguaOpts = results[2];
      escolaridadOpts = results[3];
      ingresoOpts = results[4];
      embarazoOpts = results[5];
      tamizajeOpts = ['Sí', 'No', 'No aplica'];
      freqSaludOpts = results[6];
      toxicomaniasOpts = results[7];
      cronicasOpts = results[8];

      if (_integrantes.isEmpty) {
        addMemberForm();
      }

    } catch (e) {
      _errorMessage = e.toString();
      // Fallback for UI if error occurs
      rolesOpts = ['Madre', 'Padre', 'Hijo(a)'];
      sexoOpts = ['Masculino', 'Femenino'];
      edoCivilOpts = ['Soltero(a)', 'Casado(a)'];
      lenguaOpts = ['Español', 'Indígena'];
      escolaridadOpts = ['Primaria', 'Secundaria', 'Preparatoria'];
      ingresoOpts = ['No recibe ingresos', 'Menos de 1 salario'];
      embarazoOpts = ['Ninguno', 'En control'];
      tamizajeOpts = ['Sí', 'No', 'No aplica'];
      freqSaludOpts = ['Nunca', 'Anual'];
      toxicomaniasOpts = ['Ninguna', 'Alcohol'];
      cronicasOpts = ['Ninguna', 'Diabetes'];
      
      if (_integrantes.isEmpty) {
        addMemberForm();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  void addMemberForm() {
    _integrantes.add(MemberForm());
    notifyListeners();
  }

  void removeMemberForm(int index) {
    if (_integrantes.length > 1) {
      final form = _integrantes.removeAt(index);
      form.dispose();
      notifyListeners();
    }
  }

  void updateForm() {
    notifyListeners();
  }

  void toggleSet(Set<String> selected, String option) {
    if (option == 'NA' || option == 'Ninguna') {
      selected.clear();
      selected.add(option);
    } else {
      selected.remove('NA');
      selected.remove('Ninguna');
      if (selected.contains(option)) {
        selected.remove(option);
      } else {
        selected.add(option);
      }
    }
    notifyListeners();
  }

  int? _parseEdad(String ageText) {
    final text = ageText.trim();
    if (text.isEmpty) return null;
    if (text.toLowerCase().contains('mes')) {
      final regExp = RegExp(r'\d+');
      final match = regExp.firstMatch(text);
      if (match != null) {
        return int.tryParse(match.group(0)!);
      }
    }
    final digits = RegExp(r'\d+').firstMatch(text);
    if (digits != null) {
      return int.tryParse(digits.group(0)!);
    }
    return int.tryParse(text);
  }

  List<Map<String, dynamic>> toPayload() {
    return _integrantes.map((i) {
      final isFem = i.sexo == 'Femenino';
      return {
        "nombre": i.nombre.text,
        "fecha_nacimiento": i.fechaNacimiento.text,
        "edad": _parseEdad(i.edad.text),
        "sexo": i.sexo,
        "estado_civil": i.estadoCivil,
        "parentesco": i.parentesco,
        "lengua": i.lengua,
        "lenguaEspecificar": i.lengua == 'Lengua indígena' ? (i.lenguaEsp.text.isEmpty ? null : i.lenguaEsp.text) : null,
        "escolaridad": i.escolaridad,
        "ocupacion": i.ocupacion.text,
        "ingreso": i.ingreso,
        "alfabetizacion": i.alfabetizacion,
        "seguridad_social": i.seguridadSocial,
        "higiene": i.higiene,
        "discapacidad": i.discapacidad,
        "tipoDiscapacidad": i.discapacidad ? (i.tipoDisc.text.isEmpty ? null : i.tipoDisc.text) : null,
        "proteina": int.tryParse(i.proteina.text),
        "frutasVerduras": int.tryParse(i.frutasVerd.text),
        "cereales": int.tryParse(i.cereales.text),
        "toxicomanias": i.toxicomanias.toList(),
        "otraSustancia": i.toxicomanias.contains('Otras sustancias') ? (i.otraSust.text.isEmpty ? null : i.otraSust.text) : null,
        "cronicas": i.cronicas.toList(),
        "embarazo": isFem ? i.embarazo : null,
        "tamizajeCervico": isFem ? i.tamizajeCervico : null,
        "fechaCervico": (isFem && i.tamizajeCervico == 'Sí') ? (i.fechaCervico.text.isEmpty ? null : i.fechaCervico.text) : null,
        "tamizajeMama": isFem ? i.tamizajeMama : null,
        "fechaMama": (isFem && i.tamizajeMama == 'Sí') ? (i.fechaMama.text.isEmpty ? null : i.fechaMama.text) : null,
        "frecuenciaSalud": i.frecuenciaSalud,
        "motivoSalud": i.motivoSalud.text,
      };
    }).toList();
  }

  @override
  void dispose() {
    for (final form in _integrantes) {
      form.dispose();
    }
    super.dispose();
  }
}
