import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/sums_text_field.dart';
import '../widgets/form_helpers.dart';

class CedulaFormPage extends StatefulWidget {
  const CedulaFormPage({super.key});

  @override
  State<CedulaFormPage> createState() => _CedulaFormPageState();
}

class _CedulaFormPageState extends State<CedulaFormPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <TextEditingController>[];
  final _vacunas = <_VaccineForm>[];
  final _integrantes = <_MemberForm>[];

  int _currentStep = 0;
  late final AnimationController _animController;

  late final _informanteNombre = _c();
  late final _informanteEdad   = _c();
  late final _domicilio        = _c();
  late final _localidad        = _c();
  late final _manzana          = _c();
  late final _viviendaRef      = _c();

  String? _rolInformante;
  String? _techo;
  String? _paredes;
  String? _piso;
  late final _materialOtros       = _c();
  late final _cuartos             = _c();
  late final _habitantes          = _c();
  bool _aguaEntubada  = false;
  bool _energiaElect  = false;
  String? _cocina;
  bool _coccionLena   = false;
  String? _excretas;
  bool _alcantarillado = false;
  bool _fosaSeptica    = false;
  bool _perrosGatos    = false;
  bool _animVacunas    = false;
  bool _esterilizados  = false;
  final _otrosAnimales = <String>{};
  late final _animalOtro  = _c();
  late final _animalObs   = _c();

  bool _seAplicoVacuna = false;

  static const _steps = [
    _WizardStep('Familia',     Icons.groups_outlined,      AppColors.green),
    _WizardStep('Vivienda',    Icons.home_outlined,        AppColors.terracota),
    _WizardStep('Vacunación',  Icons.vaccines_outlined,    AppColors.burgundy),
    _WizardStep('Integrantes', Icons.people_alt_outlined,  AppColors.gold),
  ];

  // catálogos de opciones ─────────────────────────────────────────────────────
  static const _roles = ['Madre', 'Padre', 'Hijo(a)', 'Abuelo(a)'];
  static const _matTechoParedes  = ['Concreto o cemento', 'Madera', 'Lámina', 'Otros'];
  static const _matPiso          = ['Concreto o cemento', 'Madera', 'Tierra', 'Otros'];
  static const _cocinas          = ['Fuera del dormitorio', 'Dentro del dormitorio'];
  static const _excretasOpts     = ['WC', 'Letrina', 'Al ras de suelo'];
  static const _otrosAnimalesOpts = ['Aves de corral', 'Bovinos', 'Porcinos', 'NA'];
  static const _vacunasOpts = [
    'BCG', 'Hexavalente (DPaT+VPI+Hib+HepB)', 'DPT', 'Hepatitis A',
    'Hepatitis B', 'COVID-19', 'Neumocócica conjugada (13 valente)',
    'Influenza estacional', 'Neumocócica polisacárida (23 serotipos)',
    'Rotavirus (RV1)', 'SRP triple viral', 'SR', 'Td', 'Tdpa',
    'VPH', 'Varicela', 'Otra',
  ];
  static const _dosisOpts      = ['Única', '1era', '2da', '3era', 'Refuerzo'];
  static const _sexoOpts       = ['Masculino', 'Femenino'];
  static const _edoCivilOpts   = ['Soltero(a)', 'Casado(a)', 'Viudo(a)', 'Unión libre'];
  static const _lenguaOpts     = ['Español', 'Lengua indígena'];
  static const _escolaridadOpts = [
    'NA', 'Preescolar', 'Primaria', 'Secundaria',
    'Bachillerato', 'Licenciatura', 'Maestría', 'Doctorado',
  ];
  static const _ingresoOpts = [
    'Hasta un salario mínimo', '1 a 2', '2 a 3', '3 a 5',
    'Mayor a 5', 'No recibe ingresos',
  ];
  static const _toxicomaniasOpts  = ['NA', 'Alcoholismo', 'Tabaquismo', 'Otras sustancias'];
  static const _cronicasOpts      = ['NA', 'Obesidad', 'Hipertensión', 'Diabetes Mellitus tipo 2', 'Tosedor crónico'];
  static const _embarazoOpts      = ['NA', 'Sector público', 'Sector privado', 'Hogar'];
  static const _freqSaludOpts     = ['Mensual', 'Trimestral', 'Semestral', 'Anual'];
  static const _tamizajeOpts      = ['Sí', 'No', 'NA'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _vacunas.add(_newVaccineForm());
    _integrantes.add(_newMemberForm());
  }

  @override
  void dispose() {
    _animController.dispose();
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  TextEditingController _c([String t = '']) {
    final c = TextEditingController(text: t);
    _controllers.add(c);
    return c;
  }

  _VaccineForm _newVaccineForm() => _VaccineForm(
        paciente: _c(), fechaNacimiento: _c(), edad: _c(), otraVacuna: _c());

  _MemberForm _newMemberForm() => _MemberForm(
        nombre: _c(), fechaNacimiento: _c(), edad: _c(),
        lenguaEsp: _c(), ocupacion: _c(), proteina: _c(),
        frutasVerd: _c(), cereales: _c(), otraSust: _c(),
        tipoDisc: _c(), fechaCervico: _c(), fechaMama: _c(),
        motivoSalud: _c(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _WizardHeader(
              steps:       _steps,
              currentStep: _currentStep,
              onStepTap:   (i) => setState(() => _currentStep = i),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: SingleChildScrollView(
                  key: ValueKey(_currentStep),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Form(
                    key: _formKey,
                    child: _currentStepContent(),
                  ),
                ),
              ),
            ),
            _BottomNav(
              currentStep: _currentStep,
              totalSteps:  _steps.length,
              onBack: () => setState(() => _currentStep--),
              onNext: _goNext,
              onFinish: _finishCapture,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cédula familiar'),
            Text(
              _steps[_currentStep].label,
              style: const TextStyle(
                fontSize: 11, color: AppColors.muted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _steps[_currentStep].color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentStep + 1} / ${_steps.length}',
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: _steps[_currentStep].color,
              ),
            ),
          ),
        ],
      );

  Widget _currentStepContent() {
    switch (_currentStep) {
      case 0: return _familiaStep();
      case 1: return _viviendaStep();
      case 2: return _vacunacionStep();
      case 3: return _integrantesStep();
      default: return const SizedBox.shrink();
    }
  }

  // ── Pasos ─────────────────────────────────────────────────────────────────

  Widget _familiaStep() => _StepPanel(
        title:    'III. Identificación de la familia',
        icon:     Icons.groups_outlined,
        color:    AppColors.green,
        children: [
          _fieldGrid([
            SumsTextField(controller: _informanteNombre, label: 'Nombre del informante', icon: Icons.person_outline),
            _numberField(_informanteEdad, 'Edad del informante', Icons.cake_outlined),
            _select(label: 'Rol familiar', icon: Icons.diversity_3_outlined, value: _rolInformante, options: _roles, onChanged: (v) => setState(() => _rolInformante = v)),
            SumsTextField(controller: _domicilio,    label: 'Domicilio',  icon: Icons.location_on_outlined),
            SumsTextField(controller: _localidad,    label: 'Localidad',  icon: Icons.location_city_outlined),
            SumsTextField(controller: _manzana,      label: 'Manzana',    icon: Icons.grid_view_outlined),
            SumsTextField(controller: _viviendaRef,  label: 'Vivienda',   icon: Icons.home_work_outlined),
          ]),
        ],
      );

  Widget _viviendaStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepPanel(
            title: 'IV. Características de la vivienda',
            icon: Icons.home_outlined,
            color: AppColors.terracota,
            children: [
              _fieldGrid([
                _select(label: 'Techo',   icon: Icons.roofing_outlined,    value: _techo,   options: _matTechoParedes, onChanged: (v) => setState(() => _techo   = v)),
                _select(label: 'Paredes', icon: Icons.foundation_outlined,  value: _paredes, options: _matTechoParedes, onChanged: (v) => setState(() => _paredes = v)),
                _select(label: 'Piso',   icon: Icons.square_foot_outlined,  value: _piso,    options: _matPiso,         onChanged: (v) => setState(() => _piso    = v)),
                SumsTextField(controller: _materialOtros, label: 'Otros materiales, especificar', icon: Icons.edit_outlined),
                _numberField(_cuartos,   'Número de cuartos',   Icons.meeting_room_outlined),
                _numberField(_habitantes, 'Número de habitantes', Icons.people_outline),
              ]),
              const SizedBox(height: 14),
              _sectionDivider('Servicios básicos'),
              const SizedBox(height: 12),
              _toggleGrid([
                _yesNo('Agua entubada',    _aguaEntubada, (v) => setState(() => _aguaEntubada = v)),
                _yesNo('Energía eléctrica', _energiaElect, (v) => setState(() => _energiaElect = v)),
                _yesNo('Cocción con leña', _coccionLena,  (v) => setState(() => _coccionLena = v)),
              ]),
              const SizedBox(height: 14),
              _fieldGrid([
                _select(label: 'Ubicación de cocina',   icon: Icons.restaurant_outlined, value: _cocina,   options: _cocinas,      onChanged: (v) => setState(() => _cocina   = v)),
                _select(label: 'Manejo de excretas',    icon: Icons.wc_outlined,         value: _excretas, options: _excretasOpts, onChanged: (v) => setState(() => _excretas = v)),
              ]),
              const SizedBox(height: 14),
              _toggleGrid([
                _yesNo('Red de alcantarillado', _alcantarillado, (v) => setState(() => _alcantarillado = v)),
                _yesNo('Fosa séptica',           _fosaSeptica,   (v) => setState(() => _fosaSeptica   = v)),
              ]),
            ],
          ),
          const SizedBox(height: 14),
          _StepPanel(
            title: 'Convivencia con animales',
            icon: Icons.pets_outlined,
            color: AppColors.gold,
            children: [
              _toggleGrid([
                _yesNo('Perros y/o gatos dentro', _perrosGatos,    (v) => setState(() => _perrosGatos   = v)),
                _yesNo('Vacunas corrientes',        _animVacunas,   (v) => setState(() => _animVacunas   = v)),
                _yesNo('Mascotas esterilizadas',    _esterilizados, (v) => setState(() => _esterilizados = v)),
              ]),
              const SizedBox(height: 14),
              _chipGroup(label: 'Otros animales', options: _otrosAnimalesOpts, selected: _otrosAnimales, onToggle: (o) => _toggleSet(_otrosAnimales, o)),
              const SizedBox(height: 12),
              _fieldGrid([
                SumsTextField(controller: _animalOtro, label: 'Otros, especificar', icon: Icons.edit_outlined),
                SumsTextField(controller: _animalObs,  label: 'Observaciones',     icon: Icons.notes_outlined, minLines: 2, maxLines: 4),
              ]),
            ],
          ),
        ],
      );

  Widget _vacunacionStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepPanel(
            title: 'V. Esquema de vacunación',
            icon: Icons.vaccines_outlined,
            color: AppColors.burgundy,
            children: [
              _yesNo('Se aplicó vacuna durante la visita', _seAplicoVacuna, (v) => setState(() => _seAplicoVacuna = v)),
            ],
          ),
          if (_seAplicoVacuna) ...[
            const SizedBox(height: 14),
            for (var i = 0; i < _vacunas.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _VaccineCard(
                  index: i,
                  form: _vacunas[i],
                  canRemove: _vacunas.length > 1,
                  onRemove: () => setState(() => _vacunas.removeAt(i)),
                  vacunasOpts: _vacunasOpts,
                  dosisOpts: _dosisOpts,
                  onChanged: () => setState(() {}),
                  numberField: _numberField,
                  select: _select,
                  c: _c,
                ),
              ),
            OutlinedButton.icon(
              onPressed: () => setState(() => _vacunas.add(_newVaccineForm())),
              icon: const Icon(Icons.add_outlined),
              label: const Text('Agregar otra vacuna'),
            ),
          ],
        ],
      );

  Widget _integrantesStep() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _integrantes.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _MemberCard(
                index: i,
                form: _integrantes[i],
                canRemove: _integrantes.length > 1,
                onRemove: () => setState(() => _integrantes.removeAt(i)),
                onChanged: () => setState(() {}),
                // opciones
                roles: _roles, sexoOpts: _sexoOpts, edoCivilOpts: _edoCivilOpts,
                lenguaOpts: _lenguaOpts, escolaridadOpts: _escolaridadOpts,
                ingresoOpts: _ingresoOpts, embarazoOpts: _embarazoOpts,
                tamizajeOpts: _tamizajeOpts, freqSaludOpts: _freqSaludOpts,
                toxicomaniasOpts: _toxicomaniasOpts, cronicasOpts: _cronicasOpts,
                // helpers
                select: _select, toggleSet: _toggleSet,
                numberField: _numberField, daysField: _daysField,
              ),
            ),
          OutlinedButton.icon(
            onPressed: () => setState(() => _integrantes.add(_newMemberForm())),
            icon: const Icon(Icons.person_add_alt_outlined),
            label: const Text('Agregar integrante'),
          ),
          const SizedBox(height: 80), // espacio para el FAB
        ],
      );

  // ── Helpers de layout ─────────────────────────────────────────────────────

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(builder: (_, c) {
      if (c.maxWidth < 720) {
        return Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      }
      final w = (c.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12, runSpacing: 12,
        children: [for (final child in children) SizedBox(width: w, child: child)],
      );
    });
  }

  Widget _toggleGrid(List<Widget> children) {
    return LayoutBuilder(builder: (_, c) {
      final cols = c.maxWidth >= 900 ? 3 : c.maxWidth >= 560 ? 2 : 1;
      final w = (c.maxWidth - 12 * (cols - 1)) / cols;
      return Wrap(
        spacing: 12, runSpacing: 12,
        children: [for (final child in children) SizedBox(width: w, child: child)],
      );
    });
  }

  Widget _sectionDivider(String label) => Row(
        children: [
          Expanded(child: Divider(color: AppColors.line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: AppColors.muted, letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.line)),
        ],
      );

  Widget _select({
    required String label, required IconData icon,
    required String? value, required List<String> options,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        isExpanded:    true,
        initialValue:  value,
        decoration:    InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, overflow: TextOverflow.ellipsis))).toList(),
        onChanged:     onChanged,
      );

  Widget _yesNo(String label, bool value, ValueChanged<bool> onChanged) =>
      InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: true,  label: Text('Sí')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected:          {value},
          onSelectionChanged: (s) => onChanged(s.first),
        ),
      );

  Widget _chipGroup({
    required String label, required List<String> options,
    required Set<String> selected, required ValueChanged<String> onToggle,
  }) =>
      InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (final o in options)
              FilterChip(
                label:    Text(o),
                selected: selected.contains(o),
                onSelected: (_) => onToggle(o),
              ),
          ],
        ),
      );

  void _toggleSet(Set<String> selected, String option, {bool rebuild = true}) {
    void mutate() {
      if (option == 'NA') { selected..clear()..add(option); return; }
      selected.remove('NA');
      selected.contains(option) ? selected.remove(option) : selected.add(option);
    }
    rebuild ? setState(mutate) : mutate();
  }

  Widget _numberField(TextEditingController c, String label, IconData icon) =>
      SumsTextField(
        controller: c, label: label, icon: icon,
        keyboardType: TextInputType.number,
        validator: nonNegativeIntText,
      );

  Widget _daysField(TextEditingController c, String label) =>
      SumsTextField(
        controller: c, label: label,
        icon: Icons.calendar_view_week_outlined,
        helperText: '0 a 7 días', keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return null;
          final p = int.tryParse(v.trim());
          if (p == null || p < 0 || p > 7) return 'Ingresa un número de 0 a 7';
          return null;
        },
      );

  void _goNext() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _currentStep++);
  }

  void _finishCapture() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _showSuccessSheet();
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context:     context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.soft, shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppColors.green, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cédula lista para guardar',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: AppColors.greenDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Todos los campos han sido validados. Confirma para enviar la cédula al servidor.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Revisar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Wizard Header ─────────────────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  final List<_WizardStep> steps;
  final int currentStep;
  final ValueChanged<int> onStepTap;

  const _WizardHeader({
    required this.steps,
    required this.currentStep,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / steps.length;
    final stepColor = steps[currentStep].color;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 300),
              builder: (_, value, __) => LinearProgressIndicator(
                value: value, minHeight: 5,
                backgroundColor: AppColors.soft,
                valueColor: AlwaysStoppedAnimation(stepColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Chips de pasos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  _StepChip(
                    step:      steps[i],
                    index:     i,
                    isActive:  i == currentStep,
                    isDone:    i < currentStep,
                    onTap:     () => onStepTap(i),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 20, height: 1,
                      color: i < currentStep ? steps[i].color : AppColors.line,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final _WizardStep step;
  final int     index;
  final bool    isActive;
  final bool    isDone;
  final VoidCallback onTap;

  const _StepChip({
    required this.step, required this.index,
    required this.isActive, required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = step.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.12)
              : isDone
                  ? color.withOpacity(0.06)
                  : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : isDone ? color.withOpacity(0.3) : AppColors.line,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : step.icon,
              size: 14,
              color: isActive || isDone ? color : AppColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              step.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive || isDone ? color : AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const _BottomNav({
    required this.currentStep, required this.totalSteps,
    required this.onBack, required this.onNext, required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = currentStep == 0;
    final isLast  = currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_outlined, size: 16),
                label: const Text('Anterior'),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),
          Expanded(
            flex: isFirst ? 1 : 1,
            child: FilledButton.icon(
              onPressed: isLast ? onFinish : onNext,
              icon: Icon(
                isLast ? Icons.cloud_upload_outlined : Icons.arrow_forward_outlined,
                size: 16,
              ),
              label: Text(isLast ? 'Guardar cédula' : 'Siguiente'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Panel de paso ─────────────────────────────────────────────────────────────

class _StepPanel extends StatelessWidget {
  final String        title;
  final IconData      icon;
  final Color         color;
  final List<Widget>  children;

  const _StepPanel({
    required this.title, required this.icon,
    required this.color, required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header de la sección
          Container(
            color: color.withOpacity(0.06),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w800,
                      color: color == AppColors.green ? AppColors.greenDark : color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vacuna Card ───────────────────────────────────────────────────────────────

class _VaccineCard extends StatelessWidget {
  final int index;
  final _VaccineForm form;
  final bool canRemove;
  final VoidCallback onRemove;
  final List<String> vacunasOpts;
  final List<String> dosisOpts;
  final VoidCallback onChanged;
  final Widget Function(TextEditingController, String, IconData) numberField;
  final Widget Function({
    required String label, required IconData icon, required String? value,
    required List<String> options, required ValueChanged<String?> onChanged,
  }) select;
  final TextEditingController Function([String]) c;

  const _VaccineCard({
    required this.index, required this.form, required this.canRemove,
    required this.onRemove, required this.vacunasOpts, required this.dosisOpts,
    required this.onChanged, required this.numberField,
    required this.select, required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.line),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Vacuna ${index + 1}',
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.burgundy,
                  ),
                ),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed:   onRemove,
                  icon:        const Icon(Icons.delete_outline, size: 18),
                  color:       AppColors.muted,
                  style:       IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceAlt,
                    padding: const EdgeInsets.all(6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (_, con) {
            final w = con.maxWidth < 720 ? con.maxWidth : (con.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12, runSpacing: 12,
              children: [
                SizedBox(width: w, child: SumsTextField(controller: form.paciente, label: 'Identificación del paciente', icon: Icons.person_outline)),
                SizedBox(width: w, child: SumsTextField(controller: form.fechaNacimiento, label: 'Fecha de nacimiento', icon: Icons.event_outlined, keyboardType: TextInputType.datetime)),
                SizedBox(width: w, child: numberField(form.edad, 'Edad', Icons.cake_outlined)),
                SizedBox(width: w, child: select(label: 'Vacuna aplicada', icon: Icons.vaccines_outlined, value: form.tipo, options: vacunasOpts, onChanged: (v) { form.tipo = v; onChanged(); })),
                SizedBox(width: w, child: select(label: 'Dosis', icon: Icons.medication_liquid_outlined, value: form.dosis, options: dosisOpts, onChanged: (v) { form.dosis = v; onChanged(); })),
                SizedBox(width: w, child: SumsTextField(controller: form.otraVacuna, label: 'Otra, especificar', icon: Icons.edit_outlined)),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Member Card ───────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final int index;
  final _MemberForm form;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  final List<String> roles, sexoOpts, edoCivilOpts, lenguaOpts,
      escolaridadOpts, ingresoOpts, embarazoOpts, tamizajeOpts,
      freqSaludOpts, toxicomaniasOpts, cronicasOpts;

  final Widget Function({
    required String label, required IconData icon, required String? value,
    required List<String> options, required ValueChanged<String?> onChanged,
  }) select;
  final void Function(Set<String>, String, {bool rebuild}) toggleSet;
  final Widget Function(TextEditingController, String, IconData) numberField;
  final Widget Function(TextEditingController, String) daysField;

  const _MemberCard({
    required this.index, required this.form, required this.canRemove,
    required this.onRemove, required this.onChanged,
    required this.roles, required this.sexoOpts, required this.edoCivilOpts,
    required this.lenguaOpts, required this.escolaridadOpts,
    required this.ingresoOpts, required this.embarazoOpts,
    required this.tamizajeOpts, required this.freqSaludOpts,
    required this.toxicomaniasOpts, required this.cronicasOpts,
    required this.select, required this.toggleSet,
    required this.numberField, required this.daysField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header del integrante
          Container(
            color: AppColors.gold.withOpacity(0.07),
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'VI. Integrante ${index + 1}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15,
                    color: AppColors.greenDark,
                  ),
                ),
                const Spacer(),
                if (canRemove)
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: AppColors.muted,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(builder: (_, con) {
              final w = con.maxWidth < 720 ? con.maxWidth : (con.maxWidth - 12) / 2;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: w, child: SumsTextField(controller: form.nombre, label: 'Nombre completo', icon: Icons.person_outline)),
                    SizedBox(width: w, child: select(label: 'Sexo', icon: Icons.wc_outlined, value: form.sexo, options: sexoOpts, onChanged: (v) { form.sexo = v; onChanged(); })),
                    SizedBox(width: w, child: SumsTextField(controller: form.fechaNacimiento, label: 'Fecha de nacimiento', icon: Icons.event_outlined, keyboardType: TextInputType.datetime)),
                    SizedBox(width: w, child: numberField(form.edad, 'Edad', Icons.cake_outlined)),
                    SizedBox(width: w, child: select(label: 'Estado civil', icon: Icons.favorite_border, value: form.estadoCivil, options: edoCivilOpts, onChanged: (v) { form.estadoCivil = v; onChanged(); })),
                    SizedBox(width: w, child: select(label: 'Parentesco/rol familiar', icon: Icons.diversity_3_outlined, value: form.parentesco, options: roles, onChanged: (v) { form.parentesco = v; onChanged(); })),
                    SizedBox(width: w, child: select(label: 'Lengua', icon: Icons.record_voice_over_outlined, value: form.lengua, options: lenguaOpts, onChanged: (v) { form.lengua = v; onChanged(); })),
                    SizedBox(width: w, child: SumsTextField(controller: form.lenguaEsp, label: 'Lengua indígena, especificar', icon: Icons.edit_outlined)),
                    SizedBox(width: w, child: select(label: 'Escolaridad', icon: Icons.school_outlined, value: form.escolaridad, options: escolaridadOpts, onChanged: (v) { form.escolaridad = v; onChanged(); })),
                    SizedBox(width: w, child: SumsTextField(controller: form.ocupacion, label: 'Ocupación', icon: Icons.work_outline)),
                    SizedBox(width: w, child: select(label: 'Ingreso - salario mínimo', icon: Icons.payments_outlined, value: form.ingreso, options: ingresoOpts, onChanged: (v) { form.ingreso = v; onChanged(); })),
                  ]),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Condiciones de salud'),
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: w, child: _buildYesNo(context, 'Alfabetización', form.alfabetizacion, (v) { form.alfabetizacion = v; onChanged(); })),
                    SizedBox(width: w, child: _buildYesNo(context, 'Seguridad social', form.seguridadSocial, (v) { form.seguridadSocial = v; onChanged(); })),
                    SizedBox(width: w, child: _buildYesNo(context, 'Higiene buco-dental diaria', form.higiene, (v) { form.higiene = v; onChanged(); })),
                    SizedBox(width: w, child: _buildYesNo(context, 'Presenta discapacidad', form.discapacidad, (v) { form.discapacidad = v; onChanged(); })),
                  ]),
                  const SizedBox(height: 14),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: w, child: daysField(form.proteina, 'Carne, pescado y pollo')),
                    SizedBox(width: w, child: daysField(form.frutasVerd, 'Frutas y verduras')),
                    SizedBox(width: w, child: daysField(form.cereales, 'Cereales, granos y leguminosas')),
                    SizedBox(width: w, child: SumsTextField(controller: form.tipoDisc, label: 'Tipo de discapacidad', icon: Icons.accessible_forward_outlined)),
                  ]),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Toxicomanías'),
                  const SizedBox(height: 10),
                  _chipGroup(context, toxicomaniasOpts, form.toxicomanias),
                  const SizedBox(height: 12),
                  SumsTextField(controller: form.otraSust, label: 'Otra sustancia, especificar', icon: Icons.edit_outlined),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Enfermedades crónico-degenerativas'),
                  const SizedBox(height: 10),
                  _chipGroup(context, cronicasOpts, form.cronicas),
                  const SizedBox(height: 16),
                  const _SubLabel(text: 'Seguimiento preventivo'),
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 12, children: [
                    SizedBox(width: w, child: select(label: 'Atención de embarazo', icon: Icons.pregnant_woman_outlined, value: form.embarazo, options: embarazoOpts, onChanged: (v) { form.embarazo = v; onChanged(); })),
                    SizedBox(width: w, child: select(label: 'Tamizaje cérvico-uterino', icon: Icons.health_and_safety_outlined, value: form.tamizajeCervico, options: tamizajeOpts, onChanged: (v) { form.tamizajeCervico = v; onChanged(); })),
                    SizedBox(width: w, child: SumsTextField(controller: form.fechaCervico, label: 'Fecha cérvico-uterino', icon: Icons.event_outlined, keyboardType: TextInputType.datetime)),
                    SizedBox(width: w, child: select(label: 'Tamizaje cáncer de mama', icon: Icons.medical_services_outlined, value: form.tamizajeMama, options: tamizajeOpts, onChanged: (v) { form.tamizajeMama = v; onChanged(); })),
                    SizedBox(width: w, child: SumsTextField(controller: form.fechaMama, label: 'Fecha cáncer de mama', icon: Icons.event_outlined, keyboardType: TextInputType.datetime)),
                    SizedBox(width: w, child: select(label: 'Frecuencia de uso de servicios', icon: Icons.schedule_outlined, value: form.frecuenciaSalud, options: freqSaludOpts, onChanged: (v) { form.frecuenciaSalud = v; onChanged(); })),
                    SizedBox(width: w, child: SumsTextField(controller: form.motivoSalud, label: 'Motivo de uso de servicios', icon: Icons.notes_outlined)),
                  ]),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNo(BuildContext context, String label, bool value, ValueChanged<bool> onChange) =>
      InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: true,  label: Text('Sí')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected:           {value},
          onSelectionChanged: (s) => onChange(s.first),
        ),
      );

  Widget _chipGroup(BuildContext context, List<String> options, Set<String> selected) =>
      InputDecorator(
        decoration: const InputDecoration(labelText: ''),
        child: Wrap(
          spacing: 8, runSpacing: 8,
          children: [
            for (final o in options)
              FilterChip(
                label:      Text(o),
                selected:   selected.contains(o),
                onSelected: (_) => toggleSet(selected, o, rebuild: true),
              ),
          ],
        ),
      );
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700,
          color: AppColors.muted, letterSpacing: 1.0,
        ),
      );
}

// ── Modelos locales ───────────────────────────────────────────────────────────

class _WizardStep {
  final String   label;
  final IconData icon;
  final Color    color;
  const _WizardStep(this.label, this.icon, this.color);
}

class _VaccineForm {
  final TextEditingController paciente;
  final TextEditingController fechaNacimiento;
  final TextEditingController edad;
  final TextEditingController otraVacuna;
  String? tipo;
  String? dosis;

  _VaccineForm({
    required this.paciente, required this.fechaNacimiento,
    required this.edad, required this.otraVacuna,
  });
}

class _MemberForm {
  final TextEditingController nombre;
  final TextEditingController fechaNacimiento;
  final TextEditingController edad;
  final TextEditingController lenguaEsp;
  final TextEditingController ocupacion;
  final TextEditingController proteina;
  final TextEditingController frutasVerd;
  final TextEditingController cereales;
  final TextEditingController otraSust;
  final TextEditingController tipoDisc;
  final TextEditingController fechaCervico;
  final TextEditingController fechaMama;
  final TextEditingController motivoSalud;

  String? sexo, estadoCivil, lengua, parentesco, escolaridad,
          ingreso, embarazo, tamizajeCervico, tamizajeMama, frecuenciaSalud;

  bool alfabetizacion = false;
  bool seguridadSocial = false;
  bool higiene  = false;
  bool discapacidad = false;

  final toxicomanias = <String>{};
  final cronicas     = <String>{};

  _MemberForm({
    required this.nombre, required this.fechaNacimiento, required this.edad,
    required this.lenguaEsp, required this.ocupacion, required this.proteina,
    required this.frutasVerd, required this.cereales, required this.otraSust,
    required this.tipoDisc, required this.fechaCervico, required this.fechaMama,
    required this.motivoSalud,
  });
}

// Alias necesario para compilar con el import existente
const surfaceAlt = AppColors.surfaceAlt;