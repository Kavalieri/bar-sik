# =============================================================================
# T017 - ACHIEVEMENT MANAGER SYSTEM
# =============================================================================
# Sistema completo de logros con rewards automáticos y progression tracking
# Fecha: 22 Agosto 2025
# Estado: 🔄 EN DESARROLLO

extends Node
class_name AchievementManager

# =============================================================================
# SIGNALS
# =============================================================================

signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)
signal achievement_progress_updated(achievement_id: String, current: int, required: int)
signal reward_granted(reward_type: String, amount: int)

# =============================================================================
# CONSTANTS
# =============================================================================

const ACHIEVEMENT_SAVE_KEY = "achievements_data"
const NOTIFICATION_DURATION = 3.0

# =============================================================================
# VARIABLES
# =============================================================================

var game_data: GameData
var unlocked_achievements: Array[String] = []
var achievement_progress: Dictionary = {}

# Tracking variables para condiciones
var session_start_time: float = 0.0
var last_save_time: float = 0.0

# =============================================================================
# ACHIEVEMENT DEFINITIONS
# =============================================================================

var achievement_definitions: Dictionary = {
	# BÁSICOS - First Steps (5-15 rewards)
	"first_sale":
	{
		"name": "Primera Venta",
		"description": "Vende tu primera cerveza",
		"icon": "🍺",
		"category": "basic",
		"reward": {"tokens": 5},
		"condition_type": "stat_threshold",
		"condition": {"stat": "products_sold", "threshold": 1}
	},
	"unlock_customers":
	{
		"name": "Cliente VIP",
		"description": "Desbloquea el sistema de clientes automáticos",
		"icon": "👥",
		"category": "basic",
		"reward": {"tokens": 25, "gems": 5},
		"condition_type": "boolean_flag",
		"condition": {"flag": "customer_system_unlocked"}
	},
	"first_generator":
	{
		"name": "Empresario Novato",
		"description": "Compra tu primer generador",
		"icon": "🏭",
		"category": "basic",
		"reward": {"tokens": 10},
		"condition_type": "generator_owned",
		"condition": {"any_generator": true}
	},
	"money_milestone_1k":
	{
		"name": "Primeros Ahorros",
		"description": "Acumula $1,000",
		"icon": "💰",
		"category": "basic",
		"reward": {"tokens": 15},
		"condition_type": "stat_threshold",
		"condition": {"stat": "money", "threshold": 1000.0}
	},
	"production_starter":
	{
		"name": "Maestro Cervecero",
		"description": "Produce 10 cervezas",
		"icon": "⚗️",
		"category": "basic",
		"reward": {"tokens": 20},
		"condition_type": "stat_threshold",
		"condition": {"stat": "products_crafted", "threshold": 10}
	},
	# PROGRESIÓN - Mid Game (20-50 rewards)
	"money_milestone_10k":
	{
		"name": "Pequeño Empresario",
		"description": "Acumula $10,000",
		"icon": "💎",
		"category": "progression",
		"reward": {"tokens": 30, "gems": 10},
		"condition_type": "stat_threshold",
		"condition": {"stat": "money", "threshold": 10000.0}
	},
	"customer_master":
	{
		"name": "Rey del Servicio",
		"description": "Sirve 100 clientes automáticos",
		"icon": "🤴",
		"category": "progression",
		"reward": {"tokens": 50, "gems": 15},
		"condition_type": "stat_threshold",
		"condition": {"stat": "customers_served", "threshold": 100}
	},
	"sales_expert":
	{
		"name": "Vendedor Experto",
		"description": "Realiza 500 ventas manuales",
		"icon": "🎯",
		"category": "progression",
		"reward": {"tokens": 40, "gems": 12},
		"condition_type": "stat_threshold",
		"condition": {"stat": "products_sold", "threshold": 500}
	},
	"generator_collector":
	{
		"name": "Coleccionista Industrial",
		"description": "Posee al menos 5 de cada generador",
		"icon": "🏗️",
		"category": "progression",
		"reward": {"tokens": 60, "gems": 20},
		"condition_type": "generators_each_min",
		"condition": {"min_each": 5}
	},
	"upgrade_enthusiast":
	{
		"name": "Tecnólogo Avanzado",
		"description": "Compra 5 upgrades diferentes",
		"icon": "⚙️",
		"category": "progression",
		"reward": {"tokens": 45, "gems": 18},
		"condition_type": "upgrades_count",
		"condition": {"count": 5}
	},
	# AVANZADOS - Late Game (50-100 rewards)
	"money_milestone_100k":
	{
		"name": "Magnate Cervecero",
		"description": "Acumula $100,000",
		"icon": "🏦",
		"category": "advanced",
		"reward": {"tokens": 100, "gems": 30},
		"condition_type": "stat_threshold",
		"condition": {"stat": "money", "threshold": 100000.0}
	},
	"prestige_master":
	{
		"name": "Leyenda del Prestigio",
		"description": "Realiza tu primer prestigio",
		"icon": "⭐",
		"category": "advanced",
		"reward": {"tokens": 150, "gems": 50},
		"condition_type": "stat_threshold",
		"condition": {"stat": "prestige_count", "threshold": 1}
	},
	"star_collector":
	{
		"name": "Cazador de Estrellas",
		"description": "Acumula 10 estrellas de prestigio",
		"icon": "🌟",
		"category": "advanced",
		"reward": {"tokens": 200, "gems": 75},
		"condition_type": "stat_threshold",
		"condition": {"stat": "prestige_stars", "threshold": 10}
	},
	"automation_lord":
	{
		"name": "Señor de la Automatización",
		"description": "Tiene 10 clientes automáticos activos",
		"icon": "🤖",
		"category": "advanced",
		"reward": {"tokens": 120, "gems": 40},
		"condition_type": "customer_count",
		"condition": {"count": 10}
	},
	"millionaire":
	{
		"name": "Millonario",
		"description": "Acumula $1,000,000",
		"icon": "💰",
		"category": "advanced",
		"reward": {"tokens": 300, "gems": 100},
		"condition_type": "stat_threshold",
		"condition": {"stat": "money", "threshold": 1000000.0}
	},
	# SECRETOS - Hidden Achievements (100+ rewards)
	"speed_demon":
	{
		"name": "Demonio de la Velocidad",
		"description": "Vende 100 productos en menos de 5 minutos",
		"icon": "⚡",
		"category": "secret",
		"reward": {"tokens": 500, "gems": 150},
		"condition_type": "speed_challenge",
		"condition": {"products": 100, "time_limit": 300.0}
	},
	"night_owl":
	{
		"name": "Búho Nocturno",
		"description": "Juega después de medianoche",
		"icon": "🦉",
		"category": "secret",
		"reward": {"tokens": 200, "gems": 50},
		"condition_type": "time_based",
		"condition": {"hour_range": [0, 6]}
	},
	"lucky_seven":
	{
		"name": "Siete de la Suerte",
		"description": "Ten exactamente $7,777",
		"icon": "🍀",
		"category": "secret",
		"reward": {"tokens": 777, "gems": 77},
		"condition_type": "exact_value",
		"condition": {"stat": "money", "value": 7777.0}
	},
	"hoarder":
	{
		"name": "Acumulador",
		"description": "Ten 1000+ de cada recurso simultáneamente",
		"icon": "📦",
		"category": "secret",
		"reward": {"tokens": 400, "gems": 120},
		"condition_type": "resources_min_all",
		"condition": {"min_each": 1000}
	},
	"perfectionist":
	{
		"name": "Perfeccionista",
		"description": "Completa 20 logros en una sola sesión",
		"icon": "🏆",
		"category": "secret",
		"reward": {"tokens": 1000, "gems": 300},
		"condition_type": "session_achievements",
		"condition": {"count": 20}
	}
}

# =============================================================================
# INITIALIZATION
# =============================================================================


func _ready():
	"""Inicialización del AchievementManager"""
	print("🏆 AchievementManager inicializando...")

	session_start_time = Time.get_ticks_msec() / 1000.0
	last_save_time = session_start_time

	# Conectar a GameEvents si está disponible
	call_deferred("_connect_to_events")

	print("✅ AchievementManager inicializado con %d logros" % achievement_definitions.size())


func _connect_to_events():
	"""Conectar a eventos del juego"""
	if has_node("/root/GameEvents"):
		GameEvents.money_changed.connect(_on_money_changed)
		GameEvents.product_sold.connect(_on_product_sold)
		GameEvents.customer_served.connect(_on_customer_served)
		print("🔗 AchievementManager conectado a GameEvents")


func set_game_data(data: GameData):
	"""Configurar referencia a GameData"""
	game_data = data
	_load_achievement_data()
	print("📊 GameData configurado en AchievementManager")


# =============================================================================
# SAVE/LOAD SYSTEM
# =============================================================================


func _load_achievement_data():
	"""Cargar datos de logros desde GameData"""
	if not game_data:
		return

	var save_dict = game_data.to_dict()
	if save_dict.has(ACHIEVEMENT_SAVE_KEY):
		var achievement_data = save_dict[ACHIEVEMENT_SAVE_KEY]
		unlocked_achievements = achievement_data.get("unlocked", [])
		achievement_progress = achievement_data.get("progress", {})
		print("📚 Cargados %d logros desbloqueados" % unlocked_achievements.size())


func _save_achievement_data():
	"""Guardar datos de logros en GameData"""
	if not game_data:
		return

	# Agregar datos a GameData (extendemos el sistema existente)
	var save_dict = game_data.to_dict()
	save_dict[ACHIEVEMENT_SAVE_KEY] = {
		"unlocked": unlocked_achievements.duplicate(), "progress": achievement_progress.duplicate()
	}

	# Usar el método from_dict para actualizar GameData
	game_data.from_dict(save_dict)


# =============================================================================
# ACHIEVEMENT CHECKING SYSTEM
# =============================================================================


func check_all_achievements():
	"""Verificar todos los logros no desbloqueados"""
	if not game_data:
		return

	for achievement_id in achievement_definitions.keys():
		if not is_achievement_unlocked(achievement_id):
			check_achievement(achievement_id)


func check_achievement(achievement_id: String) -> bool:
	"""Verificar un logro específico"""
	if is_achievement_unlocked(achievement_id):
		return true

	var achievement = achievement_definitions.get(achievement_id)
	if not achievement:
		return false

	var condition_met = _evaluate_condition(achievement.condition_type, achievement.condition)

	if condition_met:
		_unlock_achievement(achievement_id)
		return true
	else:
		_update_achievement_progress(achievement_id, achievement)

	return false


func _evaluate_condition(condition_type: String, condition: Dictionary) -> bool:
	"""Evaluar una condición específica"""
	if not game_data:
		return false

	match condition_type:
		"stat_threshold":
			var stat_value = game_data.statistics.get(condition.stat, 0)
			if condition.stat == "money":
				stat_value = game_data.money
			elif condition.stat == "prestige_count":
				stat_value = game_data.prestige_count
			elif condition.stat == "prestige_stars":
				stat_value = game_data.prestige_stars
			return stat_value >= condition.threshold

		"boolean_flag":
			return game_data.get(condition.flag, false)

		"generator_owned":
			if condition.get("any_generator", false):
				for generator_id in game_data.generators:
					if game_data.generators[generator_id] > 0:
						return true
			return false

		"generators_each_min":
			var min_each = condition.min_each
			for generator_id in game_data.generators:
				if game_data.generators[generator_id] < min_each:
					return false
			return true

		"upgrades_count":
			var upgrade_count = 0
			for upgrade_key in game_data.upgrades:
				if game_data.upgrades[upgrade_key] == true:
					upgrade_count += 1
			return upgrade_count >= condition.count

		"exact_value":
			var stat_value = game_data.statistics.get(condition.stat, 0)
			if condition.stat == "money":
				stat_value = game_data.money
			return abs(stat_value - condition.value) < 0.01

		"time_based":
			var current_hour = Time.get_datetime_dict_from_system().hour
			var hour_range = condition.hour_range
			return current_hour >= hour_range[0] and current_hour <= hour_range[1]

		"resources_min_all":
			var min_each = condition.min_each
			for resource_name in game_data.resources:
				if game_data.resources[resource_name] < min_each:
					return false
			return true

		"customer_count":
			# Necesitaríamos acceso al CustomerManager para esto
			# Por simplicidad, usamos un upgrade como proxy
			return (
				game_data.upgrades.get("customer_system_unlocked", false) and condition.count <= 10
			)

		"speed_challenge", "session_achievements":
			# Estos requerirían tracking más complejo, simplificamos por ahora
			return false

	return false


func _update_achievement_progress(achievement_id: String, achievement: Dictionary):
	"""Actualizar progreso de un logro"""
	var condition_type = achievement.condition_type
	var condition = achievement.condition
	var current_value = 0
	var required_value = 0

	match condition_type:
		"stat_threshold":
			current_value = game_data.statistics.get(condition.stat, 0)
			if condition.stat == "money":
				current_value = int(game_data.money)
			elif condition.stat == "prestige_count":
				current_value = game_data.prestige_count
			elif condition.stat == "prestige_stars":
				current_value = game_data.prestige_stars
			required_value = condition.threshold

		"generators_each_min":
			# Encontrar el generador con menos cantidad
			var min_owned = 999999
			for generator_id in game_data.generators:
				if game_data.generators[generator_id] < min_owned:
					min_owned = game_data.generators[generator_id]
			current_value = min_owned
			required_value = condition.min_each

	if required_value > 0:
		achievement_progress[achievement_id] = {
			"current": current_value,
			"required": required_value,
			"percentage": min(100.0, (float(current_value) / float(required_value)) * 100.0)
		}

		achievement_progress_updated.emit(achievement_id, current_value, required_value)


func _unlock_achievement(achievement_id: String):
	"""Desbloquear un logro y otorgar recompensas"""
	if is_achievement_unlocked(achievement_id):
		return

	var achievement = achievement_definitions[achievement_id]
	unlocked_achievements.append(achievement_id)

	# Otorgar recompensas
	_grant_rewards(achievement.reward)

	# Guardar progreso
	_save_achievement_data()

	# Emitir señal
	achievement_unlocked.emit(achievement_id, achievement)

	print("🏆 LOGRO DESBLOQUEADO: %s - %s" % [achievement.name, achievement.description])


func _grant_rewards(reward: Dictionary):
	"""Otorgar recompensas de un logro"""
	if not game_data:
		return

	for reward_type in reward:
		var amount = reward[reward_type]

		match reward_type:
			"tokens":
				game_data.add_tokens(amount)
				reward_granted.emit("tokens", amount)
				print("🪙 +%d tokens por logro" % amount)

			"gems":
				game_data.add_gems(amount)
				reward_granted.emit("gems", amount)
				print("💎 +%d gems por logro" % amount)


# =============================================================================
# PUBLIC API
# =============================================================================


func is_achievement_unlocked(achievement_id: String) -> bool:
	"""Verificar si un logro está desbloqueado"""
	return achievement_id in unlocked_achievements


func get_achievement_info(achievement_id: String) -> Dictionary:
	"""Obtener información completa de un logro"""
	if not achievement_definitions.has(achievement_id):
		return {}

	var achievement = achievement_definitions[achievement_id].duplicate()
	achievement["id"] = achievement_id
	achievement["unlocked"] = is_achievement_unlocked(achievement_id)
	achievement["progress"] = achievement_progress.get(achievement_id, {})

	return achievement


func get_achievements_by_category(category: String) -> Array:
	"""Obtener todos los logros de una categoría"""
	var filtered_achievements = []

	for achievement_id in achievement_definitions:
		var achievement = achievement_definitions[achievement_id]
		if achievement.category == category:
			filtered_achievements.append(get_achievement_info(achievement_id))

	return filtered_achievements


func get_unlocked_count() -> int:
	"""Obtener cantidad de logros desbloqueados"""
	return unlocked_achievements.size()


func get_total_count() -> int:
	"""Obtener cantidad total de logros"""
	return achievement_definitions.size()


func get_completion_percentage() -> float:
	"""Obtener porcentaje de completitud"""
	return (float(get_unlocked_count()) / float(get_total_count())) * 100.0


# =============================================================================
# EVENT HANDLERS
# =============================================================================


func _on_money_changed(new_amount: float):
	"""Manejar cambio de dinero"""
	check_achievement("money_milestone_1k")
	check_achievement("money_milestone_10k")
	check_achievement("money_milestone_100k")
	check_achievement("millionaire")
	check_achievement("lucky_seven")


func _on_product_sold(product_name: String, amount: int):
	"""Manejar venta de producto"""
	check_achievement("first_sale")
	check_achievement("sales_expert")


func _on_customer_served():
	"""Manejar cliente servido"""
	check_achievement("customer_master")


# =============================================================================
# UPDATE SYSTEM
# =============================================================================


func _process(delta):
	"""Update continuo para verificar condiciones"""
	# Solo verificar cada 2 segundos para no sobrecargar
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_save_time > 2.0:
		check_all_achievements()
		last_save_time = current_time


# =============================================================================
# UI HELPER FUNCTIONS - T019
# =============================================================================


func get_filtered_achievements(filter_mode: String = "all") -> Dictionary:
	"""Obtener logros filtrados para UI"""
	var filtered_achievements = {}

	for achievement_id in achievement_definitions:
		var achievement_data = achievement_definitions[achievement_id].duplicate()
		var is_unlocked = is_achievement_unlocked(achievement_id)

		# Agregar información de estado
		achievement_data["id"] = achievement_id
		achievement_data["unlocked"] = is_unlocked

		# Agregar progreso
		if achievement_progress.has(achievement_id):
			achievement_data["progress"] = achievement_progress[achievement_id].percentage
		else:
			achievement_data["progress"] = 0.0 if not is_unlocked else 100.0

		# Filtrar según modo
		match filter_mode:
			"completed":
				if is_unlocked:
					filtered_achievements[achievement_id] = achievement_data
			"pending":
				if not is_unlocked:
					filtered_achievements[achievement_id] = achievement_data
			"all", _:
				filtered_achievements[achievement_id] = achievement_data

	return filtered_achievements


func get_total_achievements() -> int:
	"""Obtener número total de logros"""
	return achievement_definitions.size()


func get_unlocked_count() -> int:
	"""Obtener número de logros desbloqueados"""
	if not game_data:
		return 0
	return game_data.unlocked_achievements.size()


func get_achievement_by_category(category: String) -> Dictionary:
	"""Obtener logros de una categoría específica"""
	var category_achievements = {}

	for achievement_id in achievement_definitions:
		var achievement = achievement_definitions[achievement_id]
		if achievement.category == category:
			category_achievements[achievement_id] = achievement

	return category_achievements

# EOF - AchievementManager.gd
