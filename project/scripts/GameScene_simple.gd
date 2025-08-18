extends Control
## GameScene - Escena principal del idle game
## Contiene la interfaz principal de juego con recursos, botones y estadísticas

# Referencias a los nodos de UI principales
@onready var pause_button: Button = $MainContainer/TopPanel/PauseButton


func _ready() -> void:
	print("🍺 GameScene cargado")

	# Configurar botón de pausa
	if pause_button:
		pause_button.text = "⏸️ Pausa"
		pause_button.pressed.connect(_on_pause_pressed)

	print("🎮 GameScene básico configurado")


func _on_pause_pressed() -> void:
	print("⏸️ Juego pausado")
	Router.goto_scene("pause")


# Manejar pausa con ESC
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_pause_pressed()
