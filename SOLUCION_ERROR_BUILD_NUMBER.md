# 🔧 Solución: Error de Build Number en Codemagic

## ⚠️ Problema

El build falló con este error:
```
The bundle version must be higher than the previously uploaded version: '2'
```

**Causa:**
- Ya existe un build en TestFlight con el build number `2`
- Apple requiere que cada nuevo build tenga un número **mayor** que el anterior
- Estás intentando subir otro build con el mismo número `2`

---

## ✅ Solución

### **Paso 1: Incrementar el Build Number**

El build number está en `pubspec.yaml`:
```yaml
version: 1.0.0+2  # El número después del + es el build number
```

**Cambiar a:**
```yaml
version: 1.0.0+3  # Incrementar de 2 a 3
```

### **Paso 2: Subir el Cambio a GitHub**

```bash
git add pubspec.yaml
git commit -m "Incrementar build number a 3"
git push
```

### **Paso 3: Iniciar Nuevo Build en Codemagic**

1. Ve a Codemagic
2. Haz clic en **"Start new build"**
3. Selecciona branch: `main`
4. Selecciona workflow: `ios-workflow`
5. Haz clic en **"Start build"**

---

## 📋 Formato de Versión

El formato es: `VERSION_NAME+BUILD_NUMBER`

**Ejemplos:**
- `1.0.0+1` → Versión 1.0.0, Build 1
- `1.0.0+2` → Versión 1.0.0, Build 2
- `1.0.0+3` → Versión 1.0.0, Build 3
- `1.0.1+1` → Versión 1.0.1, Build 1 (nueva versión)

---

## 🔄 Para Futuros Builds

Cada vez que quieras subir un nuevo build:

1. **Incrementa el build number** en `pubspec.yaml`
2. **Haz commit y push** a GitHub
3. **Inicia nuevo build** en Codemagic

**Ejemplo:**
- Build 1: `1.0.0+1`
- Build 2: `1.0.0+2`
- Build 3: `1.0.0+3` ← **Ya está configurado**
- Build 4: `1.0.0+4` (próximo)

---

## ⚠️ Importante

- **El build number DEBE incrementarse** cada vez que subas un nuevo build
- **No puedes reutilizar** un build number que ya existe en TestFlight
- **El build number es independiente** de la versión (puedes tener `1.0.0+10` si quieres)

---

## ✅ Checklist

- [ ] Build number incrementado en `pubspec.yaml` (de 2 a 3)
- [ ] Cambios subidos a GitHub
- [ ] Nuevo build iniciado en Codemagic
- [ ] Build completado exitosamente
- [ ] Build aparece en TestFlight

---

**Una vez que incrementes el build number y subas el código, el build debería funcionar correctamente.** 🚀



