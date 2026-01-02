# 🔥 Cómo Activar Crashlytics en Firebase Console

## ✅ Pasos para Activar Crashlytics

### **Paso 1: Ir a Firebase Console**

1. Ve a: **https://console.firebase.google.com/**
2. Selecciona tu proyecto **"certiva-crashlytics"** (o el que creaste)

### **Paso 2: Ir a Crashlytics**

1. En el menú lateral izquierdo, busca **"Crashlytics"**
2. Si no lo ves, puede estar en **"Build"** → **"Crashlytics"**
3. O busca en **"Productos"** o **"Products"**

### **Paso 3: Activar Crashlytics**

1. Si es la primera vez, verás un botón **"Activar Crashlytics"** o **"Enable Crashlytics"**
2. Haz clic en **"Activar"** o **"Enable"**
3. Puede tardar unos minutos en activarse

### **Paso 4: Verificar que Esté Activo**

1. Después de activar, deberías ver:
   - **Dashboard de Crashlytics**
   - **Lista de crashes** (si hay alguno)
   - **Estadísticas** de crashes

---

## 📱 Configurar para iOS

### **Paso 1: Verificar App iOS**

1. En Crashlytics, verifica que tu app iOS esté listada
2. Debería aparecer con el Bundle ID: `py.com.certiva.app`

### **Paso 2: Verificar GoogleService-Info.plist**

1. Asegúrate de que `GoogleService-Info.plist` esté descargado
2. Debe estar en: `certiva_app/ios/Runner/GoogleService-Info.plist`

### **Paso 3: Verificar Configuración**

1. En Firebase Console, ve a **"Configuración del proyecto"** (⚙️)
2. Verifica que la app iOS esté agregada
3. Verifica que el Bundle ID sea correcto: `py.com.certiva.app`

---

## 🔍 Verificar que Funciona

### **Después de Compilar:**

1. **Compilar la app** con Crashlytics integrado
2. **Instalar en un dispositivo** (TestFlight o físico)
3. **Forzar un crash** (opcional, solo para testing):
   ```dart
   FirebaseCrashlytics.instance.crash();
   ```
4. **Esperar 5-10 minutos**
5. **Ir a Firebase Console** → **Crashlytics**
6. **Deberías ver el crash** en la lista

---

## ⚠️ Importante

### **Crashlytics NO se activa automáticamente:**

- ❌ Solo agregar las dependencias **NO activa** Crashlytics
- ✅ Debes **activarlo manualmente** en Firebase Console
- ✅ Debes tener **GoogleService-Info.plist** configurado
- ✅ La app debe **compilarse y ejecutarse** al menos una vez

---

## 📋 Checklist

- [ ] Proyecto Firebase creado
- [ ] App iOS agregada con Bundle ID `py.com.certiva.app`
- [ ] `GoogleService-Info.plist` descargado y colocado en `ios/Runner/`
- [ ] Crashlytics **activado** en Firebase Console
- [ ] Dependencias agregadas en `pubspec.yaml`
- [ ] Código integrado en `main.dart` y `user_service.dart`
- [ ] App compilada y ejecutada al menos una vez
- [ ] Crashes visibles en Firebase Console → Crashlytics

---

## 🎯 Ubicación en Firebase Console

**Ruta típica:**
```
Firebase Console
  └── Tu Proyecto (certiva-crashlytics)
      └── Build (o Productos)
          └── Crashlytics ← AQUÍ
```

**O en el menú lateral:**
- **"Crashlytics"** (si está visible directamente)
- **"Build"** → **"Crashlytics"**
- **"Productos"** → **"Crashlytics"**

---

## 🆘 Si No Ves "Crashlytics"

### **Posibles Razones:**

1. **No está activado:**
   - Busca un botón "Activar Crashlytics" o "Enable Crashlytics"
   - Haz clic para activarlo

2. **Está en otra ubicación:**
   - Busca en "Build" o "Productos"
   - O usa la búsqueda en Firebase Console

3. **Necesitas permisos:**
   - Verifica que tengas permisos de Admin o Editor en el proyecto

---

**¿Puedes ir a Firebase Console y activar Crashlytics?** 🔥



