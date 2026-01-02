# Cómo Cambiar el Bundle Identifier

El Bundle Identifier es un identificador único para tu app. Actualmente está configurado como `com.example.certivaApp`, pero necesitas cambiarlo por uno único que coincida con tu cuenta de Apple Developer.

## ⚠️ Importante

El Bundle Identifier debe:
- Ser único (no puede estar en uso por otra app)
- Seguir el formato: `com.tuempresa.nombreapp` o `py.com.certiva.app`
- Coincidir exactamente con el configurado en App Store Connect

## 🔧 Método 1: Usando Xcode (Recomendado)

1. Abre el proyecto en Xcode:
   ```
   certiva_app/ios/Runner.xcworkspace
   ```
   **Nota:** Debes abrir el `.xcworkspace`, NO el `.xcodeproj`

2. En el navegador de archivos (lado izquierdo), haz clic en el proyecto "Runner" (el icono azul en la parte superior)

3. En el panel central, selecciona el target "Runner" (no el proyecto)

4. Ve a la pestaña **"Signing & Capabilities"**

5. En la sección **"Bundle Identifier"**, cambia el valor de:
   ```
   com.example.certivaApp
   ```
   a tu Bundle ID único, por ejemplo:
   ```
   com.tuempresa.certivaapp
   ```
   o
   ```
   py.com.certiva.app
   ```

6. Guarda los cambios (Cmd+S)

## 🔧 Método 2: Edición Manual del Archivo project.pbxproj

Si prefieres editar manualmente:

1. Abre el archivo: `certiva_app/ios/Runner.xcodeproj/project.pbxproj`

2. Busca todas las ocurrencias de `com.example.certivaApp`

3. Reemplázalas con tu nuevo Bundle ID

**Ubicaciones típicas:**
- Línea ~371: `PRODUCT_BUNDLE_IDENTIFIER = com.example.certivaApp;` (Profile)
- Línea ~550: `PRODUCT_BUNDLE_IDENTIFIER = com.example.certivaApp;` (Debug)
- Línea ~572: `PRODUCT_BUNDLE_IDENTIFIER = com.example.certivaApp;` (Release)

**Ejemplo de búsqueda y reemplazo:**
Busca: `com.example.certivaApp`
Reemplaza con: `com.tuempresa.certivaapp`

## ✅ Verificar el Cambio

Después de cambiar el Bundle ID:

1. Abre Xcode: `certiva_app/ios/Runner.xcworkspace`

2. Selecciona el target "Runner" → "Signing & Capabilities"

3. Verifica que el Bundle Identifier muestra tu nuevo ID

4. Si tienes "Automatically manage signing" activado, Xcode debería validar automáticamente

## 📝 Ejemplos de Bundle IDs Válidos

- `com.certiva.app`
- `py.com.certiva.app`
- `com.tuempresa.certivaapp`
- `app.certiva.mobile`

## ❌ Ejemplos de Bundle IDs Inválidos

- `certiva app` (no puede tener espacios)
- `certiva-app` (debe empezar con dominio inverso)
- `com.example.certivaApp` (ya está en uso como ejemplo)

## 🔗 Sincronizar con App Store Connect

**IMPORTANTE:** El Bundle ID que uses en Xcode debe ser exactamente el mismo que configures en App Store Connect:

1. Ve a [App Store Connect](https://appstoreconnect.apple.com)
2. Crea una nueva app
3. Cuando te pida el Bundle ID, usa el mismo que configuraste en Xcode
4. Si el Bundle ID ya existe en tu cuenta, no podrás crear otra app con el mismo ID

## 🆘 Problemas Comunes

### "Bundle identifier already exists"
- **Solución:** Elige un Bundle ID diferente que no esté en uso

### "Invalid bundle identifier"
- **Solución:** Asegúrate de que sigue el formato correcto (com.dominio.app)

### El Bundle ID no se guarda en Xcode
- **Solución:** Cierra y vuelve a abrir Xcode, o edita manualmente el archivo `project.pbxproj`

---

**Nota:** Después de cambiar el Bundle ID, es posible que necesites limpiar y reconstruir el proyecto:
```bash
flutter clean
flutter pub get
```






