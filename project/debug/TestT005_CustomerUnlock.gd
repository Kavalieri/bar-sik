extends Node
## Test T005 - Sistema de Desbloqueo de Clientes
## Verifica que el sistema de desbloqueo funciona correctamente


func _ready():
	print("🧪 === TEST T005: SISTEMA DE DESBLOQUEO DE CLIENTES ===")
	run_all_tests()


func run_all_tests():
	test_unlock_system()
	test_gem_spending()
	test_gamedata_integration()
	print("✅ Todos los tests de T005 completados\n")


func test_unlock_system():
	print("\n🔒 TEST: Sistema de desbloqueo básico")

	# Crear GameData con sistema bloqueado
	var test_data = GameData.new()
	test_data.customer_system_unlocked = false
	test_data.gems = 100  # Suficientes gems

	print("• Estado inicial: customer_system_unlocked =", test_data.customer_system_unlocked)
	print("• Gems disponibles:", test_data.gems)

	# Simular desbloqueo
	var unlock_cost = 50
	if test_data.spend_gems(unlock_cost):
		test_data.customer_system_unlocked = true
		print("✅ Sistema desbloqueado exitosamente")
		print("• Gems restantes:", test_data.gems)
		print("• Sistema activo:", test_data.customer_system_unlocked)
	else:
		print("❌ Error: No se pudo desbloquear el sistema")


func test_gem_spending():
	print("\n💎 TEST: Gasto de gems y validaciones")

	# Test con gems insuficientes
	var test_data_poor = GameData.new()
	test_data_poor.gems = 30  # Insuficientes gems

	print("• Gems disponibles:", test_data_poor.gems, "(insuficiente)")

	if not test_data_poor.spend_gems(50):
		print("✅ Correctamente rechazado: gems insuficientes")
	else:
		print("❌ Error: Se permitió gasto con gems insuficientes")

	# Test con gems exactos
	var test_data_exact = GameData.new()
	test_data_exact.gems = 50

	print("• Gems exactos:", test_data_exact.gems)

	if test_data_exact.spend_gems(50):
		print("✅ Gasto exitoso con gems exactos")
		print("• Gems restantes:", test_data_exact.gems)
	else:
		print("❌ Error: No se permitió gasto con gems exactos")


func test_gamedata_integration():
	print("\n🔄 TEST: Integración con GameData")

	var test_data = GameData.new()

	# Test de campos requeridos
	var required_fields = ["customer_system_unlocked", "gems", "tokens"]

	for field in required_fields:
		if field in test_data:
			print("✅ Campo requerido presente:", field)
		else:
			print("❌ Campo faltante:", field)

	# Test de métodos de currency
	var currency_methods = ["spend_gems", "add_gems", "add_tokens", "format_gems"]

	for method in currency_methods:
		if test_data.has_method(method):
			print("✅ Método presente:", method)
		else:
			print("❌ Método faltante:", method)

	print("✅ Integración GameData verificada")
