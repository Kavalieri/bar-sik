extends Node
## Test para nueva arquitectura - Currencies en GameData directamente
## Verifica que los métodos de currency funcionen sin CurrencyManager


func _ready():
	print_rich("[color=cyan]🧪 TEST CURRENCY REFACTOR - GameData Direct[/color]")
	test_currency_refactor()


func test_currency_refactor():
	print("\n=== CURRENCY REFACTOR TEST ===")

	# 1. Crear GameData
	var game_data = GameData.new()
	print("📊 GameData inicial:")
	print(
		"  Money: %.1f, Tokens: %d, Gems: %d" % [game_data.money, game_data.tokens, game_data.gems]
	)

	# 2. Test métodos de money
	print("\n💵 Testing money methods...")
	print("  Initial: %.1f" % game_data.money)
	game_data.add_money(25.5)
	print("  After add_money(25.5): %.1f" % game_data.money)

	var can_spend = game_data.can_afford_money(30.0)
	print("  Can afford 30.0: %s" % can_spend)

	var spent = game_data.spend_money(20.0)
	print("  Spend 20.0 success: %s, new amount: %.1f" % [spent, game_data.money])

	# 3. Test métodos de tokens
	print("\n🪙 Testing token methods...")
	game_data.add_tokens(15)
	print("  After add_tokens(15): %d" % game_data.tokens)

	var token_spent = game_data.spend_tokens(5)
	print("  Spend 5 tokens success: %s, new amount: %d" % [token_spent, game_data.tokens])

	# 4. Test métodos de gems
	print("\n💎 Testing gem methods...")
	print("  Initial gems: %d" % game_data.gems)

	var gems_spent = game_data.spend_gems(50)
	print("  Spend 50 gems success: %s, new amount: %d" % [gems_spent, game_data.gems])

	# 5. Test formateo
	print("\n📊 Testing formatting...")
	game_data.add_money(12345.0)
	print("  Money formatted: $%s" % game_data.format_money())

	game_data.add_tokens(2500)
	print("  Tokens formatted: %s" % game_data.format_tokens())
	print("  Gems formatted: %s" % game_data.format_gems())

	# 6. Test persistencia (to_dict/from_dict)
	print("\n💾 Testing persistence...")
	var save_dict = game_data.to_dict()
	print(
		(
			"  Saved money: %.1f, tokens: %d, gems: %d"
			% [save_dict.money, save_dict.tokens, save_dict.gems]
		)
	)

	# 7. Test nuevo GameData con from_dict
	var new_game_data = GameData.new()
	new_game_data.from_dict(save_dict)
	print(
		(
			"  Loaded money: %.1f, tokens: %d, gems: %d"
			% [new_game_data.money, new_game_data.tokens, new_game_data.gems]
		)
	)

	# 8. Test backward compatibility
	print("\n🔄 Testing backward compatibility...")
	var old_save = {"money": 100.0, "resources": {}}  # Sin tokens/gems
	var compat_data = GameData.new()
	compat_data.from_dict(old_save)
	print(
		(
			"  Old save compatibility - money: %.1f, tokens: %d, gems: %d"
			% [compat_data.money, compat_data.tokens, compat_data.gems]
		)
	)

	print("\n✅ CURRENCY REFACTOR TEST COMPLETED")
	print("Architecture: GameData direct methods, no CurrencyManager, no signals")
	print("Persistence: SaveSystem automatic via GameData.to_dict()")
	print("Performance: Direct calls, no signal overhead")
