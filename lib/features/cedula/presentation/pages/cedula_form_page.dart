import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../viewmodels/cedula_viewmodel.dart';
import '../widgets/form_helpers.dart';
import '../widgets/form_section_card.dart';

class CedulaFormPage extends StatefulWidget {
  const CedulaFormPage({super.key});

  @override
  State<CedulaFormPage> createState() => _CedulaFormPageState();
}

class _CedulaFormPageState extends State<CedulaFormPage> {
  final _controllers = <TextEditingController>[];

  late final _cedulaForm = GlobalKey<FormState>();
  late final _nucleoForm = GlobalKey<FormState>();
  late final _personaForm = GlobalKey<FormState>();
  late final _integranteForm = GlobalKey<FormState>();
  late final _viviendaForm = GlobalKey<FormState>();
  late final _materialForm = GlobalKey<FormState>();
  late final _servicioForm = GlobalKey<FormState>();
  late final _animalForm = GlobalKey<FormState>();
  late final _alimentacionForm = GlobalKey<FormState>();
  late final _higieneForm = GlobalKey<FormState>();
  late final _preventivaForm = GlobalKey<FormState>();
  late final _servicioSaludForm = GlobalKey<FormState>();
  late final _toxicomaniaForm = GlobalKey<FormState>();
  late final _cronicaForm = GlobalKey<FormState>();
  late final _vacunacionForm = GlobalKey<FormState>();

  late final _cedulaUnidad = _c();
  late final _cedulaEntrevistador = _c();
  late final _cedulaLevantamiento = _c();
  late final _cedulaNucleo = _c();
  late final _cedulaFecha = _c(todayIsoDate());
  late final _cedulaObservaciones = _c();
  String _cedulaEstado = 'borrador';

  late final _nucleoJefe = _c();
  late final _nucleoComentarios = _c();

  late final _personaPrimerNombre = _c();
  late final _personaSegundoNombre = _c();
  late final _personaApellidoPaterno = _c();
  late final _personaApellidoMaterno = _c();
  late final _personaFechaNacimiento = _c();
  late final _personaEstadoCivil = _c();
  late final _personaLengua = _c();
  late final _personaEscolaridad = _c();
  late final _personaOcupacion = _c();
  late final _personaIngreso = _c();
  String _personaSexo = 'masculino';
  bool _personaAlfabetizacion = true;

  late final _integranteNucleo = _c();
  late final _integrantePersona = _c();
  late final _integranteParentesco = _c();
  late final _integranteFechaSalida = _c();
  late final _integranteComentarios = _c();

  late final _viviendaNucleo = _c();
  late final _viviendaDireccion = _c();
  late final _viviendaCuartos = _c();
  late final _viviendaHabitantes = _c();
  late final _viviendaManejoExcretas = _c();
  late final _viviendaComentarios = _c();
  String _cocinaUbicacion = 'fuera_del_dormitorio';
  bool _cocinaConLena = false;
  bool _redAlcantarillado = false;
  bool _fosaSeptica = false;

  late final _materialVivienda = _c();
  late final _materialTipo = _c();
  late final _materialId = _c();
  late final _materialOtro = _c();

  late final _servicioVivienda = _c();
  late final _servicioId = _c();
  bool _servicioDisponible = true;

  late final _animalNucleo = _c();
  late final _animalId = _c();
  late final _animalCantidad = _c();
  late final _animalComentarios = _c();
  bool _animalDentro = false;
  bool _animalVacunas = false;
  bool _animalEsterilizado = false;

  late final _alimentacionPersona = _c();
  late final _alimentacionId = _c();
  late final _alimentacionFrecuencia = _c();
  late final _alimentacionFecha = _c(todayIsoDate());

  late final _higienePersona = _c();
  late final _higieneFecha = _c(todayIsoDate());
  bool _higieneDiaria = true;

  late final _preventivaPersona = _c();
  late final _preventivaAtencionEmbarazo = _c();
  late final _preventivaFechaCervico = _c();
  late final _preventivaFechaMama = _c();
  late final _preventivaFechaRegistro = _c(todayIsoDate());
  bool _tamizajeCervico = false;
  bool _tamizajeMama = false;

  late final _servicioSaludPersona = _c();
  late final _servicioSaludFrecuencia = _c();
  late final _servicioSaludMotivo = _c();
  late final _servicioSaludFecha = _c(todayIsoDate());

  late final _toxicomaniaPersona = _c();
  late final _toxicomaniaId = _c();
  late final _toxicomaniaOtra = _c();
  late final _toxicomaniaInicio = _c();
  late final _toxicomaniaFin = _c();

  late final _cronicaPersona = _c();
  late final _cronicaId = _c();
  late final _cronicaFecha = _c();
  late final _cronicaObservaciones = _c();

  late final _vacunacionPersona = _c();
  late final _vacunacionEsquema = _c();
  late final _vacunacionUnidad = _c();
  late final _vacunacionCedula = _c();
  late final _vacunacionVacuna = _c();
  late final _vacunacionDosis = _c();
  late final _vacunacionFecha = _c(todayIsoDate());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CedulaViewModel>().loadCatalogs();
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _c([String text = '']) {
    final controller = TextEditingController(text: text);
    _controllers.add(controller);
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CedulaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formularios de cedula'),
        actions: [
          IconButton(
            tooltip: 'Recargar catalogos',
            onPressed: viewModel.isLoading ? null : viewModel.loadCatalogs,
            icon: const Icon(Icons.sync_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BrandHeader(
                    title: 'Captura de cedula',
                    subtitle:
                        'Campos conectados a la API y al modelo DBML corregido.',
                    compact: true,
                  ),
                  const SizedBox(height: 16),
                  _StatusBanner(viewModel: viewModel),
                  FormSectionCard(
                    title: 'Cedula maestra',
                    subtitle: 'Unidad, entrevistador, nucleo y estado.',
                    icon: Icons.assignment_outlined,
                    children: [_cedulaSection(viewModel)],
                  ),
                  FormSectionCard(
                    title: 'Nucleo familiar y persona',
                    subtitle:
                        'Crea nucleo, persona y relacion por nucleo_persona.',
                    icon: Icons.groups_outlined,
                    children: [
                      _nucleoSection(viewModel),
                      const Divider(height: 32),
                      _personaSection(viewModel),
                      const Divider(height: 32),
                      _integranteSection(viewModel),
                    ],
                  ),
                  FormSectionCard(
                    title: 'Vivienda',
                    subtitle:
                        'Datos de vivienda, materiales, servicios y animales.',
                    icon: Icons.home_outlined,
                    children: [
                      _viviendaSection(viewModel),
                      const Divider(height: 32),
                      _materialSection(viewModel),
                      const Divider(height: 32),
                      _servicioViviendaSection(viewModel),
                      const Divider(height: 32),
                      _animalSection(viewModel),
                    ],
                  ),
                  FormSectionCard(
                    title: 'Salud preventiva y estilo de vida',
                    subtitle:
                        'Alimentacion, higiene, tamizajes, toxicomanias y cronicas.',
                    icon: Icons.health_and_safety_outlined,
                    children: [
                      _alimentacionSection(viewModel),
                      const Divider(height: 32),
                      _higieneSection(viewModel),
                      const Divider(height: 32),
                      _preventivaSection(viewModel),
                      const Divider(height: 32),
                      _servicioSaludSection(viewModel),
                      const Divider(height: 32),
                      _toxicomaniaSection(viewModel),
                      const Divider(height: 32),
                      _cronicaSection(viewModel),
                    ],
                  ),
                  FormSectionCard(
                    title: 'Vacunacion',
                    subtitle: 'Inmunizacion con vacuna y cat_dosis.',
                    icon: Icons.vaccines_outlined,
                    children: [_vacunacionSection(viewModel)],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cedulaSection(CedulaViewModel viewModel) {
    return Form(
      key: _cedulaForm,
      child: Column(
        children: [
          _grid([
            _numberField(_cedulaUnidad, 'Unidad salud ID', Icons.local_hospital_outlined),
            _numberField(_cedulaEntrevistador, 'Entrevistador ID', Icons.badge_outlined),
            _numberField(_cedulaLevantamiento, 'Levantamiento ID', Icons.map_outlined, required: false),
            _numberField(_cedulaNucleo, 'Nucleo familiar ID', Icons.groups_outlined),
            SumsTextField(controller: _cedulaFecha, label: 'Fecha registro', icon: Icons.event_outlined, validator: requiredText),
            DropdownButtonFormField<String>(
              initialValue: _cedulaEstado,
              decoration: const InputDecoration(labelText: 'Estado'),
              items: const ['borrador', 'sincronizada', 'validada', 'cerrada']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _cedulaEstado = value ?? 'borrador'),
            ),
          ]),
          const SizedBox(height: 12),
          SumsTextField(
            controller: _cedulaObservaciones,
            label: 'Observaciones',
            icon: Icons.notes_outlined,
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: 14),
          _saveButton(
            viewModel,
            label: 'Guardar cedula',
            onPressed: () => _submit(
              form: _cedulaForm,
              path: '/cedulas',
              captureIdAs: 'cedula',
              successMessage: 'Cedula guardada.',
              bodyBuilder: () => {
                'unidad_salud_id': requiredInt(_cedulaUnidad.text),
                'entrevistador_id': requiredInt(_cedulaEntrevistador.text),
                'levantamiento_id': optionalInt(_cedulaLevantamiento.text),
                'nucleo_familiar_id': requiredInt(_cedulaNucleo.text),
                'fecha_registro': _cedulaFecha.text,
                'estado': _cedulaEstado,
                'observaciones': _cedulaObservaciones.text,
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _nucleoSection(CedulaViewModel viewModel) {
    return Form(
      key: _nucleoForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Crear nucleo familiar', style: _sectionTitleStyle()),
          const SizedBox(height: 12),
          _grid([
            _numberField(_nucleoJefe, 'Jefe persona ID', Icons.person_outline, required: false),
            SumsTextField(controller: _nucleoComentarios, label: 'Comentarios', icon: Icons.notes_outlined),
          ]),
          const SizedBox(height: 14),
          _saveButton(
            viewModel,
            label: 'Crear nucleo',
            onPressed: () => _submit(
              form: _nucleoForm,
              path: '/nucleos-familiares',
              captureIdAs: 'nucleo',
              successMessage: 'Nucleo creado.',
              bodyBuilder: () => {
                'jefe_persona_id': optionalInt(_nucleoJefe.text),
                'comentarios': _nucleoComentarios.text,
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _personaSection(CedulaViewModel viewModel) {
    return Form(
      key: _personaForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Crear persona', style: _sectionTitleStyle()),
          const SizedBox(height: 12),
          _grid([
            SumsTextField(controller: _personaPrimerNombre, label: 'Primer nombre', icon: Icons.person_outline, validator: requiredText),
            SumsTextField(controller: _personaSegundoNombre, label: 'Segundo nombre', icon: Icons.person_outline),
            SumsTextField(controller: _personaApellidoPaterno, label: 'Apellido paterno', icon: Icons.person_outline, validator: requiredText),
            SumsTextField(controller: _personaApellidoMaterno, label: 'Apellido materno', icon: Icons.person_outline),
            SumsTextField(controller: _personaFechaNacimiento, label: 'Fecha nacimiento', icon: Icons.event_outlined, validator: requiredText),
            DropdownButtonFormField<String>(
              initialValue: _personaSexo,
              decoration: const InputDecoration(labelText: 'Sexo'),
              items: const ['masculino', 'femenino']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _personaSexo = value ?? 'masculino'),
            ),
            _numberField(_personaEstadoCivil, 'Estado civil ID', Icons.favorite_border, required: false),
            _numberField(_personaLengua, 'Lengua ID', Icons.record_voice_over_outlined, required: false),
            _numberField(_personaEscolaridad, 'Escolaridad ID', Icons.school_outlined, required: false),
            _numberField(_personaOcupacion, 'Ocupacion ID', Icons.work_outline, required: false),
            _numberField(_personaIngreso, 'Ingreso salarial ID', Icons.payments_outlined, required: false),
          ]),
          BooleanSwitch(
            label: 'Alfabetizacion',
            value: _personaAlfabetizacion,
            onChanged: (value) => setState(() => _personaAlfabetizacion = value),
          ),
          _catalogHint('estado-civil, lengua, escolaridad, ocupacion, ingreso-salarial'),
          const SizedBox(height: 14),
          _saveButton(
            viewModel,
            label: 'Crear persona',
            onPressed: () => _submit(
              form: _personaForm,
              path: '/personas',
              captureIdAs: 'persona',
              successMessage: 'Persona creada.',
              bodyBuilder: () => {
                'primer_nombre': _personaPrimerNombre.text,
                'segundo_nombre': _personaSegundoNombre.text,
                'apellido_paterno': _personaApellidoPaterno.text,
                'apellido_materno': _personaApellidoMaterno.text,
                'fecha_nacimiento': _personaFechaNacimiento.text,
                'sexo': _personaSexo,
                'alfabetizacion': _personaAlfabetizacion,
                'estado_civil_id': optionalInt(_personaEstadoCivil.text),
                'lengua_id': optionalInt(_personaLengua.text),
                'escolaridad_id': optionalInt(_personaEscolaridad.text),
                'ocupacion_id': optionalInt(_personaOcupacion.text),
                'ingreso_salarial_id': optionalInt(_personaIngreso.text),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _integranteSection(CedulaViewModel viewModel) {
    return Form(
      key: _integranteForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Relacionar persona con nucleo', style: _sectionTitleStyle()),
          const SizedBox(height: 12),
          _grid([
            _numberField(_integranteNucleo, 'Nucleo familiar ID', Icons.groups_outlined),
            _numberField(_integrantePersona, 'Persona ID', Icons.person_outline),
            _numberField(_integranteParentesco, 'Parentesco ID', Icons.diversity_3_outlined, required: false),
            SumsTextField(controller: _integranteFechaSalida, label: 'Fecha salida', icon: Icons.event_busy_outlined),
          ]),
          SumsTextField(controller: _integranteComentarios, label: 'Comentarios', icon: Icons.notes_outlined),
          _catalogHint('parentesco'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _saveButton(
                  viewModel,
                  label: 'Agregar integrante',
                  onPressed: () => _submit(
                    form: _integranteForm,
                    pathBuilder: () =>
                        '/nucleos-familiares/${requiredInt(_integranteNucleo.text)}/integrantes',
                    successMessage: 'Integrante agregado.',
                    bodyBuilder: () => {
                      'persona_id': requiredInt(_integrantePersona.text),
                      'parentesco_id': optionalInt(_integranteParentesco.text),
                      'fecha_salida': _integranteFechaSalida.text,
                      'comentarios': _integranteComentarios.text,
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: viewModel.isLoading
                      ? null
                      : () => _submit(
                            form: _integranteForm,
                            pathBuilder: () =>
                                '/nucleos-familiares/${requiredInt(_integranteNucleo.text)}/integrantes/${requiredInt(_integrantePersona.text)}',
                            successMessage: 'Integrante actualizado.',
                            patch: true,
                            bodyBuilder: () => {
                              'parentesco_id': optionalInt(_integranteParentesco.text),
                              'fecha_salida': _integranteFechaSalida.text,
                              'comentarios': _integranteComentarios.text,
                            },
                          ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Actualizar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _viviendaSection(CedulaViewModel viewModel) {
    return Form(
      key: _viviendaForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Vivienda', style: _sectionTitleStyle()),
          const SizedBox(height: 12),
          _grid([
            _numberField(_viviendaNucleo, 'Nucleo familiar ID', Icons.groups_outlined),
            _numberField(_viviendaDireccion, 'Direccion ID', Icons.location_on_outlined, required: false),
            _numberField(_viviendaCuartos, 'Numero cuartos', Icons.meeting_room_outlined, required: false, nonNegative: true),
            _numberField(_viviendaHabitantes, 'Numero habitantes', Icons.people_outline, required: false, nonNegative: true),
            DropdownButtonFormField<String>(
              initialValue: _cocinaUbicacion,
              decoration: const InputDecoration(labelText: 'Ubicacion cocina'),
              items: const ['fuera_del_dormitorio', 'dentro_del_dormitorio']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _cocinaUbicacion = value ?? 'fuera_del_dormitorio'),
            ),
            _numberField(_viviendaManejoExcretas, 'Manejo excretas ID', Icons.wc_outlined, required: false),
          ]),
          BooleanSwitch(label: 'Cocina con lena', value: _cocinaConLena, onChanged: (value) => setState(() => _cocinaConLena = value)),
          BooleanSwitch(label: 'Red alcantarillado', value: _redAlcantarillado, onChanged: (value) => setState(() => _redAlcantarillado = value)),
          BooleanSwitch(label: 'Fosa septica', value: _fosaSeptica, onChanged: (value) => setState(() => _fosaSeptica = value)),
          SumsTextField(controller: _viviendaComentarios, label: 'Comentarios', icon: Icons.notes_outlined),
          _catalogHint('manejo-excretas'),
          const SizedBox(height: 14),
          _saveButton(
            viewModel,
            label: 'Guardar vivienda',
            onPressed: () => _submit(
              form: _viviendaForm,
              path: '/viviendas',
              captureIdAs: 'vivienda',
              successMessage: 'Vivienda guardada.',
              bodyBuilder: () => {
                'nucleo_familiar_id': requiredInt(_viviendaNucleo.text),
                'direccion_id': optionalInt(_viviendaDireccion.text),
                'numero_cuartos': optionalInt(_viviendaCuartos.text),
                'numero_habitantes': optionalInt(_viviendaHabitantes.text),
                'cocina_ubicacion': _cocinaUbicacion,
                'cocina_con_lena': _cocinaConLena,
                'manejo_excretas_id': optionalInt(_viviendaManejoExcretas.text),
                'red_alcantarillado': _redAlcantarillado,
                'fosa_septica': _fosaSeptica,
                'comentarios': _viviendaComentarios.text,
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _materialSection(CedulaViewModel viewModel) => Form(
        key: _materialForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Material de vivienda', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_materialVivienda, 'Vivienda ID', Icons.home_outlined),
              _numberField(_materialTipo, 'Tipo material vivienda ID', Icons.roofing_outlined),
              _numberField(_materialId, 'Material ID', Icons.construction_outlined, required: false),
              SumsTextField(controller: _materialOtro, label: 'Otro especificar', icon: Icons.edit_outlined),
            ]),
            _catalogHint('tipo-material-vivienda, material'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar material',
              onPressed: () => _submit(
                form: _materialForm,
                path: '/viviendas-materiales',
                successMessage: 'Material guardado.',
                bodyBuilder: () => {
                  'vivienda_id': requiredInt(_materialVivienda.text),
                  'tipo_material_vivienda_id': requiredInt(_materialTipo.text),
                  'material_id': optionalInt(_materialId.text),
                  'otro_especificar': _materialOtro.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _servicioViviendaSection(CedulaViewModel viewModel) => Form(
        key: _servicioForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Servicio de vivienda', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_servicioVivienda, 'Vivienda ID', Icons.home_outlined),
              _numberField(_servicioId, 'Servicio vivienda ID', Icons.water_drop_outlined),
            ]),
            BooleanSwitch(label: 'Disponible', value: _servicioDisponible, onChanged: (value) => setState(() => _servicioDisponible = value)),
            _catalogHint('servicio-vivienda'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar servicio',
              onPressed: () => _submit(
                form: _servicioForm,
                path: '/viviendas-servicios',
                successMessage: 'Servicio guardado.',
                bodyBuilder: () => {
                  'vivienda_id': requiredInt(_servicioVivienda.text),
                  'servicio_vivienda_id': requiredInt(_servicioId.text),
                  'disponible': _servicioDisponible,
                },
              ),
            ),
          ],
        ),
      );

  Widget _animalSection(CedulaViewModel viewModel) => Form(
        key: _animalForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Animales de la familia', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_animalNucleo, 'Nucleo familiar ID', Icons.groups_outlined),
              _numberField(_animalId, 'Animal ID', Icons.pets_outlined),
              _numberField(_animalCantidad, 'Cantidad', Icons.numbers_outlined, required: false, nonNegative: true),
              SumsTextField(controller: _animalComentarios, label: 'Comentarios', icon: Icons.notes_outlined),
            ]),
            BooleanSwitch(label: 'Vive dentro de vivienda', value: _animalDentro, onChanged: (value) => setState(() => _animalDentro = value)),
            BooleanSwitch(label: 'Esquema vacunas corriente', value: _animalVacunas, onChanged: (value) => setState(() => _animalVacunas = value)),
            BooleanSwitch(label: 'Esterilizado', value: _animalEsterilizado, onChanged: (value) => setState(() => _animalEsterilizado = value)),
            _catalogHint('animal'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar animal',
              onPressed: () => _submit(
                form: _animalForm,
                path: '/familias-animales',
                successMessage: 'Animal guardado.',
                bodyBuilder: () => {
                  'nucleo_familiar_id': requiredInt(_animalNucleo.text),
                  'animal_id': requiredInt(_animalId.text),
                  'cantidad': optionalInt(_animalCantidad.text),
                  'vive_dentro_vivienda': _animalDentro,
                  'esquema_vacunas_corriente': _animalVacunas,
                  'esterilizado': _animalEsterilizado,
                  'comentarios': _animalComentarios.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _alimentacionSection(CedulaViewModel viewModel) => Form(
        key: _alimentacionForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Alimentacion', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_alimentacionPersona, 'Persona ID', Icons.person_outline),
              _numberField(_alimentacionId, 'Alimentacion ID', Icons.restaurant_outlined),
              _numberField(_alimentacionFrecuencia, 'Frecuencia dias 0-7', Icons.calendar_view_week_outlined),
              SumsTextField(controller: _alimentacionFecha, label: 'Fecha registro', icon: Icons.event_outlined),
            ]),
            _catalogHint('alimentacion'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar alimentacion',
              onPressed: () => _submit(
                form: _alimentacionForm,
                path: '/personas-alimentacion',
                successMessage: 'Alimentacion guardada.',
                bodyBuilder: () => {
                  'persona_id': requiredInt(_alimentacionPersona.text),
                  'alimentacion_id': requiredInt(_alimentacionId.text),
                  'frecuencia_dias': requiredInt(_alimentacionFrecuencia.text),
                  'fecha_registro': _alimentacionFecha.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _higieneSection(CedulaViewModel viewModel) => Form(
        key: _higieneForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Higiene', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_higienePersona, 'Persona ID', Icons.person_outline),
              SumsTextField(controller: _higieneFecha, label: 'Fecha registro', icon: Icons.event_outlined),
            ]),
            BooleanSwitch(label: 'Bano y bucodental diaria', value: _higieneDiaria, onChanged: (value) => setState(() => _higieneDiaria = value)),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar higiene',
              onPressed: () => _submit(
                form: _higieneForm,
                path: '/personas-higiene',
                successMessage: 'Higiene guardada.',
                bodyBuilder: () => {
                  'persona_id': requiredInt(_higienePersona.text),
                  'higiene_bano_bucodental_diaria': _higieneDiaria,
                  'fecha_registro': _higieneFecha.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _preventivaSection(CedulaViewModel viewModel) => Form(
        key: _preventivaForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Salud preventiva', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_preventivaPersona, 'Persona ID', Icons.person_outline),
              _numberField(_preventivaAtencionEmbarazo, 'Atencion embarazo ID', Icons.pregnant_woman_outlined, required: false),
              SumsTextField(controller: _preventivaFechaCervico, label: 'Fecha tamizaje cervico uterino', icon: Icons.event_outlined),
              SumsTextField(controller: _preventivaFechaMama, label: 'Fecha tamizaje cancer mama', icon: Icons.event_outlined),
              SumsTextField(controller: _preventivaFechaRegistro, label: 'Fecha registro', icon: Icons.event_outlined),
            ]),
            BooleanSwitch(label: 'Tamizaje cervico uterino', value: _tamizajeCervico, onChanged: (value) => setState(() => _tamizajeCervico = value)),
            BooleanSwitch(label: 'Tamizaje cancer mama', value: _tamizajeMama, onChanged: (value) => setState(() => _tamizajeMama = value)),
            _catalogHint('atencion-embarazo'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar salud preventiva',
              onPressed: () => _submit(
                form: _preventivaForm,
                path: '/personas-salud-preventiva',
                successMessage: 'Salud preventiva guardada.',
                bodyBuilder: () => {
                  'persona_id': requiredInt(_preventivaPersona.text),
                  'atencion_embarazo_id': optionalInt(_preventivaAtencionEmbarazo.text),
                  'tamizaje_cervico_uterino': _tamizajeCervico,
                  'fecha_tamizaje_cervico_uterino': _preventivaFechaCervico.text,
                  'tamizaje_cancer_mama': _tamizajeMama,
                  'fecha_tamizaje_cancer_mama': _preventivaFechaMama.text,
                  'fecha_registro': _preventivaFechaRegistro.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _servicioSaludSection(CedulaViewModel viewModel) => Form(
        key: _servicioSaludForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Uso de servicios de salud', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_servicioSaludPersona, 'Persona ID', Icons.person_outline),
              _numberField(_servicioSaludFrecuencia, 'Frecuencia servicio salud ID', Icons.schedule_outlined, required: false),
              SumsTextField(controller: _servicioSaludMotivo, label: 'Motivo uso', icon: Icons.notes_outlined),
              SumsTextField(controller: _servicioSaludFecha, label: 'Fecha registro', icon: Icons.event_outlined),
            ]),
            _catalogHint('frecuencia-servicio-salud'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar servicio salud',
              onPressed: () => _submit(
                form: _servicioSaludForm,
                path: '/personas-servicios-salud',
                successMessage: 'Servicio de salud guardado.',
                bodyBuilder: () => {
                  'persona_id': requiredInt(_servicioSaludPersona.text),
                  'frecuencia_servicio_salud_id': optionalInt(_servicioSaludFrecuencia.text),
                  'motivo_uso': _servicioSaludMotivo.text,
                  'fecha_registro': _servicioSaludFecha.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _toxicomaniaSection(CedulaViewModel viewModel) => Form(
        key: _toxicomaniaForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Toxicomania', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_toxicomaniaPersona, 'Persona ID', Icons.person_outline),
              _numberField(_toxicomaniaId, 'Toxicomania ID', Icons.smoking_rooms_outlined),
              SumsTextField(controller: _toxicomaniaOtra, label: 'Otra sustancia', icon: Icons.edit_outlined),
              SumsTextField(controller: _toxicomaniaInicio, label: 'Fecha inicio', icon: Icons.event_outlined),
              SumsTextField(controller: _toxicomaniaFin, label: 'Fecha fin', icon: Icons.event_outlined),
            ]),
            _catalogHint('toxicomania'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar toxicomania',
              onPressed: () => _submit(
                form: _toxicomaniaForm,
                path: '/personas-toxicomanias',
                successMessage: 'Toxicomania guardada.',
                bodyBuilder: () => {
                  'persona_id': requiredInt(_toxicomaniaPersona.text),
                  'toxicomania_id': requiredInt(_toxicomaniaId.text),
                  'otra_sustancia': _toxicomaniaOtra.text,
                  'fecha_inicio': _toxicomaniaInicio.text,
                  'fecha_fin': _toxicomaniaFin.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _cronicaSection(CedulaViewModel viewModel) => Form(
        key: _cronicaForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Enfermedad cronica', style: _sectionTitleStyle()),
            const SizedBox(height: 12),
            _grid([
              _numberField(_cronicaPersona, 'Persona ID', Icons.person_outline),
              _numberField(_cronicaId, 'Enfermedad cronica ID', Icons.monitor_heart_outlined),
              SumsTextField(controller: _cronicaFecha, label: 'Fecha diagnostico', icon: Icons.event_outlined),
              SumsTextField(controller: _cronicaObservaciones, label: 'Observaciones', icon: Icons.notes_outlined),
            ]),
            _catalogHint('enfermedad-cronica'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar enfermedad',
              onPressed: () => _submit(
                form: _cronicaForm,
                path: '/personas-enfermedades-cronicas',
                successMessage: 'Enfermedad cronica guardada.',
                bodyBuilder: () => {
                  'persona_id': requiredInt(_cronicaPersona.text),
                  'enfermedad_cronica_id': requiredInt(_cronicaId.text),
                  'fecha_diagnostico': _cronicaFecha.text,
                  'observaciones': _cronicaObservaciones.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _vacunacionSection(CedulaViewModel viewModel) => Form(
        key: _vacunacionForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _grid([
              _numberField(_vacunacionPersona, 'Persona ID', Icons.person_outline, required: false),
              _numberField(_vacunacionEsquema, 'Esquema vacunacion ID', Icons.assignment_outlined, required: false),
              _numberField(_vacunacionUnidad, 'Unidad salud ID', Icons.local_hospital_outlined, required: false),
              _numberField(_vacunacionCedula, 'Cedula ID', Icons.assignment_outlined, required: false),
              _numberField(_vacunacionVacuna, 'Vacuna ID', Icons.vaccines_outlined),
              _numberField(_vacunacionDosis, 'Dosis ID', Icons.medication_liquid_outlined, required: false),
              SumsTextField(controller: _vacunacionFecha, label: 'Fecha aplicacion', icon: Icons.event_outlined),
            ]),
            _catalogHint('vacuna, dosis'),
            const SizedBox(height: 14),
            _saveButton(
              viewModel,
              label: 'Guardar inmunizacion',
              onPressed: () => _submit(
                form: _vacunacionForm,
                path: '/vacunaciones',
                successMessage: 'Inmunizacion guardada.',
                bodyBuilder: () => {
                  'persona_id': optionalInt(_vacunacionPersona.text),
                  'esquema_vacunacion_id': optionalInt(_vacunacionEsquema.text),
                  'unidad_salud_id': optionalInt(_vacunacionUnidad.text),
                  'cedula_id': optionalInt(_vacunacionCedula.text),
                  'vacuna_id': requiredInt(_vacunacionVacuna.text),
                  'dosis_id': optionalInt(_vacunacionDosis.text),
                  'fecha_aplicacion': _vacunacionFecha.text,
                },
              ),
            ),
          ],
        ),
      );

  Widget _grid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 720 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: children.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 4.2 : 4.5,
          ),
          itemBuilder: (_, index) => children[index],
        );
      },
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = true,
    bool nonNegative = false,
  }) {
    return SumsTextField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: TextInputType.number,
      validator: required
          ? positiveIntText
          : nonNegative
              ? nonNegativeIntText
              : null,
    );
  }

  Widget _saveButton(
    CedulaViewModel viewModel, {
    required String label,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: viewModel.isLoading ? null : onPressed,
      icon: viewModel.isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save_outlined),
      label: Text(label),
    );
  }

  Future<void> _submit({
    required GlobalKey<FormState> form,
    String? path,
    String Function()? pathBuilder,
    required Map<String, dynamic> Function() bodyBuilder,
    required String successMessage,
    String? captureIdAs,
    bool patch = false,
  }) async {
    if (!form.currentState!.validate()) return;
    final resolvedPath = path ?? pathBuilder?.call();
    if (resolvedPath == null) return;
    final body = bodyBuilder();
    final viewModel = context.read<CedulaViewModel>();
    final success = await viewModel.submit(
      path: resolvedPath,
      body: body,
      successMessage: successMessage,
      captureIdAs: captureIdAs,
      patch: patch,
    );
    if (!mounted || !success) return;
    _syncLastIds(viewModel);
  }

  void _syncLastIds(CedulaViewModel viewModel) {
    setState(() {
      if (viewModel.lastNucleoId != null) {
        final id = viewModel.lastNucleoId.toString();
        _cedulaNucleo.text = id;
        _viviendaNucleo.text = id;
        _integranteNucleo.text = id;
        _animalNucleo.text = id;
      }
      if (viewModel.lastPersonaId != null) {
        final id = viewModel.lastPersonaId.toString();
        _integrantePersona.text = id;
        _alimentacionPersona.text = id;
        _higienePersona.text = id;
        _preventivaPersona.text = id;
        _servicioSaludPersona.text = id;
        _toxicomaniaPersona.text = id;
        _cronicaPersona.text = id;
        _vacunacionPersona.text = id;
      }
      if (viewModel.lastCedulaId != null) {
        _vacunacionCedula.text = viewModel.lastCedulaId.toString();
      }
      if (viewModel.lastViviendaId != null) {
        final id = viewModel.lastViviendaId.toString();
        _materialVivienda.text = id;
        _servicioVivienda.text = id;
      }
    });
  }

  Widget _catalogHint(String keys) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        'Catalogos relacionados: $keys',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
            ),
      ),
    );
  }

  TextStyle? _sectionTitleStyle() {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.burgundy,
          fontWeight: FontWeight.w900,
        );
  }
}

class _StatusBanner extends StatelessWidget {
  final CedulaViewModel viewModel;

  const _StatusBanner({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final message = viewModel.errorMessage ?? viewModel.successMessage;
    if (message == null) {
      final catalogs = viewModel.catalogs.length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          catalogs == 0
              ? 'Catalogos pendientes de cargar. Puedes capturar IDs manualmente.'
              : 'Catalogos cargados: $catalogs. Puedes usar esos IDs en los formularios.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
        ),
      );
    }

    final isError = viewModel.errorMessage != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xffffdad6) : AppColors.soft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? const Color(0xffba1a1a) : AppColors.gold,
        ),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? const Color(0xff93000a) : AppColors.greenDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
