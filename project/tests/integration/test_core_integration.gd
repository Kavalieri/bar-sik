extends Node
## Test script para T003 - Integración CurrencyManager-GameData
## Verifica que la sincronización bidireccional funciona correctamente


func _ready():
	print_rich("[color=cyan]🧪 TEST T003 - CurrencyManager-GameData Integration[/color]")
	test_t003_integration()


func test_t003_integration():
	print("\n=== T003 INTEGRATION TEST ===")

	# 1. Crear GameData y CurrencyManager
	var game_data = GameData.new()
	var currency_manager = CurrencyManager.new()

	print("📊 Initial GameData state:")
	print("  Money: %d, Tokens: %d, Gems: %d" % [game_data.money, game_data.tokens, game_data.gems])

	# 2. Conectar CurrencyManager con GameData
	currency_manager.set_game_data(game_data)
	print("\n🔗 CurrencyManager connected to GameData")

	# 3. Verificar sincronización inicial (from GameData)
	print("\n💰 Currency states after connection:")
	print("  Cash: %d" % currency_manager.get_currency_amount("cash"))
	print("  Tokens: %d" % currency_manager.get_currency_amount("tokens"))
	print("  Gems: %d" % currency_manager.get_currency_amount("gems"))

	# 4. Test: Modificar currencies y verificar sync hacia GameData
	print("\n🔄 Testing sync TO GameData...")
	currency_manager.add_currency("cash", 25)
	currency_manager.add_currency("tokens", 10)
	currency_manager.spend_currency("gems", 20)

	print("GameData after currency changes:")
	print(
		"  Money: %.1f, Tokens: %d, Gems: %d" % [game_data.money, game_data.tokens, game_data.gems]
	)

	# 5. Test: Modificar GameData directamente y verificar que sync funciona
	print("\n🔄 Testing sync FROM GameData...")
	game_data.money = 200.0
	game_data.tokens = 50
	game_data.gems = 300

	# Simular carga desde save
	currency_manager.set_game_data(game_data)  # Re-sync

	print("Currencies after GameData direct modification:")
	print("  Cash: %d" % currency_manager.get_currency_amount("cash"))
	print("  Tokens: %d" % currency_manager.get_currency_amount("tokens"))
	print("  Gems: %d" % currency_manager.get_currency_amount("gems"))

	# 6. Test: Verificar nuevo jugador
	print("\n🆕 Testing new player initialization...")
	var fresh_data = GameData.new()
	var fresh_currency = CurrencyManager.new()
	fresh_currency.set_game_data(fresh_data)

	print("Fresh player currencies:")
	print("  Cash: %d" % fresh_currency.get_currency_amount("cash"))
	print("  Tokens: %d" % fresh_currency.get_currency_amount("tokens"))
	print("  Gems: %d" % fresh_currency.get_currency_amount("gems"))

	print("\n✅ T003 INTEGRATION TEST COMPLETED")
	print("Next: T004 - Triple currency UI display")
