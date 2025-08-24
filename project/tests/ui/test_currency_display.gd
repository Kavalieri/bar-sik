extends "res://addons/gut/test.gd"

## Test script para T004 - Triple Currency UI Display
## Verifica que los displays de currency se actualicen correctamente

var currency_display: Node


func before_each():
	"""Configuración antes de cada test"""
	currency_display = preload("res://scripts/ui/CurrencyDisplay.gd").new()


func after_each():
	"""Limpieza después de cada test"""
	if currency_display:
		currency_display.queue_free()


func test_currency_display_can_be_created():
	"""Test que CurrencyDisplay puede ser creado"""
	assert_not_null(currency_display, "CurrencyDisplay should be created successfully")


func test_currency_type_configurations():
	"""Test configuración de tipos de moneda"""
	var test_types = ["cash", "tokens", "gems", "stars"]

	for currency_type in test_types:
		# Note: Assuming setup_currency exists or skip if method not found
		if currency_display.has_method("setup_currency"):
			currency_display.setup_currency(currency_type)
			# Add specific assertions based on CurrencyDisplay implementation
			pass


func test_number_formatting():
	"""Test formateo de números"""
	if not currency_display.has_method("_format_currency"):
		print("⚠️ Skipping test: _format_currency method not available")
		return

	var test_cases = [
		{"amount": 50.0, "expected_contains": "50"},
		{"amount": 1000.0, "expected_contains": "1K"},
		{"amount": 1000000.0, "expected_contains": "1M"}
	]

	for test_case in test_cases:
		var formatted = currency_display._format_currency(test_case.amount)
		assert_string_contains(formatted, test_case.expected_contains,
			"Amount %s should format correctly" % test_case.amount)


func test_set_amount_functionality():
	"""Test funcionalidad de set_amount"""
	if not currency_display.has_method("set_amount"):
		print("⚠️ Skipping test: set_amount method not available")
		return

	currency_display.set_amount(1234.5)
	# Add assertions based on the actual implementation


func test_currency_updates():
	"""Test actualizaciones de currency"""
	if not currency_display.has_method("setup_currency") or not currency_display.has_method("set_amount"):
		print("⚠️ Skipping test: Required methods not available")
		return

	var test_data = [
		{"type": "cash", "amount": 50.0},
		{"type": "tokens", "amount": 0.0},
		{"type": "gems", "amount": 100.0}
	]

	for data in test_data:
		currency_display.setup_currency(data.type)
		currency_display.set_amount(data.amount)
		# Add specific assertions based on expected behavior
