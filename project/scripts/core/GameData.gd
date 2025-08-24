class_name GameData
extends Resource
## GameData - Estructura centralizada de datos del juego
## Separar datos de lógica para mejor mantenibilidad

## Datos económicos - Triple Moneda v2.0
@export var money: float = 50.0
@export var tokens: int = 0  # Tokens ganados por clientes automáticos y misiones
@export var gems: int = 150  # T026: Diamantes premium - INICIAL MEJORADO (era 100)

## T013 - Sistema de Prestigio
@export var prestige_stars: int = 0  # Estrellas de prestigio acumuladas
@export var prestige_count: int = 0  # Número de prestigios realizados
@export var active_star_bonuses: Array[String] = []  # Bonificaciones activas
@export var total_cash_earned: float = 0.0  # Cash total ganado (para cálculo de stars)

# T017 - Sistema de Logros
@export var unlocked_achievements: Array[String] = []  # IDs de logros desbloqueados
@export var achievement_progress: Dictionary = {}  # Progreso de achievements
@export var lifetime_stats: Dictionary = {}  # Estadísticas de por vida para achievements

# T018/T030 - Sistema de Misiones Diarias y Semanales
@export var active_missions: Dictionary = {}  # Misiones diarias activas
@export var active_weekly_missions: Dictionary = {}  # T030 - Misiones semanales activas
@export var last_mission_reset: int = 0  # Timestamp del último reset diario
@export var last_weekly_mission_reset: int = 0  # T030 - Timestamp del último reset semanal

## Estado del tutorial y sistemas
@export var tutorial_completed: bool = false
@export var first_generator_bought: bool = false
@export var customer_system_unlocked: bool = true  # HABILITADO PARA PRUEBAS

## Recursos disponibles
@export var resources: Dictionary = {"barley": 0, "hops": 0, "water": 0, "yeast": 0}

## Límites máximos de recursos (capacidad de almacenamiento)
@export var resource_limits: Dictionary = {"barley": 100, "hops": 100, "water": 50, "yeast": 25}

## Productos fabricados
@export var products: Dictionary = GameConfig.get_default_products()

## Generadores poseídos
@export var generators: Dictionary = GameConfig.get_default_generators()

## Estaciones de producción
@export var stations: Dictionary = GameConfig.get_default_stations()

## Sistema de ofertas automáticas para clientes
@export var offers: Dictionary = {
	"brewery": {"enabled": false, "price_multiplier": 1.0},  # Multiplicador del precio base
	"bar_station": {"enabled": false, "price_multiplier": 1.0}
}

## Sistema de upgrades
@export var upgrades: Dictionary = {
	"auto_sell_enabled": false,
	"auto_sell_speed": 1.0,
	"auto_sell_efficiency": 1.0,
	"manager_level": 0,
	"faster_customers": false,
	"premium_customers": false,
	"bulk_buyers": false
}

## Hitos desbloqueados
@export var milestones: Dictionary = {"generators": {}, "stations": {}}

## Estadísticas del juego
@export var statistics: Dictionary = {
	"total_money_earned": 0.0,
	"products_sold": 0,
	"customers_served": 0,
	"resources_generated": 0,
	"products_crafted": 0,
	"autosell_earnings": 0.0,
	# T018 - Estadísticas adicionales para misiones
	"total_resources_generated": 0,
	"manual_sales_money": 0.0,
	"offers_activated": 0,
	"products_produced": 0,
	"generators_purchased": 0,
	"stations_purchased": 0
}


## Validar integridad de datos
func validate() -> bool:
	return money >= 0.0 and resources.size() > 0


## Obtener datos como diccionario (compatibilidad legacy)
func to_dict() -> Dictionary:
	return {
		"money": money,
		"tokens": tokens,  # NUEVO - tokens de clientes/misiones
		"gems": gems,  # NUEVO - diamantes premium
		"customer_system_unlocked": customer_system_unlocked,  # NUEVO
		# T013 - Sistema de Prestigio
		"prestige_stars": prestige_stars,
		"prestige_count": prestige_count,
		"active_star_bonuses": active_star_bonuses.duplicate(),
		"total_cash_earned": total_cash_earned,
		# T017 - Sistema de Logros
		"unlocked_achievements": unlocked_achievements.duplicate(),
		"achievement_progress": achievement_progress.duplicate(),
		"lifetime_stats": lifetime_stats.duplicate(),
		# T018/T030 - Sistema de Misiones Diarias y Semanales
		"active_missions": active_missions.duplicate(true),
		"active_weekly_missions": active_weekly_missions.duplicate(true),
		"last_mission_reset": last_mission_reset,
		"last_weekly_mission_reset": last_weekly_mission_reset,
		# Datos del juego
		"resources": resources,
		"products": products,
		"generators": generators,
		"stations": stations,
		"offers": offers,
		"upgrades": upgrades,
		"milestones": milestones,
		"statistics": statistics,
		# T031 - Sistema de Desbloqueos Progresivos
		"unlock_data": _get_unlock_manager_data()  # Se llenará por UnlockManager
	}


## Cargar desde diccionario
func from_dict(data: Dictionary) -> void:
	money = data["money"] if data.has("money") else 50.0
	tokens = data["tokens"] if data.has("tokens") else 0  # NUEVO - backward compatibility
	gems = data["gems"] if data.has("gems") else 100  # NUEVO - backward compatibility
	customer_system_unlocked = (
		data["customer_system_unlocked"] if data.has("customer_system_unlocked") else false
	)  # NUEVO
	# T013 - Sistema de Prestigio
	prestige_stars = data["prestige_stars"] if data.has("prestige_stars") else 0
	prestige_count = data["prestige_count"] if data.has("prestige_count") else 0
	active_star_bonuses = data["active_star_bonuses"] if data.has("active_star_bonuses") else []
	total_cash_earned = data["total_cash_earned"] if data.has("total_cash_earned") else 0.0
	# T017 - Sistema de Logros
	unlocked_achievements = (
		data["unlocked_achievements"] if data.has("unlocked_achievements") else []
	)
	achievement_progress = data["achievement_progress"] if data.has("achievement_progress") else {}
	lifetime_stats = data["lifetime_stats"] if data.has("lifetime_stats") else {}
	# T018/T030 - Sistema de Misiones Diarias y Semanales
	active_missions = data["active_missions"] if data.has("active_missions") else {}
	active_weekly_missions = (
		data["active_weekly_missions"] if data.has("active_weekly_missions") else {}
	)
	last_mission_reset = data["last_mission_reset"] if data.has("last_mission_reset") else 0
	last_weekly_mission_reset = (
		data["last_weekly_mission_reset"] if data.has("last_weekly_mission_reset") else 0
	)
	# Datos del juego
	resources = data["resources"] if data.has("resources") else resources
	products = data["products"] if data.has("products") else products
	generators = data["generators"] if data.has("generators") else generators
	stations = data["stations"] if data.has("stations") else stations
	offers = data["offers"] if data.has("offers") else offers
	upgrades = data["upgrades"] if data.has("upgrades") else upgrades
	milestones = data["milestones"] if data.has("milestones") else milestones
	statistics = data["statistics"] if data.has("statistics") else statistics

	# T031 - Sistema de Desbloqueos Progresivos (carga diferida)
	unlock_data = data["unlock_data"] if data.has("unlock_data") else {}


## === T031 - UNLOCK MANAGER INTEGRATION ===

# Variable para almacenar los datos de unlock temporal
var unlock_data: Dictionary = {}


func _get_unlock_manager_data() -> Dictionary:
	"""Obtiene los datos del UnlockManager para guardado"""
	# GameData es Resource, no puede acceder al árbol de nodos directamente
	return unlock_data  # Usar datos almacenados


func load_unlock_data_to_manager():
	"""Carga los datos de desbloqueos al UnlockManager"""
	# Esta función será llamada desde GameController que tiene acceso al árbol
	print("🔓 Datos de desbloqueos disponibles para cargar")


## === CURRENCY METHODS - Refactorizado desde CurrencyManager ===


## Métodos para CASH (💵) - Gameplay principal con tracking de prestigio
func add_money(amount: float) -> void:
	money += amount
	total_cash_earned += amount  # T013 - Para cálculo de prestige stars
	statistics["total_money_earned"] += amount
	print(
		(
			"💰 Cash añadido: $%.2f | Total: $%.2f | Histórico: $%.2f"
			% [amount, money, total_cash_earned]
		)
	)


func spend_money(amount: float) -> bool:
	if money >= amount:
		money -= amount
		return true
	return false


func can_afford_money(amount: float) -> bool:
	return money >= amount


## Métodos para TOKENS (🪙) - Clientes automáticos
func add_tokens(amount: int) -> void:
	tokens += amount


func spend_tokens(amount: int) -> bool:
	if tokens >= amount:
		tokens -= amount
		return true
	return false


func can_afford_tokens(amount: int) -> bool:
	return tokens >= amount


## Métodos para GEMS (💎) - Currency premium
func add_gems(amount: int) -> void:
	gems += amount


func spend_gems(amount: int) -> bool:
	if gems >= amount:
		gems -= amount
		return true
	return false


func can_afford_gems(amount: int) -> bool:
	return gems >= amount


## Formateo para UI
func format_money() -> String:
	if money < 1000:
		return "%.1f" % money
	elif money < 1000000:
		return "%.1fK" % (money / 1000.0)
	elif money < 1000000000:
		return "%.1fM" % (money / 1000000.0)
	else:
		return "%.1fB" % (money / 1000000000.0)


func format_tokens() -> String:
	if tokens < 1000:
		return str(tokens)
	elif tokens < 1000000:
		return "%.1fK" % (tokens / 1000.0)
	else:
		return "%.1fM" % (tokens / 1000000.0)


func format_gems() -> String:
	return str(gems)  # Gems siempre número exacto
