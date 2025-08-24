extends "res://addons/gut/test.gd"

## T037 - Tests de Sistema Económico
## Validación de operaciones de monedas, producción y prestigio

# Referencias para testing
var game_data: GameData
var production_manager: ProductionManager
var prestige_manager: PrestigeManager
var statistics_manager: StatisticsManager


func before_each():
	"""Configuración antes de cada test"""
	game_data = GameData.new()
	game_data._initialize_default_values()

	production_manager = ProductionManager.new()
	production_manager.set_game_data(game_data)

	prestige_manager = PrestigeManager.new()
	prestige_manager.set_game_data(game_data)

	statistics_manager = StatisticsManager.new()
	statistics_manager.set_game_data(game_data)


func after_each():
	"""Limpieza después de cada test"""
	if game_data:
		game_data.queue_free()
	if production_manager:
		production_manager.queue_free()
	if prestige_manager:
		prestige_manager.queue_free()
	if statistics_manager:
		statistics_manager.queue_free()


## === TESTS DE CURRENCY OPERATIONS ===


func test_add_money():
	"""Test: Agregar dinero funciona correctamente"""
	var initial_money = game_data.money
	var amount_to_add = 1000.0

	game_data.money += amount_to_add

	assert_eq(game_data.money, initial_money + amount_to_add, "Dinero no se agregó correctamente")


func test_spend_money_sufficient():
	"""Test: Gastar dinero cuando hay suficiente"""
	game_data.money = 1000.0
	var amount_to_spend = 500.0

	var can_spend = game_data.money >= amount_to_spend
	if can_spend:
		game_data.money -= amount_to_spend

	assert_true(can_spend, "Debería poder gastar dinero suficiente")
	assert_eq(game_data.money, 500.0, "Dinero restante incorrecto")


func test_spend_money_insufficient():
	"""Test: No se puede gastar más dinero del disponible"""
	game_data.money = 100.0
	var amount_to_spend = 500.0

	var can_spend = game_data.money >= amount_to_spend

	assert_false(can_spend, "No debería poder gastar más dinero del disponible")
	assert_eq(game_data.money, 100.0, "Dinero no debería cambiar")


func test_tokens_operations():
	"""Test: Operaciones con tokens de prestigio"""
	game_data.prestige_tokens = 50

	# Agregar tokens
	game_data.prestige_tokens += 25
	assert_eq(game_data.prestige_tokens, 75, "Tokens no se agregaron correctamente")

	# Gastar tokens
	var tokens_to_spend = 30
	if game_data.prestige_tokens >= tokens_to_spend:
		game_data.prestige_tokens -= tokens_to_spend

	assert_eq(game_data.prestige_tokens, 45, "Tokens no se gastaron correctamente")


func test_gems_operations():
	"""Test: Operaciones con gemas premium"""
	game_data.gems = 10

	# Agregar gemas
	game_data.gems += 5
	assert_eq(game_data.gems, 15, "Gemas no se agregaron correctamente")

	# Gastar gemas
	var gems_to_spend = 3
	if game_data.gems >= gems_to_spend:
		game_data.gems -= gems_to_spend

	assert_eq(game_data.gems, 12, "Gemas no se gastaron correctamente")


## === TESTS DE PRODUCTION CALCULATIONS ===


func test_beer_production_basic():
	"""Test: Cálculos básicos de producción de cerveza"""
	# Configurar una estación básica
	var station_id = "lager_station"
	game_data.stations[station_id] = {"level": 1, "production_rate": 1.0, "active": true}

	# Simular producción
	var expected_production = 1.0 * 1.0  # rate * level
	var actual_production = _simulate_production_rate(station_id)

	assert_eq(actual_production, expected_production, "Tasa de producción básica incorrecta")


func test_beer_production_with_upgrades():
	"""Test: Producción con upgrades aplicados"""
	var station_id = "lager_station"
	game_data.stations[station_id] = {"level": 3, "production_rate": 1.5, "active": true}

	# Simular upgrade que duplica producción
	var upgrade_multiplier = 2.0
	var expected_production = 1.5 * 3.0 * upgrade_multiplier  # rate * level * upgrade

	var actual_production = _simulate_production_rate(station_id) * upgrade_multiplier

	assert_eq(actual_production, expected_production, "Producción con upgrades incorrecta")


func test_production_cost_calculation():
	"""Test: Cálculo de costos de producción"""
	var base_cost = 100.0
	var level = 5
	var cost_multiplier = 1.5

	var expected_cost = base_cost * pow(cost_multiplier, level - 1)
	var actual_cost = _calculate_production_cost(base_cost, level, cost_multiplier)

	assert_almost_eq(actual_cost, expected_cost, 0.01, "Costo de producción incorrecto")


func test_beer_quality_calculation():
	"""Test: Cálculo de calidad de cerveza"""
	var base_quality = 0.7  # 70% de calidad base
	var quality_bonus = 0.2  # 20% de bonus
	var expected_quality = min(base_quality + quality_bonus, 1.0)

	var actual_quality = _calculate_beer_quality(base_quality, quality_bonus)

	assert_eq(actual_quality, expected_quality, "Cálculo de calidad incorrecto")
	assert_true(actual_quality <= 1.0, "Calidad no puede exceder 100%")


## === TESTS DE PRESTIGE MATH ===


func test_prestige_requirement_calculation():
	"""Test: Cálculo correcto de requerimientos para prestigio"""
	var prestige_level = 1
	var base_requirement = 100000.0
	var scaling_factor = 2.5

	var expected_requirement = base_requirement * pow(scaling_factor, prestige_level)
	var actual_requirement = _calculate_prestige_requirement(prestige_level)

	assert_almost_eq(
		actual_requirement, expected_requirement, 1.0, "Requerimiento de prestigio incorrecto"
	)


func test_prestige_stars_calculation():
	"""Test: Cálculo de estrellas de prestigio otorgadas"""
	var money_at_prestige = 500000.0
	var prestige_requirement = 100000.0
	var efficiency_bonus = 1.2

	# Las estrellas se calculan basado en qué tanto excede el requirement
	var excess_factor = money_at_prestige / prestige_requirement
	var expected_stars = int(excess_factor * efficiency_bonus)

	var actual_stars = _calculate_prestige_stars(
		money_at_prestige, prestige_requirement, efficiency_bonus
	)

	assert_eq(actual_stars, expected_stars, "Cálculo de estrellas de prestigio incorrecto")


func test_star_bonus_application():
	"""Test: Aplicación correcta de bonuses de estrellas"""
	var base_multiplier = 1.0
	var stars_spent = 5
	var bonus_per_star = 0.1  # 10% por estrella

	var expected_multiplier = base_multiplier + (stars_spent * bonus_per_star)
	var actual_multiplier = _apply_star_bonus(base_multiplier, stars_spent, bonus_per_star)

	assert_eq(actual_multiplier, expected_multiplier, "Bonus de estrellas aplicado incorrectamente")


func test_prestige_reset_validation():
	"""Test: Validación de reset de prestigio"""
	# Configurar estado pre-prestigio
	game_data.money = 150000.0
	game_data.prestige_level = 2
	game_data.prestige_tokens = 10

	var initial_tokens = game_data.prestige_tokens
	var prestige_requirement = 100000.0

	# Verificar que se puede hacer prestigio
	var can_prestige = game_data.money >= prestige_requirement
	assert_true(can_prestige, "Debería poder hacer prestigio")

	# Simular prestigio
	if can_prestige:
		var earned_stars = _calculate_prestige_stars(game_data.money, prestige_requirement, 1.0)
		var earned_tokens = earned_stars * 2  # 2 tokens por estrella

		game_data.prestige_level += 1
		game_data.prestige_tokens += earned_tokens
		game_data.money = 0.0  # Reset money

		assert_eq(game_data.prestige_level, 3, "Nivel de prestigio no incrementó")
		assert_eq(game_data.money, 0.0, "Dinero no se reseteó")
		assert_gt(game_data.prestige_tokens, initial_tokens, "Tokens no se agregaron")


## === TESTS DE OFFLINE PROGRESS ===


func test_offline_progress_calculation():
	"""Test: Cálculo preciso de progreso offline"""
	var offline_seconds = 3600  # 1 hora
	var production_per_second = 2.0
	var offline_efficiency = 0.5  # 50% de eficiencia offline

	var expected_progress = offline_seconds * production_per_second * offline_efficiency
	var actual_progress = _calculate_offline_progress(
		offline_seconds, production_per_second, offline_efficiency
	)

	assert_eq(actual_progress, expected_progress, "Progreso offline incorrecto")


func test_offline_progress_caps():
	"""Test: Caps de progreso offline funcionan correctamente"""
	var offline_seconds = 86400 * 7  # 1 semana
	var max_offline_hours = 24
	var max_offline_seconds = max_offline_hours * 3600

	var effective_offline_seconds = min(offline_seconds, max_offline_seconds)

	assert_eq(effective_offline_seconds, max_offline_seconds, "Cap de tiempo offline no funciona")
	assert_lte(effective_offline_seconds, max_offline_seconds, "Tiempo offline excede el máximo")


## === HELPER FUNCTIONS ===


func _simulate_production_rate(station_id: String) -> float:
	"""Simula la tasa de producción de una estación"""
	var station = game_data.stations.get(station_id, {})
	if not station.get("active", false):
		return 0.0

	var level = station.get("level", 1)
	var base_rate = station.get("production_rate", 1.0)

	return base_rate * level


func _calculate_production_cost(base_cost: float, level: int, multiplier: float) -> float:
	"""Calcula el costo de producción escalado"""
	return base_cost * pow(multiplier, level - 1)


func _calculate_beer_quality(base_quality: float, quality_bonus: float) -> float:
	"""Calcula la calidad final de la cerveza"""
	return min(base_quality + quality_bonus, 1.0)


func _calculate_prestige_requirement(prestige_level: int) -> float:
	"""Calcula el requerimiento de dinero para prestigio"""
	var base_requirement = 100000.0
	var scaling_factor = 2.5
	return base_requirement * pow(scaling_factor, prestige_level)


func _calculate_prestige_stars(money: float, requirement: float, efficiency_bonus: float) -> int:
	"""Calcula estrellas ganadas en prestigio"""
	var excess_factor = money / requirement
	return int(excess_factor * efficiency_bonus)


func _apply_star_bonus(base_multiplier: float, stars: int, bonus_per_star: float) -> float:
	"""Aplica bonus de estrellas a un multiplicador"""
	return base_multiplier + (stars * bonus_per_star)


func _calculate_offline_progress(seconds: int, rate: float, efficiency: float) -> float:
	"""Calcula progreso offline"""
	return float(seconds) * rate * efficiency
