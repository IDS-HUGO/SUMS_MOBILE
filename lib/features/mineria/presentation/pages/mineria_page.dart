import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../familia/presentation/widgets/familia_step_widget.dart';
import '../../../vivienda/presentation/widgets/vivienda_step_widget.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/entities/vacuna_aplicada.dart';
import '../viewmodels/mineria_viewmodel.dart';

class MineriaPage extends ConsumerStatefulWidget {
  const MineriaPage({super.key});
  @override
  ConsumerState<MineriaPage> createState() => _MineriaPageState();
}

class _MineriaPageState extends ConsumerState<MineriaPage> {
  // Evita re-precargar en cada rebuild y, sobre todo, evita la carrera con
  // ChangeNotifierProvider.autoDispose: si se llenan familiaViewModelProvider/
  // viviendaViewModelProvider ANTES de que FamiliaStepWidget/ViviendaStepWidget
  // existan (y por lo tanto antes de que haya un ref.watch activo sobre esos
  // providers), Riverpod desecha esa instancia por falta de listeners y crea
  // una nueva vacía en cuanto los widgets reales se montan -- los valores
  // precargados se pierden en silencio. Por eso el precargado se dispara desde
  // build() (mismo pase que monta los widgets reales) y se difiere con
  // addPostFrameCallback a JUSTO DESPUÉS de que ese pase terminó de montarlos.
  String? _prefilledDocId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mineriaViewModelProvider).init();
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      await ref
          .read(mineriaViewModelProvider)
          .setFile(File(result.files.single.path!));
    }
  }

  // ─── Precarga los formularios REALES de captura (Familia/Vivienda) con lo
  // que extrajo OCR, en vez de mantener un formulario paralelo propio.
  // Integrantes/Vacunación no se tocan: el field_map de OCR (backend) solo
  // cubre la página 1 (familia + vivienda), esas dos pantallas siempre se
  // capturan a mano igual que en la captura manual normal.
  void _prefillCedulaForms(OcrResult result) {
    final campos = result.campos;
    String texto(String key) => campos[key]?.value.trim() ?? '';
    bool marcado(String key) =>
        campos[key]?.value.trim().toLowerCase() == 'true';

    String? opcionMarcada(String base, Map<String, String> sufijoANombre) {
      for (final entry in sufijoANombre.entries) {
        if (marcado('$base.${entry.key}')) return entry.value;
      }
      return null;
    }

    final familiaVm = ref.read(familiaViewModelProvider);
    familiaVm.informanteNombre.text = texto('familia.nombre_informante');
    familiaVm.domicilio.text = texto('familia.domicilio');
    familiaVm.localidad.text = texto('familia.localidad');
    familiaVm.manzana.text = texto('familia.manzana');
    familiaVm.viviendaRef.text = texto('familia.vivienda');
    // rol_familiar es texto libre (manuscrito) -- solo se autoselecciona si
    // coincide razonablemente con el catálogo real; si no, se deja para que
    // el entrevistador lo capture a mano (más confiable que forzar un match).
    final rolTexto = texto('familia.rol_familiar').toLowerCase();
    for (final rol in familiaVm.roles) {
      final rolBase = rol.toLowerCase().replaceAll(RegExp(r'\(.\)'), '');
      if (rolBase.isNotEmpty && rolTexto.contains(rolBase)) {
        familiaVm.setRol(rol);
        break;
      }
    }

    final viviendaVm = ref.read(viviendaViewModelProvider);
    final techo = opcionMarcada('vivienda.material_techo', {
      'concreto': 'Concreto o cemento',
      'madera': 'Madera',
      'lamina': 'Lámina',
      'otros': 'Otros (especifique)',
    });
    if (techo != null) viviendaVm.setTecho(techo);
    final paredes = opcionMarcada('vivienda.material_paredes', {
      'concreto': 'Concreto o cemento',
      'madera': 'Madera',
      'lamina': 'Lámina',
      'otros': 'Otros (especifique)',
    });
    if (paredes != null) viviendaVm.setParedes(paredes);
    final piso = opcionMarcada('vivienda.material_piso', {
      'concreto': 'Concreto o cemento',
      'madera': 'Madera',
      'tierra': 'Tierra',
      'otros': 'Otros (especifique)',
    });
    if (piso != null) viviendaVm.setPiso(piso);
    if (campos.containsKey('vivienda.numero_cuartos')) {
      viviendaVm.cuartos.text = texto('vivienda.numero_cuartos');
    }
    if (campos.containsKey('vivienda.numero_habitantes')) {
      viviendaVm.habitantes.text = texto('vivienda.numero_habitantes');
    }
    viviendaVm.setAguaEntubada(marcado('vivienda.agua_entubada.si'));
    viviendaVm.setEnergiaElect(marcado('vivienda.energia_electrica.si'));
    viviendaVm.setCoccionLena(marcado('vivienda.cocina_lena.si'));
    final cocina = opcionMarcada('vivienda.cocina_ubicacion', {
      'fuera_dormitorio': 'Fuera del dormitorio',
      'dentro_dormitorio': 'Dentro del dormitorio',
    });
    if (cocina != null) viviendaVm.setCocina(cocina);
    final excretas = opcionMarcada('vivienda.excretas', {
      'wc': 'WC',
      'letrina': 'Letrina',
      'ras_suelo': 'Al ras de suelo',
    });
    if (excretas != null) viviendaVm.setExcretas(excretas);
    viviendaVm.setAlcantarillado(marcado('vivienda.red_alcantarillado.si'));
    viviendaVm.setFosaSeptica(marcado('vivienda.fosa_septica.si'));
    viviendaVm.setPerrosGatos(marcado('vivienda.perros_gatos_dentro.si'));
    viviendaVm.setAnimVacunas(marcado('vivienda.mascotas_vacunas.si'));
    viviendaVm.setEsterilizados(marcado('vivienda.mascotas_esterilizadas.si'));
    const animalSufijoANombre = {
      'aves_corral': 'Aves de corral',
      'bovinos': 'Bovinos',
      'porcinos': 'Porcinos',
      'otros': 'Otros',
    };
    for (final entry in animalSufijoANombre.entries) {
      if (marcado('vivienda.animales.${entry.key}')) {
        viviendaVm.toggleOtroAnimal(entry.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(mineriaViewModelProvider);

    // Se dispara en el MISMO pase de build que va a montar FamiliaStepWidget/
    // ViviendaStepWidget más abajo (ver _buildResults) -- para cuando el
    // callback corra, esos widgets ya están observando sus providers.
    final result = vm.result;
    if (result != null && _prefilledDocId != result.docId) {
      _prefilledDocId = result.docId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _prefillCedulaForms(result);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Captura de Cédula (PDF)'),
        actions: [
          if (vm.result != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: vm.reset,
              tooltip: 'Escanear otra',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHealthStatus(vm.healthOk),
          Expanded(
            child: vm.result != null
                ? Form(key: vm.formKey, child: _buildResults(vm))
                : _buildUploadZone(vm),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthStatus(bool ok) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: ok
          ? AppColors.green.withOpacity(0.1)
          : AppColors.error.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.error_outline,
            size: 16,
            color: ok ? AppColors.green : AppColors.error,
          ),
          const SizedBox(width: 8),
          Text(
            ok
                ? 'Conexión establecida con el servidor'
                : 'Sin conexión con el servidor de escaneo',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ok ? AppColors.green : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone(MineriaViewModel vm) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 80,
              color: vm.selectedFile != null
                  ? AppColors.green
                  : AppColors.muted,
            ),
            const SizedBox(height: 16),
            if (vm.selectedFile != null) ...[
              Text(
                vm.selectedFile!.path.split('/').last,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Archivo listo para procesar',
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ] else
              const Text(
                'Selecciona el PDF de la cédula',
                style: TextStyle(fontSize: 16, color: AppColors.ink),
              ),
            const SizedBox(height: 32),
            if (vm.isLoading)
              const CircularProgressIndicator()
            else ...[
              ElevatedButton.icon(
                onPressed: _pickPdf,
                icon: const Icon(Icons.file_open),
                label: const Text('Seleccionar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
              ),
              const SizedBox(height: 12),
              if (vm.selectedFile != null)
                ElevatedButton.icon(
                  onPressed: vm.healthOk ? vm.procesar : null,
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Comenzar Escaneo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                  ),
                ),
            ],
            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(MineriaViewModel vm) {
    final res = vm.result!;
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.dividerTheme.color ?? AppColors.line,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen de Extracción',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.greenDark,
                            ),
                          ),
                          const Divider(height: 24),
                          _buildInfoRow('ID Documento', res.docId),
                          _buildInfoRow('Archivo', res.archivoOriginal),
                          _buildInfoRow('Páginas', res.nPaginas.toString()),
                          _buildInfoRow(
                            'Total Campos',
                            res.resumen.totalCampos.toString(),
                          ),
                          _buildInfoRow(
                            'Requieren Revisión',
                            res.resumen.necesitanRevision.toString(),
                            color: res.resumen.necesitanRevision > 0
                                ? AppColors.error
                                : AppColors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildConfidenceBanner(res)),
              const SliverToBoxAdapter(child: FamiliaStepWidget()),
              const SliverToBoxAdapter(child: ViviendaStepWidget()),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    'ESQUEMA DE VACUNACIÓN (MANUAL)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.muted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _ManualVaccineCard(
                      index: index,
                      vacuna: vm.vacunasSeleccionadas[index],
                      vacunasOpts: vm.vacunasOpts,
                      dosisOpts: vm.dosisOpts,
                      onRemove: () => vm.removeVacuna(index),
                      onChanged: (v, d) =>
                          vm.updateVacuna(index, vacuna: v, dosis: d),
                    );
                  }, childCount: vm.vacunasSeleccionadas.length),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: vm.addVacuna,
                    icon: const Icon(Icons.add),
                    label: const Text('AGREGAR VACUNA'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
        _buildBottomActions(vm),
      ],
    );
  }

  Widget _buildBottomActions(MineriaViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: vm.isSaving ? null : () => _handleSave(vm),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: vm.isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'GUARDAR DATOS EXTRAÍDOS',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
        ),
      ),
    );
  }

  Future<void> _handleSave(MineriaViewModel vm) async {
    final viviendaPayload = ref.read(viviendaViewModelProvider).toPayload();
    final success = await vm.guardarCambios(viviendaPayload);
    if (!mounted) return;
    if (success) {
      if (vm.nivelRiesgo != null) {
        await _showResultadoRiesgoDialog(
          vm.nivelRiesgo!,
          vm.probabilidadAlto,
          vm.prioridadVisita,
          vm.motivoPrioridad,
        );
        if (!mounted) return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Datos guardados correctamente.'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al intentar guardar los datos.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showResultadoRiesgoDialog(
    String nivelRiesgo,
    double? probabilidadAlto,
    String? prioridadVisita,
    String? motivoPrioridad,
  ) {
    final nivelUpper = nivelRiesgo.toUpperCase();
    final Color colorRiesgo = switch (nivelUpper) {
      'ALTO' => AppColors.error,
      'MEDIO' => AppColors.warning,
      'BAJO' => AppColors.green,
      _ => AppColors.muted,
    };
    final probabilidadTexto =
        probabilidadAlto != null
            ? 'Probabilidad de riesgo alto: '
                '${(probabilidadAlto * 100).round()}%'
            : null;
    final esUrgente = prioridadVisita == 'URGENTE';

    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Resultado de la clasificación de riesgo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banda de prioridad urgente: puede activarse aunque el nivel de
              // riesgo ML sea BAJO/MEDIO -- una familia con buena vivienda
              // pero con una embarazada sin control prenatal SÍ necesita
              // visita pronto, y el modelo (agregados) no lo ve por sí solo.
              if (esUrgente)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VISITA URGENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (motivoPrioridad != null)
                        Text(
                          motivoPrioridad,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              Text(
                nivelUpper,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: colorRiesgo,
                ),
              ),
              if (probabilidadTexto != null) ...[
                const SizedBox(height: 8),
                Text(
                  probabilidadTexto,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                ),
              ],
              if (!esUrgente && motivoPrioridad != null && motivoPrioridad.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  motivoPrioridad,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  // Los widgets reales de captura (Familia/Vivienda) no tienen badge de
  // confianza por campo (los usa también la captura manual, que no tiene ese
  // dato) -- en su lugar, se lista aquí qué campos marcó OCR para revisar.
  Widget _buildConfidenceBanner(OcrResult res) {
    final bajaConfianza = res.campos.entries
        .where((e) => e.value.needsReview)
        .toList();
    if (bajaConfianza.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${bajaConfianza.length} campo(s) de baja confianza en los formularios de abajo — revíselos con cuidado',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final e in bajaConfianza)
                Chip(
                  label: Text(
                    _etiquetaCampo(e.key),
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: AppColors.warning.withOpacity(0.12),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _etiquetaCampo(String key) {
    const etiquetas = {
      'familia.nombre_informante': 'Nombre del informante',
      'familia.rol_familiar': 'Rol familiar',
      'familia.domicilio': 'Domicilio',
      'familia.localidad': 'Localidad',
      'familia.manzana': 'Manzana',
      'familia.vivienda': 'Vivienda',
    };
    return etiquetas[key] ?? key.split('.').last.replaceAll('_', ' ');
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color ?? AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualVaccineCard extends StatelessWidget {
  final int index;
  final VacunaAplicada vacuna;
  final List<String> vacunasOpts;
  final List<String> dosisOpts;
  final VoidCallback onRemove;
  final Function(String?, String?) onChanged;
  const _ManualVaccineCard({
    required this.index,
    required this.vacuna,
    required this.vacunasOpts,
    required this.dosisOpts,
    required this.onRemove,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color ?? AppColors.line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VACUNA ${index + 1}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.burgundy,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.error,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: vacuna.vacuna,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Nombre de la Vacuna',
              isDense: true,
            ),
            items: vacunasOpts
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => onChanged(v, vacuna.dosis),
            validator: (v) => v == null ? 'Seleccione vacuna' : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: vacuna.dosis,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Dosis',
              isDense: true,
            ),
            items: dosisOpts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (d) => onChanged(vacuna.vacuna, d),
            validator: (v) => v == null ? 'Seleccione dosis' : null,
          ),
        ],
      ),
    );
  }
}
