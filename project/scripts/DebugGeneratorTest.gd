extends Node
## DebugGeneratorTest - Herramienta temporal para diagnosticar generación
## Solo para debug, eliminar después

var debug_timer: Timer
var test_counter: int = 0


func _ready() -> void:
	print("🔍 DebugGeneratorTest iniciado")

	# Timer para verificar cada segundo si los generadores están trabajando
	debug_timer = Timer.new()
	debug_timer.wait_time = 5.0  # Cada 5 segundos
	debug_timer.autostart = true
	debug_timer.timeout.connect(_debug_check_generation)
	add_child(debug_timer)


func _debug_check_generation() -> void:
	test_counter += 1
	print("\n🔍 === DEBUG CHECK #%d ===" % test_counter)

	# Verificar GameData
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("❌ No se encontró GameController")
		return

	var game_data = game_controller.game_data
	if not game_data:
		print("❌ No hay game_data")
		return

	print("💰 Dinero actual: %.2f" % game_data.money)
	print("📦 Recursos actuales:")
	for resource_name in game_data.resources.keys():
		print("   %s: %d" % [resource_name, game_data.resources[resource_name]])

	print("🏭 Generadores comprados:")
	for gen_id in game_data.generators.keys():
		print("   %s: %d" % [gen_id, game_data.generators[gen_id]])

	# Verificar GeneratorManager
	var gen_manager = game_controller.generator_manager
	if gen_manager:
		print("✅ GeneratorManager existe")
		if gen_manager.generation_timer:
			print(
				"✅ Timer de generación existe - Activo: %s" % gen_manager.generation_timer.autostart
			)
			print(
				(
					"⏰ Timer: %.1fs restantes de %.1fs"
					% [
						gen_manager.generation_timer.time_left,
						gen_manager.generation_timer.wait_time
					]
				)
			)
		else:
			print("❌ Timer de generación NO existe")
	else:
		print("❌ GeneratorManager NO existe")

	print("=== FIN DEBUG CHECK ===\n")
