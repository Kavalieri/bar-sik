extends GameController
## GameScene - Escena principal del juego
## Utiliza GameController del core para toda la lógica


func _ready() -> void:
	# El GameController padre maneja toda la inicialización
	super._ready()

	# Aquí solo configuraciones específicas de esta escena si las hay
	print("🎮 GameScene inicializada usando GameController modular")
