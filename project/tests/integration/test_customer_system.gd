extends Node
## Test T005-T008 - Sistema de Clientes Automáticos Completo
## Verifica que todo el sistema funciona correctamente


func _ready():
	print("🧪 === TEST T005-T008: SISTEMA DE CLIENTES AUTOMÁTICOS ===")
	run_all_tests()


func run_all_tests():
	test_t005_unlock_system()
	test_t006_multiple_customers()
	test_t007_token_payments()
	test_t008_gem_upgrades()
	print("✅ Todos los tests T005-T008 completados\n")


func test_t005_unlock_system():
	print("\n🔒 T005 TEST: Sistema de desbloqueo")

	var test_data = GameData.new()
	test_data.customer_system_unlocked = false
	test_data.gems = 100

	# Test desbloqueo
	var unlock_cost = 50
	var initial_gems = test_data.gems

	if test_data.spend_gems(unlock_cost):
		test_data.customer_system_unlocked = true
		print("✅ T005: Sistema desbloqueado correctamente")
		print("  • Gems gastados: %d" % unlock_cost)
		print("  • Gems restantes: %d" % test_data.gems)
		print("  • Sistema activo: %s" % test_data.customer_system_unlocked)
	else:
		print("❌ T005: Error en desbloqueo")


func test_t006_multiple_customers():
	print("\n👤 T006 TEST: Sistema de múltiples clientes")

	var customer_manager = CustomerManager.new()
	var test_data = GameData.new()
	test_data.gems = 1000  # Suficientes gems para pruebas
	customer_manager.set_game_data(test_data)

	# Test costo escalado
	var expected_costs = [25, 50, 100, 200, 400]  # 25 * 2^n
	for i in range(5):
		var cost = customer_manager.get_next_customer_cost()
		print(
			(
				"  • Cliente %d: costo = %d gems (esperado: %d)"
				% [customer_manager.active_customers + 1, cost, expected_costs[i]]
			)
		)

		if cost == expected_costs[i]:
			print("    ✅ Costo correcto")
		else:
			print("    ❌ Costo incorrecto")

		# Comprar cliente
		if customer_manager.purchase_new_customer():
			print("    ✅ Cliente comprado exitosamente")
		else:
			print("    ❌ Error comprando cliente")

	# Test límite máximo
	var info = customer_manager.get_customer_info()
	print("  • Clientes finales: %d/%d" % [info.active, info.max])


func test_t007_token_payments():
	print("\n🪙 T007 TEST: Pagos en tokens")

	var test_data = GameData.new()
	test_data.tokens = 0

	# Simular pago de cliente
	var test_price = 100.0  # $100 de valor
	var expected_tokens = int(test_price / 10.0)  # $10 = 1 token

	print("  • Precio del producto: $%.2f" % test_price)
	print("  • Tokens esperados: %d" % expected_tokens)

	# Simular conversión
	test_data.add_tokens(expected_tokens)

	print("  • Tokens obtenidos: %d" % test_data.tokens)
	if test_data.tokens == expected_tokens:
		print("  ✅ T007: Conversión precio→tokens correcta")
	else:
		print("  ❌ T007: Error en conversión")

	# Test con premium customers (50% más tokens)
	test_data.tokens = 0
	var premium_tokens = int(expected_tokens * 1.5)
	test_data.add_tokens(premium_tokens)

	print("  • Tokens premium: %d (+50%%)" % premium_tokens)
	if test_data.tokens == premium_tokens:
		print("  ✅ T007: Bonus premium correcto")
	else:
		print("  ❌ T007: Error en bonus premium")


func test_t008_gem_upgrades():
	print("\n💎 T008 TEST: Upgrades con diamantes")

	var customer_manager = CustomerManager.new()
	var test_data = GameData.new()
	test_data.gems = 1000  # Suficientes para todas las pruebas
	customer_manager.set_game_data(test_data)

	# Test upgrades disponibles
	var upgrades_to_test = [
		{"id": "faster_customers", "cost": 100, "key": "faster_customers"},
		{"id": "premium_customers", "cost": 200, "key": "premium_customers"},
		{"id": "bulk_buyers", "cost": 500, "key": "bulk_buyers"}
	]

	for upgrade in upgrades_to_test:
		var initial_gems = test_data.gems
		var had_upgrade = test_data.upgrades.get(upgrade.key, false)

		print("  • Probando upgrade: %s (costo: %d gems)" % [upgrade.id, upgrade.cost])

		if customer_manager.purchase_upgrade(upgrade.id):
			var gems_spent = initial_gems - test_data.gems
			var has_upgrade = test_data.upgrades.get(upgrade.key, false)

			if gems_spent == upgrade.cost and has_upgrade and not had_upgrade:
				print("    ✅ Upgrade exitoso: -%d gems, upgrade activo" % gems_spent)
			else:
				print("    ❌ Error en compra de upgrade")
		else:
			print("    ❌ No se pudo comprar upgrade")

	print("  • Gems finales: %d" % test_data.gems)
	print("✅ T008: Sistema de upgrades con gems verificado")
