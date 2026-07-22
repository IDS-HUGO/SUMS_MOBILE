import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sums/core/di/providers.dart';
import '../../../familia/presentation/viewmodels/familia_viewmodel.dart';
import '../../../vivienda/presentation/viewmodels/vivienda_viewmodel.dart';
import '../../../integrantes/presentation/viewmodels/integrantes_viewmodel.dart';
import '../../../vacunacion/presentation/viewmodels/vacunacion_viewmodel.dart';

class CedulaDummyData {
  static void apply(WidgetRef ref) {
    final f = ref.read(familiaViewModelProvider);
    final v = ref.read(viviendaViewModelProvider);
    final i = ref.read(integrantesViewModelProvider);
    final vac = ref.read(vacunacionViewModelProvider);
    f.informanteNombre.text = 'Juan Perez Dummy';
    f.setSexo('Masculino');
    if (f.roles.isNotEmpty) f.setRol(f.roles.first);
    f.domicilio.text = 'Calle Prueba 123';
    if (v.matTechoParedesOpts.isNotEmpty) {
      v.setTecho(v.matTechoParedesOpts.first);
      v.setParedes(v.matTechoParedesOpts.first);
    }
    if (v.matPisoOpts.isNotEmpty) v.setPiso(v.matPisoOpts.first);
    v.cuartos.text = '3';
    v.habitantes.text = '4';
    v.aguaEntubada = true;
    v.energiaElect = true;
    if (v.cocinasOpts.isNotEmpty) v.setCocina(v.cocinasOpts.first);
    v.coccionLena = false;
    if (v.excretasOpts.isNotEmpty) v.setExcretas(v.excretasOpts.first);
    v.alcantarillado = true;
    v.fosaSeptica = false;
    v.perrosGatos = false;
    v.animVacunas = false;
    v.esterilizados = false;
    if (i.integrantes.isEmpty) i.addMemberForm();
    final m = i.integrantes[0];
    m.nombre.text = 'Juan Perez Dummy';
    m.sexo = 'Masculino';
    m.fechaNacimiento.text = '1980-01-01';
    m.edad.text = '46';
    if (i.edoCivilOpts.isNotEmpty) m.estadoCivil = i.edoCivilOpts.first;
    if (i.rolesOpts.isNotEmpty) m.parentesco = i.rolesOpts.first;
    if (i.escolaridadOpts.isNotEmpty) m.escolaridad = i.escolaridadOpts.first;
    if (i.lenguaOpts.isNotEmpty) m.lengua = i.lenguaOpts.first;
    if (i.ingresoOpts.isNotEmpty) m.ingreso = i.ingresoOpts.first;
    m.alfabetizacion = true;
    m.seguridadSocial = true;
    m.higiene = true;
    m.discapacidad = false;
    m.proteina.text = '2';
    m.frutasVerd.text = '2';
    m.cereales.text = '2';
    m.toxicomanias.clear();
    m.toxicomanias.add('Ninguna');
    m.cronicas.clear();
    m.cronicas.add('Ninguna');
    if (i.freqSaludOpts.isNotEmpty) m.frecuenciaSalud = i.freqSaludOpts.first;
    i.updateForm();
    vac.seAplicoVacuna = false;
    vac.updateForm();
  }
}
