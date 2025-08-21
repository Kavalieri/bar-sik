class_name MissionManager
extends Node

## T018 - Sistema de Misiones Diarias
## Manager que controla las misiones diarias del juego

# Señales para notificar eventos
signal mission_completed(mission_id: String, mission_data: Dictionary)
signal daily_missions_reset
signal mission_progress_updated(mission_id: String, progress: int, total: int)

# Referencia a GameData para acceder a estadísticas
var game_data: GameData

# Estado de las misiones
var active_missions: Dictionary = {}
var mission_definitions: Dictionary = {}
var last_reset_time: int = 0  # Timestamp del último reset

# Constantes
const MISSIONS_PER_DAY = 3
const RESET_HOUR_UTC = 0  # 00:00 UTC


func _ready():
	print("📅 MissionManager inicializado")
	_init_mission_definitions()

	# Timer para verificar reset diario
	var reset_timer = Timer.new()
	reset_timer.wait_time = 60.0  # Verificar cada minuto
	reset_timer.timeout.connect(_check_daily_reset)
	reset_timer.autostart = true
	add_child(reset_timer)


func set_game_data(data: GameData) -> void:
	"""Asignar referencia a GameData"""
	game_data = data
	print("📅 MissionManager conectado con GameData")

	# Cargar misiones guardadas o generar nuevas
	_load_or_generate_missions()


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
