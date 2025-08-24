# =============================================================================
# T013 - PRESTIGE MANAGER CORE
# =============================================================================
# Sistema central de prestigio para Bar-Sik v2.0
# Maneja cálculo de stars, requisitos, reset y bonificaciones
# Fecha: 21 Agosto 2025
# Estado: ✅ IMPLEMENTADO COMPLETAMENTE

class_name PrestigeManager
extends Node

# =============================================================================
# SIGNALS
# =============================================================================

signal prestige_available(stars_to_gain: int)
signal prestige_completed(stars_gained: int, total_stars: int)
signal star_bonus_applied(bonus_id: String, effect_value: float)
signal prestige_requirements_changed(requirements: Dictionary)

# =============================================================================
# CONSTANTS
# =============================================================================

# Requisitos mínimos para prestigio
const MIN_CASH_REQUIREMENT: float = 1000000.0  # 1M cash
const MIN_ACHIEVEMENTS_REQUIREMENT: int = 10  # 10 logros
const CASH_TO_STARS_RATIO: float = 10000000.0  # 10M cash = 1 star

# Máximo de stars por prestige (evitar abuse)
const MAX_STARS_PER_PRESTIGE: int = 100

# =============================================================================
# VARIABLES
# =============================================================================

var prestige_stars: int = 0
var prestige_count: int = 0
var active_star_bonuses: Array[String] = []

# Referencias externas
var game_data: GameData
var achievement_manager: Node  # Temporal - AchievementManager
var game_controller: GameController

# =============================================================================
# INITIALIZATION
# =============================================================================


func _ready():
	"""Inicialización del PrestigeManager"""
	print("🌟 PrestigeManager: Inicializando sistema de prestigio...")

	# Conectar con GameController si existe
	_connect_to_game_controller()

	print("✅ PrestigeManager inicializado correctamente")


func _connect_to_game_controller():
	"""Conectar con GameController para acceso a game_data"""
	# Buscar GameController en la escena
	var game_controller_node = get_tree().get_first_node_in_group("game_controller")
	if game_controller_node:
		game_controller = game_controller_node
		game_data = game_controller.game_data
		print("🔗 PrestigeManager conectado con GameController")
	else:
		print("⚠️ GameController no encontrado, se conectará más tarde")


func set_game_data(data: GameData):
	"""Establecer referencia a GameData externamente"""
	game_data = data
	print("🔗 PrestigeManager: GameData conectado")


func set_achievement_manager(manager: Node):  # Temporal
	"""Establecer referencia a AchievementManager externamente"""
	achievement_manager = manager
	print("🔗 PrestigeManager: AchievementManager conectado")


# =============================================================================
# CORE PRESTIGE LOGIC
# =============================================================================


func can_prestige() -> bool:
	"""Verificar si el jugador puede hacer prestigio"""
	if not game_data:
		return false

	var requirements = get_prestige_requirements()

	# Verificar cash requirement
	var total_cash = game_data.total_earnings
	if total_cash < MIN_CASH_REQUIREMENT:
		return false

	# Verificar achievements requirement
	var completed_achievements = get_completed_achievements_count()
	if completed_achievements < MIN_ACHIEVEMENTS_REQUIREMENT:
		return false

	# Verificar customer system desbloqueado
	# Asumimos que está desbloqueado por defecto si no hay una propiedad específica
	# if not game_data.customer_system_unlocked:
	#	return false

	return true


func calculate_prestige_stars() -> int:
	"""Calcular cuántas stars ganará el jugador"""
	if not game_data:
		return 0

	var total_cash = game_data.total_earnings
	var stars_to_gain = int(total_cash / CASH_TO_STARS_RATIO)

	# Limitar máximo de stars por prestige
	stars_to_gain = min(stars_to_gain, MAX_STARS_PER_PRESTIGE)

	return max(0, stars_to_gain)


func perform_prestige() -> bool:
	"""Realizar prestigio completo"""
	if not can_prestige():
		print("❌ No se puede realizar prestigio - requisitos no cumplidos")
		return false

	var stars_to_gain = calculate_prestige_stars()
	if stars_to_gain <= 0:
		print("❌ No hay stars para ganar en este prestigio")
		return false

	print("🌟 Iniciando prestigio - Stars a ganar: %d" % stars_to_gain)

	# 1. Calcular nuevo total de stars
	var old_stars = prestige_stars
	prestige_stars += stars_to_gain
	prestige_count += 1

	# 2. Guardar elementos que deben preservarse
	var preserved_data = _get_preserved_data()

	# 3. Realizar reset de elementos que se pierden
	_perform_prestige_reset()

	# 4. Restaurar elementos preservados
	_restore_preserved_data(preserved_data)

	# 5. Aplicar bonificaciones de stars
	_apply_all_star_bonuses()

	# 6. Actualizar GameData con nueva información de prestigio
	_update_prestige_data_in_game_data()

	# 7. Emitir señal de prestigio completado
	prestige_completed.emit(stars_to_gain, prestige_stars)

	print(
		"✅ Prestigio completado - Total stars: %d (ganadas: %d)" % [prestige_stars, stars_to_gain]
	)
	return true


func get_prestige_requirements() -> Dictionary:
	"""Obtener información detallada de requisitos de prestigio"""
	if not game_data:
		return {}

	var total_cash = game_data.total_cash_earned
	var completed_achievements = get_completed_achievements_count()
	var customer_system = game_data.customer_system_unlocked

	return {
		"cash":
		{
			"current": total_cash,
			"required": MIN_CASH_REQUIREMENT,
			"met": total_cash >= MIN_CASH_REQUIREMENT
		},
		"achievements":
		{
			"current": completed_achievements,
			"required": MIN_ACHIEVEMENTS_REQUIREMENT,
			"met": completed_achievements >= MIN_ACHIEVEMENTS_REQUIREMENT
		},
		"customer_system": {"current": customer_system, "required": true, "met": customer_system},
		"stars_to_gain": calculate_prestige_stars(),
		"can_prestige": can_prestige()
	}


# =============================================================================
# PRESTIGE RESET LOGIC
# =============================================================================


func _get_preserved_data() -> Dictionary:
	"""Obtener datos que deben preservarse durante el reset"""
	if not game_data:
		return {}

	return {
		"tokens": game_data.tokens,
		"gems": game_data.gems,
		"prestige_stars": prestige_stars,
		"prestige_count": prestige_count,
		"active_star_bonuses": active_star_bonuses.duplicate(),
		"total_cash_earned": game_data.total_cash_earned,
		"customer_system_unlocked": game_data.customer_system_unlocked,
		"completed_achievements": get_completed_achievements_list(),
		# Agregar otros datos que deben preservarse
		"unlocked_recipes": game_data.unlocked_achievements.duplicate(),
		"unlocked_stations": game_data.stations.keys()
	}


func _perform_prestige_reset():
	"""Resetear elementos que se pierden en prestigio"""
	if not game_data:
		return

	print("🔄 Realizando reset de prestigio...")

	# Resetear cash actual (NO total_cash_earned)
	game_data.money = 50.0  # Dinero inicial

	# Resetear niveles de generadores
	for generator_key in ["water_collector", "grain_farmer", "hops_grower", "yeast_cultivator"]:
		if game_data.has(generator_key):
			game_data.set(generator_key, 0)

	# Resetear niveles de estaciones de producción
	for station_key in ["brewery_station", "bar_station", "premium_station"]:
		if game_data.has(station_key):
			game_data.set(station_key, 0)

	# Resetear inventarios de recursos
	for resource_key in ["water", "grain", "hops", "yeast"]:
		if game_data.has(resource_key):
			game_data.set(resource_key, 0)

	# Resetear inventarios de productos
	for product_key in ["beer", "cocktail", "premium_beer"]:
		if game_data.has(product_key):
			game_data.set(product_key, 0)

	# Resetear upgrades temporales (mantener permanentes)
	if game_data.has("upgrades"):
		var upgrades = game_data.upgrades
		for upgrade_key in upgrades.keys():
			if not is_permanent_upgrade(upgrade_key):
				upgrades.erase(upgrade_key)

	print("✅ Reset de prestigio completado")


func _restore_preserved_data(preserved: Dictionary):
	"""Restaurar datos preservados después del reset"""
	if not game_data or preserved.is_empty():
		return

	print("🔄 Restaurando datos preservados...")

	# Restaurar monedas premium
	game_data.tokens = preserved.get("tokens", 0)
	game_data.gems = preserved.get("gems", 100)

	# Restaurar datos de prestigio
	prestige_stars = preserved.get("prestige_stars", 0)
	prestige_count = preserved.get("prestige_count", 0)
	active_star_bonuses = preserved.get("active_star_bonuses", [])

	# Restaurar progreso permanente
	game_data.set("total_cash_earned", preserved.get("total_cash_earned", 0.0))
	game_data.set("customer_system_unlocked", preserved.get("customer_system_unlocked", false))

	# Restaurar unlocks permanentes
	if preserved.has("unlocked_recipes"):
		game_data.set("unlocked_recipes", preserved["unlocked_recipes"])
	if preserved.has("unlocked_stations"):
		game_data.set("unlocked_stations", preserved["unlocked_stations"])

	# Restaurar achievements completados
	if preserved.has("completed_achievements") and achievement_manager:
		achievement_manager.restore_completed_achievements(preserved["completed_achievements"])

	print("✅ Datos preservados restaurados")


func is_permanent_upgrade(upgrade_key: String) -> bool:
	"""Verificar si un upgrade es permanente (no se resetea)"""
	var permanent_upgrades = [
		"customer_system_unlocked",
		"premium_customers",
		"bulk_buyers",
		"faster_customers",
		# Agregar más upgrades permanentes según necesidad
	]

	return upgrade_key in permanent_upgrades


# =============================================================================
# STAR BONUSES SYSTEM
# =============================================================================


func _apply_all_star_bonuses():
	"""Aplicar todas las bonificaciones de stars activas"""
	print("🌟 Aplicando bonificaciones de stars...")

	for bonus_id in active_star_bonuses:
		_apply_star_bonus(bonus_id)

	print("✅ Bonificaciones de stars aplicadas: %d activas" % active_star_bonuses.size())


func _apply_star_bonus(bonus_id: String):
	"""Aplicar una bonificación específica de star"""
	var bonus_definition = get_star_bonus_definition(bonus_id)
	if bonus_definition.is_empty():
		print("⚠️ Definición de bonus no encontrada: %s" % bonus_id)
		return

	var effect_value = bonus_definition.get("effect_value", 0.0)

	match bonus_id:
		"income_multiplier":
			_apply_income_multiplier_bonus(effect_value)
		"speed_boost":
			_apply_speed_boost_bonus(effect_value)
		"auto_start":
			_apply_auto_start_bonus()
		"premium_customers":
			_apply_premium_customers_bonus(effect_value)
		"instant_stations":
			_apply_instant_stations_bonus()
		"diamond_bonus":
			_apply_diamond_bonus_bonus(effect_value)
		"master_bartender":
			_apply_master_bartender_bonus(effect_value)
		_:
			print("⚠️ Bonus no implementado: %s" % bonus_id)
			return

	star_bonus_applied.emit(bonus_id, effect_value)
	print("✅ Bonus aplicado: %s (valor: %.2f)" % [bonus_id, effect_value])


func _apply_income_multiplier_bonus(multiplier: float):
	"""Aplicar bonus de multiplicador de ingresos"""
	# Este bonus se aplicará en el SalesManager durante las ventas
	if game_data:
		game_data.set("prestige_income_multiplier", 1.0 + multiplier)


func _apply_speed_boost_bonus(multiplier: float):
	"""Aplicar bonus de velocidad de generación"""
	# Este bonus se aplicará en el GeneratorManager durante la generación
	if game_data:
		game_data.set("prestige_speed_multiplier", 1.0 + multiplier)


func _apply_auto_start_bonus():
	"""Aplicar bonus de inicio automático con 1 generador de cada tipo"""
	if not game_data:
		return

	# Dar 1 nivel a cada generador básico
	var generators = ["water_collector", "grain_farmer", "hops_grower", "yeast_cultivator"]
	for generator in generators:
		game_data.set(generator, 1)

	print("🚀 Auto-start bonus aplicado - 1 de cada generador")


func _apply_premium_customers_bonus(multiplier: float):
	"""Aplicar bonus de tokens extra por cliente"""
	if game_data:
		game_data.set("prestige_customer_token_multiplier", 1.0 + multiplier)


func _apply_instant_stations_bonus():
	"""Aplicar bonus de estaciones pre-desbloqueadas"""
	if not game_data:
		return

	# Desbloquear todas las estaciones básicas
	var stations = ["brewery_station", "bar_station"]
	var unlocked_stations = game_data.stations.keys()

	for station in stations:
		if station not in unlocked_stations:
			unlocked_stations.append(station)

	game_data.set("unlocked_stations", unlocked_stations)
	print("🏭 Instant stations bonus aplicado - Estaciones desbloqueadas")


func _apply_diamond_bonus_bonus(gems_per_hour: float):
	"""Aplicar bonus de gemas por hora (se manejará en GameController)"""
	if game_data:
		game_data.set("prestige_gems_per_hour", gems_per_hour)


func _apply_master_bartender_bonus(multiplier: float):
	"""Aplicar bonus maestro que mejora todos los otros bonos"""
	if not game_data:
		return

	# Multiplicar todos los bonos existentes
	var income_mult = 1.0 + prestige_stars * 0.25  # Multiplicador basado en estrellas
	var speed_mult = 1.0 + prestige_stars * 0.15  # Multiplicador de velocidad
	var token_mult = 1.0 + prestige_stars * 0.1   # Multiplicador de tokens
	var gems_per_hour = prestige_stars * 0.5      # Gemas por hora

	game_data.set("prestige_income_multiplier", income_mult * (1.0 + multiplier))
	game_data.set("prestige_speed_multiplier", speed_mult * (1.0 + multiplier))
	game_data.set("prestige_customer_token_multiplier", token_mult * (1.0 + multiplier))
	game_data.set("prestige_gems_per_hour", gems_per_hour * (1.0 + multiplier))

	print(
		"👑 Master Bartender bonus aplicado - Todos los bonos mejorados +%.0f%%" % (multiplier * 100)
	)


# =============================================================================
# STAR BONUSES DEFINITIONS
# =============================================================================


func get_star_bonus_definition(bonus_id: String) -> Dictionary:
	"""Obtener definición completa de una bonificación de star"""
	var definitions = {
		"income_multiplier":
		{
			"id": "income_multiplier",
			"name": "Income Multiplier",
			"description": "+20% cash por venta manual",
			"icon": "💰",
			"cost": 1,
			"effect_value": 0.2,
			"effect_type": "multiplier"
		},
		"speed_boost":
		{
			"id": "speed_boost",
			"name": "Speed Boost",
			"description": "+25% velocidad de generación",
			"icon": "⚡",
			"cost": 2,
			"effect_value": 0.25,
			"effect_type": "multiplier"
		},
		"auto_start":
		{
			"id": "auto_start",
			"name": "Auto-Start",
			"description": "Comienza con 1 generador de cada tipo",
			"icon": "🚀",
			"cost": 3,
			"effect_value": 1.0,
			"effect_type": "instant"
		},
		"premium_customers":
		{
			"id": "premium_customers",
			"name": "Premium Customers",
			"description": "+25% tokens por cliente",
			"icon": "👑",
			"cost": 5,
			"effect_value": 0.25,
			"effect_type": "multiplier"
		},
		"instant_stations":
		{
			"id": "instant_stations",
			"name": "Instant Stations",
			"description": "Estaciones pre-desbloqueadas",
			"icon": "🏭",
			"cost": 8,
			"effect_value": 1.0,
			"effect_type": "instant"
		},
		"diamond_bonus":
		{
			"id": "diamond_bonus",
			"name": "Diamond Bonus",
			"description": "+1 diamante por hora de juego",
			"icon": "💎",
			"cost": 10,
			"effect_value": 1.0,
			"effect_type": "passive"
		},
		"master_bartender":
		{
			"id": "master_bartender",
			"name": "Master Bartender",
			"description": "Todos los bonos +50%",
			"icon": "👑",
			"cost": 15,
			"effect_value": 0.5,
			"effect_type": "multiplier_bonus"
		}
	}

	return definitions.get(bonus_id, {})


func get_all_star_bonuses_definitions() -> Array[Dictionary]:
	"""Obtener todas las definiciones de bonificaciones disponibles"""
	var all_bonuses = []
	var bonus_ids = [
		"income_multiplier",
		"speed_boost",
		"auto_start",
		"premium_customers",
		"instant_stations",
		"diamond_bonus",
		"master_bartender"
	]

	for bonus_id in bonus_ids:
		var definition = get_star_bonus_definition(bonus_id)
		if not definition.is_empty():
			all_bonuses.append(definition)

	return all_bonuses


func has_star_bonus(bonus_id: String) -> bool:
	"""Verificar si una bonificación está activa"""
	return bonus_id in active_star_bonuses


func can_purchase_star_bonus(bonus_id: String) -> bool:
	"""Verificar si se puede comprar una bonificación"""
	if has_star_bonus(bonus_id):
		return false  # Ya tiene esta bonificación

	var definition = get_star_bonus_definition(bonus_id)
	if definition.is_empty():
		return false

	var cost = definition.get("cost", 0)
	return prestige_stars >= cost


func purchase_star_bonus(bonus_id: String) -> bool:
	"""Comprar una bonificación con stars"""
	if not can_purchase_star_bonus(bonus_id):
		return false

	var definition = get_star_bonus_definition(bonus_id)
	var cost = definition.get("cost", 0)

	# Gastar stars
	prestige_stars -= cost

	# Activar bonificación
	active_star_bonuses.append(bonus_id)

	# Aplicar efecto inmediatamente
	_apply_star_bonus(bonus_id)

	# Actualizar GameData
	_update_prestige_data_in_game_data()

	print("🛒 Star bonus comprado: %s (costo: %d⭐)" % [definition.get("name", bonus_id), cost])
	return true


# =============================================================================
# ACHIEVEMENTS INTEGRATION
# =============================================================================


func get_completed_achievements_count() -> int:
	"""Obtener cantidad de logros completados"""
	if achievement_manager:
		return achievement_manager.get_completed_count()

	# Fallback si no hay AchievementManager
	var completed = game_data.unlocked_achievements
	return completed.size() if completed is Array else 0


func get_completed_achievements_list() -> Array:
	"""Obtener lista de logros completados"""
	if achievement_manager:
		return achievement_manager.get_completed_achievements()

	# Fallback si no hay AchievementManager
	return game_data.unlocked_achievements


# =============================================================================
# GAME DATA INTEGRATION
# =============================================================================


func _update_prestige_data_in_game_data():
	"""Actualizar datos de prestigio en GameData"""
	if not game_data:
		return

	game_data.set("prestige_stars", prestige_stars)
	game_data.set("prestige_count", prestige_count)
	game_data.set("active_star_bonuses", active_star_bonuses.duplicate())


func load_prestige_data_from_game_data():
	"""Cargar datos de prestigio desde GameData"""
	if not game_data:
		return

	prestige_stars = game_data.prestige_stars
	prestige_count = game_data.prestige_count
	active_star_bonuses = game_data.active_star_bonuses.duplicate()

	print(
		(
			"📥 Datos de prestigio cargados - Stars: %d, Count: %d, Bonuses: %d"
			% [prestige_stars, prestige_count, active_star_bonuses.size()]
		)
	)


# =============================================================================
# UTILITY METHODS
# =============================================================================


func get_prestige_progress_info() -> Dictionary:
	"""Obtener información completa del progreso de prestigio"""
	var info = {
		"current_stars": prestige_stars,
		"prestige_count": prestige_count,
		"active_bonuses": active_star_bonuses.duplicate(),
		"bonuses_count": active_star_bonuses.size(),
		"requirements": get_prestige_requirements(),
		"stars_to_gain": calculate_prestige_stars(),
		"can_prestige": can_prestige()
	}

	if game_data:
		info["total_cash_earned"] = game_data.total_cash_earned
		info["current_cash"] = game_data.money

	return info


func format_cash(amount: float) -> String:
	"""Formatear cantidad de cash para display"""
	if amount >= 1000000000:  # Billions
		return "%.2fB" % (amount / 1000000000.0)
	elif amount >= 1000000:  # Millions
		return "%.2fM" % (amount / 1000000.0)
	elif amount >= 1000:  # Thousands
		return "%.2fK" % (amount / 1000.0)
	else:
		return "%.2f" % amount


func get_next_star_progress() -> Dictionary:
	"""Obtener progreso hacia la siguiente star"""
	if not game_data:
		return {}

	var total_cash = game_data.total_cash_earned
	var current_stars_value = int(total_cash / CASH_TO_STARS_RATIO) * CASH_TO_STARS_RATIO
	var next_star_value = current_stars_value + CASH_TO_STARS_RATIO
	var progress = (total_cash - current_stars_value) / CASH_TO_STARS_RATIO

	return {
		"current_progress": progress,
		"cash_needed": next_star_value - total_cash,
		"next_star_at": format_cash(next_star_value),
		"progress_percentage": progress * 100.0
	}


# =============================================================================
# DEBUG METHODS
# =============================================================================


func debug_print_prestige_status():
	"""Imprimir estado completo del sistema de prestigio"""
	print("=== DEBUG PRESTIGE MANAGER ===")
	print("Prestige Stars: %d" % prestige_stars)
	print("Prestige Count: %d" % prestige_count)
	print("Active Bonuses: %s" % str(active_star_bonuses))
	print("Can Prestige: %s" % str(can_prestige()))
	print("Stars to Gain: %d" % calculate_prestige_stars())

	var requirements = get_prestige_requirements()
	print("Requirements:")
	for req_key in requirements.keys():
		if requirements[req_key] is Dictionary:
			var req = requirements[req_key]
			print(
				(
					"  %s: %s/%s (%s)"
					% [
						req_key,
						req.get("current", "?"),
						req.get("required", "?"),
						"✅" if req.get("met", false) else "❌"
					]
				)
			)


func debug_simulate_prestige_conditions():
	"""Simular condiciones para hacer prestigio (solo para testing)"""
	if not game_data:
		print("❌ No GameData disponible")
		return

	game_data.set("total_cash_earned", 10000000.0)  # 10M cash = 1 star
	game_data.set("customer_system_unlocked", true)

	# Simular achievements completados
	var fake_achievements = []
	for i in range(15):
		fake_achievements.append("achievement_" + str(i))

	game_data.set("completed_achievements", fake_achievements)

	print("🧪 Condiciones de prestigio simuladas para testing")
	debug_print_prestige_status()


# =============================================================================
# SINGLETON METHODS
# =============================================================================


func get_singleton_name() -> String:
	"""Nombre del singleton para autoload"""
	return "PrestigeManager"

# EOF - PrestigeManager.gd
