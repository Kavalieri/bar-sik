extends Control
## SettingsMenu - Menú de configuración básica
## Permite cambiar idioma, volumen y otras opciones

@onready var language_option: OptionButton = $VBoxContainer/LanguageContainer/LanguageOption
@onready var master_volume_slider: HSlider = $VBoxContainer/VolumeContainer/MasterVolumeSlider
@onready var music_volume_slider: HSlider = $VBoxContainer/VolumeContainer/MusicVolumeSlider
@onready var sfx_volume_slider: HSlider = $VBoxContainer/VolumeContainer/SfxVolumeSlider
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
    print("⚙️ SettingsMenu cargado")

    # Configurar UI inicial
    _setup_ui()

    # Conectar señales
    _connect_signals()

    # Cargar configuración actual
    _load_current_settings()

func _setup_ui() -> void:
    # Configurar opciones de idioma
    language_option.add_item("🇪🇸 Español", 0)
    language_option.add_item("🇺🇸 English", 1)
    language_option.add_item("🇫🇷 Français", 2)
    language_option.add_item("🇩🇪 Deutsch", 3)
    language_option.add_item("🇵🇹 Português", 4)

func _connect_signals() -> void:
    language_option.item_selected.connect(_on_language_changed)
    master_volume_slider.value_changed.connect(_on_master_volume_changed)
    music_volume_slider.value_changed.connect(_on_music_volume_changed)
    sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
    back_button.pressed.connect(_on_back_pressed)

func _load_current_settings() -> void:
    # Configurar valores por defecto simples (sin dependencias de autoloads)
    if language_option:
        language_option.selected = 0  # Español por defecto

    # Configurar volúmenes por defecto
    if master_volume_slider:
        master_volume_slider.value = 100.0
    if music_volume_slider:
        music_volume_slider.value = 80.0
    if sfx_volume_slider:
        sfx_volume_slider.value = 100.0

func _get_language_index(language_code: String) -> int:
    match language_code:
        "es": return 0
        "en": return 1
        "fr": return 2
        "de": return 3
        "pt": return 4
        _: return 0

func _get_language_code(index: int) -> String:
    match index:
        0: return "es"
        1: return "en"
        2: return "fr"
        3: return "de"
        4: return "pt"
        _: return "es"

func _on_language_changed(index: int) -> void:
    print("🌍 Idioma cambiado a índice: ", index)
    # TODO: Implementar cambio de idioma cuando los autoloads funcionen

func _on_master_volume_changed(value: float) -> void:
    print("🔊 Volumen principal: ", value)
    # TODO: Aplicar a AudioManager cuando esté implementado

func _on_music_volume_changed(value: float) -> void:
    print("🎵 Volumen música: ", value)
    # TODO: Aplicar a AudioManager cuando esté implementado

func _on_sfx_volume_changed(value: float) -> void:
    print("🔔 Volumen efectos: ", value)
    # TODO: Aplicar a AudioManager cuando esté implementado

func _on_back_pressed() -> void:
    print("⬅️ Volviendo atrás desde configuración")
    Router.goto_scene("main_menu")# Manejar botón atrás/ESC
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        _on_back_pressed()
