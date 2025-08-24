extends Node
class_name InputController
## Controlador especializado para input del jugador
## Separado del GameController para mejorar modularidad

signal pause_requested
signal dev_mode_toggled
signal screenshot_requested

var is_dev_mode: bool = false

func _ready():
	set_process_input(true)
	print("🎮 InputController inicializado")

func _input(event):
	"""Manejar input del jugador"""
	if not event is InputEventKey or not event.pressed:
		return
		
	match event.keycode:
		KEY_ESCAPE, KEY_P:
			print("⌨️ Tecla de pausa presionada: %s" % ("ESC" if event.keycode == KEY_ESCAPE else "P"))
			pause_requested.emit()
			get_viewport().set_input_as_handled()
		
		KEY_F3:
			if event.shift_pressed:
				print("🔧 Modo desarrollo alternado")
				is_dev_mode = !is_dev_mode
				dev_mode_toggled.emit(is_dev_mode)
				get_viewport().set_input_as_handled()
		
		KEY_F12:
			print("📸 Screenshot solicitada")
			screenshot_requested.emit()
			get_viewport().set_input_as_handled()

func handle_pause_request():
	"""Procesar solicitud de pausa"""
	pause_requested.emit()

func is_in_dev_mode() -> bool:
	"""Verificar si está en modo desarrollo"""
	return is_dev_mode

func set_dev_mode(enabled: bool):
	"""Establecer modo desarrollo"""
	is_dev_mode = enabled
	print("🔧 Modo desarrollo: %s" % ("ACTIVADO" if enabled else "DESACTIVADO"))
