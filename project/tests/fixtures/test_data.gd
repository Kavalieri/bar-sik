class_name TestData
extends Resource

## Test Data Fixtures para Bar-Sik Test Suite
## Datos de prueba estandarizados para todos los tests

# Game Data fixtures
static func create_sample_gamedata() -> Dictionary:
	"""Crear GameData de muestra para tests"""
	return {
		"money": 1000.0,
		"tokens": 50,
		"gems": 25,
		"prestige_stars": 2,
		"total_cash_earned": 50000.0,
		"customer_system_unlocked": true,
		"tutorial_completed": true,
		"resources": {
			"barley": 10,
			"hops": 8,
			"water": 20,
			"yeast": 5
		},
		"generators": {
			"basic_brewery": {"owned": 5, "level": 1},
			"hop_farm": {"owned": 2, "level": 1},
			"water_well": {"owned": 1, "level": 1}
		},
		"products": {
			"basic_beer": 100,
			"premium_beer": 50,
			"craft_beer": 10
		},
		"statistics": {
			"total_money_earned": 50000.0,
			"products_sold": 200,
			"customers_served": 150
		}
	}

# UI Test fixtures
static func create_mock_ui_scene() -> Node:
	"""Crear escena UI de prueba"""
	var test_scene = Control.new()
	test_scene.name = "TestUIScene"
	test_scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Crear contenedores básicos
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	test_scene.add_child(main_container)

	var currency_container = HBoxContainer.new()
	currency_container.name = "CurrencyContainer"
	main_container.add_child(currency_container)

	return test_scene

# Manager Test fixtures
static func create_mock_managers(game_data: GameData) -> Dictionary:
	"""Crear managers de prueba con GameData conectado"""
	var managers = {}

	# Production Manager
	managers["production"] = ProductionManager.new()
	managers["production"].set_game_data(game_data)

	# Prestige Manager
	managers["prestige"] = PrestigeManager.new()
	managers["prestige"].set_game_data(game_data)

	# Statistics Manager
	managers["statistics"] = StatisticsManager.new()
	managers["statistics"].set_game_data(game_data)

	return managers

# Test scenarios
static func get_progression_scenarios() -> Array:
	"""Escenarios de progresión del juego para tests"""
	return [
		{
			"name": "Early Game",
			"cash": 100.0,
			"generators": {"basic_brewery": 1},
			"expected_income_per_second": 1.0
		},
		{
			"name": "Mid Game",
			"cash": 10000.0,
			"generators": {"basic_brewery": 10, "hop_farm": 3},
			"expected_income_per_second": 25.0
		},
		{
			"name": "Late Game",
			"cash": 1000000.0,
			"generators": {"basic_brewery": 50, "hop_farm": 20, "water_well": 10},
			"expected_income_per_second": 500.0
		}
	]

# Currency formatting test cases
static func get_currency_format_cases() -> Array:
	"""Casos de prueba para formateo de currency"""
	return [
		{"input": 0.0, "expected": "0"},
		{"input": 50.0, "expected": "50"},
		{"input": 999.0, "expected": "999"},
		{"input": 1000.0, "expected": "1.0K"},
		{"input": 1500.0, "expected": "1.5K"},
		{"input": 999999.0, "expected": "999.9K"},
		{"input": 1000000.0, "expected": "1.0M"},
		{"input": 1500000000.0, "expected": "1.5B"}
	]

# Achievement test data
static func get_achievement_test_cases() -> Array:
	"""Casos de prueba para sistema de achievements"""
	return [
		{
			"id": "first_sale",
			"condition": {"type": "products_sold", "target": 1},
			"reward": {"gems": 10, "tokens": 5}
		},
		{
			"id": "money_milestone",
			"condition": {"type": "total_cash", "target": 1000.0},
			"reward": {"gems": 25, "multiplier": 1.1}
		},
		{
			"id": "prestige_first",
			"condition": {"type": "prestige_count", "target": 1},
			"reward": {"gems": 50, "tokens": 100}
		}
	]

# Performance test benchmarks
static func get_performance_benchmarks() -> Dictionary:
	"""Benchmarks de performance para validation"""
	return {
		"max_frame_time_ms": 16.67,  # 60 FPS
		"max_memory_usage_mb": 200,
		"max_objects_pooled": 1000,
		"max_ui_update_time_ms": 5.0
	}
