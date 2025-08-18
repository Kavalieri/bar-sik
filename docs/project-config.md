# 🎮 Configuraciones del Proyecto - Bar-Sik

## ⚙️ Configuración recomendada en Project Settings

Copia y pega estas configuraciones en **Project > Project Settings**:

### 🖥️ **Display/Window**
```
Window Size:
- Width: 1080 (portrait) o 1920 (landscape)
- Height: 1920 (portrait) o 1080 (landscape)
- Resizable: true

Stretch:
- Mode: canvas_items
- Aspect: keep_width (portrait) o keep_height (landscape)
- Scale: 1.0

Advanced:
- Use HiDPI: true
```

### 🎨 **Rendering**
```
Renderer:
- Rendering Method: Forward Mobile

Textures:
- Canvas Textures: Half Float (GLES3) o Half Float (Vulkan Mobile)

Anti Aliasing:
- Use TAA: false
- Use FXAA: true
- Screen Space AA: FXAA

Environment:
- Default Clear Color: #000000 (negro) o según tu juego
```

### 📱 **Input Map**
Añadir estas acciones:
```
ui_accept: Enter, Space, Gamepad A
ui_cancel: Escape, Gamepad B
ui_left: Left Arrow, A, Gamepad Left
ui_right: Right Arrow, D, Gamepad Right
ui_up: Up Arrow, W, Gamepad Up
ui_down: Down Arrow, S, Gamepad Down

# Acciones específicas del juego (personalizar según género):
game_action: Z, Mouse Left, Touch
game_jump: Space, Gamepad A
game_pause: Escape, P, Gamepad Start
```

### 🔧 **Application**
```
Config:
- Name: Bar-Sik
- Description: [Descripción de tu juego]
- Version: 0.1.0
- Icon: res://icon.svg

Run:
- Main Scene: res://scenes/MainMenu.tscn (cuando la crees)
```

### 📦 **AutoLoads**
**¡IMPORTANTE!** Añadir en este orden exacto:

| Orden | Path | Node Name | Enabled |
|-------|------|-----------|---------|
| 1 | `res://singletons/AppConfig.gd` | `AppConfig` | ✅ |
| 2 | `res://singletons/Router.gd` | `Router` | ✅ |
| 3 | `res://singletons/Locale.gd` | `Locale` | ✅ |
| 4 | `res://singletons/GameEvents.gd` | `GameEvents` | ✅ |
| 5 | `res://singletons/SaveSystem.gd` | `SaveSystem` | ✅ |

### 🌍 **Localization**
```
Localization:
- Test: English (en) [crear archivo CSV más adelante]
- Locales Filter:
  - Mode: Show Selected Locales Only
  - Selected: es, en, fr, de, pt
```

### 🎵 **Audio**
```
Driver:
- Enable Audio Input: false (por defecto)
- Output Latency: 15ms
- Output Buffer Size: 1024

Buses:
- Master (0 dB)
  - Music (-5 dB)
  - SFX (0 dB)
  - UI (0 dB)
```

### 📂 **File System**
```
Import:
- Reimport Missing Imported Files: true
- Use Multiple Threads: true
```

---

## 🚀 **Pasos para aplicar la configuración:**

1. **Abre Godot** con el proyecto desde `project/`
2. **Ve a** `Project > Project Settings`
3. **Aplica cada sección** desde arriba hacia abajo
4. **Añade los AutoLoads** en el orden exacto especificado
5. **Guarda el proyecto** (Ctrl+S)
6. **Cierra y reabre** Godot para aplicar todos los cambios

---

## ✅ **Verificación**

Deberías ver en la consola de Godot al iniciar:
```
🎮 AppConfig inicializado
📱 Plataforma: Windows
🏗️ Build: 0.1.0
🐛 Debug: true
🧭 Router inicializado
🌍 Locale inicializado
📱 Idioma del sistema: [tu idioma]
🔄 Idioma cambiado a: [idioma]
📡 GameEvents inicializado
💾 SaveSystem inicializado
📁 Archivos de guardado ubicados en: [ruta]
```

Si ves todos estos mensajes, ¡la configuración base está perfecta! 🎉
