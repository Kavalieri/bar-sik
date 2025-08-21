class_name OfflineProgressManager
extends Node

## T023 - Sistema de Cálculo de Progreso Offline
## Calcula lo que habría ocurrido durante tiempo offline usando automatizaciones

# Señales para notificar cálculo completado
signal offline_progress_calculated(progress_data: Dictionary)
signal offline_summary_shown

# Referencias a managers
var game_data: GameData
var automation_manager: AutomationManager
var customer_manager: CustomerManager
var generator_manager: GeneratorManager

# Configuración de offline
var max_offline_hours: float = 24.0  # Máximo 24 horas sin premium
var max_offline_premium_hours: float = 72.0  # Máximo 72 horas con premium
var offline_efficiency: float = 0.6  # Eficiencia offline base (60%)
var offline_premium_efficiency: float = 0.85  # Eficiencia con premium (85%)

# Datos de la última sesión
var last_save_time: int = 0
var session_start_time: int = 0


func _ready():
	print("📴 OfflineProgressManager inicializado")
	session_start_time = Time.get_unix_time_from_system()


func set_game_data(data: GameData) -> void:
	"""Asignar referencia a GameData"""
	game_data = data
	print("📴 OfflineProgressManager conectado con GameData")


func set_managers(
	automation: AutomationManager, customer: CustomerManager, generator: GeneratorManager
) -> void:
	"""Asignar referencias a otros managers"""
	automation_manager = automation
	customer_manager = customer
	generator_manager = generator
	print("📴 OfflineProgressManager conectado con managers")


func check_offline_progress() -> Dictionary:
	"""Verificar y calcular progreso offline al abrir el juego"""
	var current_time = Time.get_unix_time_from_system()

	# Obtener tiempo de último guardado
	last_save_time = game_data.get("last_save_time", current_time)

	# Calcular tiempo offline en segundos
	var offline_seconds = current_time - last_save_time

	print("📴 Tiempo offline detectado: %.1f minutos" % (offline_seconds / 60.0))

	# Solo calcular si han pasado más de 5 minutos
	if offline_seconds < 300:  # 5 minutos
		print("📴 Tiempo offline muy corto - No hay progreso")
		return {}

	# Calcular progreso offline
	var progress_data = calculate_offline_progress(offline_seconds)

	# Aplicar progreso si hay resultados
	if not progress_data.is_empty():
		_apply_offline_progress(progress_data)
		offline_progress_calculated.emit(progress_data)

	return progress_data


func calculate_offline_progress(offline_seconds: float) -> Dictionary:
	"""Calcular progreso offline basado en automatizaciones activas"""

	# Limitar tiempo offline según premium
	var has_premium = _has_offline_premium()
	var max_seconds = (max_offline_premium_hours if has_premium else max_offline_hours) * 3600
	offline_seconds = min(offline_seconds, max_seconds)

	print("📴 Calculando progreso para %.1f horas offline" % (offline_seconds / 3600.0))

	var progress_data = {
		"offline_hours": offline_seconds / 3600.0,
		"efficiency": offline_premium_efficiency if has_premium else offline_efficiency,
		"resources_generated": {},
		"products_produced": {},
		"products_sold": {},
		"tokens_earned": 0,
		"customers_served": 0,
		"catch_up_bonus": 0
	}

	# 1. Calcular generación de recursos offline
	progress_data.resources_generated = _calculate_offline_resources(
		offline_seconds, progress_data.efficiency
	)

	# 2. Calcular producción offline (si auto-production activada)
	progress_data.products_produced = _calculate_offline_production(
		offline_seconds, progress_data.efficiency
	)

	# 3. Calcular ventas automáticas offline
	var sell_results = _calculate_offline_auto_sell(offline_seconds, progress_data.efficiency)
	progress_data.products_sold = sell_results.products_sold

	# 4. Calcular clientes automáticos offline
	var customer_results = _calculate_offline_customers(offline_seconds, progress_data.efficiency)
	progress_data.customers_served = customer_results.customers_served
	progress_data.tokens_earned = customer_results.tokens_earned

	# 5. Calcular catch-up bonus
	progress_data.catch_up_bonus = _calculate_catch_up_bonus(offline_seconds)

	return progress_data


# =============================================================================
# CÁLCULOS ESPECÍFICOS DE OFFLINE
# =============================================================================


func _calculate_offline_resources(offline_seconds: float, efficiency: float) -> Dictionary:
	"""Calcular recursos generados offline"""
	var resources_generated = {}

	if not generator_manager or not game_data:
		return resources_generated

	# Para cada tipo de generador activo
	for generator_id in ["water", "barley", "hops", "fruits"]:
		var generator_level = game_data.generators.get(generator_id, 0)
		if generator_level <= 0:
			continue

		# Rate base del generador por segundo
		var base_rate = _get_generator_base_rate(generator_id)
		var level_multiplier = generator_level

		# Calcular generación total offline
		var total_generated = base_rate * level_multiplier * offline_seconds * efficiency

		# Aplicar límites de almacenamiento
		var current_stock = StockManager.get_stock("resource", generator_id)
		var max_storage = StockManager.get_max_stock("resource", generator_id)
		var available_space = max_storage - current_stock

		total_generated = min(total_generated, available_space)
		resources_generated[generator_id] = int(total_generated)

	print("📴 Recursos offline calculados: %s" % str(resources_generated))
	return resources_generated


func _calculate_offline_production(offline_seconds: float, efficiency: float) -> Dictionary:
	"""Calcular productos creados offline via auto-production"""
	var products_produced = {}

	if not automation_manager or not automation_manager.smart_production_priority:
		return products_produced

	# Solo calcular si auto-production está habilitada
	var production_enabled = false
	for station_id in ["brewery", "bar_station", "distillery"]:
		if automation_manager.is_auto_production_enabled(station_id):
			production_enabled = true
			break

	if not production_enabled:
		return products_produced

	# Simular producción cada 10 segundos (intervalo de auto-production offline)
	var production_cycles = int(offline_seconds / 10.0)

	for cycle in range(production_cycles):
		# Obtener cola de producción prioritaria
		var production_queue = _get_offline_production_queue()

		for production_item in production_queue:
			var station_id = production_item.station_id
			var product = production_item.product

			# Verificar recursos suficientes
			if not _has_offline_resources_for_production(station_id):
				continue

			# Verificar espacio en inventario
			var current_stock = StockManager.get_stock("product", product)
			var max_stock = automation_manager._get_max_product_storage(product)
			if current_stock >= max_stock * 0.8:  # Límite de auto-production
				continue

			# Producir 1 unidad
			_consume_offline_resources_for_production(station_id)

			if not products_produced.has(product):
				products_produced[product] = 0
			products_produced[product] += 1

			# Solo 1 producto por ciclo offline (menos agresivo)
			break

	# Aplicar eficiencia offline
	for product in products_produced:
		products_produced[product] = int(products_produced[product] * efficiency)

	print("📴 Productos offline producidos: %s" % str(products_produced))
	return products_produced


func _calculate_offline_auto_sell(offline_seconds: float, efficiency: float) -> Dictionary:
	"""Calcular ventas automáticas offline"""
	var sell_results = {"products_sold": {}, "cash_earned": 0.0}

	if not automation_manager:
		return sell_results

	# Verificar si hay productos con auto-sell habilitado
	var auto_sell_enabled = false
	for product in ["beer", "cocktail", "whiskey"]:
		if automation_manager.is_auto_sell_enabled(product):
			auto_sell_enabled = true
			break

	if not auto_sell_enabled:
		return sell_results

	# Simular auto-sell cada 5 segundos offline
	var sell_cycles = int(offline_seconds / 5.0)

	for cycle in range(sell_cycles):
		for product in ["beer", "cocktail", "whiskey"]:
			if not automation_manager.is_auto_sell_enabled(product):
				continue

			# Verificar si debería vender offline (criterios relajados)
			var current_stock = StockManager.get_stock("product", product)
			var max_stock = automation_manager._get_max_product_storage(product)
			var stock_ratio = float(current_stock) / max(1.0, float(max_stock))

			# Offline: vender si >70% lleno (más conservador)
			if stock_ratio < 0.7:
				continue

			# Calcular cantidad a vender (conservador offline)
			var amount_to_sell = min(3, max(1, int(current_stock * 0.1)))  # 10% o máximo 3

			# Simular venta
			var base_price = automation_manager._get_base_product_price(product)
			var offer_multiplier = 1.2  # Asumir oferta modesta offline
			var earnings = base_price * offer_multiplier * amount_to_sell

			# Registrar venta
			if not sell_results.products_sold.has(product):
				sell_results.products_sold[product] = 0
			sell_results.products_sold[product] += amount_to_sell
			sell_results.cash_earned += earnings

			# Reducir stock simulado
			StockManager.remove_stock("product", product, amount_to_sell)

	# Aplicar eficiencia offline
	sell_results.cash_earned *= efficiency
	for product in sell_results.products_sold:
		sell_results.products_sold[product] = int(sell_results.products_sold[product] * efficiency)

	print(
		(
			"📴 Ventas offline: %s por $%.2f"
			% [str(sell_results.products_sold), sell_results.cash_earned]
		)
	)
	return sell_results


func _calculate_offline_customers(offline_seconds: float, efficiency: float) -> Dictionary:
	"""Calcular clientes automáticos offline"""
	var customer_results = {"customers_served": 0, "tokens_earned": 0}

	if not customer_manager or not game_data.customer_system_unlocked:
		return customer_results

	# Obtener datos de clientes
	var active_customers = customer_manager.active_customers
	if active_customers <= 0:
		return customer_results

	# Calcular intervalo de clientes offline
	var base_interval = 8.0  # Segundos base
	var customer_interval = base_interval / float(active_customers)

	# Calcular clientes servidos
	var customers_served = int(offline_seconds / customer_interval)
	customers_served = int(customers_served * efficiency)

	# Calcular tokens ganados (conservador)
	var base_tokens_per_customer = 1.5  # Promedio conservador

	# Aplicar bonificaciones si están activas
	if game_data.upgrades.get("premium_customers", false):
		base_tokens_per_customer *= 1.5

	var tokens_earned = int(customers_served * base_tokens_per_customer)

	customer_results.customers_served = customers_served
	customer_results.tokens_earned = tokens_earned

	print("📴 Clientes offline: %d servidos, %d tokens" % [customers_served, tokens_earned])
	return customer_results


func _calculate_catch_up_bonus(offline_seconds: float) -> int:
	"""Calcular bonus de catch-up basado en tiempo offline"""
	var offline_hours = offline_seconds / 3600.0

	# Bonus basado en horas offline
	var bonus = 0
	if offline_hours >= 1.0:
		bonus += int(offline_hours * 5)  # 5 tokens por hora

	if offline_hours >= 8.0:
		bonus += 25  # Bonus adicional por sesión larga

	if offline_hours >= 24.0:
		bonus += 50  # Bonus por día completo

	return bonus


# =============================================================================
# APLICAR PROGRESO OFFLINE
# =============================================================================


func _apply_offline_progress(progress_data: Dictionary):
	"""Aplicar el progreso offline calculado al juego"""

	# Aplicar recursos generados
	for resource_id in progress_data.resources_generated:
		var amount = progress_data.resources_generated[resource_id]
		StockManager.add_stock("resource", resource_id, amount)
		print("📴 +%d %s" % [amount, resource_id])

	# Aplicar productos producidos
	for product_id in progress_data.products_produced:
		var amount = progress_data.products_produced[product_id]
		StockManager.add_stock("product", product_id, amount)
		print("📴 +%d %s producidos" % [amount, product_id])

	# Aplicar cash de ventas
	if progress_data.has("cash_earned"):
		var cash_earned = progress_data.cash_earned
		game_data.add_money(cash_earned)
		print("📴 +$%.2f de ventas automáticas" % cash_earned)

	# Aplicar tokens de clientes
	var tokens_earned = progress_data.tokens_earned + progress_data.catch_up_bonus
	if tokens_earned > 0:
		game_data.add_tokens(tokens_earned)
		print(
			(
				"📴 +%d tokens (%d clientes + %d bonus)"
				% [tokens_earned, progress_data.tokens_earned, progress_data.catch_up_bonus]
			)
		)

	print("✅ Progreso offline aplicado exitosamente")


# =============================================================================
# FUNCIONES AUXILIARES
# =============================================================================


func _has_offline_premium() -> bool:
	"""Verificar si tiene premium offline"""
	return game_data.upgrades.get("offline_premium", false)


func _get_generator_base_rate(generator_id: String) -> float:
	"""Obtener rate base por segundo de un generador"""
	match generator_id:
		"water":
			return 1.2
		"barley":
			return 0.8
		"hops":
			return 0.4
		"fruits":
			return 0.3
		_:
			return 0.5


func _get_offline_production_queue() -> Array:
	"""Obtener cola de producción para offline (simplificada)"""
	var queue = []

	# Prioridad simple: más rentable primero
	if automation_manager.is_auto_production_enabled("distillery"):
		queue.append({"station_id": "distillery", "product": "whiskey", "priority": 100})

	if automation_manager.is_auto_production_enabled("bar_station"):
		queue.append({"station_id": "bar_station", "product": "cocktail", "priority": 80})

	if automation_manager.is_auto_production_enabled("brewery"):
		queue.append({"station_id": "brewery", "product": "beer", "priority": 60})

	return queue


func _has_offline_resources_for_production(station_id: String) -> bool:
	"""Verificar recursos offline para producción"""
	var recipe = automation_manager._get_station_recipe(station_id)

	for resource_id in recipe:
		var required = recipe[resource_id]
		var current = StockManager.get_stock("resource", resource_id)
		if current < required:
			return false

	return true


func _consume_offline_resources_for_production(station_id: String):
	"""Consumir recursos para producción offline"""
	var recipe = automation_manager._get_station_recipe(station_id)

	for resource_id in recipe:
		var required = recipe[resource_id]
		StockManager.remove_stock("resource", resource_id, required)


# =============================================================================
# GUARDADO Y CARGA
# =============================================================================


func save_offline_data() -> Dictionary:
	"""Preparar datos offline para guardado"""
	return {
		"last_save_time": Time.get_unix_time_from_system(), "session_start_time": session_start_time
	}


func load_offline_data(data: Dictionary):
	"""Cargar datos offline desde archivo"""
	last_save_time = data.get("last_save_time", Time.get_unix_time_from_system())
	session_start_time = data.get("session_start_time", Time.get_unix_time_from_system())

	print(
		(
			"📴 Datos offline cargados - último save: %s"
			% Time.get_datetime_string_from_unix_time(last_save_time)
		)
	)
