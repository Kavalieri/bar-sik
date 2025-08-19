extends Node
## TestGeneratorPricing - Test manual para verificar precios escalados

func _ready() -> void:
	print("\n💰 === TEST DE PRECIOS ESCALADOS ===")
	call_deferred("_test_pricing")

func _test_pricing() -> void:
	await get_tree().process_frame

	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("❌ No se encontró GameController")
		return

	var gen_manager = game_controller.generator_manager
	var game_data = game_controller.game_data

	print("✅ Testeando precios escalados...")

	# Test para water_collector
	_test_generator_pricing(gen_manager, game_data, "water_collector")
	print()

	# Test para barley_farm
	_test_generator_pricing(gen_manager, game_data, "barley_farm")

func _test_generator_pricing(gen_manager, game_data, generator_id: String) -> void:
	print("🏭 Testeando generador: %s" % generator_id)

	# Mostrar precio base
	var generator_def = null
	for def in gen_manager.get_generator_definitions():
		if def.id == generator_id:
			generator_def = def
			break

	if not generator_def:
		print("❌ No se encontró definición para %s" % generator_id)
		return

	print("💲 Precio base: %.2f" % generator_def.base_cost)

	# Mostrar cuántos tiene actualmente
	var owned = game_data.generators.get(generator_id, 0)
	print("🏭 Cantidad actual: %d" % owned)

	# Calcular costos para las próximas 5 compras
	for i in range(5):
		var cost = gen_manager.get_generator_cost(generator_id, 1)
		print("  Compra #%d: $%.2f (si tuviera %d)" % [i + 1, cost, owned + i])

		# Simular la compra para el siguiente cálculo
		if i < 4:  # No simular la última para no alterar el estado
			var temp_owned = owned + i + 1
			# Temporalmente ajustar el owned para el siguiente cálculo
			game_data.generators[generator_id] = temp_owned

	# Restaurar el estado original
	game_data.generators[generator_id] = owned
	print("🔄 Estado restaurado a %d generadores" % owned)

# Función para testear compra real
func test_real_purchase(generator_id: String, quantity: int = 1) -> void:
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("❌ No se encontró GameController")
		return

	var gen_manager = game_controller.generator_manager
	var game_data = game_controller.game_data

	print("\n🛒 COMPRA REAL: %dx %s" % [quantity, generator_id])
	print("💰 Dinero antes: %.2f" % game_data.money)
	print("🏭 Generadores antes: %d" % game_data.generators.get(generator_id, 0))

	var cost = gen_manager.get_generator_cost(generator_id, quantity)
	print("💲 Costo calculado: %.2f" % cost)

	var success = gen_manager.purchase_generator(generator_id, quantity)

	if success:
		print("✅ Compra exitosa!")
		print("💰 Dinero después: %.2f" % game_data.money)
		print("🏭 Generadores después: %d" % game_data.generators.get(generator_id, 0))
	else:
		print("❌ Compra falló!")
