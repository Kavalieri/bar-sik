extends Node
class_name ProductionManager
## ProductionManager - Gestión centralizada de estaciones de producción
## Separar lógica de producción del GameScene principal

signal station_purchased(station_id: String)
signal product_produced(product_type: String, amount: int)
signal station_unlocked(station_id: String)

var game_data: GameData


func _ready() -> void:
	print("🏭 ProductionManager inicializado")


## Asignar datos del juego
func set_game_data(data: GameData) -> void:
	game_data = data


## Verificar y desbloquear estaciones automáticamente
func check_unlock_stations() -> void:
	if not game_data:
		return

	for station_id in GameConfig.STATION_DATA.keys():
		var station_def = GameConfig.STATION_DATA[station_id]

		# Verificar si ya está desbloqueada (tiene al menos 1)
		if game_data.stations.get(station_id, 0) > 0:
			continue

		# Verificar condiciones simples (por ahora, desbloquear automáticamente)
		# TODO: Implementar condiciones de desbloqueo más complejas si es necesario
		station_unlocked.emit(station_id)
		print("🔓 Estación desbloqueada: %s" % station_def.name)


## Comprar estación
func purchase_station(station_id: String) -> bool:
	if not game_data:
		return false

	var station_def = _find_station_by_id(station_id)
	if not station_def or station_def.is_empty():
		return false

	# Las estaciones están siempre disponibles para compra (desbloqueo automático)
	var owned = game_data.stations.get(station_id, 0)
	# Precio fijo simple (consistente con GeneratorManager)
	var cost = station_def.base_cost

	if game_data.money < cost:
		return false

	game_data.money -= cost
	game_data.stations[station_id] = owned + 1

	station_purchased.emit(station_id)
	return true


## Producir manualmente en una estación
func manual_production(station_id: String, quantity: int) -> int:
	if not game_data:
		return 0

	var station_def = _find_station_by_id(station_id)
	if not station_def:
		return 0

	var owned = game_data.stations.get(station_id, 0)
	if owned <= 0:
		return 0

	if not StockManager:
		print("❌ ProductionManager: StockManager no disponible")
		return 0

	var successful_productions = 0

	# Intentar producir la cantidad solicitada
	for i in range(quantity):
		if StockManager.can_afford_recipe(station_def.recipe):
			if StockManager.consume_recipe(station_def.recipe):
				# Usar StockManager en lugar de acceso directo
				StockManager.add_stock("product", station_def.produces, 1)
				successful_productions += 1
				print("🍺 Producido: +1 %s" % station_def.produces)
			else:
				break
		else:
			break

	if successful_productions > 0:
		game_data.statistics["products_crafted"] += successful_productions
		product_produced.emit(station_def.produces, successful_productions)

	return successful_productions


## Obtener costo de desbloqueo de estación (solo primera vez)
func get_unlock_cost(station_id: String) -> float:
	var config_data = GameConfig.STATION_DATA.get(station_id, {})
	return config_data.get("base_price", 0.0)


## Verificar si una estación está desbloqueada
func is_station_unlocked(station_id: String) -> bool:
	if not game_data:
		return false
	var owned = game_data.stations.get(station_id, 0)
	return owned > 0


## Verificar si se puede producir en una estación
func can_produce(station_id: String, quantity: int = 1) -> bool:
	if not game_data or not StockManager:
		return false

	var station_def = _find_station_by_id(station_id)
	if not station_def:
		return false

	return StockManager.can_afford_recipe(station_def.recipe, quantity)


## Obtener definición de estación por ID desde GameConfig
func _find_station_by_id(station_id: String) -> Dictionary:
	var station_data = GameConfig.STATION_DATA.get(station_id, {})
	if station_data.is_empty():
		return {}

	# Convertir formato GameConfig a formato esperado
	return {
		"id": station_id,
		"name": station_data.name,
		"base_cost": station_data.base_price,
		"recipe": station_data.recipe,
		"produces": station_data.produces,
		"description": station_data.description
	}


## Obtener todas las definiciones desde GameConfig
func get_station_definitions() -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	for station_id in GameConfig.STATION_DATA.keys():
		var station_def = _find_station_by_id(station_id)
		if not station_def.is_empty():
			definitions.append(station_def)
	return definitions


## Obtener datos actuales del juego
func get_game_data() -> Dictionary:
	"""Obtener datos actuales del juego para ProductionPanel"""
	if not game_data:
		return {"money": 0.0, "stations": {}, "products": {}, "resources": {}}

	return {
		"money": game_data.money,
		"stations": game_data.stations.duplicate(),
		"products": game_data.products.duplicate(),
		"resources": game_data.resources.duplicate()
	}
