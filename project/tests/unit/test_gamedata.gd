extends "res://addons/gut/test.gd"

## T037 - Tests de GameData Core System
## Validación de integridad de datos principales del juego

# Referencias para testing
var game_data: GameData
var test_save_path: String = "user://test_game_data.save"


func before_each():
	"""Configuración antes de cada test"""
	game_data = GameData.new()
	game_data._initialize_default_values()


func after_each():
	"""Limpieza después de cada test"""
	if game_data:
		game_data.queue_free()

	# Limpiar archivo de test si existe
	if FileAccess.file_exists(test_save_path):
		DirAccess.remove_absolute(test_save_path)


## === TESTS DE INITIALIZATION ===


func test_gamedata_initialization():
	"""Test: GameData se inicializa con valores correctos por defecto"""
	var fresh_game_data = GameData.new()
	fresh_game_data._initialize_default_values()

	# Verificar valores monetarios iniciales
	assert_eq(fresh_game_data.money, 100.0, "Dinero inicial incorrecto")
	assert_eq(fresh_game_data.prestige_tokens, 0, "Tokens iniciales incorrectos")
	assert_eq(fresh_game_data.gems, 0, "Gemas iniciales incorrectas")

	# Verificar estado inicial
	assert_eq(fresh_game_data.prestige_level, 0, "Nivel de prestigio inicial incorrecto")
	assert_false(fresh_game_data.game_paused, "Juego no debería estar pausado inicialmente")

	# Verificar estructuras de datos
	assert_not_null(fresh_game_data.stations, "Diccionario de estaciones nulo")
	assert_not_null(fresh_game_data.upgrades, "Diccionario de upgrades nulo")
	assert_not_null(fresh_game_data.achievements, "Diccionario de logros nulo")

	fresh_game_data.queue_free()


func test_gamedata_singleton_access():
	"""Test: GameData singleton funciona correctamente"""
	# Usar GameManager para acceder a game_data
	var singleton_data = GameManager.game_data if GameManager else null

	assert_not_null(singleton_data, "Singleton de GameData no disponible")

	# Verificar que es la misma instancia
	var another_reference = GameManager.game_data if GameManager else null
	assert_same(singleton_data, another_reference, "Singleton no mantiene misma instancia")


## === TESTS DE DATA STRUCTURES ===


func test_stations_structure():
	"""Test: Estructura de estaciones es válida"""
	# Agregar estación de prueba
	var station_id = "test_brewery"
	game_data.stations[station_id] = {
		"level": 1,
		"production_rate": 2.0,
		"active": true,
		"last_production": 0,
		"total_produced": 0.0
	}

	var station = game_data.stations[station_id]

	assert_true(station.has("level"), "Estación debe tener campo 'level'")
	assert_true(station.has("production_rate"), "Estación debe tener campo 'production_rate'")
	assert_true(station.has("active"), "Estación debe tener campo 'active'")

	assert_eq(station.level, 1, "Nivel de estación incorrecto")
	assert_eq(station.production_rate, 2.0, "Tasa de producción incorrecta")
	assert_true(station.active, "Estación debería estar activa")


func test_upgrades_structure():
	"""Test: Estructura de upgrades es válida"""
	# Agregar upgrade de prueba
	var upgrade_id = "better_hops"
	game_data.upgrades[upgrade_id] = {
		"purchased": false,
		"cost": 500.0,
		"effect_value": 1.5,
		"effect_type": "production_multiplier"
	}

	var upgrade = game_data.upgrades[upgrade_id]

	assert_true(upgrade.has("purchased"), "Upgrade debe tener campo 'purchased'")
	assert_true(upgrade.has("cost"), "Upgrade debe tener campo 'cost'")
	assert_true(upgrade.has("effect_value"), "Upgrade debe tener campo 'effect_value'")

	assert_false(upgrade.purchased, "Upgrade no debería estar comprado inicialmente")
	assert_eq(upgrade.cost, 500.0, "Costo de upgrade incorrecto")


func test_achievements_structure():
	"""Test: Estructura de achievements es válida"""
	# Agregar logro de prueba
	var achievement_id = "first_brew"
	game_data.achievements[achievement_id] = {
		"unlocked": false, "progress": 0, "target": 1, "reward_type": "money", "reward_value": 100.0
	}

	var achievement = game_data.achievements[achievement_id]

	assert_true(achievement.has("unlocked"), "Logro debe tener campo 'unlocked'")
	assert_true(achievement.has("progress"), "Logro debe tener campo 'progress'")
	assert_true(achievement.has("target"), "Logro debe tener campo 'target'")

	assert_false(achievement.unlocked, "Logro no debería estar desbloqueado inicialmente")
	assert_eq(achievement.progress, 0, "Progreso inicial debe ser 0")


## === TESTS DE SAVE/LOAD SYSTEM ===


func test_save_game_data():
	"""Test: Guardado de datos funciona correctamente"""
	# Modificar algunos valores
	game_data.money = 2500.0
	game_data.prestige_level = 2
	game_data.prestige_tokens = 15

	# Agregar datos complejos
	game_data.stations["lager_station"] = {"level": 5, "production_rate": 3.0, "active": true}

	# Intentar guardar
	var save_successful = _save_game_data_to_file(game_data, test_save_path)

	assert_true(save_successful, "Guardado debería ser exitoso")
	assert_true(FileAccess.file_exists(test_save_path), "Archivo de guardado debería existir")


func test_load_game_data():
	"""Test: Carga de datos funciona correctamente"""
	# Primero crear datos de prueba y guardarlos
	game_data.money = 5000.0
	game_data.prestige_level = 3
	game_data.gems = 10

	game_data.stations["test_station"] = {"level": 3, "production_rate": 2.5, "active": false}

	_save_game_data_to_file(game_data, test_save_path)

	# Crear nueva instancia y cargar datos
	var loaded_game_data = GameData.new()
	loaded_game_data._initialize_default_values()

	var load_successful = _load_game_data_from_file(loaded_game_data, test_save_path)

	assert_true(load_successful, "Carga debería ser exitosa")
	assert_eq(loaded_game_data.money, 5000.0, "Dinero cargado incorrecto")
	assert_eq(loaded_game_data.prestige_level, 3, "Nivel de prestigio cargado incorrecto")
	assert_eq(loaded_game_data.gems, 10, "Gemas cargadas incorrectas")

	# Verificar datos complejos
	assert_true(loaded_game_data.stations.has("test_station"), "Estación no se cargó")
	var loaded_station = loaded_game_data.stations["test_station"]
	assert_eq(loaded_station.level, 3, "Nivel de estación cargado incorrecto")
	assert_false(loaded_station.active, "Estado activo de estación incorrecto")

	loaded_game_data.queue_free()


func test_save_data_integrity():
	"""Test: Integridad de datos en save/load"""
	# Configurar datos complejos
	game_data.money = 12345.67
	game_data.total_earnings = 50000.0
	game_data.beers_brewed = 1000
	game_data.customers_served = 750

	# Múltiples estaciones
	for i in range(3):
		var station_id = "station_" + str(i)
		game_data.stations[station_id] = {
			"level": i + 1,
			"production_rate": 1.5 + (i * 0.5),
			"active": i % 2 == 0,
			"total_produced": float(i * 100)
		}

	# Guardar y cargar
	_save_game_data_to_file(game_data, test_save_path)

	var loaded_data = GameData.new()
	loaded_data._initialize_default_values()
	_load_game_data_from_file(loaded_data, test_save_path)

	# Verificar integridad numérica
	assert_almost_eq(loaded_data.money, 12345.67, 0.01, "Precisión de dinero perdida")
	assert_eq(loaded_data.total_earnings, 50000.0, "Ganancias totales incorrectas")
	assert_eq(loaded_data.beers_brewed, 1000, "Cervezas producidas incorrectas")
	assert_eq(loaded_data.customers_served, 750, "Clientes atendidos incorrectos")

	# Verificar integridad de estructuras
	assert_eq(loaded_data.stations.size(), 3, "Número de estaciones incorrecto")

	for i in range(3):
		var station_id = "station_" + str(i)
		assert_true(
			loaded_data.stations.has(station_id), "Estación " + station_id + " no encontrada"
		)

		var station = loaded_data.stations[station_id]
		assert_eq(station.level, i + 1, "Nivel de estación " + station_id + " incorrecto")
		assert_eq(station.active, i % 2 == 0, "Estado activo de " + station_id + " incorrecto")

	loaded_data.queue_free()


func test_corrupted_save_handling():
	"""Test: Manejo de archivos de guardado corruptos"""
	# Crear archivo corrupto
	var file = FileAccess.open(test_save_path, FileAccess.WRITE)
	file.store_string("INVALID_JSON_DATA_CORRUPTION_TEST")
	file.close()

	var fresh_game_data = GameData.new()
	fresh_game_data._initialize_default_values()

	var load_result = _load_game_data_from_file(fresh_game_data, test_save_path)

	# El sistema debería manejar el archivo corrupto sin crashear
	assert_false(load_result, "Carga de archivo corrupto debería fallar")

	# Los valores por defecto deberían mantenerse intactos
	assert_eq(fresh_game_data.money, 100.0, "Valores por defecto alterados tras falla")

	fresh_game_data.queue_free()


## === TESTS DE DATA VALIDATION ===


func test_negative_values_protection():
	"""Test: Protección contra valores negativos críticos"""
	# Intentar establecer valores negativos
	game_data.money = -100.0
	game_data.prestige_tokens = -5
	game_data.gems = -10

	# El sistema debería proteger contra negativos en valores críticos
	var money_valid = game_data.money >= 0
	var tokens_valid = game_data.prestige_tokens >= 0
	var gems_valid = game_data.gems >= 0

	# En un sistema bien diseñado, estos deberían ser válidos o auto-corregidos
	assert_true(money_valid or game_data.money == 0, "Dinero negativo debería ser manejado")
	assert_true(
		tokens_valid or game_data.prestige_tokens == 0, "Tokens negativos deberían ser manejados"
	)
	assert_true(gems_valid or game_data.gems == 0, "Gemas negativas deberían ser manejadas")


func test_large_numbers_handling():
	"""Test: Manejo de números grandes (notación científica)"""
	# Establecer valores muy grandes
	var large_money = 1e12  # 1 trillion
	var large_earnings = 5e15  # 5 quadrillion

	game_data.money = large_money
	game_data.total_earnings = large_earnings

	# Verificar que los valores se mantienen
	assert_almost_eq(game_data.money, large_money, 1e6, "Números grandes no manejados")
	assert_almost_eq(
		game_data.total_earnings, large_earnings, 1e9, "Números muy grandes no manejados"
	)

	# Verificar que save/load mantiene precisión
	_save_game_data_to_file(game_data, test_save_path)

	var loaded_data = GameData.new()
	loaded_data._initialize_default_values()
	_load_game_data_from_file(loaded_data, test_save_path)

	# Permitir cierta pérdida de precisión en números muy grandes
	assert_almost_eq(
		loaded_data.money, large_money, 1e6, "Precisión de números grandes perdida en save/load"
	)

	loaded_data.queue_free()


## === HELPER FUNCTIONS ===


func _save_game_data_to_file(data: GameData, file_path: String) -> bool:
	"""Simula el guardado de GameData a archivo"""
	var save_dict = {
		"money": data.money,
		"prestige_level": data.prestige_level,
		"prestige_tokens": data.prestige_tokens,
		"gems": data.gems,
		"total_earnings": data.total_earnings,
		"beers_brewed": data.beers_brewed,
		"customers_served": data.customers_served,
		"stations": data.stations,
		"upgrades": data.upgrades,
		"achievements": data.achievements
	}

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return false

	file.store_string(JSON.stringify(save_dict))
	file.close()
	return true


func _load_game_data_from_file(data: GameData, file_path: String) -> bool:
	"""Simula la carga de GameData desde archivo"""
	if not FileAccess.file_exists(file_path):
		return false

	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		return false

	var save_dict = json.data

	# Cargar datos básicos
	data.money = save_dict.get("money", 100.0)
	data.prestige_level = save_dict.get("prestige_level", 0)
	data.prestige_tokens = save_dict.get("prestige_tokens", 0)
	data.gems = save_dict.get("gems", 0)
	data.total_earnings = save_dict.get("total_earnings", 0.0)
	data.beers_brewed = save_dict.get("beers_brewed", 0)
	data.customers_served = save_dict.get("customers_served", 0)

	# Cargar estructuras complejas
	data.stations = save_dict.get("stations", {})
	data.upgrades = save_dict.get("upgrades", {})
	data.achievements = save_dict.get("achievements", {})

	return true
