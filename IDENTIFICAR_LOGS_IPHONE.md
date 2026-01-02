# 📱 Cómo Identificar los Logs de la App en el iPhone

## 🎯 Cómo Identificar los Logs de "Certiva App"

### **Los logs de tu app se llaman "Runner"**

En la lista que estás viendo, los logs de tu app son los que empiezan con:
- **`Runner-2025-12-29-111922.ips`**
- **`Runner-2025-12-29-111925.ips`**
- **`Runner-2025-12-29-112010.ips`**
- etc.

**¿Por qué "Runner"?**
- En Flutter, el nombre del ejecutable en iOS es **"Runner"**
- Todos los crashes de tu app aparecerán con este nombre

---

## 📋 Logs que Veo en tu Lista

Veo **múltiples crashes** de tu app del **29 de diciembre de 2025**:

1. `Runner-2025-12-29-111922.ips` (11:19:22)
2. `Runner-2025-12-29-111925.ips` (11:19:25)
3. `Runner-2025-12-29-112010.ips` (11:20:10)
4. `Runner-2025-12-29-112044.ips` (11:20:44)
5. `Runner-2025-12-29-112145.ips` (11:21:45)
6. `Runner-2025-12-29-112628.ips` (11:26:28)
7. `Runner-2025-12-29-120549.ips` (12:05:49)
8. `Runner-2025-12-29-120558.ips` (12:05:58)
9. `Runner-2025-12-29-120605.ips` (12:06:05)
10. `Runner-2025-12-29-120611.ips` (12:06:11)

**Esto confirma que el crash está ocurriendo frecuentemente.**

---

## 📤 Cómo Compartir los Logs

### **Paso 1: Seleccionar un Log**

1. **Haz clic en uno de los logs "Runner"** (ej: `Runner-2025-12-29-112145.ips`)
2. Se abrirá el contenido del log

### **Paso 2: Compartir el Log**

1. **Busca el botón "Compartir"** (icono de compartir) en la esquina superior derecha
2. **O haz clic derecho** en el log y selecciona "Compartir"
3. **Selecciona cómo compartirlo:**
   - **Email** (enviarlo por correo)
   - **AirDrop** (si tienes otro dispositivo cerca)
   - **Guardar en archivos** (para luego compartirlo)
   - **Copiar** (si está disponible)

### **Paso 3: Enviar el Log**

1. **Si eliges Email:**
   - Se abrirá el cliente de email
   - Adjunta el archivo `.ips`
   - Envía a tu email o al desarrollador

2. **Si eliges "Guardar en archivos":**
   - Guarda el archivo
   - Luego puedes compartirlo desde la app Archivos

---

## 🔍 Qué Contiene el Log

El archivo `.ips` contiene:
- **Stack trace completo** del crash
- **Información del dispositivo** (modelo, iOS version)
- **Versión de la app**
- **Fecha y hora exacta** del crash
- **Threads** que estaban ejecutándose
- **Registros del sistema**

---

## 💡 Recomendación

### **Para el Cliente/Tester:**

1. **Seleccionar el log más reciente:**
   - `Runner-2025-12-29-120611.ips` (el último de la lista)

2. **Compartirlo:**
   - Por email a ti
   - O guardarlo y enviarlo por WhatsApp/otro medio

3. **O compartir varios logs:**
   - Puede seleccionar múltiples logs
   - Compartirlos todos juntos

---

## 📊 Análisis de los Logs

Con estos logs podrás ver:
- **Cuántas veces** ha fallado la app
- **En qué momentos** (horarios)
- **Si el problema es consistente** o intermitente
- **El stack trace completo** de cada crash

---

## 🎯 Próximos Pasos

1. **Pedir al cliente que comparta** el log más reciente (`Runner-2025-12-29-120611.ips`)
2. **O compartir varios logs** para ver el patrón
3. **Analizar el stack trace** para identificar el problema exacto
4. **Implementar la solución** basada en los logs

---

## ✅ Instrucciones para el Cliente

**Mensaje para el cliente:**

> "Por favor, en la lista de logs, busca los que empiezan con 'Runner' (esos son de la app Certiva). Selecciona el más reciente (Runner-2025-12-29-120611.ips) y compártelo por email. Esto me ayudará a identificar y corregir el problema."

---

**¿Puedes pedirle al cliente que comparta el log más reciente?** 📤



