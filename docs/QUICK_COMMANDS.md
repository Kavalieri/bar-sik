# ⚡ COMANDOS RÁPIDOS - Bar-Sik Export

## 🚀 **USO INMEDIATO**

```powershell
# 🎯 Build completo todas las plataformas
.\build-quick.ps1 -All

# 🖥️ Solo Windows
.\build-quick.ps1 -Windows

# 🤖 Solo Android (APK + AAB)
.\build-android.ps1 -Both

# 🌐 Web con servidor local
.\build-web.ps1 -Serve -Open

# 🧹 Limpiar y rebuild todo
.\build-quick.ps1 -All -Clean
```

## 📦 **RESULTADOS**

```
builds/
├── bar-sik-v0.3.0-windows.exe    # 15-25 MB
├── bar-sik-v0.3.0-linux          # 15-25 MB
├── android/
│   ├── bar-sik-v0.3.0.apk       # 20-35 MB
│   └── bar-sik-v0.3.0.aab       # 15-25 MB
└── web/
    ├── index.html                # Entry point
    ├── bar-sik.wasm             # 8-15 MB
    └── bar-sik.pck              # 5-10 MB
```

## 🔧 **TROUBLESHOOTING**

### ❌ "Godot no encontrado"
```powershell
# Agregar Godot al PATH o usar ruta completa
$GodotPath = "C:\Godot\godot.exe"
```

### ❌ "Export template missing"
```bash
# Descargar templates desde Godot Editor
# Project → Export → Add → Manage Export Templates
```

### ❌ "Android SDK not found"
```powershell
# Instalar Android SDK/Studio
# Editor Settings → Export → Android
```

## ⚡ **AUTOMATIZACIÓN**

### Continuous Integration:
```yaml
# .github/workflows/build.yml
name: Build All
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Export Windows
        run: godot --headless --export-release "Windows Desktop" "bar-sik.exe"
```

### Build Script Personalizado:
```powershell
# Tu propio build-custom.ps1
param([string]$Platform = "Windows")
.\build-quick.ps1 -$Platform -Version (Get-Date -Format "yyyy.MM.dd")
```
