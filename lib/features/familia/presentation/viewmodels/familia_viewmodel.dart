import 'package:flutter/material.dart';
import '../../domain/repositories/familia_repository.dart';

class FamiliaViewModel extends ChangeNotifier {
  final FamiliaRepository repository;
  final informanteNombre = TextEditingController();
  String? informanteSexo;
  final domicilio = TextEditingController();
  final localidad = TextEditingController();
  final manzana = TextEditingController();
  final viviendaRef = TextEditingController();

  /// Observaciones libres de la visita (seguimiento, enfermedad rara,
  /// embarazo, vacunas pendientes, vivienda en mal estado, mascotas sin
  /// vacunar, etc). NO se envía dentro de "familia": el backend la lee como
  /// clave raíz del payload (`payload.observaciones`), por eso NO se incluye
  /// en [toPayload].
  final observaciones = TextEditingController();

  String? rolInformante;
  List<String> roles = [];
  bool isLoadingRoles = true;
  String? errorMessage;
  FamiliaViewModel({required this.repository}) {
    _loadRoles();
  }
  Future<void> _loadRoles() async {
    try {
      isLoadingRoles = true;
      notifyListeners();
      final items = await repository.getCatalog('parentesco');
      roles = items.map((e) => e.nombre).toList();
    } catch (e) {
      errorMessage = e.toString();
      roles = ['Madre', 'Padre', 'Hijo(a)', 'Abuelo(a)'];
    } finally {
      isLoadingRoles = false;
      notifyListeners();
    }
  }

  void setRol(String? rol) {
    rolInformante = rol;
    notifyListeners();
  }

  void setSexo(String? sexo) {
    informanteSexo = sexo;
    notifyListeners();
  }

  /// Anexa [frase] al texto actual de [observaciones]: si ya hay texto,
  /// concatena con un espacio; si está vacío, la frase se vuelve el texto
  /// inicial. Usado por los chips de categorías rápidas en la UI.
  void appendObservacion(String frase) {
    final actual = observaciones.text.trimRight();
    observaciones.text = actual.isEmpty ? frase : '$actual $frase';
    observaciones.selection = TextSelection.collapsed(
      offset: observaciones.text.length,
    );
    notifyListeners();
  }

  Map<String, dynamic> toPayload() {
    return {
      "informante_nombre": informanteNombre.text.trim(),
      "sexo": informanteSexo,
      "domicilio": domicilio.text.trim(),
      "localidad": localidad.text.trim(),
      "manzana": manzana.text.trim(),
      "vivienda_referencia": viviendaRef.text.trim(),
      "rol_informante": rolInformante,
    };
  }

  @override
  void dispose() {
    informanteNombre.dispose();
    domicilio.dispose();
    localidad.dispose();
    manzana.dispose();
    viviendaRef.dispose();
    observaciones.dispose();
    super.dispose();
  }
}
