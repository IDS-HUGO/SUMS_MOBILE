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

      // Dummy Data
      if (_integrantes.isNotEmpty) {
        final form = _integrantes[0];
        form.nombre.text = 'María González Pérez';
        form.fechaNacimiento.text = '1992-05-14';
        form.edad.text = '34';
        form.sexo = 'Femenino';
        form.estadoCivil = 'Casado(a)';
        form.parentesco = 'Madre';
        form.lengua = 'Español';
        form.escolaridad = 'Preparatoria';
        form.ocupacion.text = 'Hogar';
        form.ingreso = 'No recibe ingresos';
        form.alfabetizacion = true;
        form.seguridadSocial = false;
        form.higiene = true;
        form.discapacidad = false;
        form.proteina.text = '4';
        form.frutasVerd.text = '5';
        form.cereales.text = '7';
        form.toxicomanias.add('Ninguna');
        form.cronicas.add('Ninguna');
        form.embarazo = 'Ninguno';
        form.tamizajeCervico = 'No';
        form.tamizajeMama = 'No';
        form.frecuenciaSalud = 'Nunca';
        form.motivoSalud.text = 'Ninguno';
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
        "parentesco": i.parentesco,
        "lengua": i.lengua,
        "lenguaEspecificar": i.lenguaEsp.text,
        "escolaridad": i.escolaridad,
        "ocupacion": i.ocupacion.text,
        "ingreso": i.ingreso,
        "alfabetizacion": i.alfabetizacion,
        "seguridad_social": i.seguridadSocial,
        "higiene": i.higiene,
        "discapacidad": i.discapacidad,
        "tipoDiscapacidad": i.tipoDisc.text,
        "proteina": int.tryParse(i.proteina.text),
        "frutasVerduras": int.tryParse(i.frutasVerd.text),
        "cereales": int.tryParse(i.cereales.text),
        "toxicomanias": i.toxicomanias.toList(),
        "otraSustancia": i.otraSust.text,
        "cronicas": i.cronicas.toList(),
        "embarazo": i.embarazo,
        "tamizajeCervico": i.tamizajeCervico,
        "fechaCervico": i.fechaCervico.text,
        "tamizajeMama": i.tamizajeMama,
        "fechaMama": i.fechaMama.text,
        "frecuenciaSalud": i.frecuenciaSalud,
        "motivoSalud": i.motivoSalud.text,
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
