# =============================================================================
# T016 - SAVE SYSTEM INTEGRATION VALIDATION SCRIPT
# =============================================================================
# Validar que todos los sistemas implementados se guarden/carguen correctamente
# Fecha: 22 Agosto 2025

extends Node

# Test data para validar diferentes escenarios
var test_scenarios = [
	{"name": "New Player", "data": {}},
	{
		"name": "Mid Game Player",
		"data":
		{
			"money": 50000.0,
			"tokens": 150,
			"gems": 75,
			"customer_system_unlocked": true,
			"total_cash_earned": 75000.0,
			"generators": {"water_collector": 5, "barley_farm": 3},
			"upgrades": {"faster_customers": true}
		}
	},
	{
		"name": "Prestige Player",
		"data":
		{
			"money": 1500000.0,
			"tokens": 890,
			"gems": 250,
			"prestige_stars": 3,
			"prestige_count": 1,
			"active_star_bonuses": ["income_multiplier", "speed_boost"],
			"total_cash_earned": 15000000.0,
			"customer_system_unlocked": true,
			"upgrades": {"premium_customers": true, "bulk_buyers": true}
		}
	}
]


func _ready():
	print("🧪 T016 - Save System Integration Validation")
	print("=============================================================================")

	# Esperar un frame para que todo se inicialice
	await get_tree().process_frame

	# Ejecutar tests
	run_all_tests()


func run_all_tests():
	"""Ejecutar todos los tests de validación"""
	var total_tests = 0
	var passed_tests = 0

	# Test 1: Validar estructura de GameData
	print("\n🔍 TEST 1: Validar estructura GameData.to_dict()")
	if test_gamedata_structure():
		passed_tests += 1
		print("✅ PASSED - GameData estructura correcta")
	else:
		print("❌ FAILED - GameData estructura incorrecta")
	total_tests += 1

	# Test 2: Save/Load básico
	print("\n🔍 TEST 2: Save/Load básico")
	if test_basic_save_load():
		passed_tests += 1
		print("✅ PASSED - Save/Load básico funcional")
	else:
		print("❌ FAILED - Save/Load básico con errores")
	total_tests += 1

	# Test 3: Backward compatibility
	print("\n🔍 TEST 3: Backward compatibility con saves antiguos")
	if test_backward_compatibility():
		passed_tests += 1
		print("✅ PASSED - Backward compatibility funcional")
	else:
		print("❌ FAILED - Backward compatibility con problemas")
	total_tests += 1

	# Test 4: Campos de prestigio
	print("\n🔍 TEST 4: Campos de sistema de prestigio")
	if test_prestige_fields():
		passed_tests += 1
		print("✅ PASSED - Campos de prestigio correctos")
	else:
		print("❌ FAILED - Campos de prestigio con problemas")
	total_tests += 1

	# Test 5: Triple currency system
	print("\n🔍 TEST 5: Triple currency system")
	if test_triple_currency():
		passed_tests += 1
		print("✅ PASSED - Triple currency system correcto")
	else:
		print("❌ FAILED - Triple currency system con problemas")
	total_tests += 1

	# Test 6: Stress test con datos grandes
	print("\n🔍 TEST 6: Stress test con datos grandes")
	if test_large_data_handling():
		passed_tests += 1
		print("✅ PASSED - Manejo de datos grandes correcto")
	else:
		print("❌ FAILED - Problemas con datos grandes")
	total_tests += 1

	# Resultados finales
	print("\n=============================================================================")
	print("📊 RESULTADOS FINALES T016:")
	print("✅ Tests Pasados: %d/%d" % [passed_tests, total_tests])
	print("📈 Success Rate: %.1f%%" % ((passed_tests * 100.0) / total_tests))

	if passed_tests == total_tests:
		print("🎉 ¡TODOS LOS TESTS PASARON! Save System validado al 100%")
	elif passed_tests >= (total_tests * 0.8):
		print("⚠️ La mayoría de tests pasaron, revisar fallos menores")
	else:
		print("❌ CRÍTICO: Múltiples fallos en Save System, requiere fixes")

	print("=============================================================================")


func test_gamedata_structure() -> bool:
	"""Validar que GameData.to_dict() incluye todos los campos necesarios"""
	var game_data = GameData.new()
	var data_dict = game_data.to_dict()

	var required_fields = [
		"money",
		"tokens",
		"gems",
		"customer_system_unlocked",
		"prestige_stars",
		"prestige_count",
		"active_star_bonuses",
		"total_cash_earned",
		"resources",
		"products",
		"generators",
		"stations",
		"upgrades",
		"statistics"
	]

	for field in required_fields:
		if not data_dict.has(field):
			print("❌ Campo faltante: %s" % field)
			return false
		print("✓ Campo presente: %s" % field)

	return true


func test_basic_save_load() -> bool:
	"""Test básico de guardado y carga"""
	if not SaveSystem:
		print("❌ SaveSystem no disponible")
		return false

	# Crear data de prueba
	var test_data = {
		"money": 12345.67,
		"tokens": 89,
		"gems": 42,
		"prestige_stars": 2,
		"total_cash_earned": 50000.0,
		"active_star_bonuses": ["income_multiplier"],
		"resources": {"water": 25, "barley": 15}
	}

	# Guardar
	var save_success = SaveSystem.save_game_data_with_encryption(test_data)
	if not save_success:
		print("❌ Error al guardar datos de prueba")
		return false

	# Cargar
	var loaded_data = SaveSystem.load_game_data()
	if loaded_data.is_empty():
		print("❌ Error al cargar datos guardados")
		return false

	# Verificar campos críticos
	var critical_fields = ["money", "tokens", "gems", "prestige_stars"]
	for field in critical_fields:
		if not loaded_data.has(field):
			print("❌ Campo crítico faltante después de load: %s" % field)
			return false
		if loaded_data[field] != test_data[field]:
			print(
				(
					"❌ Valor incorrecto para %s: esperado %s, obtenido %s"
					% [field, test_data[field], loaded_data[field]]
				)
			)
			return false

	return true


func test_backward_compatibility() -> bool:
	"""Verificar que saves antiguos sin campos de prestigio se cargan correctamente"""
	var old_save_format = {
		"money": 1000.0,
		"resources": {"water": 10, "barley": 5},
		"products": {"basic_beer": 3},
		"generators": {"water_collector": 2}
		# Sin tokens, gems, ni campos de prestigio
	}

	# Crear GameData y cargar formato antiguo
	var game_data = GameData.new()
	game_data.from_dict(old_save_format)

	# Verificar que los campos nuevos tienen valores por defecto
	if game_data.tokens != 0:
		print("❌ Tokens no inicializados correctamente: %d" % game_data.tokens)
		return false

	if game_data.gems != 100:
		print("❌ Gems no inicializados correctamente: %d" % game_data.gems)
		return false

	if game_data.prestige_stars != 0:
		print("❌ Prestige stars no inicializados correctamente: %d" % game_data.prestige_stars)
		return false

	if game_data.active_star_bonuses.size() != 0:
		print(
			(
				"❌ Active star bonuses no inicializados correctamente: %s"
				% game_data.active_star_bonuses
			)
		)
		return false

	return true


func test_prestige_fields() -> bool:
	"""Verificar que todos los campos de prestigio se guardan/cargan correctamente"""
	var game_data = GameData.new()

	# Configurar datos de prestigio
	game_data.prestige_stars = 5
	game_data.prestige_count = 2
	game_data.active_star_bonuses = ["income_multiplier", "speed_boost", "premium_customers"]
	game_data.total_cash_earned = 25000000.0

	# Convertir a dict y de vuelta
	var data_dict = game_data.to_dict()
	var new_game_data = GameData.new()
	new_game_data.from_dict(data_dict)

	# Verificar que los valores se preservan
	if new_game_data.prestige_stars != 5:
		print("❌ prestige_stars no preservado: %d" % new_game_data.prestige_stars)
		return false

	if new_game_data.prestige_count != 2:
		print("❌ prestige_count no preservado: %d" % new_game_data.prestige_count)
		return false

	if new_game_data.active_star_bonuses.size() != 3:
		print(
			"❌ active_star_bonuses size incorrecto: %d" % new_game_data.active_star_bonuses.size()
		)
		return false

	if new_game_data.total_cash_earned != 25000000.0:
		print("❌ total_cash_earned no preservado: %f" % new_game_data.total_cash_earned)
		return false

	return true


func test_triple_currency() -> bool:
	"""Verificar que el sistema de triple currency funciona correctamente"""
	var game_data = GameData.new()

	# Test métodos de cash
	game_data.add_money(1000.0)
	if game_data.money != 1050.0:  # 50 inicial + 1000
		print("❌ add_money falló: expected 1050.0, got %f" % game_data.money)
		return false

	if not game_data.spend_money(500.0):
		print("❌ spend_money debería retornar true")
		return false

	if game_data.money != 550.0:
		print("❌ spend_money falló: expected 550.0, got %f" % game_data.money)
		return false

	# Test métodos de tokens
	game_data.add_tokens(100)
	if game_data.tokens != 100:
		print("❌ add_tokens falló: expected 100, got %d" % game_data.tokens)
		return false

	if not game_data.spend_tokens(25):
		print("❌ spend_tokens debería retornar true")
		return false

	if game_data.tokens != 75:
		print("❌ spend_tokens falló: expected 75, got %d" % game_data.tokens)
		return false

	# Test métodos de gems
	game_data.add_gems(50)
	if game_data.gems != 150:  # 100 inicial + 50
		print("❌ add_gems falló: expected 150, got %d" % game_data.gems)
		return false

	if not game_data.spend_gems(25):
		print("❌ spend_gems debería retornar true")
		return false

	if game_data.gems != 125:
		print("❌ spend_gems falló: expected 125, got %d" % game_data.gems)
		return false

	return true


func test_large_data_handling() -> bool:
	"""Test con datos grandes para verificar performance y estabilidad"""
	var game_data = GameData.new()

	# Generar datos grandes
	game_data.total_cash_earned = 999999999999.0  # 1 trillion
	game_data.prestige_stars = 50
	game_data.prestige_count = 25

	# Llenar con muchas bonificaciones
	for i in range(20):
		game_data.active_star_bonuses.append("bonus_%d" % i)

	# Llenar estadísticas grandes
	game_data.statistics["products_sold"] = 1000000
	game_data.statistics["customers_served"] = 500000

	# Convertir a dict y medir tiempo
	var start_time = Time.get_ticks_msec()
	var data_dict = game_data.to_dict()
	var conversion_time = Time.get_ticks_msec() - start_time

	if conversion_time > 100:  # Más de 100ms es demasiado
		print("❌ Conversión muy lenta: %d ms" % conversion_time)
		return false

	# Verificar que el dict no está corrupto
	if not data_dict.has("total_cash_earned"):
		print("❌ Dict corrupto después de conversión")
		return false

	if data_dict["active_star_bonuses"].size() != 20:
		print(
			"❌ Array grande corrupto: expected 20, got %d" % data_dict["active_star_bonuses"].size()
		)
		return false

	return true

# EOF - T016_SaveSystemValidation.gd
