# 📋 PREREQUISITOS COMPLETOS - Bar-Sik Export

## ⚠️ **ANTES DE EXPORTAR - CONFIGURACIÓN NECESARIA**

### 🔧 **VERIFICACIÓN AUTOMÁTICA:**
```powershell
# Verificar qué tienes configurado
.\setup-export.ps1 -CheckOnly
```

---

## 📦 **LO QUE NECESITAS INSTALAR:**

### 1. 🎯 **GODOT ENGINE** (Ya tienes ✅)
- Godot 4.4+ con CLI en PATH
- **Ya configurado** si puedes ejecutar `godot --version`

### 2. 📦 **EXPORT TEMPLATES**
❌ **FALTANTE** - Necesario para TODAS las exportaciones

```powershell
# Instalar automáticamente
.\setup-export.ps1 -InstallTemplates
```

**Manual:** Godot Editor → Project → Export → Manage Export Templates → Download and Install

### 3. 🤖 **ANDROID (para APK/AAB)**
❌ **FALTANTE** - Necesario para Android

#### **Instalación rápida:**
1. **Android Studio:** https://developer.android.com/studio
2. **Abrir Android Studio → SDK Manager**
3. **Instalar:**
   - ✅ Android SDK Platform-Tools
   - ✅ Android SDK Build-Tools (34.0.0+)
   - ✅ Android SDK Platform API 34
   - ✅ Android SDK Command-line Tools

4. **Variables de entorno:**
```powershell
# Agregar al PATH del sistema
$env:ANDROID_SDK_ROOT = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:PATH += ";$env:ANDROID_SDK_ROOT\platform-tools;$env:ANDROID_SDK_ROOT\cmdline-tools\latest\bin"
```

### 4. ☕ **JAVA JDK**
```powershell
# Verificar si tienes Java
java -version

# Si no tienes, instalar OpenJDK 11+
winget install Microsoft.OpenJDK.11
```

### 5. ⚙️ **CONFIGURAR GODOT**
```powershell
# Después de instalar Android SDK
# Abrir Godot Editor → Editor → Editor Settings → Export → Android
# Configurar rutas del SDK
```

---

## ⚡ **CONFIGURACIÓN AUTOMÁTICA COMPLETA**

```powershell
# 1. Verificar estado actual
.\setup-export.ps1 -CheckOnly

# 2. Instalar lo que se pueda automáticamente
.\setup-export.ps1 -InstallTemplates

# 3. Para Android, sigue las instrucciones que aparecen
# 4. Verificar de nuevo
.\setup-export.ps1 -CheckOnly

# 5. Cuando todo esté ✅, exportar
.\build-quick.ps1 -All
```

---

## 🎯 **ESTADO ACTUAL VS NECESARIO**

| Componente | Estado | Acción |
|------------|--------|---------|
| 🎯 Godot Engine | ✅ Instalado | Listo |
| 📦 Export Templates | ❌ Faltante | `.\setup-export.ps1 -InstallTemplates` |
| 🤖 Android SDK | ❌ Faltante | Instalar Android Studio |
| ☕ Java JDK | ❓ Verificar | `java -version` |
| ⚙️ Configuración | ❌ Pendiente | Configurar en Godot Editor |

---

## 🚀 **FLUJO COMPLETO DE SETUP**

### **Paso 1: Verificar**
```powershell
.\setup-export.ps1 -CheckOnly
```

### **Paso 2: Instalar Export Templates**
```powershell
.\setup-export.ps1 -InstallTemplates
```

### **Paso 3: Android SDK (si quieres APK/AAB)**
1. Descargar Android Studio
2. Instalar SDK components
3. Configurar variables de entorno
4. Configurar en Godot Editor

### **Paso 4: Verificar de nuevo**
```powershell
.\setup-export.ps1 -CheckOnly
# Debe mostrar todo ✅
```

### **Paso 5: ¡Exportar!**
```powershell
.\build-quick.ps1 -All
```

---

## 💡 **NOTAS IMPORTANTES**

- **Windows/Linux:** Solo necesitas Export Templates
- **Android:** Necesitas todo el SDK + configuración
- **Web:** Solo Export Templates
- **Primera vez:** Puede tardar 30-60 minutos configurar Android
- **Después:** Los exports son instantáneos

**¿Empezamos con la verificación?**
