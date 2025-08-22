extends Control
## Menú principal del juego - UI MODULAR PROFESIONAL
## Primera pantalla que ve el jugador al iniciar - Sistema coherente

@onready var main_container: VBoxContainer = $VBoxContainer
@onready var start_button: Button = $VBoxContainer/StartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var credits_button: Button = $VBoxContainer/CreditsButton
@onready var qa_button: Button = $VBoxContainer/QAButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var version_label: Label = $VersionLabel


func _ready() -> void:
	print("📱 MainMenu cargado - Aplicando tema profesional")

	# Aplicar tema consistente a todos los botones
	_apply_consistent_theming()

	# Configurar versión del juego
	if version_label:
		version_label.text = "v1.0.0"
		version_label.add_theme_color_override("font_color", UITheme.Colors.LIGHT)

	# Conectar botones
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	qa_button.pressed.connect(_on_qa_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Configurar efectos hover
	_setup_hover_effects()

	# Foco inicial
	start_button.grab_focus()

	# Animación de entrada
	UIComponentsFactory.animate_fade_in(main_container)

	print("🎯 MainMenu configurado con tema profesional cervecería")


func _apply_consistent_theming() -> void:
	"""Aplicar el tema coherente a todos los botones del menú"""
	var buttons = [start_button, settings_button, credits_button, qa_button, quit_button]

	for button in buttons:
		if button:
			UITheme.apply_button_style(button, "large")
			UIComponentsFactory.make_responsive(button)


func _setup_hover_effects() -> void:
	"""Configurar efectos hover profesionales"""
	var buttons = [start_button, settings_button, credits_button, qa_button, quit_button]

	for button in buttons:
		if button:
			UIComponentsFactory.setup_button_hover(button)


func _on_start_pressed() -> void:
	print("🎮 Iniciando juego...")
	Router.goto_scene("game")


func _on_settings_pressed() -> void:
	print("⚙️ Abriendo configuración...")
	Router.goto_scene("settings")


func _on_credits_pressed() -> void:
	print("📜 Mostrando créditos...")
	Router.goto_scene("credits")


func _on_qa_pressed() -> void:
	print("🎯 Abriendo Professional QA Pass...")
	var qa_panel = load("res://scenes/QAPanel.tscn").instantiate()
	get_tree().current_scene.add_child(qa_panel)


func _on_quit_pressed() -> void:
	print("❌ Saliendo del juego...")
	get_tree().quit()


# Manejar el botón "atrás" de Android
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_quit_pressed()
