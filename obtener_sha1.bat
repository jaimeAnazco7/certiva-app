@echo off
echo ============================================
echo Obtener SHA-1 para Firebase - Certiva App
echo ============================================
echo.

echo Buscando SHA-1 del certificado de debug...
echo.

REM Intentar obtener SHA-1 del keystore de debug por defecto
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android 2>nul

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo No se encontro el keystore de debug en la ubicacion predeterminada.
    echo.
    echo Por favor, proporciona la ruta al keystore o presiona Enter para usar el predeterminado:
    set /p KEYSTORE_PATH=
    
    if "%KEYSTORE_PATH%"=="" (
        set KEYSTORE_PATH=%USERPROFILE%\.android\debug.keystore
    )
    
    echo.
    echo Por favor, proporciona el alias (o presiona Enter para usar 'androiddebugkey'):
    set /p KEY_ALIAS=androiddebugkey
    
    echo.
    echo Por favor, proporciona la contraseña del keystore (o presiona Enter para usar 'android'):
    set /p KEYSTORE_PASS=android
    
    echo.
    echo Obteniendo SHA-1...
    keytool -list -v -keystore "%KEYSTORE_PATH%" -alias "%KEY_ALIAS%" -storepass "%KEYSTORE_PASS%"
)

echo.
echo ============================================
echo IMPORTANTE:
echo 1. Copia el valor de SHA1: que aparece arriba
echo 2. Ve a Firebase Console
echo 3. Agrega el SHA-1 en la configuracion de la app Android
echo ============================================
echo.
pause



