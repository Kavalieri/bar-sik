extends Node
class_name GeneratorManager
## GeneratorManager - Gestión centralizada de generadores de recursos
## Separar lógica de generadores del GameScene principal

signal generator_purchased(generator_id: String, quantity: int)
signal resource_generated(resource_type: String, amount: int)

## Definición de generadores disponibles
var generator_definitions: Array[Dictionary] = [
	{
		"id": "water_collector",
		"name": "💧 Recolector de Agua",
		"base_cost": 10.0,
		"produces": "water",
		"production_rate": 2.0,
		"scale_factor": 1.10,
		"description": "Recolecta agua cada 2 segundos"
	},
	{
		"id": "barley_farm",
		"name": "🌾 Granja de Cebada",
		"base_cost": 100.0,
		"produces": "barley",
		"production_rate": 1.0,
		"scale_factor": 1.10,
		"description": "Genera cebada cada 3 segundos"
	},
	{
		"id": "hops_farm",
		"name": "🌿 Granja de Lúpulo",
		"base_cost": 1000.0,
		"produces": "hops",
		"production_rate": 1.0,
		"scale_factor": 1.10,
		"description": "Genera lúpulo cada 5 segundos"
	}
]

var game_data: GameData
var generation_timer: Timer

func _ready() -> void:
	_setup_generation_timer()

## Configurar timer de generación de recursos
func _setup_generation_timer() -> void:
	generation_timer = Timer.new()
	generation_timer.wait_time = 3.0
	generation_timer.autostart = true
	generation_timer.timeout.connect(_generate_resources)
	add_child(generation_timer)

## Asignar datos del juego
func set_game_data(data: GameData) -> void:
	game_data = data

## Procesar generación automática de recursos
func _generate_resources() -> void:
	if not game_data:
		return

	for generator_def in generator_definitions:
		var owned_count = game_data.generators.get(generator_def.id, 0)
		if owned_count > 0:
			var resource_type = generator_def.produces
			var amount = int(generator_def.production_rate * owned_count)

			game_data.resources[resource_type] += amount
			game_data.statistics["resources_generated"] += amount

			resource_generated.emit(resource_type, amount)

## Comprar generador por cantidad
func purchase_generator(generator_id: String, quantity: int) -> bool:
	if not game_data:
		return false

	var generator_def = _find_generator_by_id(generator_id)
	if not generator_def:
		return false

	# Precio fijo por unidad (como las ventas de ingredientes)
	var total_cost = generator_def.base_cost * quantity

	if game_data.money < total_cost:
		return false

	var owned = game_data.generators.get(generator_id, 0)
	game_data.money -= total_cost
	game_data.generators[generator_id] = owned + quantity

	generator_purchased.emit(generator_id, quantity)
	return true

## Obtener costo de compra de generador (precio fijo)
func get_generator_cost(generator_id: String, quantity: int = 1) -> float:
	var generator_def = _find_generator_by_id(generator_id)
	if not generator_def:
		return 0.0

	# Precio fijo por unidad (como las ventas)
	return generator_def.base_cost * quantity

## Obtener definición de generador por ID
func _find_generator_by_id(generator_id: String) -> Dictionary:
	for generator_def in generator_definitions:
		if generator_def.id == generator_id:
			return generator_def
	return {}

## Obtener todas las definiciones
func get_generator_definitions() -> Array[Dictionary]:
	return generator_definitions
