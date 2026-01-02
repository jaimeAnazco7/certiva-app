# 📊 Cómo Ver los Logs del Sistema en App Store Connect

## 🎯 Dónde Están los Logs

Los logs que agregamos (🚀 [MAIN], 📦 [UserService], etc.) **NO están en la lista de "Comentarios de errores"**.

Están en la **página de detalles de cada crash individual**.

---

## 📋 Pasos para Ver los Logs

### **Paso 1: Ir a la Lista de Crashes**

1. Estás en **TestFlight** → **"Comentarios"** → **"Errores"**
2. Verás la tabla con los crashes (como la que estás viendo ahora)

### **Paso 2: Hacer Clic en un Crash Específico**

1. **Haz clic en cualquier fila** de la tabla (cualquier crash)
   - Por ejemplo, haz clic en el crash del **29 dic. 2025, a las 14:21** (build 1.0.0 (3))
2. Se abrirá la **página de detalles del crash**

### **Paso 3: Buscar los Logs del Sistema**

En la página de detalles del crash, busca estas secciones:

#### **Opción A: "System Logs" o "Registros del sistema"**
- Busca una pestaña o sección llamada **"System Logs"**
- O **"Registros del sistema"**
- O **"Device Logs"** / **"Registros del dispositivo"**

#### **Opción B: "Console Output" o "Salida de consola"**
- Busca **"Console Output"**
- O **"Salida de consola"**
- O **"Application Logs"** / **"Registros de la aplicación"**

#### **Opción C: "Crash Details" o "Detalles del crash"**
- En la página de detalles, busca una sección expandible
- Puede estar en **"Crash Details"** → **"System Logs"**
- O en **"Additional Information"** → **"Logs"**

---

## 🔍 Qué Buscar en los Logs

Una vez que encuentres los logs, busca estos mensajes:

### **Logs de Inicialización:**
```
🚀 [MAIN] Inicio de la aplicación - 2025-12-29T14:21:44.753Z
🔧 [MAIN] Llamando WidgetsFlutterBinding.ensureInitialized()...
✅ [MAIN] WidgetsFlutterBinding.ensureInitialized() completado
📱 [MAIN] Llamando runApp()...
✅ [MAIN] runApp() completado - App iniciada
🔄 [MAIN] Iniciando inicialización de Hive en segundo plano...
```

### **Logs de Hive:**
```
⏳ [HIVE_BG] Iniciando inicialización diferida de Hive - 2025-12-29T14:21:45.754Z
⏳ [HIVE_BG] Esperando 1000ms para que los plugins nativos estén listos...
✅ [HIVE_BG] Delay completado después de 1000ms
🔄 [HIVE_BG] Intentando inicializar UserService (primer intento)...
```

### **Logs de UserService:**
```
📦 [UserService] Iniciando inicialización de Hive - 2025-12-29T14:21:45.754Z
📦 [UserService] Paso 1/5: Llamando Hive.initFlutter()...
```

### **Si Hay Error:**
```
❌ [UserService] Error inicializando Hive después de 50ms
❌ [UserService] Error: EXC_BAD_ACCESS...
❌ [UserService] Stack trace: ...
```

---

## ⚠️ Si No Aparecen los Logs

### **Posibles Razones:**

1. **Los logs no se capturaron:**
   - Si el crash ocurre muy rápido, los logs pueden no haberse guardado
   - O si el crash ocurre antes de que Flutter inicie completamente

2. **Los logs están en otra sección:**
   - Busca en todas las pestañas/secciones de la página de detalles
   - Puede estar en "Raw Crash Log" o "Symbolicated Crash Log"

3. **Los logs están en formato diferente:**
   - Puede que aparezcan sin los emojis
   - Busca por texto como "[MAIN]", "[UserService]", "[HIVE_BG]"

4. **Los logs solo aparecen en release mode si usamos `debugPrint`:**
   - Si usamos `print`, puede que no aparezcan en release
   - Necesitamos cambiar a `debugPrint` para que siempre aparezcan

---

## 🔧 Cambiar a `debugPrint` (Si No Aparecen)

Si los logs no aparecen, podemos cambiar todos los `print` por `debugPrint`:

```dart
// En lugar de:
print('🚀 [MAIN] Inicio...');

// Usar:
debugPrint('🚀 [MAIN] Inicio...');
```

**`debugPrint` siempre imprime, incluso en release mode.**

---

## 📍 Ubicación Exacta (Resumen)

1. **TestFlight** → **"Comentarios"** → **"Errores"** (donde estás ahora)
2. **Hacer clic en un crash** (ej: 29 dic. 2025, 14:21)
3. **En la página de detalles**, buscar:
   - **"System Logs"** o **"Registros del sistema"**
   - **"Console Output"** o **"Salida de consola"**
   - **"Device Logs"** o **"Registros del dispositivo"**
4. **Buscar los emojis** (🚀, 📦, ⏳, ✅, ❌) o el texto `[MAIN]`, `[UserService]`, `[HIVE_BG]`

---

## 🎯 Próximos Pasos

1. **Haz clic en el crash más reciente** (29 dic. 2025, 14:21)
2. **Busca las secciones mencionadas** en la página de detalles
3. **Dime qué ves** o si no encuentras los logs
4. **Si no aparecen**, podemos cambiar a `debugPrint`

---

**¿Puedes hacer clic en un crash y decirme qué secciones ves en la página de detalles?** 🔍



