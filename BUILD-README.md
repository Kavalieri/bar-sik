# 🚀 **SISTEMA DE COMPILACIÓN AUTOMATIZADA - BAR-SIK**

Sistema completo de compilación multiplataforma para Godot 4.4.1 con organización automática por timestamps y gestión de builds.

---

## 📋 **SCRIPTS DISPONIBLES**

### **🎯 Scripts de Compilación Principal**

| Script | Descripción | Uso |
|--------|-------------|-----|
| `build-quick.ps1` | Build rápido Windows release | `.\build-quick.ps1` |
| `build-debug.ps1` | Build Windows con consola debug | `.\build-debug.ps1` |
| `build-web.ps1` | Build HTML5/WebAssembly | `.\build-web.ps1` |
| `build-android.ps1` | Build APK/AAB para Android | `.\build-android.ps1` |
| `build-all.ps1` | **Compilación automática completa** | `.\build-all.ps1` |

### **🛠️ Scripts de Gestión**

| Script | Descripción | Uso |
|--------|-------------|-----|
| `setup-export.ps1` | Instalar templates y configurar | `.\setup-export.ps1` |
| `build-history.ps1` | Ver historial de builds | `.\build-history.ps1` |
| `clean-builds.ps1` | Limpiar builds antiguos | `.\clean-builds.ps1 -Keep 3` |

---

## 🚀 **COMPILACIÓN RÁPIDA**

### **Solo Windows (más rápido)**
```powershell
.\build-quick.ps1
```

### **Compilación Completa (todas las plataformas)**
```powershell
.\build-all.ps1
```

### **Solo builds rápidos (sin web/android)**
```powershell
.\build-all.ps1 -QuickOnly
```

### **Con modo debug**
```powershell
.\build-all.ps1 -Debug
```

---

## 📁 **ESTRUCTURA DE OUTPUTS**

```
builds/
├── windows/
│   ├── 2025-01-19_16-48-23/    ← Build con timestamp
│   │   ├── bar-sik.exe          ← Ejecutable standalone (97.7 MB)
│   │   └── bar-sik.pck          ← (solo si embed_pck=false)
│   └── latest/                  ← Symlink/Copy al build más reciente
│       └── bar-sik.exe
├── web/
│   ├── 2025-01-19_16-50-15/
│   │   ├── index.html
│   │   ├── bar-sik.js
│   │   ├── bar-sik.wasm
│   │   └── bar-sik.pck
│   └── latest/
└── android/
    ├── 2025-01-19_16-55-30/
    │   ├── bar-sik.apk
    │   └── bar-sik.aab
    └── latest/
```

---

## ⚙️ **CONFIGURACIÓN DETALLADA**

### **1. Primera vez - Instalar templates**
```powershell
.\setup-export.ps1
```

### **2. Parámetros del build-all.ps1**

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `-Debug` | Builds con consola de debug | `.\build-all.ps1 -Debug` |
| `-SkipWeb` | Omitir build web | `.\build-all.ps1 -SkipWeb` |
| `-SkipAndroid` | Omitir build Android | `.\build-all.ps1 -SkipAndroid` |
| `-QuickOnly` | Solo Windows (rápido) | `.\build-all.ps1 -QuickOnly` |
| `-CleanKeep 3` | Mantener solo 3 builds | `.\build-all.ps1 -CleanKeep 3` |

### **3. Builds específicos**

```powershell
# Solo Windows release
.\build-quick.ps1

# Solo Windows debug (con consola)
.\build-debug.ps1

# Solo web
.\build-web.ps1

# Solo Android
.\build-android.ps1
```

---

## 🧹 **GESTIÓN DE BUILDS**

### **Ver historial completo**
```powershell
.\build-history.ps1
```

### **Limpiar builds antiguos**
```powershell
# Mantener solo los últimos 3 builds de cada plataforma
.\clean-builds.ps1 -Keep 3

# Solo mostrar qué se eliminaría (dry run)
.\clean-builds.ps1 -Keep 3 -DryRun

# Mantener solo el latest de cada plataforma
.\clean-builds.ps1 -KeepOnlyLatest

# Limpiar solo una plataforma específica
.\clean-builds.ps1 -Platform windows -Keep 2
```

---

## 🎯 **BUILDS STANDALONE**

### **Windows EXE Standalone**
- ✅ **Archivo único**: `bar-sik.exe` (97.7 MB)
- ✅ **Sin dependencias**: PCK embebido
- ✅ **Portátil**: Funciona sin instalación
- ✅ **Debug**: Builds con consola disponibles

### **Web HTML5**
- ✅ **Multiplataforma**: Funciona en cualquier navegador moderno
- ✅ **Sin instalación**: Se ejecuta directamente
- ✅ **Archivos**: HTML, JS, WASM, PCK

### **Android APK/AAB**
- ✅ **APK**: Para instalación directa
- ✅ **AAB**: Para Google Play Store
- ⚠️ **Requiere**: Android SDK configurado

---

## 📊 **OPTIMIZACIÓN Y RENDIMIENTO**

### **Tiempos aproximados de compilación**
- 🖥️ **Windows**: ~30-60 segundos
- 🌐 **Web**: ~45-90 segundos
- 📱 **Android**: ~60-120 segundos

### **Tamaños de archivo típicos**
- 🖥️ **Windows EXE**: ~97.7 MB (standalone)
- 🌐 **Web total**: ~25-50 MB
- 📱 **Android APK**: ~30-60 MB

---

## 🔧 **SOLUCIÓN DE PROBLEMAS**

### **Error: "No export template found"**
```powershell
# Reinstalar templates
.\setup-export.ps1
```

### **Error: "Could not start editor"**
```powershell
# Verificar ruta de Godot en build-quick.ps1
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"
```

### **Build falla silenciosamente**
```powershell
# Usar modo debug para ver errores
.\build-debug.ps1
```

### **Limpiar todo y empezar de nuevo**
```powershell
# Limpiar builds antiguos
.\clean-builds.ps1 -KeepOnlyLatest

# Reinstalar templates
.\setup-export.ps1

# Build completo
.\build-all.ps1
```

---

## 🎮 **FLUJO DE TRABAJO RECOMENDADO**

### **1. Desarrollo Diario**
```powershell
# Build rápido para testear
.\build-quick.ps1
```

### **2. Antes de Commit**
```powershell
# Build debug para verificar
.\build-debug.ps1
```

### **3. Release/Demo**
```powershell
# Build completo todas las plataformas
.\build-all.ps1

# Ver que todo esté bien
.\build-history.ps1
```

### **4. Mantenimiento Semanal**
```powershell
# Limpiar builds antiguos
.\clean-builds.ps1 -Keep 5
```

---

## 📋 **CHECKLIST DE RELEASE**

- [ ] Código limpio y sin warnings
- [ ] Scenes principales testeadas
- [ ] `.\build-all.ps1` ejecutado exitosamente
- [ ] Windows EXE probado
- [ ] Web build probado en navegador
- [ ] Android APK probado (si aplica)
- [ ] `.\build-history.ps1` muestra builds exitosos
- [ ] Builds subidos a carpeta de distribución

---

## 🏆 **COMANDOS ESENCIALES**

```powershell
# Setup inicial (solo una vez)
.\setup-export.ps1

# Build diario más común
.\build-quick.ps1

# Build completo para release
.\build-all.ps1

# Ver qué builds tienes
.\build-history.ps1

# Limpiar espacio
.\clean-builds.ps1 -Keep 3
```

---

*Sistema de build automatizado para **Bar-Sik** - Godot 4.4.1*
*Builds organizados automáticamente con timestamps y gestión inteligente* 🚀
