extends Node
class_name ResourceManager
## Sistema central de gestión de recursos del bar
## Maneja ingredientes, bebidas, almacenamiento y conversiones

# Señales para comunicar cambios
signal resource_changed(resource_id: String, old_amount: int, new_amount: int)
signal storage_full(resource_id: String)
signal recipe_completed(beverage_id: String, amount: int)

# Datos de los recursos (ingredientes)
var resources: Dictionary = {}

# Definición de todos los recursos disponibles
const RESOURCE_DATA = {
	# Tier 1 - Básicos (disponibles al inicio)
	"water":
	{
		"name": "Agua",
		"emoji": "🫐",
		"tier": 1,
		"base_generation": 1,
		"max_storage": 100,
		"unlock_cost": 0,
		"unlocked": true
	},
	"lemon":
	{
		"name": "Limón",
		"emoji": "🍋",
		"tier": 1,
		"base_generation": 1,
		"max_storage": 50,
		"unlock_cost": 100,
		"unlocked": false
	},
	"ice":
	{
		"name": "Hielo",
		"emoji": "🧊",
		"tier": 1,
		"base_generation": 1,
		"max_storage": 75,
		"unlock_cost": 250,
		"unlocked": false
	},
	# Tier 2 - Intermedio
	"orange":
	{
		"name": "Naranja",
		"emoji": "🍊",
		"tier": 2,
		"base_generation": 1,
		"max_storage": 40,
		"unlock_cost": 1000,
		"unlocked": false
	},
	"strawberry":
	{
		"name": "Fresa",
		"emoji": "🍓",
		"tier": 2,
		"base_generation": 1,
		"max_storage": 30,
		"unlock_cost": 2500,
		"unlocked": false
	},
	"mint":
	{
		"name": "Menta",
		"emoji": "🌿",
		"tier": 2,
		"base_generation": 1,
		"max_storage": 25,
		"unlock_cost": 5000,
		"unlocked": false
	}
}

# Definición de recetas de bebidas
const BEVERAGE_RECIPES = {
	"lemonade":
	{
		"name": "Limonada",
		"emoji": "🍋‍🟩",
		"price": 5,
		"time": 2.0,
		"ingredients": {"water": 2, "lemon": 1, "ice": 1},
		"unlock_requirements": {"resources": ["water", "lemon", "ice"]}
	},
	"strawberry_water":
	{
		"name": "Agua de Fresa",
		"emoji": "🍓🥤",
		"price": 8,
		"time": 3.0,
		"ingredients": {"water": 3, "strawberry": 2, "ice": 1},
		"unlock_requirements": {"resources": ["water", "strawberry", "ice"]}
	},
	"orange_juice":
	{
		"name": "Jugo de Naranja",
		"emoji": "🍊🥤",
		"price": 12,
		"time": 4.0,
		"ingredients": {"water": 1, "orange": 3, "ice": 1},
		"unlock_requirements": {"resources": ["water", "orange", "ice"]}
	}
}


func _ready() -> void:
	print("🏪 ResourceManager inicializado")
	_initialize_resources()


## Inicializar recursos con valores por defecto
func _initialize_resources() -> void:
	for resource_id in RESOURCE_DATA:
		resources[resource_id] = {
			"amount": 0,
			"max_storage": RESOURCE_DATA[resource_id].max_storage,
			"unlocked": RESOURCE_DATA[resource_id].unlocked
		}

	# Dar algunos recursos iniciales para testing
	if AppConfig.is_debug:
		add_resource("water", 10)


## Añadir cantidad de un recurso
func add_resource(resource_id: String, amount: int) -> bool:
	if not resources.has(resource_id):
		push_error("❌ Recurso no válido: " + resource_id)
		return false

	if not resources[resource_id].unlocked:
		push_warning("⚠️ Recurso no desbloqueado: " + resource_id)
		return false

	var old_amount = resources[resource_id].amount
	var max_storage = resources[resource_id].max_storage
	var new_amount = min(old_amount + amount, max_storage)

	resources[resource_id].amount = new_amount

	# Emitir señal si cambió la cantidad
	if new_amount != old_amount:
		resource_changed.emit(resource_id, old_amount, new_amount)

		if AppConfig.is_debug:
			print("📦 ", RESOURCE_DATA[resource_id].name, ": ", old_amount, " → ", new_amount)

	# Avisar si el almacén está lleno
	if new_amount >= max_storage:
		storage_full.emit(resource_id)

	return new_amount > old_amount


## Remover cantidad de un recurso
func remove_resource(resource_id: String, amount: int) -> bool:
	if not resources.has(resource_id):
		push_error("❌ Recurso no válido: " + resource_id)
		return false

	var old_amount = resources[resource_id].amount
	if old_amount < amount:
		return false  # No hay suficiente

	var new_amount = old_amount - amount
	resources[resource_id].amount = new_amount

	resource_changed.emit(resource_id, old_amount, new_amount)

	if AppConfig.is_debug:
		print("📦 ", RESOURCE_DATA[resource_id].name, ": ", old_amount, " → ", new_amount)

	return true


## Obtener cantidad de un recurso
func get_resource_amount(resource_id: String) -> int:
	if not resources.has(resource_id):
		return 0
	return resources[resource_id].amount


## Verificar si se puede hacer una receta
func can_make_beverage(beverage_id: String) -> bool:
	if not BEVERAGE_RECIPES.has(beverage_id):
		return false

	var recipe = BEVERAGE_RECIPES[beverage_id]

	# Verificar que todos los ingredientes requeridos estén desbloqueados
	for resource_id in recipe.unlock_requirements.resources:
		if not is_resource_unlocked(resource_id):
			return false

	# Verificar que tengamos suficientes ingredientes
	for ingredient_id in recipe.ingredients:
		var required = recipe.ingredients[ingredient_id]
		var available = get_resource_amount(ingredient_id)
		if available < required:
			return false

	return true


## Hacer una bebida (consume ingredientes)
func make_beverage(beverage_id: String) -> bool:
	if not can_make_beverage(beverage_id):
		return false

	var recipe = BEVERAGE_RECIPES[beverage_id]

	# Consumir ingredientes
	for ingredient_id in recipe.ingredients:
		var required = recipe.ingredients[ingredient_id]
		remove_resource(ingredient_id, required)

	recipe_completed.emit(beverage_id, 1)

	if AppConfig.is_debug:
		print("🍹 Bebida completada: ", recipe.name)

	return true


## Desbloquear un recurso
func unlock_resource(resource_id: String) -> bool:
	if not resources.has(resource_id):
		return false

	if resources[resource_id].unlocked:
		return false  # Ya estaba desbloqueado

	resources[resource_id].unlocked = true
	print("🔓 Recurso desbloqueado: ", RESOURCE_DATA[resource_id].name)

	return true


## Verificar si un recurso está desbloqueado
func is_resource_unlocked(resource_id: String) -> bool:
	if not resources.has(resource_id):
		return false
	return resources[resource_id].unlocked


## Obtener datos de un recurso
func get_resource_data(resource_id: String) -> Dictionary:
	if not RESOURCE_DATA.has(resource_id):
		return {}
	return RESOURCE_DATA[resource_id]


## Obtener datos de una bebida
func get_beverage_data(beverage_id: String) -> Dictionary:
	if not BEVERAGE_RECIPES.has(beverage_id):
		return {}
	return BEVERAGE_RECIPES[beverage_id]


## Obtener lista de recursos desbloqueados
func get_unlocked_resources() -> Array:
	var unlocked = []
	for resource_id in resources:
		if resources[resource_id].unlocked:
			unlocked.append(resource_id)
	return unlocked


## Obtener lista de bebidas disponibles
func get_available_beverages() -> Array:
	var available = []
	for beverage_id in BEVERAGE_RECIPES:
		if can_make_beverage(beverage_id):
			available.append(beverage_id)
	return available


## Obtener estado completo para guardado
func get_save_data() -> Dictionary:
	return {"resources": resources}


## Cargar estado desde guardado
func load_save_data(data: Dictionary) -> void:
	if data.has("resources"):
		resources = data.resources
