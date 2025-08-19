extends Node
## DebugPersistence - Debug manual de persistencia sin resets automáticos


func _ready() -> void:
	print("\n🛠️ === DEBUG PERSISTENCIA MANUAL ===")
	call_deferred("_debug_save_load")


func _debug_save_load() -> void:
	await get_tree().process_frame

	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("❌ No se encontró GameController")
		return

	print("✅ GameController encontrado")

	# Mostrar estado actual
	_show_current_state(game_controller)

	# Verificar archivo de guardado
	_check_save_file()


func _show_current_state(game_controller) -> void:
	print("\n📊 ESTADO ACTUAL:")
	var game_data = game_controller.game_data
	print("💰 Dinero: %.2f" % game_data.money)
	print("📦 Recursos: %s" % game_data.resources)
	print("🏭 Generadores: %s" % game_data.generators)
	print("🏢 Estaciones: %s" % game_data.stations)


func _check_save_file() -> void:
	print("\n💾 VERIFICANDO ARCHIVO DE GUARDADO:")

	var save_path = "user://barsik_save.dat"
	if FileAccess.file_exists(save_path):
		print("✅ Archivo de guardado existe")

		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(content)

			if parse_result == OK:
				var data = json.get_data()
				print("✅ Archivo parseado correctamente")
				print("🕒 Timestamp: %s" % data.get("timestamp", "N/A"))
				print("📋 Versión: %s" % data.get("version", "N/A"))

				var game_data = data.get("game_data", {})
				print("💰 Dinero guardado: %.2f" % game_data.get("money", 0))
				print("📦 Recursos guardados: %s" % game_data.get("resources", {}))
				print("🏭 Generadores guardados: %s" % game_data.get("generators", {}))
			else:
				print("❌ Error al parsear archivo: %d" % parse_result)
		else:
			print("❌ No se pudo abrir archivo")
	else:
		print("❌ No existe archivo de guardado")


# Función manual para testear guardado
func test_manual_save() -> void:
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if game_controller:
		print("\n💾 TESTEANDO GUARDADO MANUAL...")
		game_controller._save_game()
		await get_tree().create_timer(0.5).timeout
		_check_save_file()


# Función manual para testear reset SIN ejecutarlo
func show_reset_info() -> void:
	print("\n🗑️ INFO DE RESET (sin ejecutar):")
	print("  Para testear reset manualmente, usa:")
	print("  get_tree().get_first_node_in_group('game_controller')._on_reset_data_requested()")
