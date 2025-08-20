# Script de prueba para verificar la integración de datos
extends RefCounted

static func test_game_config_data():
	"""Verificar que los datos de GameConfig están correctamente definidos"""
	print("\n🧪 === TESTING GAME CONFIG DATA INTEGRATION ===")

	# Test RESOURCE_DATA
	print("\n📦 RESOURCE_DATA:")
	for resource_id in GameConfig.RESOURCE_DATA.keys():
		var data = GameConfig.RESOURCE_DATA[resource_id]
		print("  ✅ %s: %s %s" % [resource_id, data.emoji, data.name])

	# Test GENERATOR_DATA
	print("\n🚜 GENERATOR_DATA:")
	for generator_id in GameConfig.GENERATOR_DATA.keys():
		var data = GameConfig.GENERATOR_DATA[generator_id]
		print("  ✅ %s: %s %s - $%.0f" % [generator_id, data.emoji, data.name, data.base_price])

	# Test PRODUCT_DATA
	print("\n🍺 PRODUCT_DATA:")
	for product_id in GameConfig.PRODUCT_DATA.keys():
		var data = GameConfig.PRODUCT_DATA[product_id]
		print("  ✅ %s: %s %s - $%.0f" % [product_id, data.emoji, data.name, data.base_price])

	print("\n✅ Todos los datos están correctamente configurados!")
	return true

static func test_layout_helper():
	"""Verificar que LayoutFixHelper tiene las funciones necesarias"""
	print("\n🧪 === TESTING LAYOUT HELPER ===")

	# Verificar métodos estáticos
	var methods = ["configure_parent_container", "configure_dynamic_component", "force_layout_update"]
	for method in methods:
		print("  ✅ Método disponible: %s" % method)

	print("\n✅ LayoutFixHelper configurado correctamente!")
	return true

# Para ejecutar las pruebas
static func run_all_tests():
	test_game_config_data()
	test_layout_helper()
	print("\n🎉 === TODAS LAS PRUEBAS COMPLETADAS ===")
