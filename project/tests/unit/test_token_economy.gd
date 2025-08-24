extends Node

## ═══════════════════════════════════════════════════════════════════════════════════
## T025 - VALIDACIÓN DEL BALANCE DE ECONOMÍA DE TOKENS
## ═══════════════════════════════════════════════════════════════════════════════════
## Descripción: Validar el rebalance de la economía de tokens para objetivos T025
## Versión: 1.0
## Fecha: 2024-12-19
## ═══════════════════════════════════════════════════════════════════════════════════


func _ready():
	print("\n🔍 === T025 - VALIDACIÓN BALANCE ECONOMÍA DE TOKENS ===")
	await _validate_token_economy()


func _validate_token_economy():
	print("\n🪙 Iniciando validación de economía de tokens T025...")

	# 1. Verificar CustomerManager tiene nuevas funciones
	print("\n1️⃣ Verificando funciones del CustomerManager...")
	var game_controller = get_tree().get_first_node_in_group("game_controller")

	if not game_controller:
		print("❌ GameController no encontrado")
		return

	var customer_manager = game_controller.get("customer_manager")
	if not customer_manager:
		print("❌ CustomerManager no encontrado")
		return

	var required_methods = ["get_token_economy_stats", "_calculate_expected_tokens_per_customer"]

	for method in required_methods:
		if customer_manager.has_method(method):
			print("✅ Método %s: OK" % method)
		else:
			print("❌ Método %s: NO ENCONTRADO" % method)

	# 2. Simular diferentes configuraciones
	print("\n2️⃣ Simulando configuraciones de token economy...")
	_simulate_token_scenarios(customer_manager)

	# 3. Verificar rates objetivos T025
	print("\n3️⃣ Verificando cumplimiento de objetivos T025...")
	_verify_target_rates(customer_manager)

	# 4. Probar escalado con upgrades
	print("\n4️⃣ Probando escalado con upgrades...")
	_test_upgrade_scaling(customer_manager)

	print("\n✅ === VALIDACIÓN T025 COMPLETADA ===")


func _simulate_token_scenarios(customer_manager: Node):
	"""Simular diferentes escenarios de economía de tokens"""

	# Crear datos de juego simulados
	var mock_game_data = _create_mock_game_data()
	customer_manager.set_game_data(mock_game_data)

	print("   📊 Escenarios de token economy:")

	# Escenario 1: Base (1 cliente, sin upgrades)
	customer_manager.active_customers = 1
	mock_game_data.upgrades = {
		"auto_sell_enabled": true,
		"premium_customers": false,
		"bulk_buyers": false,
		"faster_customers": false
	}
	customer_manager._update_timer_settings()

	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		print(
			"      Base (1 cliente): %.0f tokens/hora" % stats.get("tokens_per_hour_estimated", 0)
		)

	# Escenario 2: Múltiples clientes
	customer_manager.active_customers = 3
	customer_manager._update_timer_settings()

	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		print(
			(
				"      Múltiples (3 clientes): %.0f tokens/hora"
				% stats.get("tokens_per_hour_estimated", 0)
			)
		)

	# Escenario 3: Con upgrades
	mock_game_data.upgrades["premium_customers"] = true
	mock_game_data.upgrades["bulk_buyers"] = true
	mock_game_data.upgrades["faster_customers"] = true
	customer_manager._update_timer_settings()

	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		print(
			"      Premium completo: %.0f tokens/hora" % stats.get("tokens_per_hour_estimated", 0)
		)


func _verify_target_rates(customer_manager: Node):
	"""Verificar que se cumplan los objetivos de T025"""

	print("   🎯 Objetivos T025:")
	print("      Early game: 20-40 tokens/hora")
	print("      Mid game: ~150 tokens/hora")
	print("      Premium: 300-400 tokens/hora")

	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		var current_rate = stats.get("tokens_per_hour_estimated", 0)
		var tier = stats.get("performance_tier", "Unknown")

		print("      Estado actual: %.0f tokens/hora (%s)" % [current_rate, tier])

		# Verificar si está en rango apropiado
		if current_rate >= 20:
			print("      ✅ Rate mínimo cumplido")
		else:
			print("      ⚠️ Rate muy bajo para early game")


func _test_upgrade_scaling(customer_manager: Node):
	"""Probar el impacto de cada upgrade individual"""

	print("   ⬆️ Impacto individual de upgrades:")

	var base_data = _create_mock_game_data()
	base_data.upgrades["auto_sell_enabled"] = true
	customer_manager.set_game_data(base_data)
	customer_manager.active_customers = 2

	# Base
	customer_manager._update_timer_settings()
	var base_rate = 0.0
	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		base_rate = stats.get("tokens_per_hour_estimated", 0)

	print("      Base: %.0f tokens/hora" % base_rate)

	# Con Premium Customers
	base_data.upgrades["premium_customers"] = true
	customer_manager._update_timer_settings()
	var premium_rate = 0.0
	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		premium_rate = stats.get("tokens_per_hour_estimated", 0)

	var premium_improvement = (
		((premium_rate - base_rate) / base_rate * 100.0) if base_rate > 0 else 0.0
	)
	print(
		(
			"      + Premium Customers: %.0f tokens/hora (+%.1f%%)"
			% [premium_rate, premium_improvement]
		)
	)

	# Con Bulk Buyers
	base_data.upgrades["bulk_buyers"] = true
	customer_manager._update_timer_settings()
	var bulk_rate = 0.0
	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		bulk_rate = stats.get("tokens_per_hour_estimated", 0)

	var bulk_improvement = (
		((bulk_rate - premium_rate) / premium_rate * 100.0) if premium_rate > 0 else 0.0
	)
	print("      + Bulk Buyers: %.0f tokens/hora (+%.1f%%)" % [bulk_rate, bulk_improvement])

	# Con Faster Customers
	base_data.upgrades["faster_customers"] = true
	customer_manager._update_timer_settings()
	var fast_rate = 0.0
	if customer_manager.has_method("get_token_economy_stats"):
		var stats = customer_manager.get_token_economy_stats()
		fast_rate = stats.get("tokens_per_hour_estimated", 0)

	var fast_improvement = ((fast_rate - bulk_rate) / bulk_rate * 100.0) if bulk_rate > 0 else 0.0
	print("      + Faster Customers: %.0f tokens/hora (+%.1f%%)" % [fast_rate, fast_improvement])


func _create_mock_game_data() -> Dictionary:
	"""Crear datos de juego simulados para testing"""
	return {
		"upgrades": {},
		"customer_system_unlocked": true,
		"tokens": 0,
		"money": 1000.0,
		"products": {"cerveza_rubia": 50, "cerveza_negra": 30},
		"add_tokens": func(amount: int): pass,
		"add_money": func(amount: float): pass,
		"statistics": {"products_sold": 0, "customers_served": 0}
	}
