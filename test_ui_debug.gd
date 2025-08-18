extends Node
## Script de prueba para debuggear problemas de UI

func _ready():
	print("=== TEST DE DEBUG DE UI ===")

	# Simular datos de juego básicos
	var test_game_data = {
		"money": 100,
		"resources": {
			"water": 50,
			"barley": 10,
			"hops": 5
		},
		"products": {
			"basic_beer": 2
		},
		"stations": {
			"basic_brewery": 1
		}
	}

	print("📊 Datos de prueba creados:")
	print("   - Dinero: ", test_game_data["money"])
	print("   - Recursos: ", test_game_data["resources"])
	print("   - Productos: ", test_game_data["products"])
	print("   - Estaciones: ", test_game_data["stations"])

	print("✅ Test básico completado")
