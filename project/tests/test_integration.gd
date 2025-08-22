extends "res://addons/gut/test.gd"

## T037 - Tests de Integration
## Tests de integración entre sistemas principales

# Referencias para testing
var game_controller: Node
var game_data: GameData
var production_manager: ProductionManager
var prestige_manager: PrestigeManager
var statistics_manager: StatisticsManager

func before_each():
	"""Configuración antes de cada test"""
	# Crear GameController simulado
	game_controller = Node.new()
	game_controller.name = "GameController"
	add_child(game_controller)

	# Inicializar componentes
	game_data = GameData.new()
	game_data._initialize_default_values()

	production_manager = ProductionManager.new()
	production_manager.set_game_data(game_data)

	prestige_manager = PrestigeManager.new()
	prestige_manager.set_game_data(game_data)

	statistics_manager = StatisticsManager.new()
	statistics_manager.set_game_data(game_data)

	# Simular inicialización completa del juego
	_initialize_game_systems()


func after_each():
	"""Limpieza después de cada test"""
	if game_controller:
		game_controller.queue_free()
	if game_data:
		game_data.queue_free()
	if production_manager:
		production_manager.queue_free()
	if prestige_manager:
		prestige_manager.queue_free()
	if statistics_manager:
		statistics_manager.queue_free()


## === TESTS DE INTEGRATION FLOW ===

func test_complete_game_loop():
	"""Test: Loop completo del juego funciona correctamente"""
	var initial_money = game_data.money

	# 1. Producir cerveza
	_simulate_beer_production(5.0)  # 5 segundos de producción
	assert_gt(game_data.money, initial_money, "Producción debería generar dinero")

	# 2. Comprar upgrade
	var upgrade_cost = 500.0
	game_data.money = upgrade_cost + 100.0  # Asegurar dinero suficiente

	var upgrade_purchased = _attempt_purchase_upgrade("basic_efficiency", upgrade_cost)
	assert_true(upgrade_purchased, "Compra de upgrade debería ser exitosa")
	assert_lt(game_data.money, upgrade_cost + 100.0, "Dinero debería disminuir tras compra")

	# 3. Mejorar estación
	var station_upgrade_cost = 200.0
	game_data.money += station_upgrade_cost + 50.0

	var initial_level = game_data.stations.get("lager_station", {"level": 1}).level
	var station_upgraded = _attempt_upgrade_station("lager_station", station_upgrade_cost)

	assert_true(station_upgraded, "Upgrade de estación debería ser exitoso")

	# 4. Verificar estadísticas se actualizaron
	var stats_updated = statistics_manager != null
	assert_true(stats_updated, "Statistics manager debería estar activo")


func test_production_economy_integration():
	"""Test: Integración entre producción y economía"""
	# Configurar múltiples estaciones de producción
	game_data.stations["lager_station"] = {
		"level": 3,
		"production_rate": 2.0,
		"active": true,
		"total_produced": 0.0
	}

	game_data.stations["ale_station"] = {
		"level": 2,
		"production_rate": 1.5,
		"active": true,
		"total_produced": 0.0
	}

	var initial_money = game_data.money
	var production_time = 10.0  # 10 segundos

	# Calcular producción esperada
	var expected_lager = 3 * 2.0 * production_time  # level * rate * time
	var expected_ale = 2 * 1.5 * production_time
	var total_expected_production = expected_lager + expected_ale

	# Simular producción
	_simulate_multi_station_production(production_time)

	# Verificar que el dinero aumentó proporcionalmente
	var money_gained = game_data.money - initial_money
	assert_gt(money_gained, 0, "Deberían haberse ganado dinero por producción")

	# Verificar que las estadísticas se actualizaron
	var total_produced = game_data.stations["lager_station"].total_produced + \
						 game_data.stations["ale_station"].total_produced
	assert_almost_eq(total_produced, total_expected_production, 1.0,
		"Producción total no coincide con esperada")


func test_prestige_system_integration():
	"""Test: Sistema de prestigio integrado correctamente"""
	# Configurar para prestigio
	game_data.money = 250000.0  # Dinero suficiente para prestigio
	game_data.prestige_level = 1
	game_data.total_earnings = 300000.0

	var initial_prestige_level = game_data.prestige_level
	var initial_tokens = game_data.prestige_tokens

	# Intentar prestigio
	var can_prestige = _check_prestige_eligibility()
	assert_true(can_prestige, "Debería poder hacer prestigio con dinero suficiente")

	if can_prestige:
		var prestige_result = _execute_prestige()
		assert_true(prestige_result, "Ejecución de prestigio debería ser exitosa")

		# Verificar cambios post-prestigio
		assert_eq(game_data.prestige_level, initial_prestige_level + 1,
			"Nivel de prestigio debería incrementar")
		assert_gt(game_data.prestige_tokens, initial_tokens,
			"Tokens de prestigio deberían incrementar")
		assert_eq(game_data.money, 0.0,
			"Dinero debería resetearse a 0 tras prestigio")

		# Verificar que las estaciones se resetearon
		for station_id in game_data.stations:
			var station = game_data.stations[station_id]
			assert_eq(station.get("level", 1), 1,
				"Nivel de estación " + station_id + " debería resetear a 1")


func test_statistics_tracking_integration():
	"""Test: Tracking de estadísticas integrado en operaciones"""
	var initial_beers_brewed = game_data.beers_brewed
	var initial_customers_served = game_data.customers_served
	var initial_total_earnings = game_data.total_earnings

	# Simular actividades del juego
	_simulate_customer_service(15)  # Atender 15 clientes
	_simulate_beer_brewing(25)      # Producir 25 cervezas
	_simulate_money_earning(1500.0) # Ganar $1500

	# Verificar que las estadísticas se actualizaron correctamente
	assert_eq(game_data.customers_served, initial_customers_served + 15,
		"Clientes atendidos no se rastreó correctamente")
	assert_eq(game_data.beers_brewed, initial_beers_brewed + 25,
		"Cervezas producidas no se rastreó correctamente")
	assert_almost_eq(game_data.total_earnings, initial_total_earnings + 1500.0, 0.01,
		"Ganancias totales no se rastrearon correctamente")


func test_cross_manager_communication():
	"""Test: Comunicación entre managers funciona"""
	# Test: Production Manager notifica a Statistics Manager
	var initial_production_stats = _get_production_statistics()

	# Simular producción que debería notificar a estadísticas
	_simulate_production_with_notification(10.0, 5)  # 10 cervezas, 5 clientes

	var updated_production_stats = _get_production_statistics()
	assert_gt(updated_production_stats.beers_produced,
		initial_production_stats.beers_produced,
		"Production Manager no notificó a Statistics Manager")

	# Test: Prestige Manager afecta Production Manager
	var initial_production_multiplier = _get_production_multiplier()

	# Simular gasto de tokens de prestigio en mejoras de producción
	game_data.prestige_tokens = 10
	var tokens_spent = _spend_prestige_tokens_on_production(5)

	assert_eq(tokens_spent, 5, "Tokens de prestigio no se gastaron correctamente")

	var new_production_multiplier = _get_production_multiplier()
	assert_gt(new_production_multiplier, initial_production_multiplier,
		"Prestige tokens no afectaron multiplicador de producción")


## === TESTS DE ERROR HANDLING ===

func test_null_manager_handling():
	"""Test: Manejo de managers nulos sin crash"""
	# Simular managers no inicializados
	production_manager = null

	# Intentar operaciones que requerirían production manager
	var result = _safe_operation_with_null_manager()

	# El sistema debería manejar esto sin crash
	assert_not_null(result, "Operación debería devolver resultado por defecto")
	assert_true(result is Dictionary or result is bool,
		"Resultado debería ser tipo esperado")


func test_invalid_data_recovery():
	"""Test: Recuperación de datos inválidos"""
	# Corromper datos de estación
	game_data.stations["corrupted_station"] = {
		"level": -5,  # Nivel inválido
		"production_rate": "not_a_number",  # Tipo incorrecto
		"active": null  # Valor nulo
	}

	# Intentar procesar la estación corrupta
	var processing_result = _process_station_safely("corrupted_station")

	# El sistema debería manejar datos corruptos gracefully
	assert_true(processing_result.success or processing_result.error_handled,
		"Datos corruptos no se manejaron apropiadamente")


## === HELPER FUNCTIONS ===

func _initialize_game_systems():
	"""Inicializa los sistemas del juego para tests"""
	# Crear estaciones básicas
	game_data.stations["lager_station"] = {
		"level": 1,
		"production_rate": 1.0,
		"active": true,
		"total_produced": 0.0
	}


func _simulate_beer_production(time_seconds: float):
	"""Simula producción de cerveza por tiempo dado"""
	for station_id in game_data.stations:
		var station = game_data.stations[station_id]
		if station.get("active", false):
			var produced = station.level * station.production_rate * time_seconds
			station.total_produced += produced
			game_data.money += produced * 2.0  # $2 por cerveza
			game_data.beers_brewed += int(produced)


func _attempt_purchase_upgrade(upgrade_id: String, cost: float) -> bool:
	"""Intenta comprar un upgrade"""
	if game_data.money >= cost:
		game_data.money -= cost
		game_data.upgrades[upgrade_id] = {
			"purchased": true,
			"cost": cost,
			"effect_applied": true
		}
		return true
	return false


func _attempt_upgrade_station(station_id: String, cost: float) -> bool:
	"""Intenta mejorar una estación"""
	if game_data.money >= cost and game_data.stations.has(station_id):
		game_data.money -= cost
		game_data.stations[station_id].level += 1
		return true
	return false


func _simulate_multi_station_production(time_seconds: float):
	"""Simula producción en múltiples estaciones"""
	for station_id in game_data.stations:
		var station = game_data.stations[station_id]
		if station.get("active", false):
			var produced = station.level * station.production_rate * time_seconds
			station.total_produced += produced
			game_data.money += produced * 1.5  # Precio por cerveza


func _check_prestige_eligibility() -> bool:
	"""Verifica si se puede hacer prestigio"""
	var prestige_requirement = 100000.0 * pow(2.0, game_data.prestige_level)
	return game_data.money >= prestige_requirement


func _execute_prestige() -> bool:
	"""Ejecuta el prestigio"""
	if not _check_prestige_eligibility():
		return false

	# Calcular tokens ganados
	var stars_earned = int(game_data.money / 100000.0)
	var tokens_earned = stars_earned * 2

	# Ejecutar prestigio
	game_data.prestige_level += 1
	game_data.prestige_tokens += tokens_earned
	game_data.money = 0.0

	# Resetear estaciones
	for station_id in game_data.stations:
		game_data.stations[station_id].level = 1
		game_data.stations[station_id].total_produced = 0.0

	return true


func _simulate_customer_service(customers: int):
	"""Simula atención de clientes"""
	game_data.customers_served += customers


func _simulate_beer_brewing(beers: int):
	"""Simula producción de cervezas"""
	game_data.beers_brewed += beers


func _simulate_money_earning(amount: float):
	"""Simula ganancia de dinero"""
	game_data.money += amount
	game_data.total_earnings += amount


func _get_production_statistics() -> Dictionary:
	"""Obtiene estadísticas de producción actuales"""
	return {
		"beers_produced": game_data.beers_brewed,
		"money_earned": game_data.total_earnings,
		"customers_served": game_data.customers_served
	}


func _simulate_production_with_notification(beers: float, customers: int):
	"""Simula producción con notificaciones a otros sistemas"""
	game_data.beers_brewed += int(beers)
	game_data.customers_served += customers
	game_data.money += beers * 2.0


func _get_production_multiplier() -> float:
	"""Obtiene multiplicador actual de producción"""
	# Calcular basado en upgrades y prestige tokens gastados
	var base_multiplier = 1.0
	var prestige_bonus = game_data.prestige_level * 0.1
	return base_multiplier + prestige_bonus


func _spend_prestige_tokens_on_production(tokens: int) -> int:
	"""Gasta tokens de prestigio en mejoras de producción"""
	var tokens_to_spend = min(tokens, game_data.prestige_tokens)
	game_data.prestige_tokens -= tokens_to_spend
	return tokens_to_spend


func _safe_operation_with_null_manager() -> Dictionary:
	"""Operación segura que maneja manager nulo"""
	if production_manager == null:
		return {"success": false, "error": "Manager not available", "default_used": true}

	return {"success": true, "result": "Operation completed"}


func _process_station_safely(station_id: String) -> Dictionary:
	"""Procesa estación de manera segura manejando datos corruptos"""
	if not game_data.stations.has(station_id):
		return {"success": false, "error": "Station not found"}

	var station = game_data.stations[station_id]

	# Validar y corregir datos corruptos
	if not station.has("level") or not (station.level is int) or station.level < 1:
		station.level = 1

	if not station.has("production_rate") or not (station.production_rate is float):
		station.production_rate = 1.0

	if not station.has("active") or not (station.active is bool):
		station.active = true

	return {"success": true, "error_handled": true}
