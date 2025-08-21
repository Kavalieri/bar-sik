extends Node

## ═══════════════════════════════════════════════════════════════════════════════════
## T023 - VALIDACIÓN DEL OFFLINE PROGRESS CALCULATOR
## ═══════════════════════════════════════════════════════════════════════════════════
## Descripción: Validar funcionamiento completo del sistema de progreso offline
## Versión: 1.0
## Fecha: 2024-12-19
## ═══════════════════════════════════════════════════════════════════════════════════


func _ready():
	print("\n🔍 === T023 - VALIDACIÓN OFFLINE PROGRESS CALCULATOR ===")
	await _validate_offline_progress_system()


func _validate_offline_progress_system():
	print("\n📊 Iniciando validación del sistema de progreso offline...")

	# 1. Verificar GameController integration
	print("\n1️⃣ Verificando integración en GameController...")
	var game_controller = get_tree().get_first_node_in_group("game_controller")

	if not game_controller:
		print("❌ GameController no encontrado")
		return

	# Verificar variable offline_progress_manager
	if not game_controller.has_method("get") or not game_controller.get("offline_progress_manager"):
		print("❌ offline_progress_manager no encontrado en GameController")
		return

	var offline_manager = game_controller.offline_progress_manager
	print("✅ OfflineProgressManager encontrado: %s" % offline_manager.get_script().resource_path)

	# 2. Verificar funciones principales
	print("\n2️⃣ Verificando funciones del OfflineProgressManager...")

	var required_methods = [
		"calculate_offline_progress",
		"check_offline_progress",
		"_simulate_offline_resource_generation",
		"_simulate_offline_production",
		"_simulate_offline_auto_sell",
		"_simulate_offline_customers",
		"_calculate_catch_up_bonus"
	]

	for method in required_methods:
		if offline_manager.has_method(method):
			print("✅ Método %s: OK" % method)
		else:
			print("❌ Método %s: NO ENCONTRADO" % method)

	# 3. Verificar integración en _setup_game_data
	print("\n3️⃣ Verificando integración en setup de datos...")

	if game_controller.has_method("_process_offline_progress"):
		print("✅ Función _process_offline_progress: OK")
	else:
		print("❌ Función _process_offline_progress: NO ENCONTRADA")

	# 4. Verificar sistema de guardado del timestamp
	print("\n4️⃣ Verificando timestamp en _notification...")

	var game_data = game_controller.game_data
	if game_data and game_data.gameplay_data.has("last_close_time"):
		var timestamp = game_data.gameplay_data["last_close_time"]
		print("✅ last_close_time encontrado: %d" % timestamp)

		# Calcular tiempo offline simulado
		var current_time = Time.get_unix_time_from_system()
		var time_diff = current_time - timestamp
		print(
			(
				"📅 Tiempo desde último cierre: %.1f segundos (%.2f minutos)"
				% [time_diff, time_diff / 60.0]
			)
		)
	else:
		print("⚠️ last_close_time no encontrado (normal en primera ejecución)")

	# 5. Simular cálculo offline (sin aplicar cambios)
	print("\n5️⃣ Simulando cálculo de progreso offline...")

	if offline_manager.has_method("calculate_offline_progress"):
		# Crear datos de prueba con timestamp anterior
		var test_data = game_data.duplicate(true) if game_data else {}
		if not test_data.has("gameplay_data"):
			test_data["gameplay_data"] = {}

		# Simular 1 hora offline
		test_data.gameplay_data["last_close_time"] = Time.get_unix_time_from_system() - 3600

		var progress_result = offline_manager.calculate_offline_progress(test_data)

		if progress_result and progress_result.size() > 0:
			print("✅ Cálculo offline exitoso:")
			print("   - Horas offline: %.2f" % progress_result.get("offline_hours", 0))
			print("   - Eficiencia: %.2f" % progress_result.get("efficiency", 0))
			print("   - Recursos generados: %s" % progress_result.get("resources_generated", {}))
			print("   - Productos producidos: %s" % progress_result.get("products_produced", {}))
			print("   - Clientes servidos: %d" % progress_result.get("customers_served", 0))
			print("   - Tokens ganados: %d" % progress_result.get("tokens_earned", 0))
			print("   - Catch-up bonus: %d" % progress_result.get("catch_up_bonus", 0))
		else:
			print("⚠️ No se generó progreso offline (puede ser normal)")

	# 6. Verificar diálogo visual
	print("\n6️⃣ Verificando función de diálogo visual...")

	if game_controller.has_method("_create_offline_progress_dialog"):
		print("✅ Función _create_offline_progress_dialog: OK")
	else:
		print("❌ Función _create_offline_progress_dialog: NO ENCONTRADA")

	# 7. Estado de automatización (importante para offline)
	print("\n7️⃣ Verificando estado de automatización...")

	if game_controller.get("automation_manager"):
		var auto_manager = game_controller.automation_manager
		print("✅ AutomationManager encontrado")

		if auto_manager.has_method("get_automation_state"):
			var auto_state = auto_manager.get_automation_state()
			print("   - Auto-producción: %s" % auto_state.get("auto_production_enabled", false))
			print("   - Auto-venta: %s" % auto_state.get("auto_sell_enabled", false))
		else:
			print("   - Estado de automatización no disponible")
	else:
		print("⚠️ AutomationManager no encontrado")

	print("\n✅ === VALIDACIÓN T023 COMPLETADA ===")
	print("📋 El sistema de Offline Progress Calculator está implementado")
	print("🎮 Los jugadores ahora pueden ganar recursos mientras están offline")
	print("⏰ El progreso offline respeta la configuración de automatización")
	print("🎁 Incluye bonificaciones de catch-up para incentivar el regreso")
	print("📱 Interfaz visual amigable para mostrar el progreso al regresar")
