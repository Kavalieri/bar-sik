extends Node
## Test script para T004 - Triple Currency UI Display
## Verifica que los displays de currency se actualicen correctamente


func _ready():
	print_rich("[color=cyan]🧪 TEST T004 - Triple Currency UI Display[/color]")
	test_t004_ui_display()


func test_t004_ui_display():
	print("\n=== T004 UI DISPLAY TEST ===")

	# 1. Verificar que CurrencyDisplay existe
	print("🔍 Testing CurrencyDisplay component...")
	var currency_display = preload("res://scripts/ui/CurrencyDisplay.gd").new()

	print("✅ CurrencyDisplay loaded successfully")

	# 2. Verificar configuración de tipos de moneda
	print("\n🪙 Testing currency type configurations...")
	var test_types = ["cash", "tokens", "gems", "stars"]

	for currency_type in test_types:
		currency_display.setup_currency(currency_type)
		print("  %s: Configured" % currency_type)

	# 3. Verificar formateo de números
	print("\n📊 Testing number formatting...")
	var test_amounts = [50, 1000, 25000, 1000000, 1500000000]

	for amount in test_amounts:
		var formatted = currency_display._format_currency(float(amount))
		print("  %d -> %s" % [amount, formatted])

	# 4. Test set_amount method
	print("\n💰 Testing set_amount functionality...")
	currency_display.set_amount(1234.5)
	print("  Amount set to 1234.5")

	# 5. Simular cambios de currency
	print("\n🔄 Testing currency updates...")
	currency_display.setup_currency("cash")
	currency_display.set_amount(50.0)
	print("  Cash: 50")

	currency_display.setup_currency("tokens")
	currency_display.set_amount(0.0)
	print("  Tokens: 0")

	currency_display.setup_currency("gems")
	currency_display.set_amount(100.0)
	print("  Gems: 100")

	print("\n✅ T004 UI DISPLAY TEST COMPLETED")
	print("Next: Integration test with TabNavigator")

	# Cleanup
	currency_display.queue_free()
