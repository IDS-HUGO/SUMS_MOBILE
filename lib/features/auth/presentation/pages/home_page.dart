import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/brand_header.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final userName = auth.session?.user.nombreUsuario ?? 'usuario';

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUMS'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
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
                    title: 'Hola, $userName',
                    subtitle:
                        'Captura cedulas por nucleo familiar y envia los datos a la API SUMS.',
                    compact: true,
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flujo de captura',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AppColors.burgundy,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '1. Crear nucleo y persona. 2. Registrar cedula y vivienda. 3. Capturar salud preventiva, alimentacion y vacunacion.',
                          ),
                          const SizedBox(height: 18),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRoutes.cedula);
                            },
                            icon: const Icon(Icons.assignment_add),
                            label: const Text('Abrir formularios de cedula'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Image.asset(
                    'assets/images/hero-sums-system.png',
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
