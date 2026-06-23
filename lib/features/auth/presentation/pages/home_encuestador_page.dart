import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../cedula_orquestador/presentation/viewmodels/cedula_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeEncuestadorPage extends StatefulWidget {
  const HomeEncuestadorPage({super.key});

  @override
  State<HomeEncuestadorPage> createState() => _HomeEncuestadorPageState();
}

class _HomeEncuestadorPageState extends State<HomeEncuestadorPage> {
  final int _cedulasHoy = 0;
  final int _cedulasSemana = 0;
  final int _personasRegistradas = 0;

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthViewModel>();
    final userName = auth.session?.user.nombreUsuario ?? 'encuestador';
    final today    = _todayLabel();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Cabecera con saludo ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: _GreetingSection(userName: userName, date: today),
            ),

            // ── Métricas ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              sliver: SliverToBoxAdapter(
                child: _MetricsRow(
                  cedulasHoy:         _cedulasHoy,
                  cedulasSemana:      _cedulasSemana,
                  personasRegistradas: _personasRegistradas,
                ),
              ),
            ),

            // ── Acción principal ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _MainActionCard(onTap: _goToCedula),
              ),
            ),

            // ── Flujo de captura ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              sliver: SliverToBoxAdapter(
                child: SectionCard(
                  title:       'Flujo de captura',
                  subtitle:    '4 secciones · ~15 min por familia',
                  icon:        Icons.route_outlined,
                  accentColor: AppColors.terracota,
                  children: const [_FlowSteps()],
                ),
              ),
            ),

            // ── Consejo de campo ─────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
              sliver: SliverToBoxAdapter(
                child: _TipCard(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:       _goToCedula,
        icon:            const Icon(Icons.assignment_add),
        label:           const Text('Nueva cédula'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        elevation:       2,
      ),
    );
  }

  void _goToCedula() {
    context.read<CedulaViewModel>().clearMessages();
    Navigator.of(context).pushNamed(AppRoutes.cedula);
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        title: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                color: AppColors.rolEncuestador,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Encuestador'),
          ],
        ),
        actions: [
          IconButton(
            tooltip:  'Cerrar sesión',
            icon:     const Icon(Icons.logout_outlined),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (!context.mounted) return;
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            },
          ),
          const SizedBox(width: 4),
        ],
      );

  String _todayLabel() {
    final now = DateTime.now();
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${now.day} de ${meses[now.month]} ${now.year}';
  }
}

// ── Sección de saludo ─────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  final String userName;
  final String date;
  const _GreetingSection({required this.userName, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greenDark,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, $userName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Captura cédulas de microdiagnóstico familiar',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Métricas ──────────────────────────────────────────────────────────────────

class _MetricsRow extends StatelessWidget {
  final int cedulasHoy;
  final int cedulasSemana;
  final int personasRegistradas;

  const _MetricsRow({
    required this.cedulasHoy,
    required this.cedulasSemana,
    required this.personasRegistradas,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -16),
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              value: '$cedulasHoy',
              label: 'Hoy',
              icon:  Icons.assignment_turned_in_outlined,
              color: AppColors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              value: '$cedulasSemana',
              label: 'Esta semana',
              icon:  Icons.calendar_view_week_outlined,
              color: AppColors.terracota,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              value: '$personasRegistradas',
              label: 'Personas',
              icon:  Icons.people_outline,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDark.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Acción principal ──────────────────────────────────────────────────────────

class _MainActionCard extends StatelessWidget {
  final VoidCallback onTap;
  const _MainActionCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(AppDimens.radiusL),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_add,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Iniciar nueva cédula',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17, fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Familia · Vivienda · Vacunación · Integrantes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white60,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pasos del flujo ───────────────────────────────────────────────────────────

class _FlowSteps extends StatelessWidget {
  const _FlowSteps();

  static const _steps = [
    _FlowStep(
      num: '1', title: 'Familia',
      detail: 'Informante, domicilio, localidad',
      icon: Icons.groups_outlined,
    ),
    _FlowStep(
      num: '2', title: 'Vivienda',
      detail: 'Materiales, servicios y saneamiento',
      icon: Icons.home_outlined,
    ),
    _FlowStep(
      num: '3', title: 'Vacunación',
      detail: 'Esquema aplicado durante la visita',
      icon: Icons.vaccines_outlined,
    ),
    _FlowStep(
      num: '4', title: 'Integrantes',
      detail: 'Salud, alimentación y datos de cada miembro',
      icon: Icons.people_alt_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          _FlowStepRow(step: _steps[i], isLast: i == _steps.length - 1),
        ],
      ],
    );
  }
}

class _FlowStep {
  final String num;
  final String title;
  final String detail;
  final IconData icon;
  const _FlowStep({
    required this.num,
    required this.title,
    required this.detail,
    required this.icon,
  });
}

class _FlowStepRow extends StatelessWidget {
  final _FlowStep step;
  final bool isLast;
  const _FlowStepRow({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Número + línea vertical
        Column(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.terracota.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.terracota.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  step.num,
                  style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w900,
                    color: AppColors.terracota,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5, height: 36,
                color: AppColors.line,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
            child: Row(
              children: [
                Icon(step.icon, size: 16, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        step.detail,
                        style: const TextStyle(
                          fontSize: 12, color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Consejo de campo ──────────────────────────────────────────────────────────

class _TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_outlined,
              color: AppColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consejo de campo',
                  style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13,
                    color: AppColors.greenDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Verifica la conectividad antes de iniciar. Los datos se sincronizan al guardar.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
