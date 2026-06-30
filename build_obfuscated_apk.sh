#!/bin/bash
# Script para compilar el APK de la aplicación con ofuscación de código activada.
# La ofuscación hace que el código sea difícil de leer mediante ingeniería inversa
# y extrae la información de depuración en una carpeta aparte.

echo "Iniciando compilación de APK con ofuscación..."

# Limpiamos el build anterior para evitar caché
flutter clean
flutter pub get

# Ejecutamos el build con los flags de ofuscación
flutter build apk --release --obfuscate --split-debug-info=./build/app/outputs/symbols

echo "=========================================================="
echo "✅ Compilación terminada."
echo "El APK se encuentra en: build/app/outputs/flutter-apk/app-release.apk"
echo "Los símbolos de depuración (por si necesitas leer un crash log) están en: build/app/outputs/symbols"
echo "=========================================================="
