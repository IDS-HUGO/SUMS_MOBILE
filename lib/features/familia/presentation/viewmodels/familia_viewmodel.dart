import 'package:flutter/material.dart';
import '../../domain/repositories/familia_repository.dart';

class FamiliaViewModel extends ChangeNotifier {
  final FamiliaRepository repository;

  final informanteNombre = TextEditingController();
  final informanteEdad = TextEditingController();
  final domicilio = TextEditingController();
  final localidad = TextEditingController();
  final manzana = TextEditingController();
  final viviendaRef = TextEditingController();

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

      // Consultar el catálogo de la API
      final items = await repository.getCatalog('roles_familiares');
      roles = items.map((e) => e.nombre).toList();
    } catch (e) {
      errorMessage = e.toString();
      // Fallback a hardcoded en caso de error, o dejar vacío.
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

  Map<String, dynamic> toPayload() {
    return {
      "informante_nombre": informanteNombre.text,
      "edad": int.tryParse(informanteEdad.text),
      "domicilio": domicilio.text,
      "localidad": localidad.text,
      "manzana": manzana.text,
      "vivienda_referencia": viviendaRef.text,
      "rol_informante": rolInformante,
    };
  }

  @override
  void dispose() {
    informanteNombre.dispose();
    informanteEdad.dispose();
    domicilio.dispose();
    localidad.dispose();
    manzana.dispose();
    viviendaRef.dispose();
    super.dispose();
  }
}
