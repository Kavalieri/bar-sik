extends Node

## ═══════════════════════════════════════════════════════════════════════════════════
## T024 - VALIDACIÓN DEL SISTEMA DE ESCALADO REBALANCEADO
## ═══════════════════════════════════════════════════════════════════════════════════
## Descripción: Validar el nuevo sistema de costos escalados con curvas específicas
## Versión: 1.0
## Fecha: 2024-12-19
## ═══════════════════════════════════════════════════════════════════════════════════


func _ready():
	print("\n🔍 === T024 - VALIDACIÓN DEL ESCALADO REBALANCEADO ===")
	await _validate_cost_scaling_system()


func _validate_cost_scaling_system():
	print("\n📊 Iniciando validación del sistema de escalado T024...")

	# 1. Verificar que GameUtils tiene las nuevas funciones
	print("\n1️⃣ Verificando funciones en GameUtils...")

	var required_methods = [
		"get_scaled_cost", "get_bulk_scaled_cost", "can_afford_scaled_upgrade", "get_cost_info"
	]

	for method in required_methods:
		if GameUtils.has_method(method):
			print("✅ Método %s: OK" % method)
		else:
			print("❌ Método %s: NO ENCONTRADO" % method)

	# 2. Probar escalado de generadores
	print("\n2️⃣ Probando escalado de generadores...")
	_test_generator_scaling()

	# 3. Probar escalado de estaciones
	print("\n3️⃣ Probando escalado de estaciones...")
	_test_station_scaling()

	# 4. Probar escalado de upgrades
	print("\n4️⃣ Probando escalado de upgrades...")
	_test_upgrade_scaling()

	# 5. Probar escalado de clientes
	print("\n5️⃣ Probando escalado de clientes...")
	_test_customer_scaling()

	# 6. Verificar integración con managers
	print("\n6️⃣ Verificando integración con managers...")
	_test_manager_integration()

	print("\n✅ === VALIDACIÓN T024 COMPLETADA ===")


func _test_generator_scaling():
	"""Probar la curva de escalado de generadores"""
	var base_cost = 100.0

	print("   📈 Curva de generadores (base: %.0f):" % base_cost)

	# Early game (1-10): 1.12x
	var early_costs = []
	for level in range(1, 11):
		var cost = GameUtils.get_scaled_cost(base_cost, level, "generator")
		early_costs.append(cost)
		if level <= 3 or level == 10:
			print("      Nivel %d: %.0f" % [level, cost])

	# Mid game (11-25): 1.18x
	var mid_cost = GameUtils.get_scaled_cost(base_cost, 15, "generator")
	print("      Nivel 15 (mid): %.0f" % mid_cost)

	# Late game (25+): 1.25x
	var late_cost = GameUtils.get_scaled_cost(base_cost, 30, "generator")
	print("      Nivel 30 (late): %.0f" % late_cost)

	# Verificar que el escalado sea progresivo
	var growth_1_10 = early_costs[-1] / early_costs[0]
	print("   📊 Crecimiento niveles 1-10: %.2fx" % growth_1_10)


func _test_station_scaling():
	"""Probar escalado de estaciones"""
	var base_cost = 500.0

	print("   🏭 Escalado de estaciones (base: %.0f):" % base_cost)

	for level in [1, 3, 5, 10]:
		var cost = GameUtils.get_scaled_cost(base_cost, level, "station")
		print("      Nivel %d: %.0f" % [level, cost])


func _test_upgrade_scaling():
	"""Probar escalado de upgrades"""
	var base_cost = 1000.0

	print("   ⬆️ Escalado de upgrades (base: %.0f):" % base_cost)

	for level in [1, 2, 3, 5]:
		var cost = GameUtils.get_scaled_cost(base_cost, level, "upgrade")
		print("      Nivel %d: %.0f" % [level, cost])


func _test_customer_scaling():
	"""Probar escalado de clientes"""
	var base_cost = 25.0

	print("   👥 Escalado de clientes (base: %.0f gems):" % base_cost)

	for level in [1, 2, 3, 5, 8]:
		var cost = GameUtils.get_scaled_cost(base_cost, level, "customer")
		print("      Cliente %d: %.0f gems" % [level, cost])


func _test_manager_integration():
	"""Verificar que los managers usan el nuevo sistema"""
	var game_controller = get_tree().get_first_node_in_group("game_controller")

	if not game_controller:
		print("   ⚠️ GameController no encontrado para testing")
		return

	# Probar GeneratorManager
	if game_controller.get("generator_manager"):
		var gen_manager = game_controller.generator_manager
		if gen_manager.has_method("get_generator_cost"):
			var cost = gen_manager.get_generator_cost("energy_generator", 1)
			print("   ✅ GeneratorManager.get_generator_cost(): %.2f" % cost)
		else:
			print("   ❌ GeneratorManager sin método get_generator_cost")

	# Probar ProductionManager
	if game_controller.get("production_manager"):
		var prod_manager = game_controller.production_manager
		if prod_manager.has_method("get_unlock_cost"):
			var cost = prod_manager.get_unlock_cost("cerveza_rubia")
			print("   ✅ ProductionManager.get_unlock_cost(): %.2f" % cost)
		else:
			print("   ❌ ProductionManager sin método get_unlock_cost")

	# Probar CustomerManager
	if game_controller.get("customer_manager"):
		var cust_manager = game_controller.customer_manager
		if cust_manager.has_method("get_next_customer_cost"):
			var cost = cust_manager.get_next_customer_cost()
			print("   ✅ CustomerManager.get_next_customer_cost(): %d" % cost)
		else:
			print("   ❌ CustomerManager sin método get_next_customer_cost")


func _test_bulk_purchases():
	"""Probar compras en bulk"""
	print("\n💰 Probando compras en bulk...")

	var base_cost = 100.0
	var current_level = 5
	var quantity = 3

	var bulk_cost = GameUtils.get_bulk_scaled_cost(base_cost, current_level, quantity, "generator")
	print("   Comprar %d generadores desde nivel %d: %.0f" % [quantity, current_level, bulk_cost])

	# Verificar que bulk = suma individual
	var individual_sum = 0.0
	for i in range(quantity):
		individual_sum += GameUtils.get_scaled_cost(base_cost, current_level + i + 1, "generator")

	var difference = abs(bulk_cost - individual_sum)
	if difference < 0.01:
		print("   ✅ Bulk cost matches individual sum")
	else:
		print("   ❌ Bulk cost mismatch: %.2f vs %.2f" % [bulk_cost, individual_sum])


func _test_cost_info():
	"""Probar función de información de costos"""
	print("\n📋 Probando get_cost_info...")

	var base_cost = 500.0
	var level = 8
	var info = GameUtils.get_cost_info(base_cost, level, "station")

	print("   Base: %.0f, Nivel: %d" % [base_cost, level])
	print("   Costo actual: %s" % info.formatted_cost)
	print("   Próximo costo: %s" % info.formatted_next)
	print("   Crecimiento: %.1f%%" % info.growth_percentage)
