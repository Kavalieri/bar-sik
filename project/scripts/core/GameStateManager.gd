extends Node
## GameStateManager - Sistema centralizado de gestión de estado reactivo
## Mantiene coherencia de datos entre todas las pestañas

# Señales para comunicación reactiva entre paneles
signal money_changed(new_amount: float)
signal resources_changed(resources: Dictionary)
signal generators_changed(generators: Dictionary)
signal stations_changed(stations: Dictionary)
signal products_changed(products: Dictionary)
signal game_state_updated(full_state: Dictionary)

# Cache del estado actual
var cached_game_state: Dictionary = {}
var cached_money: float = 0.0
var cached_resources: Dictionary = {}
var cached_generators: Dictionary = {}
var cached_stations: Dictionary = {}
var cached_products: Dictionary = {}

# Referencias a paneles (se configuran desde GameController)
var generation_panel: Control
var production_panel: Control
var sales_panel: Control
var customers_panel: Control
var tab_navigator: Control

func _ready() -> void:
	print("🔄 GameStateManager inicializado - Sistema reactivo activo")

## === CONFIGURACIÓN DEL SISTEMA ===

func setup_panel_references(panels: Dictionary) -> void:
	"""Configura las referencias a todos los paneles"""
	generation_panel = panels.get("generation")
	production_panel = panels.get("production")
	sales_panel = panels.get("sales")
	customers_panel = panels.get("customers")
	tab_navigator = panels.get("tab_navigator")

	print("📱 GameStateManager - Referencias de paneles configuradas")

## === GESTIÓN DE ESTADO CENTRALIZADA ===

func update_game_state(new_state: Dictionary) -> void:
	"""Actualiza el estado completo del juego y notifica cambios"""
	var old_state = cached_game_state.duplicate()
	cached_game_state = new_state.duplicate()

	_check_and_emit_changes(old_state, new_state)

	# Emisión general de cambio de estado
	game_state_updated.emit(new_state)

func _check_and_emit_changes(old_state: Dictionary, new_state: Dictionary) -> void:
	"""Detecta cambios específicos y emite señales correspondientes"""

	# Verificar cambio de dinero
	var new_money = new_state.get("money", 0.0)
	if new_money != cached_money:
		cached_money = new_money
		money_changed.emit(new_money)
		_update_affordability_states(new_money)

	# Verificar cambio de recursos
	var new_resources = new_state.get("resources", {})
	if not _dictionaries_equal(new_resources, cached_resources):
		cached_resources = new_resources.duplicate()
		resources_changed.emit(new_resources)

	# Verificar cambio de generadores
	var new_generators = new_state.get("generators", {})
	if not _dictionaries_equal(new_generators, cached_generators):
		cached_generators = new_generators.duplicate()
		generators_changed.emit(new_generators)

	# Verificar cambio de estaciones
	var new_stations = new_state.get("stations", {})
	if not _dictionaries_equal(new_stations, cached_stations):
		cached_stations = new_stations.duplicate()
		stations_changed.emit(new_stations)

func _update_affordability_states(money: float) -> void:
	"""Actualiza solo los estados de botones según dinero disponible"""

	# Actualizar generadores en GenerationPanel
	if generation_panel and generation_panel.has_method("update_button_affordability"):
		generation_panel.update_button_affordability(money)

	# Actualizar estaciones en ProductionPanel
	if production_panel and production_panel.has_method("update_button_affordability"):
		production_panel.update_button_affordability(money)

func _dictionaries_equal(dict1: Dictionary, dict2: Dictionary) -> bool:
	"""Compara si dos diccionarios son iguales"""
	if dict1.size() != dict2.size():
		return false

	for key in dict1.keys():
		if not dict2.has(key) or dict1[key] != dict2[key]:
			return false

	return true

## === MÉTODOS DE CONVENIENCIA ===

func get_current_money() -> float:
	"""Obtiene el dinero actual"""
	return cached_money

func get_current_resources() -> Dictionary:
	"""Obtiene los recursos actuales"""
	return cached_resources.duplicate()

func get_current_generators() -> Dictionary:
	"""Obtiene los generadores actuales"""
	return cached_generators.duplicate()

func get_full_state() -> Dictionary:
	"""Obtiene el estado completo actual"""
	return cached_game_state.duplicate()

## === FUNCIONES DE DEBUG ===

func debug_print_state() -> void:
	"""Imprime el estado actual para debugging"""
	print_rich("[color=cyan]🔄 GAME STATE MANAGER - Estado actual:[/color]")
	print("💰 Dinero: %s" % cached_money)
	print("📦 Recursos: %s" % cached_resources.size())
	print("🏭 Generadores: %s" % cached_generators.size())
	print("🏢 Estaciones: %s" % cached_stations.size())
