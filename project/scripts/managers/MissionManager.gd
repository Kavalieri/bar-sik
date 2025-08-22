class_name MissionManager
extends Node

## T030 - Sistema de Misiones Diarias y Semanales Profesional
## Manager que controla las misiones para engagement y retention

# Señales para notificar eventos
signal mission_completed(mission_id: String, mission_data: Dictionary)
signal daily_missions_reset
signal weekly_missions_reset
signal mission_progress_updated(mission_id: String, progress: int, total: int)
signal missions_refreshed(mission_type: String)
signal mission_notification(mission_data: Dictionary)

# Referencia a GameData para acceder a estadísticas
var game_data: GameData

# Estado de las misiones
var active_missions: Dictionary = {}
var active_weekly_missions: Dictionary = {}
var mission_definitions: Dictionary = {}
var weekly_mission_definitions: Dictionary = {}
var last_reset_time: int = 0  # Timestamp del último reset diario
var last_weekly_reset_time: int = 0  # Timestamp del último reset semanal

# Estadísticas de misiones
var total_missions_completed: int = 0
var daily_streak: int = 0
var weekly_streak: int = 0

# Constantes
const MISSIONS_PER_DAY = 3
const WEEKLY_MISSIONS_PER_WEEK = 2
const RESET_HOUR_UTC = 0  # 00:00 UTC


func _ready():
	print("📅 MissionManager inicializado (T030 - Professional)")
	_init_mission_definitions()
	_init_weekly_mission_definitions()

	# Timer para verificar reset diario
	var reset_timer = Timer.new()
	reset_timer.wait_time = 60.0  # Verificar cada minuto
	reset_timer.timeout.connect(_check_daily_reset)
	reset_timer.timeout.connect(_check_weekly_reset)
	reset_timer.autostart = true
	add_child(reset_timer)


func set_game_data(data: GameData) -> void:
	"""Asignar referencia a GameData"""
	game_data = data
	print("📅 MissionManager conectado con GameData")

	# Cargar misiones guardadas o generar nuevas
	_load_or_generate_missions()
	_load_or_generate_weekly_missions()


func _init_mission_definitions():
	"""Definir todos los tipos de misiones disponibles"""
	mission_definitions = {
		"serve_customers":
		{
			"name": "Servir Clientes Automáticos",
			"description": "Sirve {target} clientes automáticos",
			"icon": "👥",
			"base_target": 10,
			"target_range": [5, 25],
			"token_reward": 15,
			"track_stat": "customers_served",
			"category": "customers"
		},
		"generate_resources":
		{
			"name": "Generar Recursos",
			"description": "Genera {target} recursos de cualquier tipo",
			"icon": "🌾",
			"base_target": 500,
			"target_range": [200, 1000],
			"token_reward": 12,
			"track_stat": "total_resources_generated",
			"category": "resources"
		},
		"manual_sales":
		{
			"name": "Ventas Manuales",
			"description": "Vende manualmente por ${target}",
			"icon": "💰",
			"base_target": 5000,
			"target_range": [2000, 15000],
			"token_reward": 20,
			"track_stat": "manual_sales_money",
			"category": "sales"
		},
		"activate_offers":
		{
			"name": "Activar Ofertas",
			"description": "Activa ofertas en {target} productos diferentes",
			"icon": "🎯",
			"base_target": 3,
			"target_range": [2, 8],
			"token_reward": 18,
			"track_stat": "offers_activated",
			"category": "offers"
		},
		"produce_products":
		{
			"name": "Producir Bebidas",
			"description": "Produce {target} bebidas en total",
			"icon": "🍺",
			"base_target": 30,
			"target_range": [15, 60],
			"token_reward": 10,
			"track_stat": "products_produced",
			"category": "production"
		},
		"purchase_generators":
		{
			"name": "Comprar Generadores",
			"description": "Compra {target} generadores",
			"icon": "⚙️",
			"base_target": 5,
			"target_range": [3, 12],
			"token_reward": 25,
			"track_stat": "generators_purchased",
			"category": "generators"
		},
		"earn_money":
		{
			"name": "Ganar Dinero",
			"description": "Acumula ${target} en efectivo",
			"icon": "💵",
			"base_target": 10000,
			"target_range": [5000, 25000],
			"token_reward": 15,
			"track_stat": "total_money_earned",
			"category": "money"
		},
		"purchase_stations":
		{
			"name": "Comprar Estaciones",
			"description": "Compra {target} estaciones de producción",
			"icon": "🏭",
			"base_target": 2,
			"target_range": [1, 5],
			"token_reward": 30,
			"track_stat": "stations_purchased",
			"category": "stations"
		}
	}

	print("📅 %d tipos de misiones definidos" % mission_definitions.size())


func _init_weekly_mission_definitions():
	"""Definir todas las misiones semanales disponibles"""
	weekly_mission_definitions = {
		"weekly_prestige":
		{
			"name": "Progreso Semanal",
			"description": "Completa {target} prestige esta semana",
			"icon": "⭐",
			"base_target": 1,
			"target_range": [1, 3],
			"token_reward": 100,
			"gem_reward": 25,
			"track_stat": "prestige_count",
			"category": "meta"
		},
		"weekly_automation_hours":
		{
			"name": "Automatización Total",
			"description": "Usa automatización por {target} horas esta semana",
			"icon": "🤖",
			"base_target": 3,
			"target_range": [2, 8],
			"token_reward": 75,
			"gem_reward": 15,
			"track_stat": "automation_hours",
			"category": "automation"
		},
		"weekly_achievements":
		{
			"name": "Cazador Semanal",
			"description": "Desbloquea {target} achievements esta semana",
			"icon": "🏆",
			"base_target": 3,
			"target_range": [2, 5],
			"token_reward": 150,
			"gem_reward": 50,
			"track_stat": "achievements_unlocked",
			"category": "meta"
		},
		"weekly_customer_milestone":
		{
			"name": "Servicio Premium",
			"description": "Sirve {target} clientes premium esta semana",
			"icon": "👑",
			"base_target": 100,
			"target_range": [50, 200],
			"token_reward": 80,
			"gem_reward": 20,
			"track_stat": "premium_customers_served",
			"category": "customers"
		},
		"weekly_money_massive":
		{
			"name": "Imperio Económico",
			"description": "Gana ${target} esta semana",
			"icon": "💎",
			"base_target": 1000000,
			"target_range": [500000, 2000000],
			"token_reward": 120,
			"gem_reward": 30,
			"track_stat": "weekly_money_earned",
			"category": "money"
		}
	}

	print("📅 %d tipos de misiones semanales definidos" % weekly_mission_definitions.size())


func _load_or_generate_missions():
	"""Cargar misiones guardadas o generar nuevas si es necesario"""
	if not game_data:
		print("⚠️ GameData no disponible, esperando...")
		return

	# Verificar si necesitamos hacer reset diario
	var current_time = Time.get_unix_time_from_system()
	var should_reset = _should_reset_missions(current_time)

	if should_reset or game_data.active_missions.is_empty():
		print("📅 Generando nuevas misiones diarias")
		_generate_daily_missions()
		game_data.last_mission_reset = current_time
	else:
		print("📅 Cargando misiones existentes")
		active_missions = game_data.active_missions.duplicate(true)

	# Verificar progreso en las misiones activas
	_update_all_mission_progress()


func _should_reset_missions(current_time: int) -> bool:
	"""Verificar si es momento de resetear las misiones diarias"""
	if game_data.last_mission_reset == 0:
		return true  # Primera vez

	var reset_time = game_data.last_mission_reset
	var current_date = Time.get_date_dict_from_unix_time(current_time)
	var reset_date = Time.get_date_dict_from_unix_time(reset_time)

	# Resetear si es un día diferente después de la hora UTC configurada
	var day_changed = current_date.day != reset_date.day
	var month_changed = current_date.month != reset_date.month
	var year_changed = current_date.year != reset_date.year

	if day_changed or month_changed or year_changed:
		var current_hour = Time.get_time_dict_from_unix_time(current_time).hour
		if current_hour >= RESET_HOUR_UTC:
			return true

	return false


func _generate_daily_missions():
	"""Generar 3 misiones diarias aleatorias"""
	active_missions.clear()

	# Obtener tipos de misiones disponibles
	var available_types = mission_definitions.keys()
	var selected_types = []

	# Seleccionar 3 tipos únicos aleatoriamente
	for i in range(MISSIONS_PER_DAY):
		if available_types.is_empty():
			break

		var random_index = randi() % available_types.size()
		var selected_type = available_types[random_index]
		selected_types.append(selected_type)
		available_types.erase(selected_type)  # No repetir tipos

	# Crear misiones con objetivos aleatorios
	for i in range(selected_types.size()):
		var mission_type = selected_types[i]
		var definition = mission_definitions[mission_type]
		var mission_id = "daily_%d" % i

		# Calcular objetivo aleatorio dentro del rango
		var min_target = definition.target_range[0]
		var max_target = definition.target_range[1]
		var target = randi_range(min_target, max_target)

		# Crear misión
		var mission_data = {
			"id": mission_id,
			"type": mission_type,
			"name": definition.name,
			"description": definition.description.format({"target": target}),
			"icon": definition.icon,
			"target": target,
			"progress": 0,
			"token_reward": definition.token_reward,
			"track_stat": definition.track_stat,
			"category": definition.category,
			"completed": false,
			"start_value": 0  # Valor inicial de la estadística
		}

		# Establecer valor inicial para tracking relativo
		if game_data.statistics.has(definition.track_stat):
			mission_data.start_value = game_data.statistics[definition.track_stat]

		active_missions[mission_id] = mission_data
		print("📋 Misión generada: %s (objetivo: %d)" % [mission_data.name, target])

	# Guardar en GameData
	game_data.active_missions = active_missions.duplicate(true)
	daily_missions_reset.emit()


func _update_all_mission_progress():
	"""Actualizar el progreso de todas las misiones activas"""
	if not game_data:
		return

	var missions_completed = []

	for mission_id in active_missions:
		var mission = active_missions[mission_id]
		if mission.completed:
			continue

		var old_progress = mission.progress
		_update_mission_progress(mission_id)

		# Si hubo cambio en el progreso, emitir señal
		if mission.progress != old_progress:
			mission_progress_updated.emit(mission_id, mission.progress, mission.target)

		# Verificar si se completó
		if mission.progress >= mission.target and not mission.completed:
			_complete_mission(mission_id)
			missions_completed.append(mission_id)

	# Actualizar GameData si hubo cambios
	if not missions_completed.is_empty():
		game_data.active_missions = active_missions.duplicate(true)
		print("📅 %d misiones completadas: %s" % [missions_completed.size(), missions_completed])


func _update_mission_progress(mission_id: String):
	"""Actualizar el progreso de una misión específica"""
	var mission = active_missions.get(mission_id)
	if not mission or mission.completed:
		return

	var stat_name = mission.track_stat
	var current_value = 0

	if game_data.statistics.has(stat_name):
		current_value = game_data.statistics[stat_name]

	# Calcular progreso relativo desde el inicio de la misión
	var progress = max(0, current_value - mission.start_value)
	mission.progress = min(progress, mission.target)


func _complete_mission(mission_id: String):
	"""Completar una misión y otorgar recompensas"""
	var mission = active_missions.get(mission_id)
	if not mission or mission.completed:
		return

	mission.completed = true

	# Otorgar recompensa de tokens
	if mission.token_reward > 0:
		game_data.add_tokens(mission.token_reward)
		print("🪙 +%d tokens por misión completada: %s" % [mission.token_reward, mission.name])

	# Emitir señal
	mission_completed.emit(mission_id, mission)

	print("✅ Misión completada: %s" % mission.name)


func _check_daily_reset():
	"""Verificar si es momento de resetear las misiones (llamado por timer)"""
	if not game_data:
		return

	var current_time = Time.get_unix_time_from_system()
	if _should_reset_missions(current_time):
		print("📅 Reseteando misiones diarias automáticamente")
		_generate_daily_missions()


# ============================================================================
# 📅 WEEKLY MISSIONS SYSTEM
# ============================================================================

func _load_or_generate_weekly_missions():
	"""Cargar misiones semanales guardadas o generar nuevas si es necesario"""
	if not game_data:
		print("⚠️ GameData no disponible para misiones semanales")
		return

	var current_time = Time.get_unix_time_from_system()
	var should_reset = _should_reset_weekly_missions(current_time)

	if should_reset or not game_data.has("active_weekly_missions") or game_data.active_weekly_missions.is_empty():
		print("📅 Generando nuevas misiones semanales")
		_generate_weekly_missions()
		game_data.last_weekly_mission_reset = current_time
	else:
		print("📅 Cargando misiones semanales existentes")
		active_weekly_missions = game_data.active_weekly_missions.duplicate(true)

	_update_all_weekly_mission_progress()


func _should_reset_weekly_missions(current_time: int) -> bool:
	"""Verificar si es momento de resetear las misiones semanales"""
	if not game_data.has("last_weekly_mission_reset") or game_data.last_weekly_mission_reset == 0:
		return true  # Primera vez

	var reset_time = game_data.last_weekly_mission_reset
	var time_passed = current_time - reset_time

	# Reset semanal: 7 días = 604800 segundos
	return time_passed >= 604800


func _generate_weekly_missions():
	"""Generar 2 misiones semanales aleatorias"""
	active_weekly_missions.clear()

	var available_types = weekly_mission_definitions.keys()
	var selected_types = []

	# Seleccionar 2 tipos únicos aleatoriamente
	for i in range(WEEKLY_MISSIONS_PER_WEEK):
		if available_types.is_empty():
			break

		var random_index = randi() % available_types.size()
		var selected_type = available_types[random_index]
		selected_types.append(selected_type)
		available_types.erase(selected_type)

	# Crear misiones semanales
	for i in range(selected_types.size()):
		var mission_type = selected_types[i]
		var definition = weekly_mission_definitions[mission_type]
		var mission_id = "weekly_%d" % i

		# Calcular objetivo aleatorio dentro del rango
		var min_target = definition.target_range[0]
		var max_target = definition.target_range[1]
		var target = randi_range(min_target, max_target)

		# Crear misión semanal
		var mission_data = {
			"id": mission_id,
			"type": mission_type,
			"name": definition.name,
			"description": definition.description.format({"target": target}),
			"icon": definition.icon,
			"target": target,
			"progress": 0,
			"token_reward": definition.token_reward,
			"gem_reward": definition.get("gem_reward", 0),
			"track_stat": definition.track_stat,
			"category": definition.category,
			"completed": false,
			"start_value": 0,
			"is_weekly": true
		}

		# Establecer valor inicial para tracking relativo
		if game_data.statistics.has(definition.track_stat):
			mission_data.start_value = game_data.statistics[definition.track_stat]

		active_weekly_missions[mission_id] = mission_data
		print("📋 Misión semanal generada: %s (objetivo: %d)" % [mission_data.name, target])

	# Guardar en GameData
	if not game_data.has("active_weekly_missions"):
		game_data.active_weekly_missions = {}
	game_data.active_weekly_missions = active_weekly_missions.duplicate(true)
	weekly_missions_reset.emit()
	missions_refreshed.emit("weekly")


func _update_all_weekly_mission_progress():
	"""Actualizar el progreso de todas las misiones semanales activas"""
	if not game_data:
		return

	var missions_completed = []

	for mission_id in active_weekly_missions:
		var mission = active_weekly_missions[mission_id]
		if mission.completed:
			continue

		var old_progress = mission.progress
		_update_weekly_mission_progress(mission_id)

		# Si hubo cambio en el progreso, emitir señal
		if mission.progress != old_progress:
			mission_progress_updated.emit(mission_id, mission.progress, mission.target)

		# Verificar si se completó
		if mission.progress >= mission.target and not mission.completed:
			_complete_weekly_mission(mission_id)
			missions_completed.append(mission_id)

	# Actualizar GameData si hubo cambios
	if not missions_completed.is_empty():
		game_data.active_weekly_missions = active_weekly_missions.duplicate(true)
		print("📅 %d misiones semanales completadas: %s" % [missions_completed.size(), missions_completed])


func _update_weekly_mission_progress(mission_id: String):
	"""Actualizar el progreso de una misión semanal específica"""
	var mission = active_weekly_missions.get(mission_id)
	if not mission or mission.completed:
		return

	var stat_name = mission.track_stat
	var current_value = 0

	if game_data.statistics.has(stat_name):
		current_value = game_data.statistics[stat_name]

	# Calcular progreso relativo desde el inicio de la misión
	var progress = max(0, current_value - mission.start_value)
	mission.progress = min(progress, mission.target)


func _complete_weekly_mission(mission_id: String):
	"""Completar una misión semanal y otorgar recompensas"""
	var mission = active_weekly_missions.get(mission_id)
	if not mission or mission.completed:
		return

	mission.completed = true
	total_missions_completed += 1
	weekly_streak += 1

	# Otorgar recompensa de tokens
	if mission.token_reward > 0:
		game_data.add_tokens(mission.token_reward)
		print("🪙 +%d tokens por misión semanal completada: %s" % [mission.token_reward, mission.name])

	# Otorgar recompensa de gems
	if mission.gem_reward > 0:
		game_data.gems += mission.gem_reward
		print("💎 +%d gems por misión semanal completada: %s" % [mission.gem_reward, mission.name])

	# Emitir señal
	mission_completed.emit(mission_id, mission)
	mission_notification.emit(mission)

	print("✅ Misión semanal completada: %s" % mission.name)


func _check_weekly_reset():
	"""Verificar si es momento de resetear las misiones semanales"""
	if not game_data:
		return

	var current_time = Time.get_unix_time_from_system()
	if _should_reset_weekly_missions(current_time):
		print("📅 Reseteando misiones semanales automáticamente")
		_generate_weekly_missions()
		game_data.last_mission_reset = current_time


# Funciones para notificar eventos del juego
func notify_customer_served():
	"""Notificar que se sirvió un cliente"""
	if game_data and game_data.statistics.has("customers_served"):
		game_data.statistics.customers_served += 1
	_update_all_mission_progress()


func notify_resource_generated(resource_type: String, amount: int):
	"""Notificar generación de recursos"""
	if game_data and game_data.statistics.has("total_resources_generated"):
		game_data.statistics.total_resources_generated += amount
	_update_all_mission_progress()


func notify_manual_sale(amount: float):
	"""Notificar venta manual"""
	if game_data and game_data.statistics.has("manual_sales_money"):
		game_data.statistics.manual_sales_money += amount
	_update_all_mission_progress()


func notify_offer_activated():
	"""Notificar activación de oferta"""
	if game_data and game_data.statistics.has("offers_activated"):
		game_data.statistics.offers_activated += 1
	_update_all_mission_progress()


func notify_product_produced(amount: int):
	"""Notificar producción de productos"""
	if game_data and game_data.statistics.has("products_produced"):
		game_data.statistics.products_produced += amount
	_update_all_mission_progress()


func notify_generator_purchased(amount: int):
	"""Notificar compra de generadores"""
	if game_data and game_data.statistics.has("generators_purchased"):
		game_data.statistics.generators_purchased += amount
	_update_all_mission_progress()


func notify_money_earned(amount: float):
	"""Notificar dinero ganado"""
	if game_data and game_data.statistics.has("total_money_earned"):
		game_data.statistics.total_money_earned += amount
	_update_all_mission_progress()


func notify_station_purchased():
	"""Notificar compra de estación"""
	if game_data and game_data.statistics.has("stations_purchased"):
		game_data.statistics.stations_purchased += 1
	_update_all_mission_progress()


# Funciones de utilidad para UI
func get_active_missions() -> Dictionary:
	"""Obtener misiones activas para UI"""
	return active_missions.duplicate(true)


func get_mission_progress_percentage(mission_id: String) -> float:
	"""Obtener progreso de misión como porcentaje"""
	var mission = active_missions.get(mission_id)
	if not mission or mission.target <= 0:
		return 0.0

	return (float(mission.progress) / float(mission.target)) * 100.0


func get_completed_missions_today() -> int:
	"""Obtener número de misiones completadas hoy"""
	var completed = 0
	for mission_id in active_missions:
		var mission = active_missions[mission_id]
		if mission.completed:
			completed += 1
	return completed


func get_time_until_reset() -> Dictionary:
	"""Obtener tiempo restante hasta el próximo reset"""
	var current_time = Time.get_unix_time_from_system()
	var current_date = Time.get_date_dict_from_unix_time(current_time)
	var current_time_dict = Time.get_time_dict_from_unix_time(current_time)

	# Calcular próximo reset (mañana a las 00:00 UTC)
	var tomorrow = Time.get_unix_time_from_datetime_dict(
		{
			"year": current_date.year,
			"month": current_date.month,
			"day": current_date.day + 1,
			"hour": RESET_HOUR_UTC,
			"minute": 0,
			"second": 0
		}
	)

	var time_diff = tomorrow - current_time
	var hours = int(time_diff) / 3600
	var minutes = (int(time_diff) % 3600) / 60

	return {"hours": hours, "minutes": minutes, "total_seconds": time_diff}


func save_mission_data() -> Dictionary:
	"""Preparar datos de misiones para guardado"""
	return {"active_missions": active_missions, "last_reset_time": last_reset_time}


func load_mission_data(data: Dictionary):
	"""Cargar datos de misiones desde archivo"""
	if data.has("active_missions"):
		active_missions = data.active_missions
	if data.has("last_reset_time"):
		last_reset_time = data.last_reset_time

	_update_all_mission_progress()


# ============================================================================
# 📊 T030 ENHANCED PUBLIC API
# ============================================================================

func get_all_active_missions() -> Array:
	"""Obtener todas las misiones activas (diarias + semanales)"""
	var all_missions = []

	# Agregar misiones diarias
	for mission_id in active_missions:
		var mission = active_missions[mission_id]
		mission["is_weekly"] = false
		all_missions.append(mission)

	# Agregar misiones semanales
	for mission_id in active_weekly_missions:
		var mission = active_weekly_missions[mission_id]
		mission["is_weekly"] = true
		all_missions.append(mission)

	return all_missions


func get_daily_missions() -> Array:
	"""Obtener solo las misiones diarias"""
	var daily_missions = []
	for mission_id in active_missions:
		daily_missions.append(active_missions[mission_id])
	return daily_missions


func get_weekly_missions() -> Array:
	"""Obtener solo las misiones semanales"""
	var weekly_missions = []
	for mission_id in active_weekly_missions:
		weekly_missions.append(active_weekly_missions[mission_id])
	return weekly_missions


func get_mission_statistics() -> Dictionary:
	"""Obtener estadísticas completas del sistema de misiones"""
	var daily_completed = 0
	var daily_total = active_missions.size()
	var weekly_completed = 0
	var weekly_total = active_weekly_missions.size()

	for mission_id in active_missions:
		if active_missions[mission_id].completed:
			daily_completed += 1

	for mission_id in active_weekly_missions:
		if active_weekly_missions[mission_id].completed:
			weekly_completed += 1

	return {
		"daily": {
			"completed": daily_completed,
			"total": daily_total,
			"percentage": 0.0 if daily_total == 0 else float(daily_completed) / float(daily_total) * 100.0
		},
		"weekly": {
			"completed": weekly_completed,
			"total": weekly_total,
			"percentage": 0.0 if weekly_total == 0 else float(weekly_completed) / float(weekly_total) * 100.0
		},
		"streaks": {
			"daily": daily_streak,
			"weekly": weekly_streak
		},
		"lifetime": {
			"total_completed": total_missions_completed
		}
	}


func get_time_until_weekly_reset() -> Dictionary:
	"""Obtener tiempo restante hasta el próximo reset semanal"""
	if not game_data.has("last_weekly_mission_reset"):
		return {"days": 0, "hours": 0, "minutes": 0, "total_seconds": 0}

	var current_time = Time.get_unix_time_from_system()
	var last_reset = game_data.last_weekly_mission_reset
	var next_reset = last_reset + 604800  # 7 días

	var time_diff = max(0, next_reset - current_time)
	var days = int(time_diff) / 86400
	var hours = (int(time_diff) % 86400) / 3600
	var minutes = (int(time_diff) % 3600) / 60

	return {
		"days": days,
		"hours": hours,
		"minutes": minutes,
		"total_seconds": time_diff
	}


func force_refresh_daily_missions():
	"""Forzar refresh de misiones diarias (para testing)"""
	_generate_daily_missions()
	print("🔄 Misiones diarias refrescadas manualmente")


func force_refresh_weekly_missions():
	"""Forzar refresh de misiones semanales (para testing)"""
	_generate_weekly_missions()
	print("🔄 Misiones semanales refrescadas manualmente")


func debug_complete_mission(mission_id: String):
	"""Completar misión manualmente (para debugging)"""
	if active_missions.has(mission_id):
		_complete_mission(mission_id)
	elif active_weekly_missions.has(mission_id):
		_complete_weekly_mission(mission_id)
	else:
		print("⚠️ Misión no encontrada: ", mission_id)


func debug_print_all_missions():
	"""Imprimir todas las misiones activas (para debugging)"""
	print("=== MISIONES DIARIAS ===")
	for mission_id in active_missions:
		var mission = active_missions[mission_id]
		var status = "✅" if mission.completed else "⏳"
		print("%s %s: %d/%d (%s)" % [status, mission.name, mission.progress, mission.target, mission_id])

	print("=== MISIONES SEMANALES ===")
	for mission_id in active_weekly_missions:
		var mission = active_weekly_missions[mission_id]
		var status = "✅" if mission.completed else "⏳"
		print("%s %s: %d/%d (%s)" % [status, mission.name, mission.progress, mission.target, mission_id])

	var stats = get_mission_statistics()
	print("=== ESTADÍSTICAS ===")
	print("Diarias: %d/%d (%.1f%%)" % [stats.daily.completed, stats.daily.total, stats.daily.percentage])
	print("Semanales: %d/%d (%.1f%%)" % [stats.weekly.completed, stats.weekly.total, stats.weekly.percentage])
	print("Racha diaria: %d | Racha semanal: %d" % [stats.streaks.daily, stats.streaks.weekly])
	print("Total completadas: %d" % stats.lifetime.total_completed)
