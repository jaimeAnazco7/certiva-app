# 🔥 Implementar Firebase Crashlytics - Guía Completa

## 🎯 Objetivo

Implementar Firebase Crashlytics para capturar automáticamente los crashes y logs, lo que nos ayudará a diagnosticar el problema del crash en iOS.

---

## 📋 Paso 1: Agregar App iOS a Firebase

### **1.1. Ir a Firebase Console**

1. Ve a: **https://console.firebase.google.com/**
2. Selecciona tu proyecto **"certiva-crashlytics"** (o el que creaste)

### **1.2. Agregar App iOS**

1. En el dashboard, haz clic en el **ícono de iOS** 🍎
2. Se abrirá un formulario para registrar la app iOS

### **1.3. Configurar App iOS**

- **Bundle ID de iOS**: `py.com.certiva.app`
  - ⚠️ **IMPORTANTE**: Debe ser exactamente este Bundle ID
- **Apodo de la app (opcional)**: `Certiva App`
- **App Store ID (opcional)**: Déjalo vacío por ahora
- Haz clic en **"Registrar app"**

### **1.4. Descargar `GoogleService-Info.plist`**

1. Se te mostrará una pantalla de configuración
2. Haz clic en **"Descargar GoogleService-Info.plist"**
3. **Guarda el archivo** en: `certiva_app/ios/Runner/GoogleService-Info.plist`
   - ⚠️ **IMPORTANTE**: Debe estar en esta ubicación exacta

---

## 📦 Paso 2: Agregar Dependencias en Flutter

### **2.1. Editar `pubspec.yaml`**

Agrega estas dependencias:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... otras dependencias existentes ...
  firebase_core: ^3.5.0
  firebase_crashlytics: ^4.1.3
```

### **2.2. Instalar Dependencias**

```bash
cd certiva_app
flutter pub get
```

---

## 🔧 Paso 3: Configurar iOS

### **3.1. Verificar que `GoogleService-Info.plist` esté en la ubicación correcta**

```
certiva_app/
  ios/
    Runner/
      GoogleService-Info.plist  ← Debe estar aquí
```

### **3.2. Configurar `Podfile`**

Abre `certiva_app/ios/Podfile` y verifica que tenga:

```ruby
platform :ios, '12.0'  # O la versión mínima que uses
```

### **3.3. Instalar Pods**

```bash
cd certiva_app/ios
pod install
cd ..
```

---

## 💻 Paso 4: Integrar Crashlytics en el Código

### **4.1. Modificar `main.dart`**

Agrega la inicialización de Firebase y Crashlytics:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'screens/welcome_screen.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp();
  
  // Configurar Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // Pasar errores no capturados a Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  // Inicializar la app primero, luego Hive en segundo plano
  runApp(const MyApp());
  
  // Inicializar Hive después de que la app esté corriendo
  _initializeHiveInBackground();
}
```

---

## 📊 Paso 5: Agregar Logs Personalizados

### **5.1. Modificar `main.dart` para usar Crashlytics**

Reemplaza los `print` por logs de Crashlytics:

```dart
// En lugar de:
print('🚀 [MAIN] Inicio de la aplicación');

// Usar:
FirebaseCrashlytics.instance.log('🚀 [MAIN] Inicio de la aplicación');
debugPrint('🚀 [MAIN] Inicio de la aplicación'); // También mantener debugPrint
```

### **5.2. Modificar `user_service.dart`**

Agrega logs de Crashlytics en puntos críticos:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

static Future<void> init() async {
  final startTime = DateTime.now();
  FirebaseCrashlytics.instance.log('📦 [UserService] Iniciando inicialización de Hive');
  debugPrint('📦 [UserService] Iniciando inicialización de Hive - ${startTime.toIso8601String()}');
  
  try {
    FirebaseCrashlytics.instance.log('📦 [UserService] Paso 1/5: Llamando Hive.initFlutter()');
    await Hive.initFlutter();
    // ... resto del código ...
  } catch (e, stackTrace) {
    FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: false);
    FirebaseCrashlytics.instance.log('❌ [UserService] Error: $e');
    // ... resto del manejo de errores ...
  }
}
```

---

## 🧪 Paso 6: Probar Crashlytics

### **6.1. Forzar un Crash de Prueba (Opcional)**

Puedes agregar un botón de prueba para verificar que Crashlytics funciona:

```dart
// En algún lugar de tu app (solo para testing)
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();
  },
  child: Text('Forzar Crash (Solo Testing)'),
)
```

### **6.2. Compilar y Probar**

```bash
cd certiva_app
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

---

## 📊 Paso 7: Ver Crashes en Firebase Console

### **7.1. Ir a Firebase Console**

1. Ve a: **https://console.firebase.google.com/**
2. Selecciona tu proyecto **"certiva-crashlytics"**
3. En el menú lateral, haz clic en **"Crashlytics"**

### **7.2. Ver los Crashes**

1. Verás una lista de crashes reportados
2. Haz clic en un crash para ver:
   - **Stack trace completo**
   - **Logs personalizados** (los que agregamos)
   - **Información del dispositivo**
   - **Versión de la app**
   - **Timing exacto**

---

## ✅ Checklist de Implementación

- [ ] App iOS agregada a Firebase con Bundle ID `py.com.certiva.app`
- [ ] `GoogleService-Info.plist` descargado y colocado en `ios/Runner/`
- [ ] Dependencias agregadas en `pubspec.yaml`:
  - [ ] `firebase_core: ^3.5.0`
  - [ ] `firebase_crashlytics: ^4.1.3`
- [ ] `flutter pub get` ejecutado
- [ ] `pod install` ejecutado en `ios/`
- [ ] Firebase inicializado en `main.dart`
- [ ] Crashlytics configurado en `main.dart`
- [ ] Logs agregados en `user_service.dart`
- [ ] App compilada y probada
- [ ] Crashes visibles en Firebase Console

---

## 🎯 Ventajas de Crashlytics

1. **Captura automática** de crashes
2. **Logs personalizados** con timestamps
3. **Stack traces completos** y simbolizados
4. **Información del dispositivo** (modelo, iOS version, etc.)
5. **Agrupación de crashes** similares
6. **Alertas** cuando hay nuevos crashes

---

## 📝 Próximos Pasos

1. **Implementar Crashlytics** siguiendo esta guía
2. **Compilar y distribuir** a testers
3. **Revisar crashes en Firebase Console**
4. **Analizar los logs** para identificar el problema exacto

---

**¿Quieres que te ayude a implementar cada paso?** 🚀



