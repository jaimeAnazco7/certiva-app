# 🚀 Configurar Codemagic - Paso a Paso

## ✅ Lo que ya tienes:
- ✅ Código subido a GitHub: `jaimeAnazco7/certiva-app`
- ✅ Bundle ID configurado: `py.com.certiva.app`
- ✅ App creada en App Store Connect: "Certiva App"
- ✅ `codemagic.yaml` configurado

## 🎯 Próximos Pasos:

### Paso 1: Crear Cuenta en Codemagic

1. **Ve a:** [codemagic.io](https://codemagic.io)
2. **Haz clic en:** "Sign up" o "Get started"
3. **Inicia sesión con GitHub:**
   - Haz clic en "Sign in with GitHub"
   - Autoriza a Codemagic para acceder a tus repositorios
   - Selecciona el repositorio `certiva-app` cuando te lo pida

### Paso 2: Agregar Aplicación

1. **En Codemagic, haz clic en:** "Add application" o "+"
2. **Selecciona tu repositorio:**
   - Busca: `jaimeAnazco7/certiva-app`
   - O selecciónalo de la lista
3. **Tipo de app:**
   - Codemagic debería detectar automáticamente que es Flutter
   - Si no, selecciona "Flutter app"
4. **Haz clic en:** "Add application"

### Paso 3: Configurar Credenciales de App Store Connect

Codemagic necesita acceso a tu cuenta de App Store Connect para subir builds a TestFlight.

#### Opción A: API Key (Recomendado - Más Seguro)

1. **En App Store Connect:**
   - Ve a: [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Ve a: **"Usuarios y acceso"** → **"Claves"**
   - Haz clic en **"+"** para crear una nueva clave
   - Nombre: `Codemagic CI/CD`
   - Acceso: **Admin** o **App Manager**
   - Descarga el archivo `.p8` (solo se puede descargar una vez)
   - Anota el **Key ID** y el **Issuer ID**

2. **En Codemagic:**
   - Ve a tu app → **"Settings"** → **"Teams"** → **"App Store Connect"**
   - Haz clic en **"Add credentials"**
   - Selecciona **"App Store Connect API key"**
   - Sube el archivo `.p8`
   - Ingresa el **Key ID** y **Issuer ID**
   - Guarda

#### Opción B: Usuario y Contraseña (Más Simple)

1. **En Codemagic:**
   - Ve a tu app → **"Settings"** → **"Teams"** → **"App Store Connect"**
   - Haz clic en **"Add credentials"**
   - Selecciona **"App Store Connect credentials"**
   - Email: Tu email de Apple Developer
   - Contraseña: **Contraseña específica de app** (no tu contraseña normal)

2. **Crear contraseña específica de app:**
   - Ve a: [appleid.apple.com](https://appleid.apple.com)
   - Inicia sesión
   - Ve a **"Seguridad"** → **"Contraseñas de app"**
   - Genera una nueva para "App Store Connect"
   - Úsala en Codemagic

### Paso 4: Configurar Code Signing

1. **En Codemagic, ve a tu app**
2. **Ve a:** **"Code signing"** → **"iOS code signing"**
3. **Selecciona:** **"Automatic"**
   - Codemagic generará automáticamente los certificados y perfiles necesarios
4. **Guarda**

### Paso 5: Verificar codemagic.yaml

1. **En Codemagic, ve a:** **"Configuration"** → **"Workflow settings"**
2. **Selecciona:** **"Use codemagic.yaml"**
   - Codemagic usará el archivo `codemagic.yaml` de tu repositorio
3. **Verifica que detecte el archivo:**
   - Debería mostrar: "Using codemagic.yaml from repository"

### Paso 6: Ejecutar Primer Build

1. **En Codemagic, ve a tu app**
2. **Haz clic en:** **"Start new build"**
3. **Selecciona:**
   - Branch: `main`
   - Workflow: `ios-workflow` (debería detectarse automáticamente)
4. **Haz clic en:** **"Start build"**
5. **Espera** (15-30 minutos)

### Paso 7: Verificar en TestFlight

1. **Ve a App Store Connect:**
   - [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Selecciona tu app "Certiva App"
   - Ve a la pestaña **"TestFlight"**

2. **Espera 10-30 minutos** para que el build se procese

3. **Una vez procesado:**
   - Verás tu build listo para distribuir
   - Puedes agregar testers y distribuir

## ⚠️ Problemas Comunes

### "codemagic.yaml not found"
- Verifica que el archivo esté en la raíz del repositorio
- O ajusta la ruta en la configuración de Codemagic

### "Invalid credentials"
- Verifica que las credenciales de App Store Connect estén correctas
- Si usas contraseña, asegúrate de usar una contraseña específica de app

### "Bundle ID not found"
- Verifica que el Bundle ID en `codemagic.yaml` coincida con el de App Store Connect
- Debe ser exactamente: `py.com.certiva.app`

## 📋 Checklist Final

- [ ] Cuenta de Codemagic creada
- [ ] Repositorio conectado
- [ ] Credenciales de App Store Connect configuradas
- [ ] Code signing configurado (automático)
- [ ] codemagic.yaml detectado
- [ ] Primer build ejecutado
- [ ] Build aparece en TestFlight

---

**¿Listo para configurar Codemagic?** 🚀






