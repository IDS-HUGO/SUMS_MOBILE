# SUMS - Sistema Único de Microdiagnóstico en Salud (Mobile)

Aplicación móvil desarrollada en Flutter para la captura y gestión de datos de IMSS-Bienestar.

## Arquitectura y Tecnologías Principales

- **Arquitectura**: Clean Architecture / Hexagonal Architecture. El código está altamente modularizado separando responsabilidades (UI, ViewModels, Dominio, Repositorios, Servicios Externos).
- **Inyección de Dependencias (DI)**: Gestionada a través de `get_it` para inyectar servicios, repositorios y ViewModels.
- **Gestión del Estado**: Implementado con **Riverpod** (`ConsumerWidget`, `ConsumerStatefulWidget`, `ChangeNotifierProvider.autoDispose`), garantizando correcta gestión del ciclo de vida de la memoria y disposición de los estados al cambiar de vista.
- **Diseño (UI/UX)**: Diseño basado en Material Design 3, soporte nativo de **Modo Claro / Modo Oscuro** gestionado con `ColorScheme.fromSeed` y `AppTheme`.
- **Capacidades Offline (Offline-First)**: Arquitectura preparada para recolectar, almacenar y sincronizar datos de forma local cuando el dispositivo no tiene red y sincronizarlos cuando la conexión es reestablecida.

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

- [Flutter documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
