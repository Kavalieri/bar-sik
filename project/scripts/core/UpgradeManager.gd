extends Node
class_name UpgradeManager
## Sistema de mejoras y upgrades del juego idle
## Maneja compras, multipliers y desbloqueos progresivos

# Señales
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal upgrade_available(upgrade_id: String)

# Datos de upgrades
var upgrades: Dictionary = {}

# Definición de todos los upgrades disponibles
const UPGRADE_DATA = {
	# UPGRADES DE CLICK POWER
	"click_power_water":
	{
		"name": "Fuerza de Click - Agua",
		"description": "Genera más agua por click",
		"icon": "🫐💪",
		"category": "click",
		"resource": "water",
		"base_cost": 50,
		"cost_multiplier": 1.5,
		"base_effect": 1,
		"effect_multiplier": 1.0,
		"max_level": 50,
		"currency": "cash"
	},
	"click_power_lemon":
	{
		"name": "Fuerza de Click - Limón",
		"description": "Genera más limones por click",
		"icon": "🍋💪",
		"category": "click",
		"resource": "lemon",
		"base_cost": 200,
		"cost_multiplier": 1.6,
		"base_effect": 1,
		"effect_multiplier": 1.0,
		"max_level": 50,
		"currency": "cash",
		"unlock_requirements": {"resources": ["lemon"]}
	},
	# UPGRADES DE AUTO-GENERACIÓN
	"auto_water":
	{
		"name": "Grifo Automático",
		"description": "Genera agua automáticamente",
		"icon": "🚰🤖",
		"category": "auto",
		"resource": "water",
		"base_cost": 100,
		"cost_multiplier": 1.8,
		"base_effect": 1,
		"effect_multiplier": 0.5,  # Genera cada 2 segundos
		"max_level": 25,
		"currency": "cash"
	},
	"auto_lemon":
	{
		"name": "Limonero Automático",
		"description": "Genera limones automáticamente",
		"icon": "🌳🤖",
		"category": "auto",
		"resource": "lemon",
		"base_cost": 500,
		"cost_multiplier": 2.0,
		"base_effect": 1,
		"effect_multiplier": 0.3,
		"max_level": 25,
		"currency": "cash",
		"unlock_requirements": {"resources": ["lemon"], "upgrades": {"auto_water": 1}}
	},
	# UPGRADES DE CAPACIDAD DE ALMACENAMIENTO
	"storage_water":
	{
		"name": "Tanque de Agua",
		"description": "Almacena más agua",
		"icon": "🫐📦",
		"category": "storage",
		"resource": "water",
		"base_cost": 150,
		"cost_multiplier": 1.4,
		"base_effect": 50,  # +50 capacidad base
		"effect_multiplier": 25,  # +25 por nivel
		"max_level": 20,
		"currency": "cash"
	},
	# UPGRADES DE VELOCIDAD/EFICIENCIA
	"beverage_speed":
	{
		"name": "Batidora Rápida",
		"description": "Prepara bebidas más rápido",
		"icon": "🥤⚡",
		"category": "speed",
		"resource": "all",
		"base_cost": 300,
		"cost_multiplier": 1.7,
		"base_effect": 0.1,  # -10% tiempo
		"effect_multiplier": 0.05,  # -5% adicional por nivel
		"max_level": 10,
		"currency": "cash"
	},
	# UPGRADES DE INGRESOS
	"income_multiplier":
	{
		"name": "Marketing del Bar",
		"description": "Aumenta ingresos por ventas",
		"icon": "💰📈",
		"category": "income",
		"resource": "all",
		"base_cost": 1000,
		"cost_multiplier": 2.2,
		"base_effect": 0.25,  # +25% ingresos
		"effect_multiplier": 0.1,  # +10% adicional
		"max_level": 15,
		"currency": "cash"
	},
	# UPGRADES PREMIUM (CON TOKENS)
	"unlock_lemon":
	{
		"name": "Desbloquear Limón",
		"description": "Permite generar limones",
		"icon": "🍋🔓",
		"category": "unlock",
		"resource": "lemon",
		"base_cost": 10,
		"cost_multiplier": 1.0,
		"base_effect": 1,
		"effect_multiplier": 0,
		"max_level": 1,
		"currency": "tokens"
	},
	"unlock_ice":
	{
		"name": "Desbloquear Hielo",
		"description": "Permite generar hielo",
		"icon": "🧊🔓",
		"category": "unlock",
		"resource": "ice",
		"base_cost": 25,
		"cost_multiplier": 1.0,
		"base_effect": 1,
		"effect_multiplier": 0,
		"max_level": 1,
		"currency": "tokens"
	}
}


func _ready() -> void:
	print("🔧 UpgradeManager inicializado")
	_initialize_upgrades()


## Inicializar upgrades con valores por defecto
func _initialize_upgrades() -> void:
	for upgrade_id in UPGRADE_DATA:
		upgrades[upgrade_id] = {"level": 0, "unlocked": _check_upgrade_unlocked(upgrade_id)}


## Verificar si un upgrade está desbloqueado
func _check_upgrade_unlocked(upgrade_id: String) -> bool:
	var upgrade_data = UPGRADE_DATA[upgrade_id]

	# Verificar requisitos de desbloqueo
	if upgrade_data.has("unlock_requirements"):
		var reqs = upgrade_data.unlock_requirements

		# Verificar recursos requeridos
		if reqs.has("resources"):
			# TODO: Verificar con ResourceManager cuando esté integrado
			pass

		# Verificar upgrades requeridos
		if reqs.has("upgrades"):
			for req_upgrade in reqs.upgrades:
				var req_level = reqs.upgrades[req_upgrade]
				if get_upgrade_level(req_upgrade) < req_level:
					return false

	return true


## Obtener nivel actual de un upgrade
func get_upgrade_level(upgrade_id: String) -> int:
	if not upgrades.has(upgrade_id):
		return 0
	return upgrades[upgrade_id].level


## Verificar si un upgrade está disponible para comprar
func can_purchase_upgrade(upgrade_id: String) -> bool:
	if not UPGRADE_DATA.has(upgrade_id):
		return false

	var upgrade_data = UPGRADE_DATA[upgrade_id]
	var current_level = get_upgrade_level(upgrade_id)

	# Verificar nivel máximo
	if current_level >= upgrade_data.max_level:
		return false

	# Verificar si está desbloqueado
	if not is_upgrade_unlocked(upgrade_id):
		return false

	# Verificar si se puede pagar
	var cost = get_upgrade_cost(upgrade_id)
	# TODO: Verificar con CurrencyManager

	return true


## Verificar si un upgrade está desbloqueado
func is_upgrade_unlocked(upgrade_id: String) -> bool:
	if not upgrades.has(upgrade_id):
		return false
	return upgrades[upgrade_id].unlocked


## Calcular costo actual de un upgrade
func get_upgrade_cost(upgrade_id: String) -> int:
	if not UPGRADE_DATA.has(upgrade_id):
		return 0

	var upgrade_data = UPGRADE_DATA[upgrade_id]
	var current_level = get_upgrade_level(upgrade_id)

	# Fórmula: base_cost * (cost_multiplier ^ current_level)
	var cost = upgrade_data.base_cost * pow(upgrade_data.cost_multiplier, current_level)

	return int(cost)


## Obtener información de display de un upgrade
func get_upgrade_info(upgrade_id: String) -> Dictionary:
	if not UPGRADE_DATA.has(upgrade_id):
		return {}

	var upgrade_data = UPGRADE_DATA[upgrade_id]
	var current_level = get_upgrade_level(upgrade_id)
	var cost = get_upgrade_cost(upgrade_id)
	var current_effect = get_upgrade_effect(upgrade_id)
	var next_effect = get_upgrade_effect(upgrade_id, current_level + 1)

	return {
		"id": upgrade_id,
		"name": upgrade_data.name,
		"description": upgrade_data.description,
		"icon": upgrade_data.icon,
		"category": upgrade_data.category,
		"current_level": current_level,
		"max_level": upgrade_data.max_level,
		"cost": cost,
		"currency": upgrade_data.currency,
		"current_effect": current_effect,
		"next_effect": next_effect,
		"can_purchase": can_purchase_upgrade(upgrade_id),
		"unlocked": is_upgrade_unlocked(upgrade_id)
	}


## Calcular efecto actual de un upgrade
func get_upgrade_effect(upgrade_id: String, level: int = -1) -> float:
	if not UPGRADE_DATA.has(upgrade_id):
		return 0.0

	var upgrade_data = UPGRADE_DATA[upgrade_id]
	var upgrade_level = level if level >= 0 else get_upgrade_level(upgrade_id)

	if upgrade_level <= 0:
		return 0.0

	# Calcular efecto según tipo
	match upgrade_data.category:
		"click", "auto":
			return upgrade_data.base_effect + (upgrade_data.effect_multiplier * (upgrade_level - 1))
		"storage":
			return upgrade_data.base_effect + (upgrade_data.effect_multiplier * upgrade_level)
		"speed", "income":
			return upgrade_data.base_effect + (upgrade_data.effect_multiplier * (upgrade_level - 1))
		"unlock":
			return 1.0 if upgrade_level > 0 else 0.0
		_:
			return float(upgrade_level)


## Comprar un upgrade
func purchase_upgrade(upgrade_id: String) -> bool:
	if not can_purchase_upgrade(upgrade_id):
		return false

	var upgrade_data = UPGRADE_DATA[upgrade_id]
	var cost = get_upgrade_cost(upgrade_id)
	var currency_type = upgrade_data.currency

	# TODO: Integrar con CurrencyManager
	# if not currency_manager.spend_currency(currency_type, cost):
	#     return false

	# Aumentar nivel
	upgrades[upgrade_id].level += 1
	var new_level = upgrades[upgrade_id].level

	# Emitir señal
	upgrade_purchased.emit(upgrade_id, new_level)

	# Efectos especiales para upgrades de desbloqueo
	if upgrade_data.category == "unlock":
		_handle_unlock_upgrade(upgrade_id)

	# Verificar si se desbloquearon nuevos upgrades
	_check_new_unlocks()

	if AppConfig.is_debug:
		print("🔧 Upgrade comprado: ", upgrade_data.name, " nivel ", new_level)

	return true


## Manejar upgrades de desbloqueo
func _handle_unlock_upgrade(upgrade_id: String) -> void:
	var upgrade_data = UPGRADE_DATA[upgrade_id]

	if upgrade_data.has("resource"):
		var resource_id = upgrade_data.resource
		# TODO: Integrar con ResourceManager
		# resource_manager.unlock_resource(resource_id)


## Verificar nuevos desbloqueos
func _check_new_unlocks() -> void:
	for upgrade_id in upgrades:
		if not upgrades[upgrade_id].unlocked:
			var newly_unlocked = _check_upgrade_unlocked(upgrade_id)
			if newly_unlocked:
				upgrades[upgrade_id].unlocked = true
				upgrade_available.emit(upgrade_id)


## Obtener lista de upgrades por categoría
func get_upgrades_by_category(category: String) -> Array:
	var upgrades_in_category = []

	for upgrade_id in UPGRADE_DATA:
		if UPGRADE_DATA[upgrade_id].category == category:
			upgrades_in_category.append(upgrade_id)

	return upgrades_in_category


## Obtener lista de upgrades disponibles para compra
func get_available_upgrades() -> Array:
	var available = []

	for upgrade_id in upgrades:
		if is_upgrade_unlocked(upgrade_id) and can_purchase_upgrade(upgrade_id):
			available.append(upgrade_id)

	return available


## Obtener multipliers totales para cálculos
func get_click_multiplier(resource_id: String) -> float:
	var multiplier = 1.0

	# Buscar upgrades de click power para este recurso
	var click_upgrade = "click_power_" + resource_id
	if upgrades.has(click_upgrade):
		multiplier += get_upgrade_effect(click_upgrade)

	return multiplier


func get_auto_generation_rate(resource_id: String) -> float:
	var rate = 0.0

	# Buscar upgrade de auto-generación
	var auto_upgrade = "auto_" + resource_id
	if upgrades.has(auto_upgrade):
		var level = get_upgrade_level(auto_upgrade)
		if level > 0:
			var effect = get_upgrade_effect(auto_upgrade)
			rate = effect  # items per second

	return rate


func get_storage_bonus(resource_id: String) -> int:
	var bonus = 0

	var storage_upgrade = "storage_" + resource_id
	if upgrades.has(storage_upgrade):
		bonus = int(get_upgrade_effect(storage_upgrade))

	return bonus


func get_income_multiplier() -> float:
	var multiplier = 1.0

	if upgrades.has("income_multiplier"):
		multiplier += get_upgrade_effect("income_multiplier")

	return multiplier


func get_speed_multiplier() -> float:
	var multiplier = 1.0

	if upgrades.has("beverage_speed"):
		var speed_reduction = get_upgrade_effect("beverage_speed")
		multiplier = 1.0 - speed_reduction  # Reduce el tiempo

	return max(multiplier, 0.1)  # Mínimo 10% del tiempo original


## Guardar y cargar datos
func get_save_data() -> Dictionary:
	return {"upgrades": upgrades}


func load_save_data(data: Dictionary) -> void:
	if data.has("upgrades"):
		upgrades = data.upgrades

		# Verificar desbloqueos después de cargar
		_check_new_unlocks()
