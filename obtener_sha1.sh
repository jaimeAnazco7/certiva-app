#!/bin/bash

echo "============================================"
echo "Obtener SHA-1 para Firebase - Certiva App"
echo "============================================"
echo ""

echo "Buscando SHA-1 del certificado de debug..."
echo ""

# Intentar obtener SHA-1 del keystore de debug por defecto
if [ -f "$HOME/.android/debug.keystore" ]; then
    keytool -list -v -keystore "$HOME/.android/debug.keystore" -alias androiddebugkey -storepass android -keypass android
else
    echo "No se encontró el keystore de debug en la ubicación predeterminada."
    echo ""
    read -p "Por favor, proporciona la ruta al keystore (o presiona Enter para usar el predeterminado): " KEYSTORE_PATH
    
    if [ -z "$KEYSTORE_PATH" ]; then
        KEYSTORE_PATH="$HOME/.android/debug.keystore"
    fi
    
    read -p "Por favor, proporciona el alias (o presiona Enter para usar 'androiddebugkey'): " KEY_ALIAS
    KEY_ALIAS=${KEY_ALIAS:-androiddebugkey}
    
    read -p "Por favor, proporciona la contraseña del keystore (o presiona Enter para usar 'android'): " KEYSTORE_PASS
    KEYSTORE_PASS=${KEYSTORE_PASS:-android}
    
    echo ""
    echo "Obteniendo SHA-1..."
    keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$KEY_ALIAS" -storepass "$KEYSTORE_PASS"
fi

echo ""
echo "============================================"
echo "IMPORTANTE:"
echo "1. Copia el valor de SHA1: que aparece arriba"
echo "2. Ve a Firebase Console"
echo "3. Agrega el SHA-1 en la configuración de la app Android"
echo "============================================"
echo ""



