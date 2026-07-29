# SUMS - Sistema Único de Microdiagnóstico en Salud (Mobile)

Aplicación móvil desarrollada en Flutter para la captura y gestión de datos de IMSS-Bienestar.

## Manual de arquitectura

> La app usa Material 3 para el tema, Riverpod para el estado por pantalla,
> `get_it` para inyección de dependencias y `go_router` para navegación
> centralizada en constantes. Los providers se importan globalmente desde
> `package:sums/core/di/providers.dart`.

### Material Theme

`AppTheme` centraliza los temas claro y oscuro en
`lib/shared/theme/app_theme.dart`. Ambos usan `ColorScheme.fromSeed` y
`useMaterial3: true`; `App` los entrega a `MaterialApp.router`. El tema activo
se observa mediante `themeModeProvider`.

### Riverpod y estado por pantalla

`main.dart` envuelve la aplicación con `ProviderScope`. Cada funcionalidad
publica su ViewModel como un `ChangeNotifierProvider`; las pantallas usan
`ConsumerWidget` o `ConsumerStatefulWidget` para observarlo con `ref.watch`, y
usan `ref.read` para disparar acciones. Los providers de pantallas que no deben
conservar estado emplean `autoDispose`, liberándose al salir de la vista.

Ejemplo de importación global:

```dart
import 'package:sums/core/di/providers.dart';

final vm = ref.watch(adminUsersViewModelProvider);
ref.read(adminUsersViewModelProvider).fetchUsers();
```

### Inyección de dependencias

`lib/core/di/injection.dart` configura el contenedor `GetIt` (`sl`) antes de
crear la app. Registra cliente HTTP, almacenamiento seguro, base de datos,
repositorios y ViewModels; cada módulo agrega sus propios registros desde su
carpeta `di/`. Los providers de Riverpod obtienen los ViewModels desde ese
contenedor, separando la creación de dependencias de la UI.

### Navegación y tipos

`lib/core/routes/app_routes.dart` concentra las rutas en constantes de
`AppRoutes` y construye `GoRouter`. Las pantallas navegan con `context.go()`,
`context.push()` o `context.pop()`. El router protege las rutas según el rol
autenticado. Cuando una ruta requiere datos, se leen de `state.extra` y se
convierten al tipo esperado antes de crear la pantalla.

### Organización

Cada módulo sigue la separación `data`, `domain`, `presentation` y `di`:

- `data`: fuentes remotas/locales e implementaciones de repositorios.
- `domain`: entidades, contratos y casos de uso.
- `presentation`: páginas, widgets y ViewModels de estado.
- `di`: registros de `get_it` y providers de Riverpod del módulo.

La aplicación está preparada para trabajar offline: guarda datos localmente y
los sincroniza cuando recupera conectividad.

## Requisitos

- Flutter SDK instalado (estable) y en la variable `PATH`
- Git instalado
- Android Studio, Xcode o el SDK de la plataforma que vayas a usar para compilar

## Configuración inicial

### Clonar el repositorio e instalar dependencias

```bash
git clone <url-del-repositorio>
cd sums
flutter pub get
```

## Ejecución

### Entorno de desarrollo

```bash
flutter run
```

La app apunta por defecto a `http://localhost:3000/sums`. Para Android emulator usa la IP especial del host:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/sums
```

Para conectarse desde un dispositivo físico (ej: celular) a un servidor local, usa la IP de tu computadora en la red:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:3000/sums
```

## Funcionalidad implementada

- **Gestión de roles**: Inicio de sesión (Encuestador, Médico, Analista, Administrador) con navegación e interfaces dedicadas.
- **Microdiagnóstico Familiar**: Formularios complejos para cédulas, vivienda, núcleo familiar, estado de salud y vacunación.
- **Sincronización Inteligente**: Detección de conectividad y sincronización de cédulas con historial de capturas locales y manejo de errores (Borrador, Pendiente, Sincronizado, Fallido).
- **Diseño unificado IMSS-BIENESTAR**: Paleta institucional dinámica según tema claro/oscuro.

## Comandos Útiles

**Análisis de código estático:**
```bash
flutter analyze
```

**Ejecutar pruebas:**
```bash
flutter test
```

**Generar APK (Android):**
```bash
flutter build apk
```

## Documentación

- [Manual de arquitectura e implementación](MANUAL_ARQUITECTURA.md)
- [Flutter documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
