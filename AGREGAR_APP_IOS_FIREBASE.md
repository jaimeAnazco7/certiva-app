# 📱 Agregar App iOS a Firebase para Crashlytics

## 🎯 Objetivo

Agregar la app iOS a Firebase para que Crashlytics pueda capturar los crashes.

---

## 📋 Pasos Detallados

### **Paso 1: Ir a Configuración del Proyecto**

1. En Firebase Console, haz clic en el **ícono de configuración** (⚙️) en la parte superior
2. O ve a **"Configuración del proyecto"** o **"Project settings"**

### **Paso 2: Agregar App iOS**

1. En la página de configuración, busca la sección **"Tus apps"** o **"Your apps"**
2. Haz clic en el **ícono de iOS** 🍎
3. Se abrirá un formulario para registrar la app iOS

### **Paso 3: Configurar App iOS**

Completa el formulario:

- **Bundle ID de iOS**: `py.com.certiva.app`
  - ⚠️ **IMPORTANTE**: Debe ser exactamente este Bundle ID
- **Apodo de la app (opcional)**: `Certiva App`
- **App Store ID (opcional)**: Déjalo vacío por ahora
- Haz clic en **"Registrar app"** o **"Register app"**

### **Paso 4: Descargar GoogleService-Info.plist**

1. Se te mostrará una pantalla de configuración
2. Haz clic en **"Descargar GoogleService-Info.plist"** o **"Download GoogleService-Info.plist"**
3. **Guarda el archivo** en: `certiva_app/ios/Runner/GoogleService-Info.plist`
   - ⚠️ **IMPORTANTE**: Debe estar en esta ubicación exacta

### **Paso 5: Continuar con la Configuración**

1. Haz clic en **"Siguiente"** o **"Next"** en los pasos siguientes
2. Puedes saltar los pasos de instalación de SDK (ya lo haremos en el código)
3. Haz clic en **"Continuar a la consola"** o **"Continue to console"**

---

## 🔥 Paso 6: Activar Crashlytics para la App

### **Opción A: Desde la Página de Crashlytics**

1. Ve a **"Crashlytics"** en el menú lateral
2. Si ves **"Agrega una app para comenzar"**, haz clic en **"Agregar app"** o **"Add app"**
3. Selecciona tu app iOS (`py.com.certiva.app`)
4. Sigue las instrucciones para activar Crashlytics

### **Opción B: Desde la Configuración de la App**

1. En **"Configuración del proyecto"** → **"Tus apps"**
2. Haz clic en tu app iOS
3. Busca **"Crashlytics"** en las opciones
4. Haz clic en **"Activar"** o **"Enable"**

---

## ✅ Verificar que Está Configurado

### **Después de Agregar la App:**

1. Ve a **"Crashlytics"** en el menú lateral
2. Deberías ver:
   - Tu app iOS listada
   - Bundle ID: `py.com.certiva.app`
   - Estado: "Activo" o "Active"

### **Si Aún Dice "Agrega una app":**

1. Verifica que la app iOS esté agregada en **"Configuración del proyecto"**
2. Verifica que `GoogleService-Info.plist` esté descargado
3. Espera unos minutos (puede tardar en actualizarse)

---

## 📋 Checklist

- [ ] App iOS agregada en Firebase Console
- [ ] Bundle ID: `py.com.certiva.app`
- [ ] `GoogleService-Info.plist` descargado
- [ ] `GoogleService-Info.plist` colocado en `ios/Runner/`
- [ ] Crashlytics activado para la app iOS
- [ ] App visible en Crashlytics dashboard

---

## 🎯 Próximos Pasos

Una vez que la app esté agregada y Crashlytics activado:

1. **Compilar la app** con el código de Crashlytics
2. **Distribuir a testers** en TestFlight
3. **Ver crashes** en Firebase Console → Crashlytics

---

**¿Puedes agregar la app iOS a Firebase primero?** 📱



