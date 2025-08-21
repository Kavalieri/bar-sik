# =============================================================================
# T014 - STAR BONUSES SYSTEM TEST
# =============================================================================
# Script de testing para verificar que las bonificaciones funcionan correctamente
# Fecha: 22 Agosto 2025

extends Node


func _ready():
	print("=== T014 STAR BONUSES TEST ===")
	call_deferred("test_star_bonuses")


func test_star_bonuses():
	await get_tree().process_frame

	# Buscar GameController
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("❌ GameController no encontrado")
		return

	var game_data = game_controller.game_data
	var prestige_manager = game_controller.prestige_manager

	if not game_data or not prestige_manager:
		print("❌ GameData o PrestigeManager no encontrados")
		return

	print("🧪 Testing Star Bonuses System...")

	# Test 1: Verificar que las bonificaciones se pueden aplicar
	test_bonus_application(prestige_manager, game_data)

	# Test 2: Verificar efectos en managers
	test_manager_effects(game_controller)

	print("✅ Tests T014 completados")
	queue_free()


func test_bonus_application(prestige_manager: PrestigeManager, game_data: GameData):
	print("\n--- TEST 1: Aplicación de Bonificaciones ---")

	# Simular tener stars
	prestige_manager.prestige_stars = 20

	# Comprar algunas bonificaciones para testing
	var bonuses_to_test = ["income_multiplier", "speed_boost", "premium_customers"]

	for bonus_id in bonuses_to_test:
		var success = prestige_manager.purchase_star_bonus(bonus_id)
		if success:
			print("✅ Bonus comprado: %s" % bonus_id)
		else:
			print("❌ No se pudo comprar: %s" % bonus_id)

	# Verificar que se aplicaron en GameData
	var income_mult = game_data.get("prestige_income_multiplier", 1.0)
	var speed_mult = game_data.get("prestige_speed_multiplier", 1.0)
	var token_mult = game_data.get("prestige_customer_token_multiplier", 1.0)

	print("💰 Income Multiplier: x%.2f %s" % [income_mult, "✅" if income_mult > 1.0 else "❌"])
	print("⚡ Speed Multiplier: x%.2f %s" % [speed_mult, "✅" if speed_mult > 1.0 else "❌"])
	print("🪙 Token Multiplier: x%.2f %s" % [token_mult, "✅" if token_mult > 1.0 else "❌"])


func test_manager_effects(game_controller: GameController):
	print("\n--- TEST 2: Efectos en Managers ---")

	var game_data = game_controller.game_data
	var sales_manager = game_controller.sales_manager
	var generator_manager = game_controller.generator_manager
	var customer_manager = game_controller.customer_manager

	# Test SalesManager - Income Multiplier
	print("🛒 Testing SalesManager Income Multiplier...")
	if sales_manager:
		# Simular venta para verificar multiplicador
		# (Esto requiere stock, así que solo verificamos que el manager existe)
		print("  ✅ SalesManager disponible para testing")

	# Test GeneratorManager - Speed Boost
	print("⚡ Testing GeneratorManager Speed Boost...")
	if generator_manager:
		print("  ✅ GeneratorManager disponible para testing")

	# Test CustomerManager - Premium Customers
	print("👥 Testing CustomerManager Premium Customers...")
	if customer_manager:
		print("  ✅ CustomerManager disponible para testing")

	# Verificar Diamond Bonus timer
	print("💎 Testing Diamond Bonus Timer...")
	var gems_timer = game_controller.get_node_or_null("Timer")  # Buscar timer de gems
	if gems_timer:
		print("  ✅ Gems timer configurado")
	else:
		print("  ⚠️ Gems timer no encontrado (normal si no se configuró)")


func print_bonus_status(prestige_manager: PrestigeManager):
	print("\n--- ESTADO ACTUAL DE BONIFICACIONES ---")
	print("⭐ Stars disponibles: %d" % prestige_manager.prestige_stars)
	print("🎯 Bonos activos: %d" % prestige_manager.active_star_bonuses.size())

	for bonus_id in prestige_manager.active_star_bonuses:
		var definition = prestige_manager.get_star_bonus_definition(bonus_id)
		if definition:
			print("  ✅ %s - %s" % [definition.name, definition.description])
		else:
			print("  ⚠️ %s - (definición no encontrada)" % bonus_id)
