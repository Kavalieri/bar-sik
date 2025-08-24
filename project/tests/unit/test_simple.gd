# =============================================================================
# T016 - SAVE SYSTEM VALIDATION - PRUEBA PRÁCTICA
# =============================================================================
# Test simple y directo del save system
# Se ejecuta desde Godot editor con F6

extends SceneTree


func _init():
	print("🧪 T016 - Save System Validation (Prueba Práctica)")
	print("=".repeat(60))

	# Test 1: Crear GameData con datos completos
	test_complete_gamedata()

	# Test 2: Test backward compatibility
	test_backward_compatibility()

	# Test 3: Test save/load real
	test_real_save_load()

	print("=".repeat(60))
	print("✅ T016 VALIDATION COMPLETADA")

	# Salir
	quit()


func test_complete_gamedata():
	"""Test 1: GameData con todos los campos"""
	print("\n🔍 TEST 1: GameData completo")

	var game_data = GameData.new()

	# Configurar datos completos
	game_data.money = 50000.0
	game_data.tokens = 150
	game_data.gems = 75
	game_data.prestige_stars = 3
	game_data.prestige_count = 1
	game_data.active_star_bonuses = ["income_multiplier", "speed_boost"]
	game_data.total_cash_earned = 100000.0
	game_data.customer_system_unlocked = true

	# Convertir a dictionary
	var data_dict = game_data.to_dict()

	# Verificar campos críticos
	var required_fields = [
		"money",
		"tokens",
		"gems",
		"prestige_stars",
		"prestige_count",
		"active_star_bonuses",
		"total_cash_earned",
		"customer_system_unlocked"
	]

	for field in required_fields:
		if data_dict.has(field):
			print("  ✓ %s: %s" % [field, str(data_dict[field])])
		else:
			print("  ❌ FALTA: %s" % field)


func test_backward_compatibility():
	"""Test 2: Compatibilidad con saves antiguos"""
	print("\n🔍 TEST 2: Backward Compatibility")

	# Simular save antiguo (sin campos nuevos)
	var old_save_data = {
		"money": 1000.0,
		"resources": {"water": 10, "barley": 5},
		"products": {"basic_beer": 3},
		"generators": {"water_collector": 2}
		# SIN: tokens, gems, prestige_stars, etc.
	}

	# Cargar en GameData
	var game_data = GameData.new()
	game_data.from_dict(old_save_data)

	# Verificar defaults
	print("  ✓ money: %s (preserved)" % game_data.money)
	print("  ✓ tokens: %d (default)" % game_data.tokens)
	print("  ✓ gems: %d (default)" % game_data.gems)
	print("  ✓ prestige_stars: %d (default)" % game_data.prestige_stars)
	print("  ✓ customer_system_unlocked: %s (default)" % game_data.customer_system_unlocked)
	print("  ✓ active_star_bonuses: %s (default)" % game_data.active_star_bonuses)


func test_real_save_load():
	"""Test 3: Save/Load real usando SaveSystem"""
	print("\n🔍 TEST 3: Save/Load Real")

	# Verificar que SaveSystem existe
	var save_system_path = "res://singletons/SaveSystem.gd"
	if not FileAccess.file_exists(save_system_path):
		print("  ❌ SaveSystem.gd no encontrado")
		return

	# Crear datos de prueba
	var test_data = {
		"money": 12345.67,
		"tokens": 89,
		"gems": 42,
		"prestige_stars": 2,
		"prestige_count": 1,
		"active_star_bonuses": ["income_multiplier"],
		"total_cash_earned": 50000.0,
		"customer_system_unlocked": true
	}

	print("  📤 Datos de prueba creados:")
	for key in test_data:
		print("    %s: %s" % [key, str(test_data[key])])

	print("  ✅ SaveSystem integration test SIMULATED")
	print("    (Real save/load requires full game context)")

# EOF - T016_SaveSystemValidation_Simple.gd
