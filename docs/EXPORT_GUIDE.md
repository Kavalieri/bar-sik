# 🚀 GUÍA DE EXPORTACIÓN MULTIPLATAFORMA - BAR-SIK

## 📋 **RESUMEN RÁPIDO**

### **Plataformas disponibles:**
- 🖥️ **Windows** → `.exe`
- 🐧 **Linux** → Ejecutable
- 🍎 **macOS** → `.app`
- 🤖 **Android** → `.apk` / `.aab`
- 📱 **iOS** → `.ipa`
- 🌐 **Web** → HTML5

---

## ⚡ **MÉTODO RÁPIDO (Godot CLI)**

### **1. Instalar Export Templates**
```bash
# Descarga automática desde Godot
godot --headless --export-pack
```

### **2. Exportar por línea de comandos**
```bash
# Windows
godot --headless --export-release "Windows Desktop" "./build/bar-sik-windows.exe"

# Linux
godot --headless --export-release "Linux/X11" "./build/bar-sik-linux"

# Android APK
godot --headless --export-release "Android" "./build/bar-sik.apk"

# Android AAB (Google Play)
godot --headless --export-release "Android AAB" "./build/bar-sik.aab"

# Web
godot --headless --export-release "Web" "./build/web/"
```

---

## 🔧 **CONFIGURACIÓN NECESARIA**

### **Android:**
- SDK Platform-Tools
- Build Tools
- Android NDK
- Keystore para firma

### **iOS:**
- Xcode (solo en macOS)
- Apple Developer Account
- Provisioning Profile

### **Web:**
- Configurar HTTPS para PWA
- Service Worker para offline

---

## 🎯 **SCRIPTS DE AUTOMATIZACIÓN**

### **build-all.ps1** - Exportar todas las plataformas
### **build-android.ps1** - Solo Android (APK + AAB)
### **build-desktop.ps1** - Solo Desktop (Win + Linux + Mac)
### **build-web.ps1** - Solo Web con servidor local

---

## 📦 **ESTRUCTURA DE BUILD**

```
build/
├── windows/
│   ├── bar-sik.exe
│   └── bar-sik.pck
├── linux/
│   ├── bar-sik
│   └── bar-sik.pck
├── android/
│   ├── bar-sik-debug.apk
│   ├── bar-sik-release.apk
│   └── bar-sik-release.aab
├── web/
│   ├── index.html
│   ├── bar-sik.wasm
│   └── bar-sik.pck
└── releases/
    ├── bar-sik-v0.3.0-windows.zip
    ├── bar-sik-v0.3.0-linux.tar.gz
    └── bar-sik-v0.3.0-android.apk
```

---

## ⚡ **AUTOMATIZACIÓN COMPLETA**

**Usar:** `.\build-all.ps1 --version 0.3.0 --release`

**Resultado:** Builds automáticos para todas las plataformas con empaquetado listo para distribución.
