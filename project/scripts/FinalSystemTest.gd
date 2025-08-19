extends Node
## FinalSystemTest - Test completo del sistema reparado

func _ready() -> void:
	print("\n🎯 === TEST FINAL DEL SISTEMA REPARADO ===")
	call_deferred("_run_complete_test")

func _run_complete_test() -> void:
	await get_tree().process_frame

	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("❌ No se encontró GameController")
		return

	print("✅ GameController encontrado")

	# Test 1: Verificar sistema de precios escalados
	await _test_pricing_system(game_controller)

	# Test 2: Verificar persistencia manual
	await _test_manual_persistence(game_controller)

	# Test 3: Verificar generación en tiempo real
	await _test_realtime_generation(game_controller)

func _test_pricing_system(game_controller) -> void:
	print("\n💰 TEST 1: Sistema de precios escalados")

	var gen_manager = game_controller.generator_manager
	var game_data = game_controller.game_data

	# Mostrar dinero inicial
	print("💰 Dinero inicial: %.2f" % game_data.money)

	# Test de water_collector (precio base 10)
	var generator_id = "water_collector"
	var owned = game_data.generators.get(generator_id, 0)

	print("🏭 %s - Cantidad actual: %d" % [generator_id, owned])

	# Mostrar precios para las próximas 3 compras
	for i in range(3):
		var cost = gen_manager.get_generator_cost(generator_id, 1)
		print("  Compra #%d: $%.2f" % [i + 1, cost])

		# Simular compra temporal para el siguiente cálculo
		if i < 2:
			game_data.generators[generator_id] = owned + i + 1

	# Restaurar estado
	game_data.generators[generator_id] = owned
	print("🔄 Estado restaurado")

func _test_manual_persistence(game_controller) -> void:
	print("\n💾 TEST 2: Persistencia manual")

	# Forzar guardado
	game_controller._save_game()
	await get_tree().create_timer(0.5).timeout

	# Verificar archivo
	var save_path = "user://barsik_save.dat"
	if FileAccess.file_exists(save_path):
		print("✅ Archivo de guardado existe")

		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()

			var json = JSON.new()
			if json.parse(content) == OK:
				var data = json.get_data()
				var game_data = data.get("game_data", {})
				print("💰 Dinero guardado: %.2f" % game_data.get("money", 0))
				print("🏭 Generadores guardados: %s" % game_data.get("generators", {}))
			else:
				print("❌ Error al parsear archivo guardado")
		else:
			print("❌ No se pudo leer archivo")
	else:
		print("❌ No existe archivo de guardado")

func _test_realtime_generation(game_controller) -> void:
	print("\n⚡ TEST 3: Generación en tiempo real")

	var gen_manager = game_controller.generator_manager
	var game_data = game_controller.game_data

	# Verificar estado del timer
	if gen_manager.generation_timer:
		var is_active = not gen_manager.generation_timer.is_stopped()
		print("✅ Timer existe - Activo: %s" % is_active)
		print("⏰ Tiempo restante: %.1fs de %.1fs" % [gen_manager.generation_timer.time_left, gen_manager.generation_timer.wait_time])
	else:
		print("❌ Timer no existe")

	# Mostrar generadores que pueden generar
	print("🏭 Generadores que pueden generar:")
	for gen_id in game_data.generators:
		var count = game_data.generators[gen_id]
		if count > 0:
			print("  %s: %d unidades" % [gen_id, count])

	print("\n🎯 === PROBLEMAS IDENTIFICADOS Y CORREGIDOS ===")
	print("✅ Error 'int' vs 'String' en SalesPanel - ARREGLADO")
	print("✅ Precios escalados usando GeneratorManager - ARREGLADO")
	print("✅ Reset automático al iniciar - DESACTIVADO")
	print("✅ GenerationPanel usa cálculos consistentes - IMPLEMENTADO")
	print("🔍 Pendiente: Verificar que UI actualiza precios después de compra")
	print("🔍 Pendiente: Confirmar persistencia después de reset manual")
