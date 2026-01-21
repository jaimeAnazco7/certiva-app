#!/bin/bash

# Script para limpiar CocoaPods y dependencias de iOS
# Soluciona problemas de crash en path_provider_foundation

echo "🧹 Limpiando proyecto Flutter..."
flutter clean

echo "🗑️ Eliminando Pods y Podfile.lock..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/.symlinks
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/Flutter.podspec

echo "📦 Obteniendo dependencias de Flutter..."
flutter pub get

echo "🍎 Instalando CocoaPods..."
cd ios
pod deintegrate || true
pod install --repo-update

echo "✅ Limpieza completada. Ahora puedes compilar con:"
echo "   flutter build ios --release"
