# ==============================================================================
# 🏆 ACHIEVEMENT MANAGER - Sistema Completo de Logros
# ==============================================================================
# Gestiona 30 achievements en 7 categorías con tracking automático y recompensas

extends Node

# 🎯 ACHIEVEMENT CATEGORIES
enum AchievementCategory {
	PRODUCTION,     # Cerveza producida
	ECONOMIC,       # Dinero y ganancias
	META,          # Prestige y estrellas
	AUTOMATION,    # Sistemas automáticos
	PROGRESSION,   # Niveles y upgrades
	SPECIAL,       # Eventos especiales
	COLLECTION     # Meta-achievements
}

# 🏅 ACHIEVEMENT CLASS
class Achievement:
	var id: String
	var category: AchievementCategory
	var title: String
	var description: String
	var icon: String
	var required_value: float
	var current_progress: float = 0.0
	var is_unlocked: bool = false
	var is_hidden: bool = false
	var reward_gems: int = 0
	var reward_tokens: int = 0
	var reward_multiplier: float = 1.0

	func _init(p_id: String, p_category: AchievementCategory, p_title: String, p_description: String, p_icon: String, p_required: float, p_gems: int = 0, p_tokens: int = 0, p_multiplier: float = 1.0, p_hidden: bool = false):
		id = p_id
		category = p_category
		title = p_title
		description = p_description
		icon = p_icon
		required_value = p_required
		reward_gems = p_gems
		reward_tokens = p_tokens
		reward_multiplier = p_multiplier
		is_hidden = p_hidden

# 📊 SIGNALS
signal achievement_unlocked(achievement_id: String, achievement_data: Dictionary)
signal achievement_progress_updated(achievement_id: String, current: float, required: float)
signal achievement_notification(achievement_data: Dictionary)

# 🗂️ STORAGE
var achievements: Dictionary = {}
var unlocked_achievements: Array = []
var achievement_progress: Dictionary = {}
var lifetime_stats: Dictionary = {}

# 📈 STATISTICS
var total_gems_earned: int = 0
var total_tokens_earned: int = 0

# 🔗 REFERENCIAS A MANAGERS
@onready var game_controller = get_node_or_null("/root/GameController")
@onready var customer_manager = get_node_or_null("/root/CustomerManager")
@onready var prestige_manager = get_node_or_null("/root/PrestigeManager")
@onready var automation_manager = get_node_or_null("/root/AutomationManager")

# ⚡ INITIALIZATION
func _ready():
	_initialize_achievements()
	_initialize_stats()
	_connect_signals()
	_start_progress_tracking()

# 📊 SETUP FUNCTIONS
func _initialize_achievements():
	_create_production_achievements()
	_create_economic_achievements()
	_create_meta_achievements()
	_create_automation_achievements()
	_create_progression_achievements()
	_create_special_achievements()
	_create_collection_achievements()

func _initialize_stats():
	lifetime_stats = {
		"beers_produced": 0,
		"total_revenue": 0.0,
		"beers_sold": 0,
		"prestige_count": 0,
		"stars_earned": 0,
		"automation_time": 0.0,
		"session_count": 0,
		"total_playtime": 0.0
	}

# 🍺 PRODUCTION ACHIEVEMENTS (7 achievements)
func _create_production_achievements():
	achievements["first_batch"] = Achievement.new(
		"first_batch", AchievementCategory.PRODUCTION,
		"Primera Tanda", "Produce tu primera cerveza",
		"res://gfx/achievements/beer_icon.png", 1, 5, 0)

	achievements["hundred_beers"] = Achievement.new(
		"hundred_beers", AchievementCategory.PRODUCTION,
		"Producción Básica", "Produce 100 cervezas",
		"res://gfx/achievements/brewery_icon.png", 100, 10, 1)

	achievements["thousand_beers"] = Achievement.new(
		"thousand_beers", AchievementCategory.PRODUCTION,
		"Mil Cervezas", "Produce 1,000 cervezas",
		"res://gfx/achievements/factory_icon.png", 1000, 25, 2)

	achievements["mass_production"] = Achievement.new(
		"mass_production", AchievementCategory.PRODUCTION,
		"Producción Masiva", "Produce 10,000 cervezas",
		"res://gfx/achievements/industry_icon.png", 10000, 50, 5, 1.1)

	achievements["industrial"] = Achievement.new(
		"industrial", AchievementCategory.PRODUCTION,
		"Era Industrial", "Produce 100,000 cervezas",
		"res://gfx/achievements/industrial_icon.png", 100000, 100, 10, 1.2)

	achievements["mega_brewery"] = Achievement.new(
		"mega_brewery", AchievementCategory.PRODUCTION,
		"Mega Cervecería", "Produce 1,000,000 de cervezas",
		"res://gfx/achievements/mega_icon.png", 1000000, 250, 25, 1.5)

	achievements["beer_empire"] = Achievement.new(
		"beer_empire", AchievementCategory.PRODUCTION,
		"Imperio Cervecero", "Produce 10,000,000 de cervezas",
		"res://gfx/achievements/empire_icon.png", 10000000, 500, 50, 2.0)

# 💰 ECONOMIC ACHIEVEMENTS (8 achievements)
func _create_economic_achievements():
	achievements["first_sale"] = Achievement.new(
		"first_sale", AchievementCategory.ECONOMIC,
		"Primera Venta", "Realiza tu primera venta",
		"res://gfx/achievements/sale_icon.png", 1, 5, 0)

	achievements["small_business"] = Achievement.new(
		"small_business", AchievementCategory.ECONOMIC,
		"Pequeño Negocio", "Gana $1,000",
		"res://gfx/achievements/business_icon.png", 1000, 10, 1)

	achievements["successful_bar"] = Achievement.new(
		"successful_bar", AchievementCategory.ECONOMIC,
		"Bar Exitoso", "Gana $100,000",
		"res://gfx/achievements/success_icon.png", 100000, 25, 2)

	achievements["millionaire"] = Achievement.new(
		"millionaire", AchievementCategory.ECONOMIC,
		"Millonario", "Gana $1,000,000",
		"res://gfx/achievements/million_icon.png", 1000000, 50, 5, 1.1)

	achievements["multi_millionaire"] = Achievement.new(
		"multi_millionaire", AchievementCategory.ECONOMIC,
		"Multimillonario", "Gana $10,000,000",
		"res://gfx/achievements/multi_million_icon.png", 10000000, 100, 10, 1.2)

	achievements["billionaire"] = Achievement.new(
		"billionaire", AchievementCategory.ECONOMIC,
		"Billonario", "Gana $1,000,000,000",
		"res://gfx/achievements/billion_icon.png", 1000000000, 250, 25, 1.5)

	achievements["token_starter"] = Achievement.new(
		"token_starter", AchievementCategory.ECONOMIC,
		"Primer Token", "Gana tu primer token de prestige",
		"res://gfx/achievements/token_icon.png", 1, 0, 10)

	achievements["token_collector"] = Achievement.new(
		"token_collector", AchievementCategory.ECONOMIC,
		"Coleccionista", "Acumula 100 tokens",
		"res://gfx/achievements/collector_icon.png", 100, 25, 50, 1.1)

# ⭐ META ACHIEVEMENTS (5 achievements)
func _create_meta_achievements():
	achievements["first_prestige"] = Achievement.new(
		"first_prestige", AchievementCategory.META,
		"Primer Prestige", "Realiza tu primer prestige",
		"res://gfx/achievements/prestige_icon.png", 1, 0, 25, 1.1)

	achievements["veteran"] = Achievement.new(
		"veteran", AchievementCategory.META,
		"Veterano", "Realiza 10 prestiges",
		"res://gfx/achievements/veteran_icon.png", 10, 50, 100, 1.2)

	achievements["master"] = Achievement.new(
		"master", AchievementCategory.META,
		"Maestro", "Realiza 50 prestiges",
		"res://gfx/achievements/master_icon.png", 50, 150, 250, 1.5)

	achievements["legend"] = Achievement.new(
		"legend", AchievementCategory.META,
		"Leyenda", "Realiza 100 prestiges",
		"res://gfx/achievements/legend_icon.png", 100, 300, 500, 2.0)

	achievements["star_gazer"] = Achievement.new(
		"star_gazer", AchievementCategory.META,
		"Observador de Estrellas", "Gana 50 estrellas totales",
		"res://gfx/achievements/star_icon.png", 50, 25, 50)

# 🤖 AUTOMATION ACHIEVEMENTS (4 achievements)
func _create_automation_achievements():
	achievements["auto_pilot"] = Achievement.new(
		"auto_pilot", AchievementCategory.AUTOMATION,
		"Piloto Automático", "Usa automatización por 5 minutos",
		"res://gfx/achievements/auto_icon.png", 300, 15, 5)

	achievements["automation_master"] = Achievement.new(
		"automation_master", AchievementCategory.AUTOMATION,
		"Maestro de la Automatización", "Usa automatización por 1 hora",
		"res://gfx/achievements/automation_icon.png", 3600, 50, 20, 1.1)

	achievements["ai_overlord"] = Achievement.new(
		"ai_overlord", AchievementCategory.AUTOMATION,
		"Señor de la IA", "Usa automatización por 10 horas totales",
		"res://gfx/achievements/ai_icon.png", 36000, 150, 75, 1.3)

	achievements["efficiency_expert"] = Achievement.new(
		"efficiency_expert", AchievementCategory.AUTOMATION,
		"Experto en Eficiencia", "Alcanza 95% de eficiencia automática",
		"res://gfx/achievements/efficiency_icon.png", 95, 100, 50, 1.2)

# 📈 PROGRESSION ACHIEVEMENTS (3 achievements)
func _create_progression_achievements():
	achievements["dedicated_player"] = Achievement.new(
		"dedicated_player", AchievementCategory.PROGRESSION,
		"Jugador Dedicado", "Juega por 10 sesiones",
		"res://gfx/achievements/dedication_icon.png", 10, 25, 10)

	achievements["bar_veteran"] = Achievement.new(
		"bar_veteran", AchievementCategory.PROGRESSION,
		"Veterano del Bar", "Juega por 100 horas totales",
		"res://gfx/achievements/time_icon.png", 360000, 100, 50, 1.2)

	achievements["lifetime_dedication"] = Achievement.new(
		"lifetime_dedication", AchievementCategory.PROGRESSION,
		"Dedicación de por Vida", "Juega por 1000 horas totales",
		"res://gfx/achievements/lifetime_icon.png", 3600000, 500, 250, 2.0, true)

# 🎉 SPECIAL ACHIEVEMENTS (5 achievements)
func _create_special_achievements():
	achievements["early_bird"] = Achievement.new(
		"early_bird", AchievementCategory.SPECIAL,
		"Madrugador", "Juega antes de las 6 AM",
		"res://gfx/achievements/early_icon.png", 1, 10, 5)

	achievements["night_owl"] = Achievement.new(
		"night_owl", AchievementCategory.SPECIAL,
		"Ave Nocturna", "Juega después de las 11 PM",
		"res://gfx/achievements/night_icon.png", 1, 10, 5)

	achievements["weekend_warrior"] = Achievement.new(
		"weekend_warrior", AchievementCategory.SPECIAL,
		"Guerrero de Fin de Semana", "Juega en fin de semana",
		"res://gfx/achievements/weekend_icon.png", 1, 15, 5)

	achievements["perfectionist"] = Achievement.new(
		"perfectionist", AchievementCategory.SPECIAL,
		"Perfeccionista", "Completa una sesión sin errores",
		"res://gfx/achievements/perfect_icon.png", 1, 50, 20, 1.1, true)

	achievements["speed_demon"] = Achievement.new(
		"speed_demon", AchievementCategory.SPECIAL,
		"Demonio de la Velocidad", "Alcanza el primer prestige en menos de 1 hora",
		"res://gfx/achievements/speed_icon.png", 1, 75, 25, 1.2, true)

# 🏆 COLLECTION ACHIEVEMENTS (3 achievements)
func _create_collection_achievements():
	achievements["achievement_hunter"] = Achievement.new(
		"achievement_hunter", AchievementCategory.COLLECTION,
		"Cazador de Logros", "Desbloquea 10 achievements",
		"res://gfx/achievements/hunter_icon.png", 10, 50, 25)

	achievements["completionist"] = Achievement.new(
		"completionist", AchievementCategory.COLLECTION,
		"Completista", "Desbloquea 25 achievements",
		"res://gfx/achievements/complete_icon.png", 25, 150, 75, 1.3)

	achievements["achievement_master"] = Achievement.new(
		"achievement_master", AchievementCategory.COLLECTION,
		"Maestro de Logros", "Desbloquea todos los achievements",
		"res://gfx/achievements/master_all_icon.png", 30, 500, 200, 3.0, true)

# 🔗 SIGNAL CONNECTIONS
func _connect_signals():
	# Conexiones con otros managers si existen
	if customer_manager:
		if customer_manager.has_signal("beer_sold"):
			customer_manager.beer_sold.connect(_on_beer_sold)
		if customer_manager.has_signal("revenue_earned"):
			customer_manager.revenue_earned.connect(_on_revenue_earned)

	if prestige_manager:
		if prestige_manager.has_signal("prestige_performed"):
			prestige_manager.prestige_performed.connect(_on_prestige_performed)

	if automation_manager:
		if automation_manager.has_signal("automation_enabled"):
			automation_manager.automation_enabled.connect(_on_automation_enabled)

# ⏱️ TRACKING SETUP
func _start_progress_tracking():
	# Timer para updates periódicos
	var timer = Timer.new()
	timer.wait_time = 5.0  # Update cada 5 segundos
	timer.timeout.connect(_update_progress_tracking)
	add_child(timer)
	timer.start()

# 📈 EVENT HANDLERS
func _on_beer_produced(amount: int):
	lifetime_stats["beers_produced"] += amount
	_check_progress("first_batch", lifetime_stats["beers_produced"])
	_check_progress("hundred_beers", lifetime_stats["beers_produced"])
	_check_progress("thousand_beers", lifetime_stats["beers_produced"])
	_check_progress("mass_production", lifetime_stats["beers_produced"])
	_check_progress("industrial", lifetime_stats["beers_produced"])
	_check_progress("mega_brewery", lifetime_stats["beers_produced"])
	_check_progress("beer_empire", lifetime_stats["beers_produced"])

func _on_beer_sold(amount: int):
	lifetime_stats["beers_sold"] += amount
	_check_progress("first_sale", lifetime_stats["beers_sold"])

func _on_revenue_earned(amount: float):
	lifetime_stats["total_revenue"] += amount
	_check_progress("first_sale", 1 if lifetime_stats["total_revenue"] > 0 else 0)
	_check_progress("small_business", lifetime_stats["total_revenue"])
	_check_progress("successful_bar", lifetime_stats["total_revenue"])
	_check_progress("millionaire", lifetime_stats["total_revenue"])
	_check_progress("multi_millionaire", lifetime_stats["total_revenue"])
	_check_progress("billionaire", lifetime_stats["total_revenue"])

func _on_prestige_performed():
	lifetime_stats["prestige_count"] += 1
	_check_progress("first_prestige", lifetime_stats["prestige_count"])
	_check_progress("veteran", lifetime_stats["prestige_count"])
	_check_progress("master", lifetime_stats["prestige_count"])
	_check_progress("legend", lifetime_stats["prestige_count"])

func _on_stars_earned(amount: int):
	lifetime_stats["stars_earned"] += amount
	_check_progress("star_gazer", lifetime_stats["stars_earned"])

func _on_automation_enabled():
	# Tracking de automation time se hace en _update_progress_tracking()
	pass

# ⏰ UPDATE TRACKING PERIÓDICO
func _update_progress_tracking():
	# Automation time tracking
	if automation_manager and automation_manager.has_method("is_active") and automation_manager.is_active:
		lifetime_stats["automation_time"] += 5.0  # 5 segundos por update
		_check_progress("auto_pilot", lifetime_stats["automation_time"])
		_check_progress("automation_master", lifetime_stats["automation_time"])
		_check_progress("ai_overlord", lifetime_stats["automation_time"])

	# Collection achievements
	var unlocked_count = unlocked_achievements.size()
	_check_progress("achievement_hunter", unlocked_count)
	_check_progress("completionist", unlocked_count)
	_check_progress("achievement_master", unlocked_count)

	# Time-based achievements
	var current_hour = Time.get_datetime_dict_from_system()["hour"]
	if current_hour < 6:
		unlock_achievement("early_bird")
	elif current_hour >= 23:
		unlock_achievement("night_owl")

	# Weekend achievement
	var weekday = Time.get_datetime_dict_from_system()["weekday"]
	if weekday == 0 or weekday == 6:  # Sunday = 0, Saturday = 6
		unlock_achievement("weekend_warrior")

# 🎯 CORE ACHIEVEMENT FUNCTIONS
func _check_progress(achievement_id: String, current_value: float):
	if not achievements.has(achievement_id):
		return

	var achievement = achievements[achievement_id]
	if achievement.is_unlocked:
		return

	achievement.current_progress = current_value
	achievement_progress[achievement_id] = current_value

	# Emit progress signal
	achievement_progress_updated.emit(achievement_id, current_value, achievement.required_value)

	# Check if achievement should be unlocked
	if current_value >= achievement.required_value:
		unlock_achievement(achievement_id)

func unlock_achievement(achievement_id: String):
	if not achievements.has(achievement_id):
		return

	var achievement = achievements[achievement_id]
	if achievement.is_unlocked:
		return

	achievement.is_unlocked = true
	unlocked_achievements.append(achievement_id)

	# Give rewards
	_give_achievement_rewards(achievement)

	# Emit signals
	achievement_unlocked.emit(achievement_id, _achievement_to_dict(achievement))
	achievement_notification.emit(_achievement_to_dict(achievement))

	print("🏆 Achievement Unlocked: ", achievement.title)

func _give_achievement_rewards(achievement: Achievement):
	if game_controller and game_controller.game_data:
		var game_data = game_controller.game_data

		if achievement.reward_gems > 0:
			game_data.gems += achievement.reward_gems
			total_gems_earned += achievement.reward_gems

		if achievement.reward_tokens > 0:
			game_data.tokens += achievement.reward_tokens
			total_tokens_earned += achievement.reward_tokens

		if achievement.reward_multiplier > 1.0:
			# Apply permanent multiplier bonus
			if game_data.has_method("add_permanent_multiplier"):
				game_data.add_permanent_multiplier(achievement.reward_multiplier - 1.0)

# 📊 UTILITY FUNCTIONS
func _achievement_to_dict(achievement: Achievement) -> Dictionary:
	return {
		"id": achievement.id,
		"category": achievement.category,
		"title": achievement.title,
		"description": achievement.description,
		"icon": achievement.icon,
		"progress": achievement.current_progress,
		"required": achievement.required_value,
		"unlocked": achievement.is_unlocked,
		"hidden": achievement.is_hidden,
		"reward_gems": achievement.reward_gems,
		"reward_tokens": achievement.reward_tokens,
		"reward_multiplier": achievement.reward_multiplier
	}

func get_achievements_by_category(category: AchievementCategory) -> Array:
	var filtered = []
	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if achievement.category == category:
			filtered.append(_achievement_to_dict(achievement))
	return filtered

func get_unlocked_achievements() -> Array:
	var unlocked = []
	for achievement_id in unlocked_achievements:
		if achievements.has(achievement_id):
			unlocked.append(_achievement_to_dict(achievements[achievement_id]))
	return unlocked

func get_progress_percentage() -> float:
	if achievements.is_empty():
		return 0.0
	return float(unlocked_achievements.size()) / float(achievements.size()) * 100.0

func get_category_progress(category: AchievementCategory) -> Dictionary:
	var total = 0
	var unlocked = 0

	for achievement_id in achievements:
		var achievement = achievements[achievement_id]
		if achievement.category == category:
			total += 1
			if achievement.is_unlocked:
				unlocked += 1

	return {
		"total": total,
		"unlocked": unlocked,
		"percentage": 0.0 if total == 0 else float(unlocked) / float(total) * 100.0
	}

# 💾 SAVE/LOAD SYSTEM
func get_save_data() -> Dictionary:
	return {
		"achievements": achievement_progress,
		"unlocked": unlocked_achievements,
		"stats": lifetime_stats,
		"gems_earned": total_gems_earned,
		"tokens_earned": total_tokens_earned
	}

func load_save_data(data: Dictionary):
	if data.has("achievements"):
		achievement_progress = data.achievements

		# Restore progress to achievement objects
		for achievement_id in achievement_progress:
			if achievements.has(achievement_id):
				achievements[achievement_id].current_progress = achievement_progress[achievement_id]

	if data.has("unlocked"):
		unlocked_achievements = data.unlocked

		# Mark achievements as unlocked
		for achievement_id in unlocked_achievements:
			if achievements.has(achievement_id):
				achievements[achievement_id].is_unlocked = true

	if data.has("stats"):
		lifetime_stats.merge(data.stats)

	if data.has("gems_earned"):
		total_gems_earned = data.gems_earned

	if data.has("tokens_earned"):
		total_tokens_earned = data.tokens_earned

# 🔍 DEBUG FUNCTIONS
func debug_unlock_achievement(achievement_id: String):
	if achievements.has(achievement_id):
		unlock_achievement(achievement_id)

func debug_reset_achievements():
	for achievement_id in achievements:
		achievements[achievement_id].is_unlocked = false
		achievements[achievement_id].current_progress = 0.0
	unlocked_achievements.clear()
	achievement_progress.clear()

func debug_print_stats():
	print("=== ACHIEVEMENT STATS ===")
	print("Total Achievements: ", achievements.size())
	print("Unlocked: ", unlocked_achievements.size())
	print("Progress: ", get_progress_percentage(), "%")
	print("Gems Earned: ", total_gems_earned)
	print("Tokens Earned: ", total_tokens_earned)
