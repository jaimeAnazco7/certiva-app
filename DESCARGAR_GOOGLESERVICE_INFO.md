# 📥 Paso 2: Descargar GoogleService-Info.plist

## ✅ Paso 1 Completado

Veo que ya completaste el Paso 1:
- ✅ Bundle ID: `py.com.certiva.app`
- ✅ Apodo: `Certiva App`
- ✅ App Store ID: `6756583680`

---

## 📥 Paso 2: Descargar el Archivo

### **Qué Hacer Ahora:**

1. **Haz clic en el botón azul:**
   - **"Descargar GoogleService-Info.plist"**
   - El archivo se descargará a tu carpeta de descargas

2. **Ubicación del archivo descargado:**
   - Normalmente va a: `C:\Users\TuUsuario\Downloads\GoogleService-Info.plist`
   - O la carpeta de descargas que tengas configurada

---

## 📁 Paso 3: Colocar el Archivo en tu Proyecto Flutter

### **⚠️ IMPORTANTE: Para Flutter, la ubicación es diferente**

Firebase dice "directorio raíz de Xcode", pero para Flutter necesitas:

**Ubicación correcta:**
```
certiva_app/ios/Runner/GoogleService-Info.plist
```

**NO en:**
- ❌ `certiva_app/ios/` (muy arriba)
- ❌ `certiva_app/` (raíz del proyecto Flutter)
- ✅ `certiva_app/ios/Runner/` (aquí es donde va)

---

## 🔧 Pasos Detallados

### **1. Descargar el archivo:**
- Haz clic en "Descargar GoogleService-Info.plist"
- Espera a que se descargue

### **2. Encontrar el archivo descargado:**
- Ve a tu carpeta de descargas
- Busca: `GoogleService-Info.plist`

### **3. Copiar el archivo:**
- Copia `GoogleService-Info.plist` (Ctrl+C)

### **4. Colocar en tu proyecto:**
- Ve a: `D:\xampp\htdocs\proyecto_certiva_void\certiva_app\ios\Runner\`
- Pega el archivo ahí (Ctrl+V)

### **5. Verificar:**
- Deberías tener: `certiva_app/ios/Runner/GoogleService-Info.plist`
- El archivo debe estar ahí antes de continuar

---

## ✅ Verificación

Después de colocar el archivo, verifica que:

- ✅ El archivo existe en: `certiva_app/ios/Runner/GoogleService-Info.plist`
- ✅ El nombre es exactamente: `GoogleService-Info.plist` (con mayúsculas y guiones)
- ✅ No está en otra carpeta

---

## 🚀 Siguiente Paso

Después de colocar el archivo:

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

3. **O continúa con Codemagic** para subir a TestFlight

---

## ⚠️ Nota sobre el Paso 3

Firebase mostrará un "Paso 3: Agregar el SDK de Firebase"

**Puedes saltarlo porque:**
- ✅ Ya tienes `firebase_core` y `firebase_crashlytics` en `pubspec.yaml`
- ✅ Ya tienes el código de inicialización en `main.dart`
- ✅ Solo necesitas el archivo `GoogleService-Info.plist`

**Después de descargar y colocar el archivo, puedes:**
- Hacer clic en "Siguiente" para ver el Paso 3
- O simplemente cerrar Firebase y continuar con tu proyecto

---

## 📋 Checklist

- [ ] Archivo `GoogleService-Info.plist` descargado
- [ ] Archivo copiado a `certiva_app/ios/Runner/GoogleService-Info.plist`
- [ ] Archivo verificado en la ubicación correcta
- [ ] Listo para ejecutar `flutter pub get` y `pod install`

---

**¿Ya descargaste el archivo? ¿Necesitas ayuda para colocarlo?** 📱

