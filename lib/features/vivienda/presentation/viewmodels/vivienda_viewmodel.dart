import 'package:flutter/material.dart';
import '../../domain/repositories/vivienda_repository.dart';

class ViviendaViewModel extends ChangeNotifier {
  final ViviendaRepository repository;

  String? techo;
  String? paredes;
  String? piso;
  final techoOtro = TextEditingController();
  final paredesOtro = TextEditingController();
  final pisoOtro = TextEditingController();
  final cuartos = TextEditingController();
  final habitantes = TextEditingController();

  bool aguaEntubada = false;
  bool energiaElect = false;
  String? cocina;
  bool coccionLena = false;
  String? excretas;
  bool alcantarillado = false;
  bool fosaSeptica = false;

  bool perrosGatos = false;
  bool animVacunas = false;
  bool esterilizados = false;
  final otrosAnimales = <String>{};
  final animalOtro = TextEditingController();
  final animalObs = TextEditingController();

  // Catalogos
  List<String> matTechoParedesOpts = [];
  List<String> matPisoOpts = [];
  List<String> cocinasOpts = [];
  List<String> excretasOpts = [];
  List<String> otrosAnimalesOpts = [];

  bool isLoadingCatalogs = true;
  String? errorMessage;

  ViviendaViewModel({required this.repository}) {
    _loadCatalogs();
  }

  Future<void> _loadCatalogs() async {
    try {
      isLoadingCatalogs = true;
      notifyListeners();

      final futures = await Future.wait([
        repository.getCatalog('material'),
        repository.getCatalog('material'),
        repository.getCatalog('manejo-excretas'),
        repository.getCatalog('animal'),
      ]);

      matTechoParedesOpts = futures[0].where((e) => e.nombre != 'Tierra').map((e) => e.nombre).toList();
      matPisoOpts = futures[1].where((e) => e.nombre != 'Lámina').map((e) => e.nombre).toList();
      cocinasOpts = ['Fuera del dormitorio', 'Dentro del dormitorio'];
      excretasOpts = futures[2].map((e) => e.nombre).toList();
      otrosAnimalesOpts = futures[3].map((e) => e.nombre).toList();

    } catch (e) {
      errorMessage = e.toString();
      // Fallback
      matTechoParedesOpts = ['Concreto o cemento', 'Madera', 'Lámina', 'Otros (especifique)'];
      matPisoOpts = ['Concreto o cemento', 'Madera', 'Tierra', 'Otros (especifique)'];
      cocinasOpts = ['Fuera del dormitorio', 'Dentro del dormitorio'];
      excretasOpts = ['WC', 'Letrina', 'Al ras de suelo'];
      otrosAnimalesOpts = ['Aves de corral', 'Bovinos', 'Porcinos', 'Otros', 'NA'];
    } finally {
      isLoadingCatalogs = false;
      notifyListeners();
    }
  }



  void setTecho(String? value) { techo = value; notifyListeners(); }
  void setParedes(String? value) { paredes = value; notifyListeners(); }
  void setPiso(String? value) { piso = value; notifyListeners(); }
  void setCocina(String? value) { cocina = value; notifyListeners(); }
  void setExcretas(String? value) { excretas = value; notifyListeners(); }

  void setAguaEntubada(bool value) { aguaEntubada = value; notifyListeners(); }
  void setEnergiaElect(bool value) { energiaElect = value; notifyListeners(); }
  void setCoccionLena(bool value) { coccionLena = value; notifyListeners(); }
  void setAlcantarillado(bool value) { alcantarillado = value; notifyListeners(); }
  void setFosaSeptica(bool value) { fosaSeptica = value; notifyListeners(); }
  
  void setPerrosGatos(bool value) { perrosGatos = value; notifyListeners(); }
  void setAnimVacunas(bool value) { animVacunas = value; notifyListeners(); }
  void setEsterilizados(bool value) { esterilizados = value; notifyListeners(); }

  void toggleOtroAnimal(String option) {
    if (option == 'NA') {
      otrosAnimales.clear();
      otrosAnimales.add(option);
    } else {
      otrosAnimales.remove('NA');
      if (otrosAnimales.contains(option)) {
        otrosAnimales.remove(option);
      } else {
        otrosAnimales.add(option);
      }
    }
    notifyListeners();
  }

  Map<String, dynamic> toPayload() {
    final parts = <String>[];
    if (techo == 'Otros (especifique)' && techoOtro.text.trim().isNotEmpty) parts.add('Techo: ${techoOtro.text.trim()}');
    if (paredes == 'Otros (especifique)' && paredesOtro.text.trim().isNotEmpty) parts.add('Paredes: ${paredesOtro.text.trim()}');
    if (piso == 'Otros (especifique)' && pisoOtro.text.trim().isNotEmpty) parts.add('Piso: ${pisoOtro.text.trim()}');
    final materialOtrosStr = parts.join(', ');

    return {
      "techo": techo,
      "paredes": paredes,
      "piso": piso,
      "materialOtros": materialOtrosStr,
      "cuartos": int.tryParse(cuartos.text),
      "habitantes": int.tryParse(habitantes.text),
      "agua_entubada": aguaEntubada,
      "energia_electrica": energiaElect,
      "coccion_lena": coccionLena,
      "cocina": cocina,
      "excretas": excretas,
      "red_alcantarillado": alcantarillado,
      "fosa_septica": fosaSeptica,
      "perros_gatos": perrosGatos,
      "animales_vacunas": animVacunas,
      "mascotas_esterilizadas": esterilizados,
      "otros_animales": otrosAnimales.toList(),
      "animalOtro": animalOtro.text,
      "animalObservaciones": animalObs.text,
    };
  }

  @override
  void dispose() {
    techoOtro.dispose();
    paredesOtro.dispose();
    pisoOtro.dispose();
    cuartos.dispose();
    habitantes.dispose();
    animalOtro.dispose();
    animalObs.dispose();
    super.dispose();
  }
}
