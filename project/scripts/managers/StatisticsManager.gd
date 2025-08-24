class_name StatisticsManager
extends Node

## T034 - Sistema de Dashboard de Estadísticas
## Controla analytics detallados para engaged players

# Señales
signal stat_updated(category: String, stat_name: String, value: float)
signal milestone_reached(category: String, milestone_name: String, value: float)
signal report_generated(report_type: String, data: Dictionary)

# Referencias
var game_data: GameData

# Categorías de estadísticas
var production_stats: Dictionary = {}
var economic_stats: Dictionary = {}
var meta_stats: Dictionary = {}
var efficiency_stats: Dictionary = {}

# Tracking temporal
var session_start_time: int = 0
var last_stats_save: int = 0

# Constantes
const STATS_SAVE_INTERVAL = 60  # Guardar stats cada minuto


func _ready():
	print("📊 StatisticsManager inicializado (T034)")
	session_start_time = Time.get_unix_time_from_system()
	_initialize_stats_structure()
	_setup_periodic_updates()


func _initialize_stats_structure():
	"""Inicializa la estructura de estadísticas"""

	# === PRODUCTION STATS ===
	production_stats = {
		"total_beers_brewed": 0,
		"beer_types_produced": {},  # Por tipo de cerveza
		"production_efficiency_over_time": [],  # Muestras históricas
		"most_productive_hour": {"hour": 0, "amount": 0},
		"production_streaks": {"current": 0, "best": 0},
		"ingredients_used": {},
		"waste_generated": 0,
		"quality_metrics": {"excellent": 0, "good": 0, "poor": 0}
	}

	# === ECONOMIC STATS ===
	economic_stats = {
		"money_earned_lifetime": 0.0,
		"money_earned_session": 0.0,
		"money_per_hour_average": 0.0,
		"money_per_hour_peak": 0.0,
		"tokens_earned_breakdown": {"achievements": 0, "missions": 0, "prestige": 0},
		"gems_spent_categories": {"upgrades": 0, "automation": 0, "cosmetics": 0},
		"biggest_single_sale": {"amount": 0.0, "timestamp": 0},
		"customer_lifetime_value": {},  # Por tipo de cliente
		"revenue_by_beer_type": {},
		"profit_margins": {}
	}

	# === META STATS ===
	meta_stats = {
		"total_playtime": 0,  # En segundos
		"sessions_count": 0,
		"session_lengths": [],  # Histórico de duración de sesiones
		"offline_time_total": 0,
		"offline_gains_total": 0.0,
		"prestige_statistics":
		{"count": 0, "fastest_run": 0, "total_stars_earned": 0, "average_time_between": 0},
		"achievements_progress": {"unlocked": 0, "total": 30},
		"missions_completed": {"daily": 0, "weekly": 0},
		"features_unlocked_timeline": []
	}

	# === EFFICIENCY STATS ===
	efficiency_stats = {
		"automation_usage": {"production": 0, "sales": 0, "total_hours": 0},
		"idle_vs_active_ratio": {"idle_gains": 0.0, "active_gains": 0.0},
		"optimization_scores":
		{"resource_management": 0.0, "timing_efficiency": 0.0, "automation_setup": 0.0},
		"bottlenecks_identified": [],
		"performance_trends": []
	}


func _setup_periodic_updates():
	"""Configura actualizaciones periódicas de estadísticas"""
	var stats_timer = Timer.new()
	stats_timer.wait_time = 10.0  # Actualizar cada 10 segundos
	stats_timer.timeout.connect(_update_realtime_stats)
	stats_timer.autostart = true
	add_child(stats_timer)

	var save_timer = Timer.new()
	save_timer.wait_time = STATS_SAVE_INTERVAL
	save_timer.timeout.connect(_save_stats_to_game_data)
	save_timer.autostart = true
	add_child(save_timer)


## === PRODUCTION STATISTICS ===


func record_beer_produced(beer_type: String, quantity: int, quality: String = "good"):
	"""Registra cerveza producida"""
	production_stats["total_beers_brewed"] += quantity

	# Por tipo
	if not production_stats["beer_types_produced"].has(beer_type):
		production_stats["beer_types_produced"][beer_type] = 0
	production_stats["beer_types_produced"][beer_type] += quantity

	# Calidad
	if production_stats["quality_metrics"].has(quality):
		production_stats["quality_metrics"][quality] += quantity

	# Actualizar streak
	production_stats["production_streaks"]["current"] += quantity
	if (
		production_stats["production_streaks"]["current"]
		> production_stats["production_streaks"]["best"]
	):
		production_stats["production_streaks"]["best"] = production_stats["production_streaks"]["current"]

	stat_updated.emit("production", "beers_brewed", production_stats["total_beers_brewed"])
	_check_production_milestones()


func record_ingredient_used(ingredient: String, quantity: int):
	"""Registra uso de ingredientes"""
	if not production_stats["ingredients_used"].has(ingredient):
		production_stats["ingredients_used"][ingredient] = 0
	production_stats["ingredients_used"][ingredient] += quantity


func update_production_efficiency(efficiency_score: float):
	"""Actualiza métricas de eficiencia de producción"""
	var timestamp = Time.get_unix_time_from_system()
	var sample = {"timestamp": timestamp, "efficiency": efficiency_score}
	production_stats["production_efficiency_over_time"].append(sample)

	# Mantener solo las últimas 100 muestras
	if production_stats["production_efficiency_over_time"].size() > 100:
		production_stats["production_efficiency_over_time"].pop_front()


## === ECONOMIC STATISTICS ===


func record_money_earned(amount: float, source: String = "sales"):
	"""Registra dinero ganado"""
	economic_stats["money_earned_lifetime"] += amount
	economic_stats["money_earned_session"] += amount

	# Verificar si es la venta más grande
	if amount > economic_stats["biggest_single_sale"]["amount"]:
		economic_stats["biggest_single_sale"] = {
			"amount": amount, "timestamp": Time.get_unix_time_from_system()
		}

	stat_updated.emit("economic", "money_lifetime", economic_stats["money_earned_lifetime"])
	_update_money_per_hour()


func record_token_earned(amount: int, source: String):
	"""Registra tokens ganados"""
	if economic_stats["tokens_earned_breakdown"].has(source):
		economic_stats["tokens_earned_breakdown"][source] += amount
	stat_updated.emit("economic", "tokens_earned", amount)


func record_gem_spent(amount: int, category: String):
	"""Registra gemas gastadas"""
	if economic_stats["gems_spent_categories"].has(category):
		economic_stats["gems_spent_categories"][category] += amount
	stat_updated.emit("economic", "gems_spent", amount)


func record_customer_purchase(customer_type: String, amount: float, beer_type: String):
	"""Registra compra de cliente"""
	# Customer lifetime value
	if not economic_stats["customer_lifetime_value"].has(customer_type):
		economic_stats["customer_lifetime_value"][customer_type] = 0.0
	economic_stats["customer_lifetime_value"][customer_type] += amount

	# Revenue by beer type
	if not economic_stats["revenue_by_beer_type"].has(beer_type):
		economic_stats["revenue_by_beer_type"][beer_type] = 0.0
	economic_stats["revenue_by_beer_type"][beer_type] += amount


func _update_money_per_hour():
	"""Calcula dinero por hora actual y promedio"""
	var current_time = Time.get_unix_time_from_system()
	var session_duration = current_time - session_start_time

	if session_duration > 0:
		var money_per_hour = economic_stats["money_earned_session"] / (session_duration / 3600.0)
		economic_stats["money_per_hour_average"] = money_per_hour

		if money_per_hour > economic_stats["money_per_hour_peak"]:
			economic_stats["money_per_hour_peak"] = money_per_hour


## === META STATISTICS ===


func update_playtime():
	"""Actualiza tiempo total de juego"""
	if game_data and game_data.statistics.has("total_playtime"):
		meta_stats["total_playtime"] = game_data.statistics["total_playtime"]


func record_session_start():
	"""Registra inicio de sesión"""
	meta_stats["sessions_count"] += 1
	session_start_time = Time.get_unix_time_from_system()


func record_session_end():
	"""Registra fin de sesión"""
	var session_duration = Time.get_unix_time_from_system() - session_start_time
	meta_stats["session_lengths"].append(session_duration)

	# Mantener solo las últimas 50 sesiones
	if meta_stats["session_lengths"].size() > 50:
		meta_stats["session_lengths"].pop_front()


func record_prestige_completed(time_taken: int, stars_earned: int):
	"""Registra prestigio completado"""
	meta_stats["prestige_statistics"]["count"] += 1
	meta_stats["prestige_statistics"]["total_stars_earned"] += stars_earned

	if (
		time_taken < meta_stats["prestige_statistics"]["fastest_run"]
		or meta_stats["prestige_statistics"]["fastest_run"] == 0
	):
		meta_stats["prestige_statistics"]["fastest_run"] = time_taken


func record_offline_progress(time_offline: int, gains_made: float):
	"""Registra progreso offline"""
	meta_stats["offline_time_total"] += time_offline
	meta_stats["offline_gains_total"] += gains_made


func record_feature_unlocked(feature_name: String):
	"""Registra característica desbloqueada"""
	var unlock_record = {
		"feature": feature_name,
		"timestamp": Time.get_unix_time_from_system(),
		"session": meta_stats["sessions_count"]
	}
	meta_stats["features_unlocked_timeline"].append(unlock_record)


## === EFFICIENCY STATISTICS ===


func record_automation_usage(automation_type: String, hours_active: float):
	"""Registra uso de automatización"""
	if efficiency_stats["automation_usage"].has(automation_type):
		efficiency_stats["automation_usage"][automation_type] += hours_active
	efficiency_stats["automation_usage"]["total_hours"] += hours_active


func update_idle_vs_active_ratio(idle_gains: float, active_gains: float):
	"""Actualiza ratio de ganancias idle vs activo"""
	efficiency_stats["idle_vs_active_ratio"]["idle_gains"] += idle_gains
	efficiency_stats["idle_vs_active_ratio"]["active_gains"] += active_gains


## === REAL-TIME UPDATES ===


func _update_realtime_stats():
	"""Actualiza estadísticas en tiempo real"""
	update_playtime()
	_update_money_per_hour()
	_calculate_efficiency_scores()


func _calculate_efficiency_scores():
	"""Calcula scores de eficiencia"""
	# Resource management (basado en waste vs production)
	var total_production = production_stats.get("total_beers_brewed", 1)
	var waste = production_stats.get("waste_generated", 0)
	efficiency_stats["optimization_scores"]["resource_management"] = (
		1.0 - (float(waste) / float(total_production))
	)

	# Automation setup (basado en uso de automatización)
	var automation_hours = efficiency_stats["automation_usage"]["total_hours"]
	var total_hours = meta_stats["total_playtime"] / 3600.0
	if total_hours > 0:
		efficiency_stats["optimization_scores"]["automation_setup"] = min(
			automation_hours / total_hours, 1.0
		)


## === MILESTONE CHECKS ===


func _check_production_milestones():
	"""Verifica hitos de producción"""
	var total_beers = production_stats["total_beers_brewed"]
	var milestones = [100, 1000, 10000, 100000, 1000000]

	for milestone in milestones:
		if total_beers >= milestone and total_beers - 1 < milestone:
			milestone_reached.emit("production", "beers_brewed_%d" % milestone, total_beers)


## === REPORTS GENERATION ===


func generate_session_report() -> Dictionary:
	"""Genera reporte de la sesión actual"""
	var report = {
		"session_duration": Time.get_unix_time_from_system() - session_start_time,
		"money_earned": economic_stats["money_earned_session"],
		"money_per_hour": economic_stats["money_per_hour_average"],
		"beers_produced": production_stats["total_beers_brewed"],
		"efficiency_score": _calculate_overall_efficiency()
	}

	report_generated.emit("session", report)
	return report


func generate_lifetime_report() -> Dictionary:
	"""Genera reporte de estadísticas de por vida"""
	var report = {
		"production_stats": production_stats.duplicate(true),
		"economic_stats": economic_stats.duplicate(true),
		"meta_stats": meta_stats.duplicate(true),
		"efficiency_stats": efficiency_stats.duplicate(true),
		"generated_at": Time.get_unix_time_from_system()
	}

	report_generated.emit("lifetime", report)
	return report


func _calculate_overall_efficiency() -> float:
	"""Calcula puntuación general de eficiencia"""
	var scores = efficiency_stats["optimization_scores"]
	var total = (
		scores["resource_management"] + scores["timing_efficiency"] + scores["automation_setup"]
	)
	return total / 3.0


## === SAVE/LOAD INTEGRATION ===


func _save_stats_to_game_data():
	"""Guarda estadísticas en GameData"""
	if not game_data:
		return

	# Actualizar estadísticas principales en GameData
	game_data.statistics["total_beers_produced"] = production_stats["total_beers_brewed"]
	game_data.statistics["total_money_earned"] = economic_stats["money_earned_lifetime"]
	game_data.statistics["sessions_played"] = meta_stats["sessions_count"]
	game_data.statistics["detailed_stats"] = {
		"production": production_stats,
		"economic": economic_stats,
		"meta": meta_stats,
		"efficiency": efficiency_stats
	}

	last_stats_save = Time.get_unix_time_from_system()


func load_stats_from_game_data():
	"""Carga estadísticas desde GameData"""
	if not game_data or not game_data.statistics.has("detailed_stats"):
		return

	var detailed = game_data.statistics["detailed_stats"]
	if detailed.has("production"):
		production_stats = detailed["production"]
	if detailed.has("economic"):
		economic_stats = detailed["economic"]
	if detailed.has("meta"):
		meta_stats = detailed["meta"]
	if detailed.has("efficiency"):
		efficiency_stats = detailed["efficiency"]

	print("📊 Estadísticas cargadas desde GameData")


## === API PÚBLICAS ===


func get_production_summary() -> Dictionary:
	"""Obtiene resumen de estadísticas de producción"""
	return production_stats.duplicate(true)


func get_economic_summary() -> Dictionary:
	"""Obtiene resumen de estadísticas económicas"""
	return economic_stats.duplicate(true)


func get_efficiency_score() -> float:
	"""Obtiene puntuación de eficiencia actual"""
	return _calculate_overall_efficiency()


func get_top_beer_types(limit: int = 5) -> Array:
	"""Obtiene tipos de cerveza más producidos"""
	var beer_types = []
	for beer_type in production_stats["beer_types_produced"]:
		beer_types.append(
			{"type": beer_type, "quantity": production_stats["beer_types_produced"][beer_type]}
		)

	beer_types.sort_custom(func(a, b): return a["quantity"] > b["quantity"])
	return beer_types.slice(0, limit)


## === INTEGRATION ===


func set_game_data(data: GameData):
	"""Conectar con GameData"""
	game_data = data
	load_stats_from_game_data()
	record_session_start()
