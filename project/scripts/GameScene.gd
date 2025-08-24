extends Control
## GameScene - Escena principal del juego
## Utiliza GameController del core para toda la lógica

# Script del GameController
const GameControllerScript = preload("res://scripts/core/GameController.gd")

# Referencias para paneles dinámicos
var prestige_panel_scene: PackedScene
var automation_panel_scene: PackedScene
var missions_panel_scene: PackedScene
var achievements_panel_scene: PackedScene

# Panel activo
var current_popup_panel: Control = null

# Instancia del GameController
var game_controller: GameController

@onready var tab_navigator: Control = $TabNavigator

func _ready() -> void:
	# Permitir que GameScene funcione durante pausa para poder despausar
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Crear e instanciar GameController
	print("🔧 GameScene: Creando instancia de GameController...")
	game_controller = GameControllerScript.new()
	game_controller.name = "GameController"
	add_child(game_controller)
	print("✅ GameScene: GameController instanciado y agregado como hijo")

	# Cargar escenas de paneles
	prestige_panel_scene = load("res://scenes/ui/PrestigePanel.tscn")
	automation_panel_scene = load("res://scenes/ui/AutomationPanel.tscn")
	missions_panel_scene = load("res://scenes/ui/MissionPanel.tscn")
	achievements_panel_scene = load("res://scenes/ui/AchievementPanel.tscn")

	print("🎮 GameScene inicializada usando GameController modular")
	_connect_tab_navigator_signals()

func _input(event):
	"""Manejar input global para atajos de teclado"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# Si hay un panel abierto, cerrarlo primero
				if current_popup_panel:
					_on_panel_closed()
				else:
					_on_pause_pressed()
			KEY_P:
				# P solo para pausa
				if not current_popup_panel:  # Solo pausar si no hay panel abierto
					_on_pause_pressed()

func _connect_tab_navigator_signals():
	"""Conectar señales del TabNavigator a funciones de debug"""
	if not tab_navigator:
		print("❌ TabNavigator no encontrado")
		return

	# Conectar señales básicas
	if tab_navigator.has_signal("pause_pressed"):
		tab_navigator.pause_pressed.connect(_on_pause_pressed)
	if tab_navigator.has_signal("prestige_requested"):
		tab_navigator.prestige_requested.connect(_on_prestige_requested)
	if tab_navigator.has_signal("missions_requested"):
		tab_navigator.missions_requested.connect(_on_missions_requested)
	if tab_navigator.has_signal("automation_requested"):
		tab_navigator.automation_requested.connect(_on_automation_requested)
	if tab_navigator.has_signal("achievements_requested"):
		tab_navigator.achievements_requested.connect(_on_achievements_requested)

	print("✅ Señales del TabNavigator conectadas")

func _on_pause_pressed():
	print("⏸️ DEBUG: Botón de pausa presionado en GameScene")

	# Si hay un panel abierto, mencionar que se puede cerrar con ESC
	if current_popup_panel:
		print("ℹ️ Hay un panel abierto. Usa ESC para cerrar el panel primero.")
		return

	# Delegar la pausa al GameController que tiene la implementación completa
	if game_controller and game_controller.has_method("_on_pause_pressed"):
		print("🔗 GameScene: Delegando pausa a GameController")
		game_controller._on_pause_pressed()
	else:
		print("❌ GameScene: GameController no disponible para pausa")
		# Fallback básico
		if get_tree().paused:
			get_tree().paused = false
			print("▶️ Juego reanudado (fallback)")
		else:
			get_tree().paused = true
			print("⏸️ Juego pausado (fallback)")

func _on_prestige_requested():
	print("⭐ DEBUG: Botón de prestigio presionado")
	_show_panel(prestige_panel_scene, "Panel de Prestigio")

func _on_missions_requested():
	print("🎮 DEBUG: Botón de misiones presionado")
	_show_panel(missions_panel_scene, "Panel de Misiones")

func _on_automation_requested():
	print("🎛️ DEBUG: Botón de automatización presionado")
	_show_panel(automation_panel_scene, "Panel de Automatización")

func _on_achievements_requested():
	print("🏆 DEBUG: Botón de achievements presionado")
	_show_panel(achievements_panel_scene, "Panel de Logros")

func _show_panel(panel_scene: PackedScene, panel_name: String):
	"""Mostrar un panel dinámicamente"""
	if not panel_scene:
		print("❌ No se pudo cargar la escena para: " + panel_name)
		return

	# Cerrar panel actual si existe
	if current_popup_panel:
		current_popup_panel.queue_free()
		current_popup_panel = null

	# Crear nueva instancia del panel
	var panel_instance = panel_scene.instantiate()
	if not panel_instance:
		print("❌ No se pudo instanciar: " + panel_name)
		return

	# NO pausar el juego - dejar que el panel funcione normalmente
	# panel_instance.process_mode = Node.PROCESS_MODE_INHERIT (es el default)

	# Agregar al árbol
	add_child(panel_instance)
	current_popup_panel = panel_instance

	# Conectar señal de cierre si existe
	if panel_instance.has_signal("panel_closed"):
		panel_instance.panel_closed.connect(_on_panel_closed)

	# Llamar a show_panel() si existe para hacer el panel visible
	if panel_instance.has_method("show_panel"):
		panel_instance.show_panel()
	else:
		# Si no tiene show_panel, asegurar que sea visible
		panel_instance.visible = true

	print("✅ " + panel_name + " mostrado correctamente")
	print("🎮 El juego sigue activo - el panel no pausa el juego")

func _on_panel_closed():
	"""Manejar cierre de paneles"""
	print("🔒 Cerrando panel actual...")
	if current_popup_panel:
		current_popup_panel.queue_free()
		current_popup_panel = null
		print("✅ Panel cerrado - juego activo nuevamente")
