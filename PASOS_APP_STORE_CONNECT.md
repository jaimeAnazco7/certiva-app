# 📱 Pasos en App Store Connect - Crear Nueva App

## 🎯 Objetivo
Crear la app "Certiva App" en App Store Connect con el Bundle ID `py.com.certiva.app`

## 📋 Paso a Paso

### Paso 1: Ir a "Apps"
1. En la página principal de App Store Connect (donde estás ahora)
2. Haz clic en el icono azul **"Apps"** (el cuadrado con tres rectángulos blancos)
3. O ve directamente a: https://appstoreconnect.apple.com/apps

### Paso 2: Crear Nueva App
1. En la parte superior derecha, haz clic en el botón **"+"** o **"Nueva App"**
2. Se abrirá un formulario

### Paso 3: Completar Información de la App

Completa los siguientes campos:

#### **Plataforma:**
- Selecciona: **iOS**

#### **Nombre:**
- Ingresa: **Certiva App**
- (Este es el nombre que verán los usuarios en el App Store)

#### **Idioma principal:**
- Selecciona: **Español (España)** o **Español (México)** según tu preferencia

#### **Bundle ID:**
- **IMPORTANTE:** Selecciona o ingresa: **py.com.certiva.app**
- Si no aparece en la lista, necesitas crearlo primero (ver abajo)

#### **SKU:**
- Ingresa un identificador único, por ejemplo: **certiva-app-001**
- Este es solo para identificación interna, no se muestra a los usuarios

### Paso 4: Si el Bundle ID no existe

Si `py.com.certiva.app` no aparece en la lista de Bundle IDs:

1. Ve a [Apple Developer Portal](https://developer.apple.com/account)
2. Inicia sesión con tu cuenta
3. Ve a **"Certificates, Identifiers & Profiles"**
4. Haz clic en **"Identifiers"**
5. Haz clic en el botón **"+"** (arriba a la izquierda)
6. Selecciona **"App IDs"** → **"Continue"**
7. Selecciona **"App"** → **"Continue"**
8. Completa:
   - **Description:** Certiva App
   - **Bundle ID:** Selecciona **"Explicit"** e ingresa: `py.com.certiva.app`
9. Marca las **Capabilities** que necesites (Push Notifications, etc.)
10. Haz clic en **"Continue"** → **"Register"**
11. Vuelve a App Store Connect y crea la app

### Paso 5: Crear la App
1. Revisa que toda la información esté correcta
2. Haz clic en **"Crear"** o **"Create"**
3. ¡Listo! Tu app estará creada

## ✅ Verificación

Después de crear la app, deberías ver:
- El nombre: **Certiva App**
- Bundle ID: **py.com.certiva.app**
- Estado: **Preparar para envío** o similar

## 🚀 Siguiente Paso

Una vez creada la app:
1. Ve a la pestaña **"TestFlight"**
2. Ahí es donde aparecerán los builds que subas desde Codemagic
3. Sigue con la configuración de Codemagic (ver `GUIA_CODEMAGIC.md`)

## ⚠️ Notas Importantes

- El Bundle ID debe coincidir **exactamente** con el de tu proyecto: `py.com.certiva.app`
- El nombre de la app puede cambiarse después
- El SKU no se puede cambiar después de crear la app
- Necesitas una cuenta de Apple Developer activa ($99 USD/año)

## 🆘 Problemas Comunes

### "Bundle ID no disponible"
- Verifica que no esté en uso por otra app
- Asegúrate de que el formato sea correcto: `py.com.certiva.app`

### "No tienes permisos"
- Asegúrate de tener rol de **Admin** o **App Manager** en la cuenta
- Contacta al administrador de la cuenta si es necesario

### "Bundle ID no aparece"
- Crea el Bundle ID primero en Apple Developer Portal (ver Paso 4)
- Espera unos minutos y vuelve a intentar

---

**¡Sigue estos pasos y estarás listo para subir tu app a TestFlight!** 🎉




