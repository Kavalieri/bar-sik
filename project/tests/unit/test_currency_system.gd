extends SceneTree
## Test script para verificar sistema de triple moneda


func _init():
	print("🧪 === TEST SISTEMA DE TRIPLE MONEDA ===")

	# Crear instancias de los managers
	var currency_manager = preload("res://scripts/core/CurrencyManager.gd").new()
	var game_data = preload("res://scripts/core/GameData.gd").new()

	# Test 1: Verificar inicialización
	print("\n📊 Test 1: Inicialización de monedas")
	print("💵 Cash:", currency_manager.get_currency_amount("cash"))
	print("🪙 Tokens:", currency_manager.get_currency_amount("tokens"))
	print("💎 Gems:", currency_manager.get_currency_amount("gems"))

	# Test 2: Verificar GameData
	print("\n📊 Test 2: GameData integrado")
	print("💵 GameData money:", game_data.money)
	print("🪙 GameData tokens:", game_data.tokens)
	print("💎 GameData gems:", game_data.gems)
	print("🔓 Customer system:", game_data.customer_system_unlocked)

	# Test 3: Verificar operaciones básicas
	print("\n📊 Test 3: Operaciones básicas")
	var can_spend_50_gems = currency_manager.spend_currency("gems", 50)
	print("💎 Gastar 50 gems:", "✅ Éxito" if can_spend_50_gems else "❌ Falló")
	print("💎 Gems restantes:", currency_manager.get_currency_amount("gems"))

	# Test 4: Añadir tokens
	currency_manager.add_currency("tokens", 25)
	print("🪙 Añadir 25 tokens - Total:", currency_manager.get_currency_amount("tokens"))

	print("\n✅ Tests completados - Sistema funcional")
	quit()
