extends SceneTree
## Script de test para verificar las mejoras de debug

func _init():
	print("=== INICIANDO TEST DE MEJORAS DE DEBUG ===")

	# Cargar GameScene
	var packed_scene = load("res://scenes/GameScene.tscn")
	if not packed_scene:
		print("❌ ERROR: No se pudo cargar GameScene.tscn")
		quit(1)
		return

	print("✅ GameScene.tscn cargado exitosamente")

	var scene_instance = packed_scene.instantiate()
	if not scene_instance:
		print("❌ ERROR: No se pudo instanciar GameScene")
		quit(1)
		return

	print("✅ GameScene instanciado exitosamente")
	current_scene = scene_instance

	# Dar tiempo a que se inicialice
	await get_process_frame()
	await get_process_frame()

	# Buscar GameController
	var game_controller = scene_instance
	if not game_controller:
		print("❌ ERROR: No se encontró GameController")
		quit(1)
		return

	print("✅ GameController encontrado")

	# Verificar constantes de debug
	if game_controller.has_method("get"):
		var dev_mode = game_controller.get("DEV_MODE_UNLOCK_ALL")
		var debug_ui = game_controller.get("DEV_MODE_DEBUG_UI")
		print("🚧 DEV_MODE_UNLOCK_ALL: %s" % dev_mode)
		print("🚧 DEV_MODE_DEBUG_UI: %s" % debug_ui)

	# Verificar que el game_data está inicializado
	if game_controller.has_method("get"):
		var game_data = game_controller.get("game_data")
		if game_data:
			print("✅ game_data inicializado")
			print("🎯 customer_system_unlocked: %s" % game_data.customer_system_unlocked)
		else:
			print("❌ game_data no inicializado")

	print("=== TEST COMPLETADO ===")
	quit(0)
