import 'package:flutter/foundation.dart';
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
        repository.getCatalogOpts('roles'),
        repository.getCatalogOpts('sexo'),
        repository.getCatalogOpts('estado_civil'),
        repository.getCatalogOpts('lengua'),
        repository.getCatalogOpts('escolaridad'),
        repository.getCatalogOpts('ingreso'),
        repository.getCatalogOpts('embarazo'),
        repository.getCatalogOpts('tamizaje'),
        repository.getCatalogOpts('frecuencia_salud'),
        repository.getCatalogOpts('toxicomanias'),
        repository.getCatalogOpts('cronicas'),
      ]);

      rolesOpts = results[0];
      sexoOpts = results[1];
      edoCivilOpts = results[2];
      lenguaOpts = results[3];
      escolaridadOpts = results[4];
      ingresoOpts = results[5];
      embarazoOpts = results[6];
      tamizajeOpts = results[7];
      freqSaludOpts = results[8];
      toxicomaniasOpts = results[9];
      cronicasOpts = results[10];

      if (_integrantes.isEmpty) {
        addMemberForm();
      }
    } catch (e) {
      _errorMessage = e.toString();
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
    if (option == 'NA') {
      selected.clear();
      selected.add(option);
    } else {
      selected.remove('NA');
      if (selected.contains(option)) {
        selected.remove(option);
      } else {
        selected.add(option);
      }
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> toPayload() {
    return _integrantes.map((i) => {
        "nombre": i.nombre.text,
        "fecha_nacimiento": i.fechaNacimiento.text,
        "edad": int.tryParse(i.edad.text),
        "sexo": i.sexo,
        "estado_civil": i.estadoCivil,
        "lengua": i.lengua,
        "lengua_especificar": i.lenguaEsp.text,
        "escolaridad": i.escolaridad,
        "ocupacion": i.ocupacion.text,
        "ingreso_salarial": i.ingreso,
        "alfabetizacion": i.alfabetizacion,
        "seguridad_social": i.seguridadSocial,
        "higiene_diaria": i.higiene,
        "presenta_discapacidad": i.discapacidad,
        "tipo_discapacidad": i.tipoDisc.text,
        "proteina_dias": int.tryParse(i.proteina.text),
        "frutas_dias": int.tryParse(i.frutasVerd.text),
        "cereales_dias": int.tryParse(i.cereales.text),
        "toxicomanias": i.toxicomanias.toList(),
        "otra_sustancia": i.otraSust.text,
        "cronicas": i.cronicas.toList(),
        "atencion_embarazo": i.embarazo,
        "tamizaje_cervico": i.tamizajeCervico,
        "fecha_cervico": i.fechaCervico.text,
        "tamizaje_mama": i.tamizajeMama,
        "fecha_mama": i.fechaMama.text,
        "frecuencia_salud": i.frecuenciaSalud,
        "motivo_salud": i.motivoSalud.text,
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
