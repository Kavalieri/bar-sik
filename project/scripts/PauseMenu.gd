extends Control
## PauseMenu - Menú que aparece cuando se pausa el juego
## Permite reanudar, ir a configuración o volver al menú principal

@onready var resume_button: Button = $CenterContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton
@onready var pause_label: Label = $CenterContainer/VBoxContainer/PauseLabel


func _ready() -> void:
	print("⏸️ PauseMenu cargado")

	# Los textos ya están en la escena .tscn

	# Conectar botones
	_connect_buttons()

	# Foco inicial
	if resume_button:
		resume_button.grab_focus()


func _connect_buttons() -> void:
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)


func _on_resume_pressed() -> void:
	print("▶️ Reanudando juego")
	# Despausar el juego
	get_tree().paused = false
	# Remover este menú de pausa
	queue_free()


func _on_settings_pressed() -> void:
	print("⚙️ Abriendo configuración desde pausa")
	# Despausar antes de cambiar escena
	get_tree().paused = false
	Router.goto_scene("settings")


func _on_main_menu_pressed() -> void:
	print("🏠 Volviendo al menú principal")
	# Despausar antes de cambiar escena
	get_tree().paused = false
	Router.goto_scene("main_menu")


# Manejar botón atrás/ESC para reanudar
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_resume_pressed()
