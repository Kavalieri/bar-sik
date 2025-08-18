extends Control
## Menú principal del juego
## Primera pantalla que ve el jugador al iniciar

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var version_label: Label = $VersionLabel


func _ready() -> void:
	print("📱 MainMenu cargado")

	# Los textos ya están configurados en la escena .tscn, así que no los sobrescribimos

	# Configurar la versión del juego
	if version_label:
		version_label.text = "v1.0.0"

	# Conectar botones
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Foco inicial en el botón de inicio
	start_button.grab_focus()

	print("🎯 MainMenu configurado correctamente")


func _on_start_pressed() -> void:
	print("🎮 Iniciando juego...")
	Router.goto_scene("game")


func _on_settings_pressed() -> void:
	print("⚙️ Abriendo configuración...")
	Router.goto_scene("settings")


func _on_credits_pressed() -> void:
	print("📜 Mostrando créditos...")
	Router.goto_scene("credits")


func _on_quit_pressed() -> void:
	print("❌ Saliendo del juego...")
	get_tree().quit()


# Manejar el botón "atrás" de Android
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
