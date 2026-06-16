import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../widgets/form_helpers.dart';

class CedulaFormPage extends StatefulWidget {
  const CedulaFormPage({super.key});

  @override
  State<CedulaFormPage> createState() => _CedulaFormPageState();
}

class _CedulaFormPageState extends State<CedulaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <TextEditingController>[];
  final _vacunas = <_VaccineForm>[];
  final _integrantes = <_MemberForm>[];

  int _currentStep = 0;

  late final _informanteNombre = _c();
  late final _informanteEdad = _c();
  late final _domicilio = _c();
  late final _localidad = _c();
  late final _manzana = _c();
  late final _viviendaReferencia = _c();

  String? _rolInformante;

  String? _techo;
  String? _paredes;
  String? _piso;
  late final _materialOtros = _c();
  late final _cuartos = _c();
  late final _habitantes = _c();
  bool _aguaEntubada = false;
  bool _energiaElectrica = false;
  String? _cocina;
  bool _coccionLena = false;
  String? _excretas;
  bool _alcantarillado = false;
  bool _fosaSeptica = false;
  bool _perrosGatos = false;
  bool _animalesVacunas = false;
  bool _esterilizados = false;
  final _otrosAnimales = <String>{};
  late final _animalOtro = _c();
  late final _animalObservaciones = _c();

  bool _seAplicoVacuna = false;

  static const _steps = [
    _WizardStep('Familia', Icons.groups_outlined),
    _WizardStep('Vivienda', Icons.home_outlined),
    _WizardStep('Vacunación', Icons.vaccines_outlined),
    _WizardStep('Integrantes', Icons.people_alt_outlined),
  ];

  static const _roles = ['Madre', 'Padre', 'Hijo(a)', 'Abuelo(a)'];
  static const _materialesTechoParedes = [
    'Concreto o cemento',
    'Madera',
    'Lámina',
    'Otros',
  ];
  static const _materialesPiso = [
    'Concreto o cemento',
    'Madera',
    'Tierra',
    'Otros',
  ];
  static const _cocinas = ['Fuera del dormitorio', 'Dentro del dormitorio'];
  static const _excretasOptions = ['WC', 'Letrina', 'Al ras de suelo'];
  static const _otrosAnimalesOptions = [
    'Aves de corral',
    'Bovinos',
    'Porcinos',
    'NA',
  ];
  static const _vacunasOptions = [
    'BCG',
    'Hexavalente (DPaT+VPI+Hib+HepB)',
    'DPT',
    'Hepatitis A',
    'Hepatitis B',
    'COVID-19',
    'Neumocócica conjugada (13 valente)',
    'Influenza estacional',
    'Neumocócica polisacárida (23 serotipos)',
    'Rotavirus (RV1)',
    'SRP triple viral',
    'SR',
    'Td',
    'Tdpa',
    'VPH',
    'Varicela',
    'Otra',
  ];
  static const _dosisOptions = ['Única', '1era', '2da', '3era', 'Refuerzo'];
  static const _sexoOptions = ['Masculino', 'Femenino'];
  static const _estadoCivilOptions = [
    'Soltero(a)',
    'Casado(a)',
    'Viudo(a)',
    'Unión libre',
  ];
  static const _lenguaOptions = ['Español', 'Lengua indígena'];
  static const _escolaridadOptions = [
    'NA',
    'Preescolar',
    'Primaria',
    'Secundaria',
    'Bachillerato',
    'Licenciatura',
    'Maestría',
    'Doctorado',
  ];
  static const _ingresoOptions = [
    'Hasta un salario mínimo',
    '1 a 2',
    '2 a 3',
    '3 a 5',
    'Mayor a 5',
    'No recibe ingresos',
  ];
  static const _toxicomaniasOptions = [
    'NA',
    'Alcoholismo',
    'Tabaquismo',
    'Otras sustancias',
  ];
  static const _cronicasOptions = [
    'NA',
    'Obesidad',
    'Hipertensión',
    'Diabetes Mellitus tipo 2',
    'Tosedor crónico',
  ];
  static const _embarazoOptions = [
    'NA',
    'Sector público',
    'Sector privado',
    'Hogar',
  ];
  static const _frecuenciaSaludOptions = [
    'Mensual',
    'Trimestral',
    'Semestral',
    'Anual',
  ];
  static const _tamizajeOptions = ['Sí', 'No', 'NA'];

  @override
  void initState() {
    super.initState();
    _vacunas.add(_newVaccineForm());
    _integrantes.add(_newMemberForm());
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

  _VaccineForm _newVaccineForm() {
    return _VaccineForm(
      paciente: _c(),
      fechaNacimiento: _c(),
      edad: _c(),
      otraVacuna: _c(),
    );
  }

  _MemberForm _newMemberForm() {
    return _MemberForm(
      nombre: _c(),
      fechaNacimiento: _c(),
      edad: _c(),
      lenguaEspecificar: _c(),
      ocupacion: _c(),
      proteina: _c(),
      frutasVerduras: _c(),
      cereales: _c(),
      otraSustancia: _c(),
      tipoDiscapacidad: _c(),
      fechaCervico: _c(),
      fechaMama: _c(),
      motivoSalud: _c(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cédula familiar')),
      body: SafeArea(
        child: Column(
          children: [
            _progressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Form(key: _formKey, child: _currentStepContent()),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _progressHeader() {
    final progress = (_currentStep + 1) / _steps.length;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _steps[_currentStep].label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.greenDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${_currentStep + 1}/${_steps.length}',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.soft,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var index = 0; index < _steps.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: Icon(_steps[index].icon, size: 18),
                      label: Text(_steps[index].label),
                      selected: index == _currentStep,
                      onSelected: (_) => setState(() => _currentStep = index),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currentStepContent() {
    switch (_currentStep) {
      case 0:
        return _familiaStep();
      case 1:
        return _viviendaStep();
      case 2:
        return _vacunacionStep();
      case 3:
        return _integrantesStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _familiaStep() {
    return _panel(
      title: 'III. Identificación de la familia',
      icon: Icons.groups_outlined,
      children: [
        _fieldGrid([
          SumsTextField(
            controller: _informanteNombre,
            label: 'Nombre completo del informante',
            icon: Icons.person_outline,
          ),
          _numberField(
            _informanteEdad,
            'Edad del informante',
            Icons.cake_outlined,
          ),
          _select(
            label: 'Rol familiar',
            icon: Icons.diversity_3_outlined,
            value: _rolInformante,
            options: _roles,
            onChanged: (value) => setState(() => _rolInformante = value),
          ),
          SumsTextField(
            controller: _domicilio,
            label: 'Domicilio',
            icon: Icons.location_on_outlined,
          ),
          SumsTextField(
            controller: _localidad,
            label: 'Localidad',
            icon: Icons.location_city_outlined,
          ),
          SumsTextField(
            controller: _manzana,
            label: 'Manzana',
            icon: Icons.grid_view_outlined,
          ),
          SumsTextField(
            controller: _viviendaReferencia,
            label: 'Vivienda',
            icon: Icons.home_work_outlined,
          ),
        ]),
      ],
    );
  }

  Widget _viviendaStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(
          title: 'IV. Características de la vivienda',
          icon: Icons.home_outlined,
          children: [
            _fieldGrid([
              _select(
                label: 'Techo',
                icon: Icons.roofing_outlined,
                value: _techo,
                options: _materialesTechoParedes,
                onChanged: (value) => setState(() => _techo = value),
              ),
              _select(
                label: 'Paredes',
                icon: Icons.foundation_outlined,
                value: _paredes,
                options: _materialesTechoParedes,
                onChanged: (value) => setState(() => _paredes = value),
              ),
              _select(
                label: 'Piso',
                icon: Icons.square_foot_outlined,
                value: _piso,
                options: _materialesPiso,
                onChanged: (value) => setState(() => _piso = value),
              ),
              SumsTextField(
                controller: _materialOtros,
                label: 'Otros materiales, especificar',
                icon: Icons.edit_outlined,
              ),
              _numberField(
                _cuartos,
                'Número de cuartos',
                Icons.meeting_room_outlined,
              ),
              _numberField(
                _habitantes,
                'Número de habitantes',
                Icons.people_outline,
              ),
            ]),
            const SizedBox(height: 14),
            _toggleGrid([
              _yesNo(
                'Agua entubada',
                _aguaEntubada,
                (value) => setState(() => _aguaEntubada = value),
              ),
              _yesNo(
                'Energía eléctrica',
                _energiaElectrica,
                (value) => setState(() => _energiaElectrica = value),
              ),
            ]),
            const SizedBox(height: 14),
            _fieldGrid([
              _select(
                label: 'Ubicación de cocina',
                icon: Icons.restaurant_outlined,
                value: _cocina,
                options: _cocinas,
                onChanged: (value) => setState(() => _cocina = value),
              ),
              _select(
                label: 'Manejo de excretas',
                icon: Icons.wc_outlined,
                value: _excretas,
                options: _excretasOptions,
                onChanged: (value) => setState(() => _excretas = value),
              ),
            ]),
            const SizedBox(height: 14),
            _toggleGrid([
              _yesNo(
                'Cocción con leña',
                _coccionLena,
                (value) => setState(() => _coccionLena = value),
              ),
              _yesNo(
                'Red de alcantarillado',
                _alcantarillado,
                (value) => setState(() => _alcantarillado = value),
              ),
              _yesNo(
                'Fosa séptica',
                _fosaSeptica,
                (value) => setState(() => _fosaSeptica = value),
              ),
              _yesNo(
                'Perros y/o gatos dentro',
                _perrosGatos,
                (value) => setState(() => _perrosGatos = value),
              ),
              _yesNo(
                'Vacunas corrientes',
                _animalesVacunas,
                (value) => setState(() => _animalesVacunas = value),
              ),
              _yesNo(
                'Mascotas esterilizadas',
                _esterilizados,
                (value) => setState(() => _esterilizados = value),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 14),
        _panel(
          title: 'Convivencia con animales',
          icon: Icons.pets_outlined,
          children: [
            _chipGroup(
              label: 'Otros animales',
              options: _otrosAnimalesOptions,
              selected: _otrosAnimales,
              onToggle: (option) => _toggleSet(_otrosAnimales, option),
            ),
            const SizedBox(height: 12),
            _fieldGrid([
              SumsTextField(
                controller: _animalOtro,
                label: 'Otros, especificar',
                icon: Icons.edit_outlined,
              ),
              SumsTextField(
                controller: _animalObservaciones,
                label: 'Comentarios/observaciones',
                icon: Icons.notes_outlined,
                minLines: 2,
                maxLines: 4,
              ),
            ]),
          ],
        ),
      ],
    );
  }

  Widget _vacunacionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panel(
          title: 'V. Esquema de vacunación',
          icon: Icons.vaccines_outlined,
          children: [
            _yesNo(
              'Se aplicó vacuna durante la visita',
              _seAplicoVacuna,
              (value) => setState(() => _seAplicoVacuna = value),
            ),
          ],
        ),
        if (_seAplicoVacuna) ...[
          const SizedBox(height: 14),
          for (var index = 0; index < _vacunas.length; index++)
            _vaccineCard(index, _vacunas[index]),
          OutlinedButton.icon(
            onPressed: () => setState(() => _vacunas.add(_newVaccineForm())),
            icon: const Icon(Icons.add_outlined),
            label: const Text('Agregar otra vacuna'),
          ),
        ],
      ],
    );
  }

  Widget _vaccineCard(int index, _VaccineForm vacuna) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _itemHeader(
              title: 'Vacuna ${index + 1}',
              canRemove: _vacunas.length > 1,
              onRemove: () => setState(() => _vacunas.removeAt(index)),
            ),
            const SizedBox(height: 12),
            _fieldGrid([
              SumsTextField(
                controller: vacuna.paciente,
                label: 'Identificación del paciente',
                icon: Icons.person_outline,
              ),
              SumsTextField(
                controller: vacuna.fechaNacimiento,
                label: 'Fecha de nacimiento',
                icon: Icons.event_outlined,
                keyboardType: TextInputType.datetime,
              ),
              _numberField(vacuna.edad, 'Edad', Icons.cake_outlined),
              _select(
                label: 'Vacuna aplicada',
                icon: Icons.vaccines_outlined,
                value: vacuna.tipo,
                options: _vacunasOptions,
                onChanged: (value) => setState(() => vacuna.tipo = value),
              ),
              _select(
                label: 'Dosis',
                icon: Icons.medication_liquid_outlined,
                value: vacuna.dosis,
                options: _dosisOptions,
                onChanged: (value) => setState(() => vacuna.dosis = value),
              ),
              SumsTextField(
                controller: vacuna.otraVacuna,
                label: 'Otra, especificar',
                icon: Icons.edit_outlined,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _integrantesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < _integrantes.length; index++)
          _memberCard(index, _integrantes[index]),
        OutlinedButton.icon(
          onPressed: () => setState(() => _integrantes.add(_newMemberForm())),
          icon: const Icon(Icons.person_add_alt_outlined),
          label: const Text('Agregar integrante'),
        ),
      ],
    );
  }

  Widget _memberCard(int index, _MemberForm member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _itemHeader(
              title: 'VI. Integrante ${index + 1}',
              canRemove: _integrantes.length > 1,
              onRemove: () => setState(() => _integrantes.removeAt(index)),
            ),
            const SizedBox(height: 12),
            _fieldGrid([
              SumsTextField(
                controller: member.nombre,
                label: 'Nombre completo',
                icon: Icons.person_outline,
              ),
              _select(
                label: 'Sexo',
                icon: Icons.wc_outlined,
                value: member.sexo,
                options: _sexoOptions,
                onChanged: (value) => setState(() => member.sexo = value),
              ),
              SumsTextField(
                controller: member.fechaNacimiento,
                label: 'Fecha de nacimiento',
                icon: Icons.event_outlined,
                keyboardType: TextInputType.datetime,
              ),
              _numberField(member.edad, 'Edad', Icons.cake_outlined),
              _select(
                label: 'Estado civil',
                icon: Icons.favorite_border,
                value: member.estadoCivil,
                options: _estadoCivilOptions,
                onChanged: (value) =>
                    setState(() => member.estadoCivil = value),
              ),
              _select(
                label: 'Lengua',
                icon: Icons.record_voice_over_outlined,
                value: member.lengua,
                options: _lenguaOptions,
                onChanged: (value) => setState(() => member.lengua = value),
              ),
              SumsTextField(
                controller: member.lenguaEspecificar,
                label: 'Lengua indígena, especificar',
                icon: Icons.edit_outlined,
              ),
              _select(
                label: 'Parentesco/rol familiar',
                icon: Icons.diversity_3_outlined,
                value: member.parentesco,
                options: _roles,
                onChanged: (value) => setState(() => member.parentesco = value),
              ),
              _select(
                label: 'Escolaridad',
                icon: Icons.school_outlined,
                value: member.escolaridad,
                options: _escolaridadOptions,
                onChanged: (value) =>
                    setState(() => member.escolaridad = value),
              ),
              SumsTextField(
                controller: member.ocupacion,
                label: 'Ocupación',
                icon: Icons.work_outline,
              ),
              _select(
                label: 'Ingreso - salario mínimo',
                icon: Icons.payments_outlined,
                value: member.ingreso,
                options: _ingresoOptions,
                onChanged: (value) => setState(() => member.ingreso = value),
              ),
            ]),
            const SizedBox(height: 14),
            _toggleGrid([
              _yesNo(
                'Alfabetización',
                member.alfabetizacion,
                (value) => setState(() => member.alfabetizacion = value),
              ),
              _yesNo(
                'Seguridad social',
                member.seguridadSocial,
                (value) => setState(() => member.seguridadSocial = value),
              ),
              _yesNo(
                'Higiene buco-dental diaria',
                member.higiene,
                (value) => setState(() => member.higiene = value),
              ),
              _yesNo(
                'Presenta discapacidad',
                member.discapacidad,
                (value) => setState(() => member.discapacidad = value),
              ),
            ]),
            const SizedBox(height: 14),
            _fieldGrid([
              _daysField(member.proteina, 'Carne, pescado y pollo'),
              _daysField(member.frutasVerduras, 'Frutas y verduras'),
              _daysField(member.cereales, 'Cereales, granos y leguminosas'),
              SumsTextField(
                controller: member.tipoDiscapacidad,
                label: 'Tipo de discapacidad',
                icon: Icons.accessible_forward_outlined,
              ),
            ]),
            const SizedBox(height: 14),
            _chipGroup(
              label: 'Toxicomanías',
              options: _toxicomaniasOptions,
              selected: member.toxicomanias,
              onToggle: (option) => setState(
                () => _toggleSet(member.toxicomanias, option, rebuild: false),
              ),
            ),
            const SizedBox(height: 12),
            SumsTextField(
              controller: member.otraSustancia,
              label: 'Otra sustancia, especificar',
              icon: Icons.edit_outlined,
            ),
            const SizedBox(height: 14),
            _chipGroup(
              label: 'Enfermedades crónico-degenerativas',
              options: _cronicasOptions,
              selected: member.cronicas,
              onToggle: (option) => setState(
                () => _toggleSet(member.cronicas, option, rebuild: false),
              ),
            ),
            const SizedBox(height: 14),
            _fieldGrid([
              _select(
                label: 'Atención de embarazo',
                icon: Icons.pregnant_woman_outlined,
                value: member.embarazo,
                options: _embarazoOptions,
                onChanged: (value) => setState(() => member.embarazo = value),
              ),
              _select(
                label: 'Tamizaje cáncer cérvico-uterino',
                icon: Icons.health_and_safety_outlined,
                value: member.tamizajeCervico,
                options: _tamizajeOptions,
                onChanged: (value) =>
                    setState(() => member.tamizajeCervico = value),
              ),
              SumsTextField(
                controller: member.fechaCervico,
                label: 'Fecha cérvico-uterino',
                icon: Icons.event_outlined,
                keyboardType: TextInputType.datetime,
              ),
              _select(
                label: 'Tamizaje cáncer de mama',
                icon: Icons.medical_services_outlined,
                value: member.tamizajeMama,
                options: _tamizajeOptions,
                onChanged: (value) =>
                    setState(() => member.tamizajeMama = value),
              ),
              SumsTextField(
                controller: member.fechaMama,
                label: 'Fecha cáncer de mama',
                icon: Icons.event_outlined,
                keyboardType: TextInputType.datetime,
              ),
              _select(
                label: 'Servicios de salud: frecuencia',
                icon: Icons.schedule_outlined,
                value: member.frecuenciaSalud,
                options: _frecuenciaSaludOptions,
                onChanged: (value) =>
                    setState(() => member.frecuenciaSalud = value),
              ),
              SumsTextField(
                controller: member.motivoSalud,
                label: 'Servicios de salud: motivo de uso',
                icon: Icons.notes_outlined,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _panel({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  child: Icon(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.greenDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _itemHeader({
    required String title,
    required bool canRemove,
    required VoidCallback onRemove,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.burgundy,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (canRemove)
          IconButton(
            tooltip: 'Quitar',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }

  Widget _toggleGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final width = (constraints.maxWidth - (12 * (columns - 1))) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }

  Widget _select({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: options
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _yesNo(String label, bool value, ValueChanged<bool> onChanged) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: true, label: Text('Sí')),
          ButtonSegment(value: false, label: Text('No')),
        ],
        selected: {value},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }

  Widget _chipGroup({
    required String label,
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in options)
            FilterChip(
              label: Text(option),
              selected: selected.contains(option),
              onSelected: (_) => onToggle(option),
            ),
        ],
      ),
    );
  }

  void _toggleSet(Set<String> selected, String option, {bool rebuild = true}) {
    void mutate() {
      if (option == 'NA') {
        selected
          ..clear()
          ..add(option);
        return;
      }
      selected.remove('NA');
      if (selected.contains(option)) {
        selected.remove(option);
      } else {
        selected.add(option);
      }
    }

    if (rebuild) {
      setState(mutate);
    } else {
      mutate();
    }
  }

  Widget _numberField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return SumsTextField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: TextInputType.number,
      validator: nonNegativeIntText,
    );
  }

  Widget _daysField(TextEditingController controller, String label) {
    return SumsTextField(
      controller: controller,
      label: label,
      icon: Icons.calendar_view_week_outlined,
      helperText: '0 a 7 días',
      keyboardType: TextInputType.number,
      validator: _daysText,
    );
  }

  String? _daysText(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 7) {
      return 'Ingresa un número de 0 a 7';
    }
    return null;
  }

  Widget _bottomBar() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == _steps.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isFirst
                  ? null
                  : () => setState(() => _currentStep = _currentStep - 1),
              icon: const Icon(Icons.arrow_back_outlined),
              label: const Text('Anterior'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: isLast ? _finishCapture : _goNext,
              icon: Icon(
                isLast ? Icons.check_outlined : Icons.arrow_forward_outlined,
              ),
              label: Text(isLast ? 'Guardar' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }

  void _goNext() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _currentStep = _currentStep + 1);
  }

  void _finishCapture() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Captura revisada y lista para guardar.')),
    );
  }
}

class _WizardStep {
  final String label;
  final IconData icon;

  const _WizardStep(this.label, this.icon);
}

class _VaccineForm {
  final TextEditingController paciente;
  final TextEditingController fechaNacimiento;
  final TextEditingController edad;
  final TextEditingController otraVacuna;
  String? tipo;
  String? dosis;

  _VaccineForm({
    required this.paciente,
    required this.fechaNacimiento,
    required this.edad,
    required this.otraVacuna,
  });
}

class _MemberForm {
  final TextEditingController nombre;
  final TextEditingController fechaNacimiento;
  final TextEditingController edad;
  final TextEditingController lenguaEspecificar;
  final TextEditingController ocupacion;
  final TextEditingController proteina;
  final TextEditingController frutasVerduras;
  final TextEditingController cereales;
  final TextEditingController otraSustancia;
  final TextEditingController tipoDiscapacidad;
  final TextEditingController fechaCervico;
  final TextEditingController fechaMama;
  final TextEditingController motivoSalud;

  String? sexo;
  String? estadoCivil;
  String? lengua;
  String? parentesco;
  String? escolaridad;
  String? ingreso;
  String? embarazo;
  String? tamizajeCervico;
  String? tamizajeMama;
  String? frecuenciaSalud;

  bool alfabetizacion = false;
  bool seguridadSocial = false;
  bool higiene = false;
  bool discapacidad = false;

  final toxicomanias = <String>{};
  final cronicas = <String>{};

  _MemberForm({
    required this.nombre,
    required this.fechaNacimiento,
    required this.edad,
    required this.lenguaEspecificar,
    required this.ocupacion,
    required this.proteina,
    required this.frutasVerduras,
    required this.cereales,
    required this.otraSustancia,
    required this.tipoDiscapacidad,
    required this.fechaCervico,
    required this.fechaMama,
    required this.motivoSalud,
  });
}
