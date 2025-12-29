# 📊 Logging Detallado para Debugging

## 🎯 Objetivo

Agregamos logging detallado con timestamps para identificar exactamente:
- **Cuándo** ocurre cada paso
- **Cuánto tiempo** tarda cada operación
- **Dónde** falla exactamente (si falla)

---

## 📋 Logs que Verás

### **En `main.dart`:**

```
🚀 [MAIN] Inicio de la aplicación - 2025-12-29T11:21:44.753Z
🔧 [MAIN] Llamando WidgetsFlutterBinding.ensureInitialized()...
✅ [MAIN] WidgetsFlutterBinding.ensureInitialized() completado
📱 [MAIN] Llamando runApp()...
✅ [MAIN] runApp() completado - App iniciada
🔄 [MAIN] Iniciando inicialización de Hive en segundo plano...
✅ [MAIN] Función _initializeHiveInBackground() llamada (no esperada)
```

### **En `_initializeHiveInBackground()`:**

```
⏳ [HIVE_BG] Iniciando inicialización diferida de Hive - 2025-12-29T11:21:44.754Z
⏳ [HIVE_BG] Esperando 1000ms para que los plugins nativos estén listos...
✅ [HIVE_BG] Delay completado después de 1000ms
🔄 [HIVE_BG] Intentando inicializar UserService (primer intento)...
```

### **En `UserService.init()`:**

```
📦 [UserService] Iniciando inicialización de Hive - 2025-12-29T11:21:45.754Z
📦 [UserService] Paso 1/5: Llamando Hive.initFlutter()...
✅ [UserService] Hive.initFlutter() completado en 150ms
📦 [UserService] Paso 2/5: Registrando UserAdapter...
✅ [UserService] UserAdapter registrado en 5ms
📦 [UserService] Paso 3/5: Abriendo box de usuarios...
✅ [UserService] Box de usuarios abierto en 20ms
📦 [UserService] Paso 4/5: Abriendo box de usuario actual...
✅ [UserService] Box de usuario actual abierto en 15ms
📦 [UserService] Paso 5/5: Abriendo box de credenciales...
✅ [UserService] Box de credenciales abierto en 12ms
✅ [UserService] Inicialización de Hive completada exitosamente en 202ms
```

---

## 🔍 Si Hay un Error

### **Error en el primer intento:**

```
❌ [UserService] Error inicializando Hive después de 50ms
❌ [UserService] Error: EXC_BAD_ACCESS...
❌ [UserService] Stack trace: ...
⏳ [UserService] Esperando 500ms antes del segundo intento...
🔄 [UserService] Segundo intento de inicialización...
```

### **Error en el segundo intento:**

```
❌ [HIVE_BG] Error en segundo intento de inicialización - 2025-12-29T11:21:48.254Z
❌ [HIVE_BG] Error: EXC_BAD_ACCESS...
❌ [HIVE_BG] Stack trace: ...
⚠️ [HIVE_BG] La app continuará sin Hive inicializado
```

---

## 📊 Información que Obtendremos

### **1. Timing Exacto:**
- Cuánto tarda cada paso
- Cuánto tiempo total desde el inicio
- Si el delay es suficiente

### **2. Punto de Falla:**
- ¿Falla en `Hive.initFlutter()`?
- ¿Falla al abrir un box específico?
- ¿En qué paso exacto ocurre el crash?

### **3. Comparación:**
- ¿El primer intento falla pero el segundo funciona?
- ¿Cuánto tiempo necesita el delay?

---

## 🔍 Cómo Revisar los Logs

### **En TestFlight:**

1. **Ir a App Store Connect** → **TestFlight** → **Errores**
2. **Hacer clic en el crash** más reciente
3. **Buscar la sección "System Logs"** o **"Console Output"**
4. **Buscar los logs que empiezan con:**
   - `🚀 [MAIN]`
   - `📦 [UserService]`
   - `⏳ [HIVE_BG]`

### **En Xcode (si pruebas localmente):**

1. **Conectar iPhone**
2. **Ejecutar:** `flutter run --release`
3. **Ver logs en la consola de Xcode**

### **En Codemagic:**

1. **Ir al build** en Codemagic
2. **Revisar los logs** del paso "Building iOS"
3. **Buscar los mensajes de logging**

---

## 📋 Qué Buscar

### **Si el crash ocurre:**

1. **¿En qué paso falla?**
   - `Hive.initFlutter()` ← **Este es el problema**
   - `Hive.registerAdapter()`
   - `Hive.openBox()`

2. **¿Cuánto tiempo pasó?**
   - Si falla antes de 1000ms → El delay no es suficiente
   - Si falla después de 1000ms → El problema es otro

3. **¿El segundo intento funciona?**
   - Si funciona → Necesitamos un delay más largo
   - Si no funciona → El problema es más profundo

---

## 🎯 Próximos Pasos

1. **Compilar con el nuevo logging**
2. **Distribuir a testers**
3. **Revisar los logs del crash**
4. **Ajustar la solución** basándose en los logs

---

**Con este logging detallado, podremos identificar exactamente qué está pasando.** 🔍

