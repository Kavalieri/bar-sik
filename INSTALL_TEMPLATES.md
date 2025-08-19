# 📦 INSTALAR EXPORT TEMPLATES MANUALMENTE

## 🔥 **EL PROBLEMA:**
Los Export Templates no se instalaron correctamente. Necesitas:
- `web_nothreads_debug.zip`
- `web_nothreads_release.zip`
- `windows_debug_x86_64.exe`
- `windows_release_x86_64.exe`

## ⚡ **SOLUCIÓN RÁPIDA:**

### **1. Descargar Export Templates:**
**URL:** https://github.com/godotengine/godot/releases/tag/4.4.1-stable
**Archivo:** `Godot_v4.4.1-stable_export_templates.tpz`

### **2. Instalar manualmente:**
1. Descarga el archivo `.tpz`
2. Renómbralo a `.zip`
3. Extrae el contenido
4. Copia a: `C:\Users\Kava\AppData\Roaming\Godot\export_templates\4.4.1.stable\`

### **3. Estructura final:**
```
C:\Users\Kava\AppData\Roaming\Godot\export_templates\4.4.1.stable\
├── web_nothreads_debug.zip
├── web_nothreads_release.zip
├── windows_debug_x86_64.exe
├── windows_release_x86_64.exe
├── linux_debug.x86_64
├── linux_release.x86_64
└── (otros templates)
```

---

## 🚀 **MÉTODO AUTOMÁTICO (Recomendado):**

### **Abrir Godot Editor:**
```powershell
& "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe" "E:\GitHub\bar-sik\project\project.godot"
```

### **En el Editor:**
1. **Project → Export**
2. **Manage Export Templates**
3. **Download and Install**
4. ☕ Espera 2-5 minutos (descarga ~150MB)
5. **Add... → Windows Desktop**
6. **Add... → Web**
7. **Close**

### **Probar:**
```powershell
.\build-web.ps1 -Serve -Open
.\build-quick.ps1 -Windows -Web
```

---

## ✅ **UNA VEZ INSTALADO:**
- **Windows builds:** ✅ Funcionarán
- **Web builds:** ✅ Funcionarán
- **Android:** Necesitará Android SDK
- **Scripts automáticos:** ✅ Listos

**¿Prefieres hacerlo desde el Editor (más fácil) o descarga manual?**
