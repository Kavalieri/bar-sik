extends Control
class_name GameCoordinator
## GameCoordinator - Núcleo coordinador del juego (refactorizado)
## Coordina componentes especializados siguiendo principios SOLID

# Componentes especializados
@onready var input_controller: InputController
@onready var ui_coordinator: UICoordinator
@onready var event_bridge: EventBridge
@onready var dev_tools: DevToolsManager

# Managers del juego (sin cambios)
var game_data: GameData
var managers: Dictionary = {}

func _ready() -> void:
	print_rich("[color=yellow]🎮 GameCoordinator._ready() - Versión Refactorizada[/color]")

	_initialize_components()
	_setup_game_data()
	_setup_managers()
	_connect_components()

	print_rich("[color=green]✅ GameCoordinator listo - Arquitectura modular[/color]")

func _initialize_components():
	"""Inicializar componentes especializados"""
	input_controller = InputController.new()
	ui_coordinator = $UICoordinator  # Debe ser hijo en escena
	event_bridge = EventBridge.new()
	dev_tools = DevToolsManager.new()

	add_child(input_controller)
	add_child(event_bridge)
	add_child(dev_tools)

func _setup_game_data():
	"""Configurar datos del juego"""
	game_data = GameData.new()
	dev_tools.initialize(game_data)

func _setup_managers():
	"""Configurar managers del juego"""
	# Crear managers como antes
	# TODO: Migrar código de _setup_managers original
	pass

func _connect_components():
	"""Conectar señales entre componentes"""
	input_controller.pause_requested.connect(_on_pause_requested)
	input_controller.dev_mode_toggled.connect(_on_dev_mode_toggled)

	event_bridge.initialize(self, ui_coordinator)

	# Conectar señales del EventBridge
	event_bridge.ui_update_requested.connect(_on_ui_update_requested)
	event_bridge.manager_action_requested.connect(_on_manager_action_requested)
	event_bridge.save_game_requested.connect(_on_save_game_requested)
	event_bridge.pause_menu_requested.connect(_on_pause_menu_requested)
	event_bridge.prestige_panel_requested.connect(_on_prestige_panel_requested)

	print("🔗 Componentes conectados")

func _on_pause_requested():
	"""Manejar solicitud de pausa"""
	get_tree().paused = !get_tree().paused
	print("⏸️ Juego %s" % ("pausado" if get_tree().paused else "reanudado"))

func _on_dev_mode_toggled(enabled: bool):
	"""Manejar cambio de modo desarrollo"""
	if enabled:
		dev_tools.apply_dev_mode_unlocks()

# === MANEJADORES DE SEÑALES DEL EVENTBRIDGE ===

func _on_ui_update_requested(component: String, data: Dictionary):
	"""Manejar solicitudes de actualización de UI desde EventBridge"""
	if ui_coordinator:
		match component:
			"all":
				ui_coordinator.update_all_displays()
			"generation", "production", "sales", "customers", "money":
				# Actualizar componente específico
				ui_coordinator.refresh_panel(component)
			_:
				print("⚠️ Componente UI no reconocido: %s" % component)

func _on_manager_action_requested(action: String, params: Dictionary):
	"""Manejar solicitudes de acciones de managers desde EventBridge"""
	match action:
		"generator_purchased":
			_handle_generator_purchase(params.get("generator_id", ""), params.get("quantity", 1))
		"station_purchased":
			_handle_station_purchase(params.get("station_id", ""))
		"ui_generator_purchase":
			_handle_ui_generator_purchase(params.get("generator_id", ""), params.get("quantity", 1))
		"ui_station_purchase":
			_handle_ui_station_purchase(params.get("station_id", ""), params.get("multiplier", 1))
		_:
			print("⚠️ Acción de manager no reconocida: %s" % action)

func _on_save_game_requested():
	"""Manejar solicitud de guardado desde EventBridge"""
	# TODO: Implementar guardado
	print("💾 Guardado solicitado via EventBridge")

func _on_pause_menu_requested():
	"""Manejar solicitud de menú de pausa desde EventBridge"""
	get_tree().paused = true
	# TODO: Mostrar menú de pausa
	print("⏸️ Menú de pausa solicitado via EventBridge")

func _on_prestige_panel_requested():
	"""Manejar solicitud de panel de prestigio desde EventBridge"""
	# TODO: Mostrar panel de prestigio
	print("🌟 Panel de prestigio solicitado via EventBridge")

# === MANEJADORES DE ACCIONES ESPECÍFICAS ===

func _handle_generator_purchase(generator_id: String, quantity: int):
	"""Manejar compra de generador (lógica específica aquí)"""
	print("🏭 Procesando compra de generador: %dx %s" % [quantity, generator_id])
	# TODO: Integrar con generator_manager real

func _handle_station_purchase(station_id: String):
	"""Manejar compra de estación (lógica específica aquí)"""
	print("🏪 Procesando compra de estación: %s" % station_id)
	# TODO: Integrar con production_manager real

func _handle_ui_generator_purchase(generator_id: String, quantity: int):
	"""Manejar compra de generador desde UI"""
	print("🔗 UI -> Compra de generador: %dx %s" % [quantity, generator_id])
	_handle_generator_purchase(generator_id, quantity)

func _handle_ui_station_purchase(station_id: String, multiplier: int):
	"""Manejar compra de estación desde UI"""
	print("🔗 UI -> Compra de estación: %s (x%d)" % [station_id, multiplier])
	_handle_station_purchase(station_id)

# === INTERFAZ PÚBLICA SIMPLIFICADA ===

func get_manager(type: String) -> Node:
	"""Obtener manager específico"""
	return managers.get(type)

func get_game_data() -> GameData:
	"""Obtener datos del juego"""
	return game_data

func is_system_unlocked(system_name: String) -> bool:
	"""Verificar si un sistema está desbloqueado"""
	match system_name:
		"customers": return game_data.customer_system_unlocked
		"automation": return game_data.automation_system_unlocked
		"prestige": return game_data.prestige_system_unlocked
		"research": return game_data.research_system_unlocked
		"contracts": return game_data.contracts_system_unlocked
		_: return false
