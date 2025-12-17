# 🚀 Pasos Finales para Configurar Codemagic

## ✅ Lo que ya tienes:
- ✅ `codemagic.yaml` sin errores
- ✅ App creada en App Store Connect
- ✅ Repositorio conectado en Codemagic

## 📋 Pasos Siguientes:

### Paso 1: Subir cambios a GitHub (si no lo has hecho)

**Desde la terminal:**
```bash
cd D:\xampp\htdocs\proyecto_certiva_void\certiva_app
git add codemagic.yaml
git commit -m "Configurar codemagic.yaml para TestFlight"
git push
```

**O desde GitHub Desktop:**
1. Abre GitHub Desktop
2. Verás el cambio en `codemagic.yaml`
3. Escribe: "Configurar codemagic.yaml"
4. Commit → Push

### Paso 2: Configurar Credenciales de App Store Connect

Codemagic necesita acceso a tu cuenta de App Store Connect para subir builds.

#### Opción A: API Key (Recomendado - Más Seguro)

1. **En App Store Connect:**
   - Ve a: [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Inicia sesión
   - Ve a: **"Usuarios y acceso"** → **"Claves"**
   - Haz clic en **"+"** (arriba a la izquierda)
   - Nombre: `Codemagic CI/CD`
   - Acceso: **Admin** o **App Manager**
   - Descarga el archivo `.p8` (⚠️ solo se puede descargar una vez)
   - Anota el **Key ID** y el **Issuer ID**

2. **En Codemagic:**
   - Ve a tu app `certiva-app`
   - Ve a: **"Settings"** → **"Teams"** → **"App Store Connect"**
   - Haz clic en **"Add credentials"**
   - Selecciona **"App Store Connect API key"**
   - Sube el archivo `.p8`
   - Ingresa el **Key ID**
   - Ingresa el **Issuer ID**
   - Nombre: `app_store_credentials` (debe coincidir con el nombre en codemagic.yaml)
   - Haz clic en **"Save"**

#### Opción B: Usuario y Contraseña (Más Simple)

1. **Crear contraseña específica de app:**
   - Ve a: [appleid.apple.com](https://appleid.apple.com)
   - Inicia sesión
   - Ve a **"Seguridad"** → **"Contraseñas de app"**
   - Genera una nueva para "App Store Connect"
   - Copia la contraseña

2. **En Codemagic:**
   - Ve a: **"Settings"** → **"Teams"** → **"App Store Connect"**
   - Haz clic en **"Add credentials"**
   - Selecciona **"App Store Connect credentials"**
   - Email: Tu email de Apple Developer
   - Contraseña: La contraseña específica de app que acabas de crear
   - Nombre: `app_store_credentials`
   - Haz clic en **"Save"**

### Paso 3: Configurar Code Signing

1. **En Codemagic, ve a tu app `certiva-app`**
2. **Ve a:** **"Code signing"** → **"iOS code signing"**
3. **Selecciona:** **"Automatic"**
   - Codemagic generará automáticamente los certificados y perfiles necesarios
4. **Guarda**

### Paso 4: Verificar que Codemagic Detecte el YAML

1. **En Codemagic, ve a tu app**
2. **Ve a:** **"Workflow Editor"** o **"Configuration"**
3. **Verifica que diga:** "Using codemagic.yaml from repository"
4. Si no lo detecta, haz clic en **"Switch to YAML configuration"**

### Paso 5: Ejecutar Primer Build

1. **En Codemagic, ve a tu app `certiva-app`**
2. **Haz clic en:** **"Start new build"** (botón verde)
3. **Selecciona:**
   - Branch: `main`
   - Workflow: `ios-workflow` (debería detectarse automáticamente)
4. **Haz clic en:** **"Start build"**
5. **Espera** (15-30 minutos)

### Paso 6: Verificar en TestFlight

1. **Ve a App Store Connect:**
   - [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
   - Selecciona tu app "Certiva App"
   - Ve a la pestaña **"TestFlight"**

2. **Espera 10-30 minutos** para que el build se procese

3. **Una vez procesado:**
   - Verás tu build listo para distribuir
   - Puedes agregar testers y distribuir

## ⚠️ Importante

- El nombre de las credenciales debe ser exactamente: `app_store_credentials`
- Debe coincidir con el nombre en `codemagic.yaml` (línea 13)
- Si usas un nombre diferente, cambia también el YAML

## 📋 Checklist Final

- [ ] Cambios subidos a GitHub
- [ ] Credenciales de App Store Connect configuradas en Codemagic
- [ ] Code signing configurado (automático)
- [ ] codemagic.yaml detectado en Codemagic
- [ ] Primer build ejecutado
- [ ] Build aparece en TestFlight

## 🆘 Si Tienes Problemas

### "Credentials not found"
- Verifica que el nombre sea exactamente `app_store_credentials`
- Verifica que las credenciales estén guardadas correctamente

### "Build failed"
- Revisa los logs en Codemagic
- Verifica que el Bundle ID coincida: `py.com.certiva.app`

### "No build appears in TestFlight"
- Espera 10-30 minutos
- Verifica que el build haya terminado exitosamente
- Revisa los emails de notificación

---

**¡Sigue estos pasos y tendrás tu app en TestFlight!** 🎉


