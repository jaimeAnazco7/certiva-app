# 🔍 Cómo Revisar Logs en Codemagic para Verificar Subida a TestFlight

## 📋 Pasos para Ver los Logs

### Paso 1: Abrir el Build

1. **En Codemagic, ve a la página de Builds**
2. **Haz clic en el build** que quieres revisar (el que dice "certiva-app: Default Workflow #1")
3. O haz clic en el **icono de enlace externo** (el segundo icono a la derecha del build)

### Paso 2: Revisar el Paso "Publishing"

1. **En la página de detalles del build**, busca el panel derecho con los pasos
2. **Haz clic en el paso "Publishing"** (debería estar en la lista de pasos)
3. **Revisa los logs** que aparecen

### Paso 3: Buscar Errores Específicos

En los logs, busca:

#### ✅ Si se subió correctamente, verás:
- "Uploading to App Store Connect..."
- "Successfully uploaded to App Store Connect"
- "Build uploaded successfully"
- O mensajes similares de éxito

#### ❌ Si hay errores, verás:
- "Failed to upload"
- "Authentication failed"
- "Invalid credentials"
- "Bundle ID mismatch"
- "No app found"
- O mensajes de error en rojo

## 🔍 Qué Buscar en los Logs

### Errores Comunes:

1. **"App Store Connect API key is required"**
   - **Solución:** Verifica que las credenciales estén configuradas correctamente

2. **"No app found with bundle ID"**
   - **Solución:** Verifica que el Bundle ID en codemagic.yaml coincida con App Store Connect

3. **"Authentication failed"**
   - **Solución:** Verifica que las credenciales de App Store Connect sean válidas

4. **"Distribution step is disabled"**
   - **Solución:** Habilita "App Store Connect" en la configuración de distribución

## 📍 Ubicación de los Logs

Los logs están en:
- **Panel derecho** del build (pasos del workflow)
- **Paso "Publishing"** o **"Distribution"**
- O busca "App Store Connect" en los logs

## 🛠️ Verificar Configuración

Si no se subió, también verifica:

1. **En Workflow Editor:**
   - Ve a tu app → Workflow Editor
   - Expande "Distribution"
   - Verifica que "App Store Connect" NO esté marcado como `[disabled]`
   - Debe estar habilitado

2. **En codemagic.yaml:**
   - Verifica que `submit_to_testflight: true` esté configurado
   - Verifica que `auth: integration` esté correcto

## 📸 Cómo Ver los Logs (Paso a Paso)

1. **Haz clic en el build** en la lista
2. **En el panel derecho**, verás los pasos:
   - Preparing build machine
   - Fetching app sources
   - Installing SDKs
   - Set up code signing identities
   - Installing dependencies
   - Building iOS
   - **Publishing** ← Haz clic aquí
   - Cleaning up
3. **Haz clic en "Publishing"**
4. **Revisa los logs** que aparecen

## 🆘 Si No Aparece el Paso "Publishing"

Si no ves el paso "Publishing", significa que:
- La distribución no está habilitada
- Necesitas habilitar "App Store Connect" en la configuración

---

**¿Puedes revisar los logs y decirme qué error aparece?** 🔍



