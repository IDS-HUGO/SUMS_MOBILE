import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../../../cedula/presentation/viewmodels/cedula_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeEncuestadorPage extends StatefulWidget {
  const HomeEncuestadorPage({super.key});

  @override
  State<HomeEncuestadorPage> createState() => _HomeEncuestadorPageState();
}

class _HomeEncuestadorPageState extends State<HomeEncuestadorPage> {
  // ── stats locales (pueden conectarse al backend en el futuro) ────────────
  int _cedulasHoy = 0;

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthViewModel>();
    final userName = auth.session?.user.nombreUsuario ?? 'encuestador';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUMS · Encuestador'),
        actions: [_logoutButton(context)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BrandHeader(
                    title:    'Hola, $userName',
                    subtitle: 'Captura cédulas de microdiagnóstico familiar.',
                    compact:  true,
                  ),
                  const SizedBox(height: 22),

                  // ── tarjeta principal: nueva cédula ──────────────────────
                  _NewCedulaCard(onTap: _goToCedula),

                  const SizedBox(height: 16),

                  // ── tarjeta secundaria: capturas pendientes ──────────────
                  _PendingCapturesCard(onTap: () => Navigator.of(context).pushNamed(AppRoutes.pending)),

                  const SizedBox(height: 16),

                  // ── flujo de captura ─────────────────────────────────────
                  _FlowCard(),

                  const SizedBox(height: 16),

                  // ── resumen rápido ───────────────────────────────────────
                  _SummaryCard(cedulasHoy: _cedulasHoy),
                ],
              ),
            ),
          ),
        ),
      ),

      // FAB flotante para acceso rápido
      floatingActionButton: FloatingActionButton.extended(
        onPressed:  _goToCedula,
        icon:       const Icon(Icons.assignment_add),
        label:      const Text('Nueva cédula'),
        tooltip:    'Iniciar captura de cédula familiar',
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _goToCedula() {
    // Limpia mensajes del viewmodel antes de navegar
    context.read<CedulaViewModel>().clearMessages();
    Navigator.of(context).pushNamed(AppRoutes.cedula);
  }

  Widget _logoutButton(BuildContext context) => IconButton(
        tooltip:  'Cerrar sesión',
        icon:     const Icon(Icons.logout_outlined),
        onPressed: () async {
          await context.read<AuthViewModel>().logout();
          if (!context.mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
        },
      );
}

class _PendingCapturesCard extends StatelessWidget {
  final VoidCallback onTap;
  const _PendingCapturesCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
                child:           Icon(Icons.sync_problem),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capturas pendientes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:      AppColors.greenDark,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    Text(
                      'Sincroniza tus capturas guardadas offline.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.muted, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

// ── tarjeta de acción principal ─────────────────────────────────────────────

class _NewCedulaCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NewCedulaCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap:        onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              const CircleAvatar(
                radius:          28,
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                child:           Icon(Icons.assignment_add, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Iniciar nueva cédula',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color:      Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Captura datos del núcleo familiar, vivienda y vacunación.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white70, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── flujo de captura ─────────────────────────────────────────────────────────

class _FlowCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.route_outlined),
                ),
                const SizedBox(width: 12),
                Text(
                  'Flujo de captura',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:      AppColors.greenDark,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ..._steps.map((step) => _StepRow(step: step)),
          ],
        ),
      ),
    );
  }

  static const _steps = [
    _Step('1', 'Familia', 'Nombre del informante, domicilio y localidad'),
    _Step('2', 'Vivienda', 'Materiales, servicios y convivencia con animales'),
    _Step('3', 'Vacunación', 'Esquema aplicado durante la visita'),
    _Step('4', 'Integrantes', 'Datos personales, salud y alimentación de cada miembro'),
  ];
}

class _Step {
  final String num;
  final String title;
  final String detail;
  const _Step(this.num, this.title, this.detail);
}

class _StepRow extends StatelessWidget {
  final _Step step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius:          14,
            backgroundColor: AppColors.soft,
            foregroundColor: AppColors.greenDark,
            child: Text(step.num,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(step.detail,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── resumen ──────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int cedulasHoy;
  const _SummaryCard({required this.cedulasHoy});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen de hoy',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color:      AppColors.greenDark,
                      fontWeight: FontWeight.w900,
                    )),
            const SizedBox(height: 14),
            Row(
              children: [
                _Stat(
                  icon:  Icons.assignment_turned_in_outlined,
                  value: '$cedulasHoy',
                  label: 'Cédulas capturadas hoy',
                  color: AppColors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String   value;
  final String   label;
  final Color    color;

  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            foregroundColor: color,
            child:           Icon(icon),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color:      color,
                      )),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.muted)),
            ],
          ),
        ],
      ),
    );
  }
}