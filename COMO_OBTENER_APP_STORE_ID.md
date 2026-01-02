# 🔍 Cómo Obtener el App Store ID

## 🎯 ¿Qué es el App Store ID?

El **App Store ID** es un número único que Apple asigna a tu app cuando la creas en App Store Connect.

**Ejemplo:** `1234567890` (9-10 dígitos)

**No es lo mismo que:**
- ❌ **Bundle ID**: `py.com.certiva.app` (identificador de la app)
- ✅ **App Store ID**: `1234567890` (número único de Apple)

---

## 📱 Cómo Obtenerlo (Si Ya Tienes la App Creada)

### **Método 1: Desde App Store Connect (Más Fácil)**

1. **Ve a App Store Connect:**
   - https://appstoreconnect.apple.com
   - Inicia sesión con tu cuenta de Apple Developer

2. **Ve a "Mis Apps" o "Apps":**
   - Haz clic en el icono de apps en el menú
   - O ve directamente a: https://appstoreconnect.apple.com/apps

3. **Selecciona tu app "Certiva App"**

4. **El App Store ID está en la URL:**
   - Mira la barra de direcciones
   - Verás algo como: `https://appstoreconnect.apple.com/apps/1234567890/...`
   - El número `1234567890` es tu **App Store ID**

5. **O en la página de la app:**
   - En la parte superior, verás información de la app
   - Busca "App Store ID" o "ID de App Store"
   - O mira en "Información de la app" → "App Store ID"

---

### **Método 2: Desde la Página Principal de la App**

1. **En App Store Connect, abre tu app "Certiva App"**

2. **En la parte superior de la página:**
   - Verás el nombre de la app
   - Debajo o al lado, verás el **App Store ID**
   - Es un número de 9-10 dígitos

3. **Ejemplo de cómo se ve:**
   ```
   Certiva App
   App Store ID: 1234567890
   ```

---

### **Método 3: Desde la URL del Navegador**

1. **Abre tu app en App Store Connect**

2. **Mira la barra de direcciones:**
   ```
   https://appstoreconnect.apple.com/apps/1234567890/appstore
   ```
   - El número `1234567890` es tu **App Store ID**

---

## ⚠️ ¿Necesitas el App Store ID para Firebase?

### **Respuesta: NO es obligatorio**

**Para Firebase Crashlytics:**
- ✅ El App Store ID es **OPCIONAL**
- ✅ Puedes dejarlo **vacío** si no lo tienes
- ✅ Firebase funcionará perfectamente sin él

**Cuándo es útil:**
- Si quieres vincular Firebase con App Store Connect
- Si quieres ver estadísticas de descargas en Firebase
- Si usas otras funciones avanzadas de Firebase

**Para tu caso:**
- ✅ Puedes dejarlo vacío en Firebase
- ✅ Crashlytics funcionará perfectamente
- ✅ Los logs y crashes se capturarán normalmente

---

## 📋 Pasos para Obtenerlo (Si Quieres)

### **Si ya creaste la app en App Store Connect:**

1. Ve a: https://appstoreconnect.apple.com/apps
2. Haz clic en "Certiva App"
3. Mira la URL o la información de la app
4. Copia el número (App Store ID)

### **Si NO has creado la app aún:**

1. **Primero crea la app en App Store Connect:**
   - Ve a: https://appstoreconnect.apple.com
   - Apps → "+" → Nueva App
   - Completa el formulario con:
     - Bundle ID: `py.com.certiva.app`
     - Nombre: `Certiva App`
   - Crea la app

2. **Después de crear la app:**
   - Apple te asignará un App Store ID automáticamente
   - Lo verás en la página de la app

---

## ✅ Qué Hacer Ahora en Firebase

### **Opción 1: Dejarlo Vacío (Recomendado por Ahora)**

1. **Borra el `123456789` del campo**
2. **Déjalo vacío**
3. **Haz clic en "Registrar app"**
4. ✅ Firebase funcionará perfectamente

### **Opción 2: Agregarlo Después**

1. **Registra la app en Firebase sin el App Store ID**
2. **Después, cuando tengas el App Store ID:**
   - Ve a Firebase Console → Configuración del proyecto
   - Edita la app iOS
   - Agrega el App Store ID

---

## 🎯 Resumen

### **¿Cómo obtener el App Store ID?**
1. Ve a App Store Connect → Apps → Tu app
2. Mira la URL o la información de la app
3. Copia el número (9-10 dígitos)

### **¿Es necesario para Firebase?**
- ❌ **NO es obligatorio**
- ✅ Puedes dejarlo vacío
- ✅ Crashlytics funcionará sin él

### **Qué hacer ahora:**
- ✅ **Borra el `123456789` del campo**
- ✅ **Déjalo vacío**
- ✅ **Haz clic en "Registrar app"**
- ✅ **Continúa con la descarga de `GoogleService-Info.plist`**

---

## 📝 Ejemplo Visual

**En App Store Connect, verás algo así:**

```
┌─────────────────────────────────────┐
│  Certiva App                        │
│  App Store ID: 1234567890          │
│  Bundle ID: py.com.certiva.app     │
└─────────────────────────────────────┘
```

**O en la URL:**
```
https://appstoreconnect.apple.com/apps/1234567890/appstore
                                    ^^^^^^^^^^^^
                                    Este es el ID
```

---

**¿Prefieres dejarlo vacío por ahora o quieres obtenerlo primero?** 📱

