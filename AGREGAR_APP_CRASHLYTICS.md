# 📱 Cómo Agregar tu App iOS a Crashlytics

## 🎯 Paso a Paso (Desde la Pantalla Actual)

### **Paso 1: Agregar App iOS a Firebase**

Estás en la pantalla de Crashlytics. Ahora necesitas agregar tu app iOS:

1. **Busca el botón "Agregar app" o el ícono de iOS** 🍎
   - Debería estar en la parte superior de la pantalla
   - O busca un botón que diga "Agregar app" / "Add app"

2. **Haz clic en el ícono de iOS** 🍎
   - Se abrirá un formulario para registrar tu app

3. **Completa el formulario:**
   - **Bundle ID**: `py.com.certiva.app`
     - ⚠️ **IMPORTANTE**: Debe ser exactamente este, sin espacios
   - **Apodo de la app** (opcional): `Certiva App`
   - **App Store ID** (opcional): Déjalo vacío por ahora

4. **Haz clic en "Registrar app"** o "Register app"

---

### **Paso 2: Descargar GoogleService-Info.plist**

Después de registrar la app, Firebase te mostrará instrucciones:

1. **Descarga el archivo `GoogleService-Info.plist`**
   - Haz clic en el botón **"Descargar GoogleService-Info.plist"**
   - O busca un botón que diga "Download GoogleService-Info.plist"

2. **Guarda el archivo en la ubicación correcta:**
   - **Ruta exacta**: `certiva_app/ios/Runner/GoogleService-Info.plist`
   - ⚠️ **CRÍTICO**: Debe estar en esta ubicación exacta
   - ⚠️ **NO** lo pongas en otra carpeta

3. **Verifica que el archivo esté ahí:**
   - Deberías ver el archivo en: `certiva_app/ios/Runner/GoogleService-Info.plist`

---

### **Paso 3: Seguir las Instrucciones de Firebase**

Firebase te mostrará pasos adicionales. **Puedes saltarlos** porque ya tenemos el código configurado:

- ✅ **Paso 1**: Agregar Firebase SDK → **YA HECHO** (en `pubspec.yaml)
- ✅ **Paso 2**: Inicializar Firebase → **YA HECHO** (en `main.dart`)
- ✅ **Paso 3**: Agregar Crashlytics → **YA HECHO** (en `main.dart`)

**Solo necesitas:**
- ✅ Descargar `GoogleService-Info.plist`
- ✅ Colocarlo en `ios/Runner/`

---

## 📋 Checklist Rápido

- [ ] App iOS agregada a Firebase con Bundle ID `py.com.certiva.app`
- [ ] `GoogleService-Info.plist` descargado
- [ ] `GoogleService-Info.plist` colocado en `certiva_app/ios/Runner/`
- [ ] Archivo verificado en la ubicación correcta

---

## 🎯 Después de Agregar la App

Una vez que agregues la app y descargues el archivo:

1. **Ejecuta estos comandos:**
   ```bash
   cd certiva_app
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

2. **Compila la app:**
   ```bash
   flutter build ios --release
   ```

3. **Distribuye a testers** (TestFlight)

4. **Revisa crashes en Firebase Console** → Crashlytics

---

## 🆘 Si No Ves el Botón "Agregar App"

Si no ves un botón claro para agregar la app:

1. **Ve a la página principal del proyecto:**
   - Haz clic en el nombre del proyecto en la parte superior
   - O ve a: **https://console.firebase.google.com/project/certiva-crashlytics/overview**

2. **Busca el ícono de iOS** 🍎 en la página principal
   - Debería estar junto a otros íconos (Android, Web, etc.)

3. **Haz clic en el ícono de iOS** 🍎
   - Se abrirá el formulario para agregar la app

---

## ✅ Verificación Final

Después de completar estos pasos, deberías tener:

- ✅ App iOS registrada en Firebase
- ✅ `GoogleService-Info.plist` en `certiva_app/ios/Runner/`
- ✅ Listo para compilar y probar

---

**¿Puedes agregar la app ahora? Si tienes alguna duda, avísame.** 🚀

