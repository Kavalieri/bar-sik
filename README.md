# 🎮 Bar-Sik

> Proyecto de videojuego multiplataforma desarrollado en **Godot 4.4.1** para **Windows** y **Android**.

## 🚀 Características

- ✅ **Multiplataforma**: Windows, Android (iOS en el futuro)
- ✅ **Arquitectura profesional**: Código limpio y escalable
- ✅ **Autoloads esenciales**: Configuración, navegación, eventos, guardado
- ✅ **Sistema de localización**: Soporte para múltiples idiomas
- ✅ **CI/CD ready**: Preparado para integración continua
- ✅ **Optimización móvil**: Forward Mobile renderer, texturas optimizadas

## 📂 Estructura del proyecto

```
bar-sik/
├── .github/                    # GitHub Actions y documentación
│   ├── workflows/             # CI/CD para builds automáticos
│   └── instructions-copilot.md   # Instrucciones para el desarrollador IA
├── docs/                      # Documentación técnica completa
│   ├── README.md             # Índice de documentación organizada
│   ├── development/         # Documentación de desarrollo
│   ├── process/             # Procesos y soluciones técnicas  
│   ├── changelog/           # Historial de cambios y logros
│   ├── base.md              # Blueprint del proyecto
│   ├── GDD-Bar-Sik.md       # Game Design Document
│   └── project-config.md    # Configuración del proyecto
├── tools/                    # Scripts de construcción y herramientas
├── project/                  # Proyecto Godot principal
│   ├── singletons/          # Autoloads (AppConfig, Router, etc.)
│   ├── scripts/             # Código del juego
│   │   ├── core/           # Utilidades y helpers
│   │   ├── platform/       # Integraciones específicas de plataforma
│   │   └── gameplay/       # Lógica del juego
│   ├── scenes/             # Escenas del juego
│   ├── ui/                 # Interfaz de usuario
│   ├── res/                # Recursos (gfx, sfx, fonts, locales)
│   ├── data/               # Datos estáticos del juego
│   ├── tests/              # Pruebas unitarias
│   └── export/             # Configuración de exportación
├── build/                   # Artefactos de construcción (.exe, .aab)
└── assets_src/             # Archivos fuente originales (PSD, WAV, etc.)
```

## 🛠️ Requisitos de desarrollo

### Software necesario:
- **Godot 4.4.1** con Export Templates
- **Visual Studio Code** con extensión de Godot
- **JDK 17** (para Android)
- **Android SDK** (API 34 + Build-Tools 34.0.0)
- **Android NDK** r25c

### Variables de entorno:
```bash
JAVA_HOME=<ruta_a_jdk_17>
ANDROID_HOME=<ruta_a_android_sdk>
PATH incluye: platform-tools, cmdline-tools/latest/bin, build-tools/34.0.0
```

## 🏗️ Autoloads incluidos

| Autoload | Descripción | Funcionalidades |
|----------|-------------|-----------------|
| `AppConfig` | Configuración global | Build info, FPS, configuración de dispositivo |
| `Router` | Navegación entre escenas | Cambio fluido de pantallas, gestión de escenas |
| `Locale` | Sistema de idiomas | Localización automática, cambio de idioma |
| `GameEvents` | Bus de eventos | Comunicación desacoplada entre sistemas |
| `SaveSystem` | Persistencia de datos | Guardado de configuración y progreso |

## 🎯 Configuración del proyecto

### Display & Window:
- Resolución base: 1920×1080 (ajustable según el juego)
- Stretch Mode: `canvas_items`
- Aspect: `keep` (configurable)
- HiDPI: Habilitado

### Rendering:
- Renderer: `Forward Mobile` (optimizado para móvil)
- Texturas: ETC2 (Android), BCn (Windows)
- Half precision: Habilitado para mejor rendimiento

### Android Export:
- Min SDK: 23 (Android 6.0)
- Target SDK: 34 (Android 14)
- Formato: AAB (Android App Bundle)
- Arquitecturas: `arm64-v8a` (principal)

## 🚀 Inicio rápido

1. **Clonar el repositorio**:
   ```bash
   git clone https://github.com/tu-usuario/bar-sik.git
   cd bar-sik
   ```

2. **Abrir el proyecto en Godot**:
   - Abrir Godot 4.4.1
   - Seleccionar `project/project.godot`

3. **Configurar los Autoloads**:
   - Ir a `Project > Project Settings > AutoLoad`
   - Añadir los 5 autoloads desde la carpeta `singletons/`

4. **Probar el proyecto**:
   - Presionar F5 y seleccionar una escena principal

## � Documentación

La documentación completa está organizada en el directorio `docs/`:

- **[📖 Índice de Documentación](docs/README.md)** - Navegación completa por toda la documentación
- **[🎮 Game Design Document](docs/GDD-Bar-Sik.md)** - Diseño completo del juego
- **[🛠️ Estado del Desarrollo](docs/development/PROJECT_STATUS.md)** - Progreso actual del proyecto
- **[⚙️ Procesos de Solución](docs/process/)** - Soluciones técnicas y debugging
- **[📅 Historial de Cambios](docs/changelog/)** - Logros y milestones

## �🔧 Desarrollo

### Convenciones de código:
- **GDScript**: snake_case para variables/funciones, PascalCase para clases
- **Indentación**: 4 espacios
- **Líneas**: máximo 100 caracteres
- **Tipado**: usar tipado fuerte siempre que sea posible

### Ejemplo de código:
```gdscript
extends Node
class_name GameManager

@export var max_health: int = 100
var current_health: int = 100

func _ready() -> void:
    print("GameManager inicializado")

func take_damage(damage: int) -> void:
    current_health -= damage
    GameEvents.emit_custom_event("health_changed", {"health": current_health})
```

## 📱 Exportación

### Windows:
```bash
# El juego se exporta como .exe
# Empaquetado en .zip con dependencias
```

### Android:
```bash
# Exportación como .aab (Android App Bundle)
# Firmado digitalmente para Google Play
```

## 🤝 Contribución

Este proyecto sigue un flujo de desarrollo profesional:
1. Crear issue para nuevas funcionalidades
2. Crear branch desde `main`
3. Implementar con tests
4. Pull request con revisión
5. Merge después de aprobación

## 📄 Licencia

[Definir licencia según necesidades del proyecto]

---

**Desarrollado with ❤️ usando Godot 4.4.1**
