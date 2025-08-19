extends Node
## TestGeneratorPersistence - Test para verificar persistencia de generadores

func _ready() -> void:
	print("\n🧪 === TEST DE PERSISTENCIA DE GENERADORES ===")
	call_deferred("_run_persistence_test")

func _run_persistence_test() -> void:
	print("🔍 Ejecutando test de persistencia...")

	# Esperar a que el GameController esté listo
	await get_tree().process_frame
	await get_tree().process_frame

	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("❌ No se encontró GameController")
		return

	print("✅ GameController encontrado")

	# Test 1: Estado inicial
	_test_initial_state(game_controller)

	# Test 2: Comprar generador
	await _test_buy_generator(game_controller)

	# Test 3: Esperar generación
	await _test_wait_generation(game_controller)

	# Test 4: Reset y verificar (DESACTIVADO para evitar reset automático)
	# await _test_reset_and_verify(game_controller)
	print("🔧 Test de reset desactivado para evitar reset automático")

func _test_initial_state(game_controller) -> void:
	print("\n📊 TEST 1: Estado inicial")
	var game_data = game_controller.game_data
	print("💰 Dinero inicial: %.2f" % game_data.money)
	print("📦 Recursos iniciales: %s" % game_data.resources)
	print("🏭 Generadores iniciales: %s" % game_data.generators)

func _test_buy_generator(game_controller) -> bool:
	print("\n🛒 TEST 2: Comprar generador")

	# Simular compra de 1 water_collector
	var gen_manager = game_controller.generator_manager
	var success = gen_manager.purchase_generator("water_collector", 1)

	if success:
		print("✅ Generador comprado exitosamente")
		print("💰 Dinero después: %.2f" % game_controller.game_data.money)
		print("🏭 Generadores después: %s" % game_controller.game_data.generators)
		return true
	else:
		print("❌ Fallo al comprar generador")
		return false

func _test_wait_generation(game_controller) -> void:
	print("\n⏰ TEST 3: Esperando generación (5 segundos)...")

	var initial_water = game_controller.game_data.resources.get("water", 0)
	print("💧 Agua inicial: %d" % initial_water)

	# Esperar 5 segundos
	await get_tree().create_timer(5.0).timeout

	var final_water = game_controller.game_data.resources.get("water", 0)
	print("💧 Agua después de 5s: %d" % final_water)

	if final_water > initial_water:
		print("✅ ¡Generación funcionando!")
	else:
		print("❌ Generación NO funcionando")

func _test_reset_and_verify(game_controller) -> void:
	print("\n🗑️ TEST 4: Reset y verificación")

	# Guardar estado antes del reset
	var before_money = game_controller.game_data.money
	var before_generators = game_controller.game_data.generators.duplicate()

	# Ejecutar reset
	game_controller._on_reset_data_requested()

	# Verificar después del reset
	await get_tree().process_frame

	print("💰 Dinero antes reset: %.2f | después reset: %.2f" % [before_money, game_controller.game_data.money])
	print("🏭 Generadores antes: %s" % before_generators)
	print("🏭 Generadores después: %s" % game_controller.game_data.generators)

	# Verificar que el timer siga funcionando
	var gen_manager = game_controller.generator_manager
	if gen_manager.generation_timer and not gen_manager.generation_timer.is_stopped():
		print("✅ Timer de generación sigue activo después del reset")
	else:
		print("❌ Timer de generación roto después del reset")

	print("🧪 === FIN DEL TEST ===\n")
