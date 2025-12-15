# 📤 Subir Código a GitHub para Codemagic

## 🎯 Objetivo
Subir tu proyecto Flutter al repositorio GitHub `jaimeAnazco7/certiva-app` para que Codemagic pueda acceder a él.

## 📋 Pasos para Subir el Código

### Opción 1: Desde la Terminal/Command Line (Recomendado)

#### Si es la primera vez que subes código:

1. **Abre la terminal** en la carpeta de tu proyecto:
   ```bash
   cd D:\xampp\htdocs\proyecto_certiva_void\certiva_app
   ```

2. **Inicializa Git** (si no está inicializado):
   ```bash
   git init
   ```

3. **Agrega todos los archivos:**
   ```bash
   git add .
   ```

4. **Haz el primer commit:**
   ```bash
   git commit -m "Initial commit: Certiva App con configuración Codemagic"
   ```

5. **Conecta con tu repositorio de GitHub:**
   ```bash
   git remote add origin https://github.com/jaimeAnazco7/certiva-app.git
   ```

6. **Sube el código:**
   ```bash
   git branch -M main
   git push -u origin main
   ```

#### Si ya tienes Git inicializado:

1. **Agrega el remoto** (si no lo has hecho):
   ```bash
   git remote add origin https://github.com/jaimeAnazco7/certiva-app.git
   ```

2. **Agrega todos los archivos:**
   ```bash
   git add .
   ```

3. **Haz commit:**
   ```bash
   git commit -m "Agregar configuración Codemagic y Bundle ID actualizado"
   ```

4. **Sube el código:**
   ```bash
   git push -u origin main
   ```

### Opción 2: Desde GitHub Desktop (Más Fácil)

1. **Descarga GitHub Desktop** si no lo tienes:
   - [desktop.github.com](https://desktop.github.com)

2. **Abre GitHub Desktop**

3. **Agrega el repositorio:**
   - File → Add Local Repository
   - Selecciona: `D:\xampp\htdocs\proyecto_certiva_void\certiva_app`

4. **Haz commit:**
   - Escribe un mensaje: "Initial commit: Certiva App"
   - Haz clic en "Commit to main"

5. **Publica el repositorio:**
   - Haz clic en "Publish repository"
   - Selecciona: `jaimeAnazco7/certiva-app`
   - Haz clic en "Publish"

### Opción 3: Desde VS Code (Si usas VS Code)

1. **Abre VS Code** en la carpeta del proyecto

2. **Abre la terminal integrada** (Ctrl + `)

3. **Ejecuta los comandos:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/jaimeAnazco7/certiva-app.git
   git branch -M main
   git push -u origin main
   ```

## ✅ Verificación

Después de subir, verifica que:

1. **El archivo `codemagic.yaml` esté en el repositorio:**
   - Ve a: https://github.com/jaimeAnazco7/certiva-app
   - Deberías ver `codemagic.yaml` en la lista de archivos

2. **La estructura del proyecto esté correcta:**
   - Debe estar la carpeta `certiva_app` con todo su contenido
   - O el contenido directamente en la raíz (según cómo lo subas)

## 📁 Estructura Recomendada

Tienes dos opciones:

### Opción A: Todo en la raíz (Más simple)
```
certiva-app/
├── lib/
├── android/
├── ios/
├── pubspec.yaml
├── codemagic.yaml  ← IMPORTANTE
└── ...
```

### Opción B: Carpeta certiva_app (Tu estructura actual)
```
certiva-app/
└── certiva_app/
    ├── lib/
    ├── android/
    ├── ios/
    ├── pubspec.yaml
    ├── codemagic.yaml  ← IMPORTANTE
    └── ...
```

**Si usas Opción B**, necesitarás ajustar las rutas en `codemagic.yaml`:
```yaml
XCODE_WORKSPACE: "certiva_app/ios/Runner.xcworkspace"
```

## ⚠️ Archivos que NO debes subir

Asegúrate de tener un `.gitignore` que excluya:

```
build/
.dart_tool/
.idea/
*.iml
*.lock
.DS_Store
```

## 🚀 Después de Subir

Una vez que el código esté en GitHub:

1. ✅ Ve a Codemagic
2. ✅ Conecta el repositorio `jaimeAnazco7/certiva-app`
3. ✅ Codemagic detectará automáticamente el `codemagic.yaml`
4. ✅ Configura las credenciales de App Store Connect
5. ✅ Ejecuta el primer build

## 🆘 Problemas Comunes

### "Repository not found"
- Verifica que el repositorio sea público o que Codemagic tenga acceso
- Verifica la URL del repositorio

### "Authentication failed"
- Necesitas autenticarte con GitHub
- Usa un Personal Access Token si es necesario

### "codemagic.yaml not found"
- Verifica que el archivo esté en la raíz del repositorio
- O ajusta la ruta en la configuración de Codemagic

---

**¿Necesitas ayuda con algún paso específico?** 🎯

