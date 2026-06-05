# sums

Aplicacion Flutter para mobile y otras plataformas soportadas por Flutter.

## Requisitos

- Flutter SDK instalado y en la variable `PATH`
- Git instalado
- Android Studio, Xcode o el SDK de la plataforma que vayas a usar para compilar

## Configuracion inicial

### Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd sums
```

### Si ya tienes el repositorio

```bash
git pull
```

### Descargar dependencias

```bash
flutter pub get
```

## Como compilar y ejecutar

### Verificar el entorno

```bash
flutter doctor
```

### Ejecutar en modo desarrollo

```bash
flutter run
```

La app apunta por defecto a `http://localhost:3000/sums`. Para Android emulator usa la IP especial del host:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/sums
```

Para web, Windows o desktop local:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000/sums
```

Para un celular fisico, cambia `localhost` por la IP de tu computadora en la misma red, por ejemplo:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:3000/sums
```

## Funcionalidad implementada

- Login y registro conectados a `/login` y `/register`.
- Navegacion basica con dashboard y formularios de captura.
- Formularios conectados a cedula, nucleo familiar, persona, vivienda, salud preventiva, servicios de salud, enfermedades cronicas y vacunacion.
- Diseno basado en colores y logo IMSS-BIENESTAR del manual compartido.

Nota: la sesion se conserva en memoria durante la ejecucion de la app. Si quieres persistir el token entre reinicios, habilita Developer Mode en Windows y agrega un storage con plugin, por ejemplo `shared_preferences`.

### Analizar el proyecto

```bash
flutter analyze
```

### Ejecutar pruebas

```bash
flutter test
```

## Generar compilaciones

### Android

```bash
flutter build apk
```

### iOS

```bash
flutter build ios
```

### Web

```bash
flutter build web
```

### Windows

```bash
flutter build windows
```

### Linux

```bash
flutter build linux
```

### macOS

```bash
flutter build macos
```

## Documentacion

- [Flutter documentation](https://docs.flutter.dev/)
- [Getting started with Flutter](https://docs.flutter.dev/get-started/install)
