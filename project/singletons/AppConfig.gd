extends Node
## Configuración global de la aplicación
## Se carga automáticamente al inicio y contiene datos importantes del proyecto

# Variables de build y depuración
@export var is_debug: bool = OS.is_debug_build()
@export var build_version: String = ProjectSettings.get_setting("application/config/version", "0.1.0")
@export var game_name: String = ProjectSettings.get_setting("application/config/name", "Bar-Sik")

# Configuración de pantalla
@export var target_fps: int = 60
@export var vsync_enabled: bool = true

# Configuración de audio (valores por defecto)
@export var master_volume: float = 1.0
@export var music_volume: float = 0.8
@export var sfx_volume: float = 1.0

# Configuración de controles
@export var vibration_enabled: bool = true
@export var haptic_feedback: bool = true

func _ready() -> void:
    print("🎮 AppConfig inicializado")
    print("📱 Plataforma: ", OS.get_name())
    print("🏗️ Build: ", build_version)
    print("🐛 Debug: ", is_debug)

    # Configurar FPS objetivo
    Engine.max_fps = target_fps

    # Configurar V-Sync
    if vsync_enabled:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
    else:
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

## Obtener información del dispositivo
func get_device_info() -> Dictionary:
    return {
        "platform": OS.get_name(),
        "model": OS.get_model_name(),
        "screen_size": DisplayServer.screen_get_size(),
        "safe_area": DisplayServer.screen_get_usable_rect(),
        "dpi": DisplayServer.screen_get_dpi()
    }

## Verificar si estamos en móvil
func is_mobile() -> bool:
    return OS.get_name() in ["Android", "iOS"]

## Verificar si estamos en desktop
func is_desktop() -> bool:
    return OS.get_name() in ["Windows", "macOS", "Linux"]

## Guardar configuración (implementar más adelante)
func save_config() -> void:
    # TODO: Implementar guardado de configuración
    pass

## Cargar configuración (implementar más adelante)
func load_config() -> void:
    # TODO: Implementar carga de configuración
    pass
