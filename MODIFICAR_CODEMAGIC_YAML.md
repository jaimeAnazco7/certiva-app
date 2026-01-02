# ✏️ Qué Modificar en codemagic.yaml

## 🔴 OBLIGATORIO - Debes Cambiar:

### 1. Email para Notificaciones (Línea 46)

**Cambia:**
```yaml
- your-email@example.com
```

**Por tu email real:**
```yaml
- tu-email@ejemplo.com
```

**Ejemplo:**
```yaml
- jaime.anazco@kove.com.py
```

Esto es importante porque Codemagic te enviará emails cuando:
- ✅ El build sea exitoso
- ❌ El build falle
- 📦 El build se suba a TestFlight

---

## 🟡 OPCIONAL - Puedes Cambiar:

### 2. APP_STORE_ID (Línea 15)

Si ya tienes el ID de tu app en App Store Connect, puedes agregarlo:

**Cómo encontrarlo:**
1. Ve a App Store Connect → Tu app "Certiva App"
2. El ID aparece en la URL o en la información de la app
3. Es un número como: `1234567890`

**Si lo tienes, cambia:**
```yaml
APP_STORE_ID: ""
```

**Por:**
```yaml
APP_STORE_ID: "1234567890"  # Reemplaza con tu ID real
```

**Nota:** Si no lo tienes, déjalo vacío. Codemagic lo encontrará automáticamente.

---

### 3. Rutas (Líneas 16-17)

**Solo necesitas cambiar si:**
- Subes el proyecto dentro de una carpeta `certiva_app/` en GitHub
- La estructura es: `certiva-app/certiva_app/ios/...`

**Si es así, cambia:**
```yaml
XCODE_WORKSPACE: "ios/Runner.xcworkspace"
```

**Por:**
```yaml
XCODE_WORKSPACE: "certiva_app/ios/Runner.xcworkspace"
```

**Si subes todo en la raíz** (recomendado):
- Deja las rutas como están: `"ios/Runner.xcworkspace"`

---

### 4. Grupos de Testers (Líneas 56-58)

Si ya creaste grupos de testers en TestFlight, puedes descomentarlos:

**En App Store Connect:**
1. Ve a TestFlight → Internal Testing o External Testing
2. Crea grupos (ej: "Equipo Certiva", "Beta Testers")

**Luego en codemagic.yaml, descomenta y agrega:**
```yaml
beta_groups:
  - "Equipo Certiva"
  - "Beta Testers"
```

**Si no tienes grupos aún:**
- Déjalo comentado (con #)
- Puedes agregarlo después

---

## ✅ Ya Está Configurado Correctamente:

- ✅ **APP_ID:** `py.com.certiva.app` (correcto)
- ✅ **BUNDLE_ID:** `py.com.certiva.app` (correcto)
- ✅ **submit_to_testflight:** `true` (correcto)
- ✅ **submit_to_app_store:** `false` (correcto para empezar)

---

## 📋 Checklist de Modificaciones:

- [ ] **OBLIGATORIO:** Cambiar email en línea 46
- [ ] **OPCIONAL:** Agregar APP_STORE_ID si lo tienes
- [ ] **OPCIONAL:** Ajustar rutas si el proyecto está en subcarpeta
- [ ] **OPCIONAL:** Configurar grupos de testers si los tienes

---

## 🎯 Resumen:

**Mínimo necesario:**
1. Cambiar el email (línea 46)

**Recomendado:**
1. Cambiar el email
2. Verificar que las rutas sean correctas según tu estructura

**Opcional:**
1. Agregar APP_STORE_ID
2. Configurar grupos de testers

---

**¿Necesitas ayuda con alguna modificación específica?** 🚀






