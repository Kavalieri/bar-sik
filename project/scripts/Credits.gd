extends Control
## Credits - Pantalla de créditos del juego
## Muestra información sobre el desarrollo y reconocimientos

@onready var back_button: Button = $BackButton

func _ready() -> void:
	print("📜 Credits cargado")

	# Configurar botón de regreso
	if back_button:
		back_button.text = "⬅️ Atrás"
		back_button.pressed.connect(_on_back_pressed)

	print("✅ Credits configurado")

func _on_back_pressed() -> void:
	print("⬅️ Regresando al menú principal")
	Router.goto_scene("main_menu")

# Manejar navegación con ESC
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
