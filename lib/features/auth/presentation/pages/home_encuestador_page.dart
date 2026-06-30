import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  // ── Connectivity banner ─────────────────────────────────────────────
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _wasOffline = false;
  bool _showBanner = false;
  String _bannerMessage = '';
  Color _bannerColor = Colors.green;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _setupConnectivityListener();
    // Refrescar el conteo de cédulas cada vez que se entra al Home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CedulaViewModel>().refreshSyncCounts();
      }
    });
  }

  void _setupConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) async {
      final isOnline = !results.contains(ConnectivityResult.none);

      if (!isOnline && !_wasOffline) {
        // Acaba de perder conexión
        _wasOffline = true;
        _showToast('Sin conexión a internet', const Color(0xFF616161));
      } else if (isOnline && _wasOffline) {
        // Acaba de recuperar conexión
        _wasOffline = false;
        _showToast('Conexión restaurada', const Color(0xFF2E7D32));
        // Siempre refrescar el conteo al reconectar
        if (mounted) {
          final cvm = context.read<CedulaViewModel>();
          await cvm.refreshSyncCounts();
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted && cvm.pendingSyncCount > 0) {
            await cvm.syncNow();
          }
        }
      }
    });
    // Checar estado inicial
    Connectivity().checkConnectivity().then((results) {
      _wasOffline = results.contains(ConnectivityResult.none);
    });
  }

  void _showToast(String message, Color color) {
    _bannerTimer?.cancel();
    setState(() {
      _bannerMessage = message;
      _bannerColor = color;
      _showBanner = true;
    });
    _bannerTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _showBanner = false);
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _bannerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthViewModel>();
    final userName = auth.session?.user.nombreUsuario ?? 'encuestador';
    final today    = _todayLabel();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SafeArea(
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

                // ── Sincronización y Capturas pendientes (Offline-first) ─────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Consumer<CedulaViewModel>(
                      builder: (context, cvm, child) {
                        if (cvm.pendingSyncCount == 0) return const SizedBox.shrink();
                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.cedulaHistorial),
                              child: _SyncStatusCard(
                                pendingCount: cvm.pendingSyncCount,
                                isSyncing: cvm.isSyncing,
                                isOnline: cvm.isOnline,
                                onSyncTap: () async {
                                  final result = await cvm.syncNow();
                                  if (!context.mounted) return;
                                  if (result.error != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${result.error}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else if (result.synced > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('✅ ${result.synced} cédula(s) sincronizadas correctamente'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else if (result.failed > 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('⚠ ${result.failed} cédula(s) fallaron. Verifica tu conexión.'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _PendingCapturesCard(
                                onTap: () => Navigator.of(context).pushNamed(AppRoutes.pending)
                            ),
                          ],
                        );
                      },
                    ),
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
          // ── Banner de conectividad (tipo YouTube) ──────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: _showBanner ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: _showBanner ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _bannerColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _bannerColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      _bannerMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

// ── Capturas Pendientes ─────────────────────────────────────────────────────────

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

// ── Sección de saludo ─────────────────────────────────────────────────────────

class _GreetingSection extends StatelessWidget {
  final String userName;
  final String date;
  const _GreetingSection({required this.userName, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greenDark,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
                      'Familia · Vivienda · Integrantes · Vacunación',
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
      num: '3', title: 'Integrantes',
      detail: 'Salud, alimentación y datos de cada miembro',
      icon: Icons.people_alt_outlined,
    ),
    _FlowStep(
      num: '4', title: 'Vacunación',
      detail: 'Esquema aplicado durante la visita',
      icon: Icons.vaccines_outlined,
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

// ── Tarjeta de Estado de Sincronización ──────────────────────────────────────────

class _SyncStatusCard extends StatelessWidget {
  final int pendingCount;
  final bool isSyncing;
  final bool isOnline;
  final Future<void> Function() onSyncTap;

  const _SyncStatusCard({
    required this.pendingCount,
    required this.isSyncing,
    required this.isOnline,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSyncing
        ? const Color(0xFF2196F3)  // blue while syncing
        : isOnline
        ? AppColors.terracota   // orange when online+pending
        : const Color(0xFF757575); // grey when offline

    final subtitle = isSyncing
        ? 'Sincronizando… por favor espera.'
        : isOnline
        ? 'Tienes conexión. Presiona sincronizar para enviar.'
        : 'Sin conexión. La sincronización ocurrirá al volver online.';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          isSyncing
              ? SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: color,
            ),
          )
              : Icon(
            isOnline ? Icons.sync_outlined : Icons.sync_disabled_outlined,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$pendingCount cédula(s) pendiente(s) de sincronizar',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.ink),
                ),
              ],
            ),
          ),
          if (!isSyncing)
            IconButton(
              onPressed: isOnline ? onSyncTap : null,
              icon: Icon(Icons.sync, color: isOnline ? color : Colors.grey),
              tooltip: isOnline
                  ? 'Sincronizar ahora'
                  : 'Sin conexión a internet',
            ),
        ],
      ),
    );
  }
}