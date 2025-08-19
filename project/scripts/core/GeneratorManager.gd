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
		"base_cost": 1.0,
		"produces": "water",
		"production_rate": 2.0,
		"scale_factor": 1.10,
		"description": "Recolecta agua cada 2 segundos"
	},
	{
		"id": "barley_farm",
		"name": "🌾 Granja de Cebada",
		"base_cost": 10.0,
		"produces": "barley",
		"production_rate": 1.0,
		"scale_factor": 1.10,
		"description": "Genera cebada cada 3 segundos"
	},
	{
		"id": "hops_farm",
		"name": "🌿 Granja de Lúpulo",
		"base_cost": 100.0,
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
	print("🏭 GeneratorManager: GameData asignado")

	# CRÍTICO: Verificar que el timer esté funcionando
	_verify_generation_timer()


func _verify_generation_timer() -> void:
	"""Verifica y reinicia el timer de generación si es necesario"""
	if not generation_timer:
		print("❌ Timer de generación perdido, recreando...")
		_setup_generation_timer()
	elif generation_timer.is_stopped():
		print("⚠️ Timer de generación detenido, reiniciando...")
		generation_timer.start()
	else:
		print("✅ Timer de generación funcionando correctamente")


## Procesar generación automática de recursos
func _generate_resources() -> void:
	if not game_data:
		print("⚠️ GeneratorManager: game_data no disponible")
		return

	if not StockManager:
		print("❌ GeneratorManager: StockManager no disponible")
		return

	print("🔄 GeneratorManager: Ejecutando ciclo de generación...")
	var total_generated = 0

	for generator_def in generator_definitions:
		var owned_count = game_data.generators.get(generator_def.id, 0)
		if owned_count > 0:
			var resource_type = generator_def.produces
			var amount = int(generator_def.production_rate * owned_count)

			# Verificar límite máximo antes de generar
			var current_amount = game_data.resources.get(resource_type, 0)
			var max_limit = game_data.resource_limits.get(resource_type, 999999)
			var space_available = max_limit - current_amount

			if space_available <= 0:
				print(
					(
						"📦 %s LLENO (%d/%d) - generación pausada"
						% [resource_type, current_amount, max_limit]
					)
				)
				continue

			# Limitar cantidad generada al espacio disponible
			var actual_amount = min(amount, space_available)

			# Usar StockManager en lugar de acceso directo
			StockManager.add_stock("ingredient", resource_type, actual_amount)
			game_data.statistics["resources_generated"] += actual_amount
			total_generated += actual_amount

			resource_generated.emit(resource_type, actual_amount)

			if actual_amount < amount:
				print(
					(
						"  ⚠️ Generación limitada: %dx %s (máx %d/%d)"
						% [actual_amount, resource_type, current_amount + actual_amount, max_limit]
					)
				)
			else:
				print(
					(
						"  ✅ Generado: %dx %s (de %d %s)"
						% [actual_amount, resource_type, owned_count, generator_def.name]
					)
				)

	if total_generated > 0:
		print("📦 Total generado este ciclo: %d recursos" % total_generated)
	else:
		print("💤 No hay generadores activos para generar recursos")


## Comprar generador por cantidad
func purchase_generator(generator_id: String, quantity: int) -> bool:
	print("🛒 GeneratorManager: Intentando comprar %dx %s" % [quantity, generator_id])

	if not game_data:
		print("❌ No hay game_data disponible")
		return false

	var generator_def = _find_generator_by_id(generator_id)
	if not generator_def:
		print("❌ Generador %s no encontrado" % generator_id)
		return false

	# ARREGLO: Usar precio escalado exponencial, no precio fijo
	var total_cost = get_generator_cost(generator_id, quantity)
	print("💰 Costo calculado: $%.2f (dinero actual: $%.2f)" % [total_cost, game_data.money])

	if game_data.money < total_cost:
		print("❌ Dinero insuficiente para comprar %dx %s" % [quantity, generator_id])
		return false

	var owned = game_data.generators.get(generator_id, 0)
	game_data.money -= total_cost
	game_data.generators[generator_id] = owned + quantity

	print("✅ Compra exitosa: %dx %s (nuevo total: %d)" % [quantity, generator_id, owned + quantity])

	# Detectar primera compra post-agua para tutorial
	if not game_data.first_generator_bought and generator_id != "water_collector":
		game_data.first_generator_bought = true
		print("🎓 Tutorial: Primera compra post-agua completada!")

	generator_purchased.emit(generator_id, quantity)
	return true


## Obtener costo de compra de generador (precio escalado)
func get_generator_cost(generator_id: String, quantity: int = 1) -> float:
	var generator_def = _find_generator_by_id(generator_id)
	if not generator_def:
		return 0.0

	var owned = game_data.generators.get(generator_id, 0)
	# Usar costo escalado exponencial como los edificios
	return GameUtils.calculate_exponential_cost(generator_def.base_cost, owned, quantity)


## Obtener definición de generador por ID
func _find_generator_by_id(generator_id: String) -> Dictionary:
	for generator_def in generator_definitions:
		if generator_def.id == generator_id:
			return generator_def
	return {}


## Obtener todas las definiciones
func get_generator_definitions() -> Array[Dictionary]:
	return generator_definitions
