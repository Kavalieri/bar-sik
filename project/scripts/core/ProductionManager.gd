extends Node
class_name ProductionManager
## ProductionManager - Gestión centralizada de estaciones de producción
## Separar lógica de producción del GameScene principal

signal station_purchased(station_id: String)
signal product_produced(product_type: String, amount: int)
signal station_unlocked(station_id: String)

## Definición de estaciones disponibles
var station_definitions: Array[Dictionary] = [
	{
		"id": "brewery",
		"name": "🍺 Cervecería",
		"base_cost": 500.0,
		"recipe": {"barley": 2, "hops": 1, "water": 3},
		"produces": "basic_beer",
		"production_time": 10.0,
		"scale_factor": 1.15,
		"unlocked": false,
		"unlock_conditions": {
			"resources": {"barley": 5, "hops": 5, "water": 10}
		},
		"description": "Convierte ingredientes en cerveza básica\n🌾x2 + 🌿x1 + 💧x3 → 🍺"
	},
	{
		"id": "bar_station",
		"name": "🍹 Estación de Bar",
		"base_cost": 2500.0,
		"recipe": {"basic_beer": 2, "water": 1},
		"produces": "premium_beer",
		"production_time": 15.0,
		"scale_factor": 1.15,
		"unlocked": false,
		"unlock_conditions": {
			"products": {"basic_beer": 10}
		},
		"description": "Mejora cerveza básica a premium\n🍺x2 + 💧x1 → 🍹"
	}
]

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

	for station_def in station_definitions:
		if not station_def.unlocked:
			if _meets_unlock_conditions(station_def):
				station_def.unlocked = true
				station_unlocked.emit(station_def.id)
				print("🔓 Estación desbloqueada: %s" % station_def.name)

## Verificar si se cumplen condiciones de desbloqueo
func _meets_unlock_conditions(station_def: Dictionary) -> bool:
	var conditions = station_def.get("unlock_conditions", {})

	# Verificar condiciones de recursos
	if conditions.has("resources"):
		for resource_type in conditions.resources.keys():
			var required = conditions.resources[resource_type]
			var available = game_data.resources.get(resource_type, 0)
			if available < required:
				return false

	# Verificar condiciones de productos
	if conditions.has("products"):
		for product_type in conditions.products.keys():
			var required = conditions.products[product_type]
			var available = game_data.products.get(product_type, 0)
			if available < required:
				return false

	return true

## Comprar estación
func purchase_station(station_id: String) -> bool:
	if not game_data:
		return false

	var station_def = _find_station_by_id(station_id)
	if not station_def:
		return false

	if not station_def.unlocked:
		return false

	var owned = game_data.stations.get(station_id, 0)
	var cost = GameUtils.calculate_exponential_cost(
		station_def.base_cost,
		owned,
		1,
		station_def.scale_factor
	)

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

	var successful_productions = 0

	# Intentar producir la cantidad solicitada
	for i in range(quantity):
		if GameUtils.can_afford_recipe(game_data.resources, station_def.recipe):
			if GameUtils.consume_recipe(game_data.resources, station_def.recipe):
				game_data.products[station_def.produces] += 1
				successful_productions += 1
			else:
				break
		else:
			break

	if successful_productions > 0:
		game_data.statistics["products_crafted"] += successful_productions
		product_produced.emit(station_def.produces, successful_productions)

	return successful_productions

## Obtener costo de estación
func get_station_cost(station_id: String) -> float:
	var station_def = _find_station_by_id(station_id)
	if not station_def:
		return 0.0

	var owned = game_data.stations.get(station_id, 0) if game_data else 0
	return GameUtils.calculate_exponential_cost(
		station_def.base_cost,
		owned,
		1,
		station_def.scale_factor
	)

## Verificar si se puede producir en una estación
func can_produce(station_id: String, quantity: int = 1) -> bool:
	if not game_data:
		return false

	var station_def = _find_station_by_id(station_id)
	if not station_def:
		return false

	return GameUtils.can_afford_recipe(game_data.resources, station_def.recipe, quantity)

## Obtener definición de estación por ID
func _find_station_by_id(station_id: String) -> Dictionary:
	for station_def in station_definitions:
		if station_def.id == station_id:
			return station_def
	return {}

## Obtener todas las definiciones
func get_station_definitions() -> Array[Dictionary]:
	return station_definitions
