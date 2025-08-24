extends BasePanel
## CustomersPanel - Panel de clientes (versión debug)

# Señales específicas del panel
signal autosell_upgrade_purchased(upgrade_id: String)
signal automation_upgrade_purchased(upgrade_id: String)

# Referencias a datos del juego
var game_data: GameData

# Estado específico del panel
var customer_manager_ref: Node = null


func initialize_specific_content():
	"""Override BasePanel: Inicializar contenido específico del panel"""
	print("🔍 [CUSTOMERS] initialize_specific_content() - Iniciando...")

	# Debug GameManager
	print("🔍 [CUSTOMERS] GameManager existe: %s" % (GameManager != null))
	if GameManager:
		print("🔍 [CUSTOMERS] GameManager.game_data existe: %s" % (GameManager.game_data != null))
		if GameManager.game_data:
			print("🔍 [CUSTOMERS] GameManager.game_data tipo: %s" % GameManager.game_data.get_class())
			print("🔍 [CUSTOMERS] customer_system_unlocked INICIAL: %s" % GameManager.game_data.customer_system_unlocked)

	# Inicializar game_data si no está disponible
	if not game_data and GameManager:
		game_data = GameManager.game_data
		print("🔍 [CUSTOMERS] game_data obtenido del GameManager")

	_initialize_panel_specific()


# Función para refrescar el estado de desbloqueo (llamada desde GameController)
func refresh_unlock_status():
	"""Refrescar el estado de desbloqueo del panel"""
	print("🔄 [DEBUG] CustomersPanel.refresh_unlock_status() llamado")

	# Actualizar referencia de game_data
	if GameManager and GameManager.game_data:
		game_data = GameManager.game_data
		print("🔄 [DEBUG] CustomersPanel - game_data actualizado")

	# Re-inicializar el panel
	_initialize_panel_specific()


func _initialize_panel_specific() -> void:
	"""Inicialización específica del panel de clientes"""
	print("🔍 [CUSTOMERS] _initialize_panel_specific() - game_data: %s" % (game_data != null))
	
	# MODO DESARROLLO: Forzar desbloqueo inmediatamente
	var dev_mode_force_unlock = true  # 🚧 CAMBIAR A false PARA PRODUCCIÓN
	if dev_mode_force_unlock:
		print("🚧 [CUSTOMERS] MODO DESARROLLO FORZADO - Desbloqueando sistema de clientes")
		if game_data:
			game_data.customer_system_unlocked = true
		else:
			print("❌ [CUSTOMERS] No se puede forzar desbloqueo - game_data es null")
	
	if game_data:
		print("🔍 [CUSTOMERS] customer_system_unlocked FINAL: %s" % game_data.customer_system_unlocked)
		
		# Búsqueda de GameController (mantenida para funcionalidad completa)
		var game_scene = get_node_or_null("/root/GameScene")
		if game_scene and game_scene.has_method("get"):
			var game_controller = game_scene.get("game_controller")
			if game_controller:
				print("✅ [CUSTOMERS] GameController encontrado via GameScene")
				# Verificar si el modo desarrollo está activado en GameController también
				if game_controller.get("DEV_MODE_UNLOCK_ALL"):
					print("✅ [CUSTOMERS] GameController también tiene DEV_MODE activo")
			else:
				print("❌ [CUSTOMERS] GameController no encontrado en GameScene")
		else:
			print("❌ [CUSTOMERS] GameScene no encontrado")
	else:
		print("❌ [CUSTOMERS] game_data es null!")

	# Verificar FINAL si el sistema está desbloqueado
	if game_data and game_data.customer_system_unlocked:
		print("✅ [CUSTOMERS] Sistema DESBLOQUEADO - Configurando panel de gestión")
		_setup_management_panel()
		print("✅ [CUSTOMERS] Panel de gestión configurado exitosamente")
	else:
		print("🔒 [CUSTOMERS] Sistema AÚN BLOQUEADO - Mostrando unlock panel")
		_show_unlock_panel()


func _show_unlock_panel() -> void:
	"""Mostrar UI de desbloqueo cuando el sistema no está activo"""
	print("🔒 [CUSTOMERS] MOSTRANDO UNLOCK PANEL - sistema bloqueado")

	# Limpiar contenido existente
	if has_node("MainContainer"):
		print("🔄 [CUSTOMERS] Limpiando MainContainer existente")
		for child in $MainContainer.get_children():
			if is_instance_valid(child):
				print("🗑️ [CUSTOMERS] Removiendo hijo: %s" % child.name)
				child.queue_free()

		# Esperar un frame para que se eliminen
		await get_tree().process_frame
		
		# Crear mensaje simple
		var label = Label.new()
		label.name = "UnlockMessage"
		label.text = ("🔒 SISTEMA DE CLIENTES\n\n" +
			"Este sistema aún no está desbloqueado.\n" +
			"Trabaja en la producción para desbloquearlo.")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color.GOLD)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		$MainContainer.add_child(label)
		
		# BOTÓN DE DESARROLLO - Forzar desbloqueo
		var dev_button = Button.new()
		dev_button.name = "DevUnlockButton"
		dev_button.text = "🚧 [DEV] FORZAR DESBLOQUEO"
		dev_button.custom_minimum_size = Vector2(300, 60)
		dev_button.add_theme_font_size_override("font_size", 16)
		dev_button.add_theme_color_override("font_color", Color.RED)
		dev_button.pressed.connect(_on_dev_unlock_pressed)
		$MainContainer.add_child(dev_button)

		print("🔒 [CUSTOMERS] Unlock panel creado y agregado")
	else:
		print("❌ [CUSTOMERS] MainContainer no encontrado!")


func _setup_management_panel():
	"""Panel principal de gestión cuando sistema está desbloqueado"""
	print("🔍 [CUSTOMERS] Creando management panel REAL...")

	# Obtener referencia al CustomerManager
	var game_scene = get_node_or_null("/root/GameScene")
	if game_scene and game_scene.has_method("get"):
		var game_controller = game_scene.get("game_controller")
		if game_controller and game_controller.has_method("get"):
			customer_manager_ref = game_controller.get("customer_manager")
			if customer_manager_ref:
				print("✅ [CUSTOMERS] CustomerManager encontrado")
			else:
				print("❌ [CUSTOMERS] CustomerManager no encontrado en GameController")

	# Limpiar contenido existente del container principal
	if has_node("MainContainer"):
		# No eliminar todos los hijos, solo los placeholders
		var children_to_remove = []
		for child in $MainContainer.get_children():
			if child.name in ["TitleLabel", "TimerSection", "UpgradesSection", "VSeparator1", "VSeparator2"]:
				continue  # Mantener los contenedores de la escena
			else:
				children_to_remove.append(child)
		
		for child in children_to_remove:
			if is_instance_valid(child):
				child.queue_free()
	
	# Actualizar el título
	if has_node("MainContainer/TitleLabel"):
		$MainContainer/TitleLabel.text = "👥 CLIENTES AUTOMÁTICOS"
		$MainContainer/TitleLabel.add_theme_color_override("font_color", Color.CYAN)
	
	# Configurar sección de timers
	_setup_timer_display()
	
	# Configurar sección de upgrades
	_setup_upgrades_display()

	print("✅ [CUSTOMERS] Management panel REAL creado")


func set_customer_manager(manager: Node) -> void:
	customer_manager_ref = manager
	print("🔗 CustomersPanel conectado con CustomerManager")


func _setup_timer_display():
	"""Configurar la visualización de timers de clientes"""
	if not has_node("MainContainer/TimerSection/TimerContainer"):
		return
	
	var timer_container = $MainContainer/TimerSection/TimerContainer
	
	# Limpiar contenido anterior
	for child in timer_container.get_children():
		child.queue_free()
	
	if not customer_manager_ref:
		var no_manager_label = Label.new()
		no_manager_label.text = "❌ CustomerManager no disponible"
		no_manager_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		timer_container.add_child(no_manager_label)
		return
	
	# Estado del sistema
	var status_label = Label.new()
	var is_enabled = game_data and game_data.upgrades.get("auto_sell_enabled", false)
	status_label.text = "Estado: %s" % ("✅ ACTIVO" if is_enabled else "🔒 INACTIVO")
	status_label.add_theme_color_override("font_color", Color.GREEN if is_enabled else Color.RED)
	timer_container.add_child(status_label)
	
	# Información de clientes activos
	if customer_manager_ref.has_method("get"):
		var active_customers = customer_manager_ref.get("active_customers")
		var customers_label = Label.new()
		customers_label.text = "Clientes activos: %d" % active_customers
		customers_label.add_theme_color_override("font_color", Color.CYAN)
		timer_container.add_child(customers_label)
	
	# Barra de progreso del timer (si está activo)
	if is_enabled:
		var progress_bar = ProgressBar.new()
		progress_bar.name = "CustomerTimer"
		progress_bar.custom_minimum_size = Vector2(300, 30)
		progress_bar.value = 0
		progress_bar.max_value = 100
		timer_container.add_child(progress_bar)
		
		var timer_label = Label.new()
		timer_label.name = "TimerLabel"
		timer_label.text = "Próximo cliente en..."
		timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		timer_container.add_child(timer_label)


func _setup_upgrades_display():
	"""Configurar la visualización de upgrades de clientes"""
	if not has_node("MainContainer/UpgradesSection"):
		return
	
	var upgrades_section = $MainContainer/UpgradesSection
	
	# Buscar o crear el contenedor de upgrades
	var upgrades_container = upgrades_section.get_node_or_null("UpgradesContainer")
	if not upgrades_container:
		upgrades_container = VBoxContainer.new()
		upgrades_container.name = "UpgradesContainer"
		upgrades_section.add_child(upgrades_container)
	
	# Limpiar upgrades anteriores
	for child in upgrades_container.get_children():
		child.queue_free()
	
	if not customer_manager_ref:
		var no_manager_label = Label.new()
		no_manager_label.text = "❌ CustomerManager no disponible para upgrades"
		no_manager_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		upgrades_container.add_child(no_manager_label)
		return
	
	# Obtener upgrades disponibles
	if customer_manager_ref.has_method("get"):
		var upgrades = customer_manager_ref.get("customer_upgrades")
		if upgrades:
			_create_upgrade_buttons(upgrades_container, upgrades)
		else:
			var no_upgrades_label = Label.new()
			no_upgrades_label.text = "No hay upgrades disponibles"
			upgrades_container.add_child(no_upgrades_label)


func _create_upgrade_buttons(container: Node, upgrades: Array):
	"""Crear botones de upgrade"""
	for upgrade in upgrades:
		var upgrade_panel = _create_upgrade_panel(upgrade)
		container.add_child(upgrade_panel)


func _create_upgrade_panel(upgrade: Dictionary) -> Control:
	"""Crear un panel individual para un upgrade"""
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 80)
	
	var hbox = HBoxContainer.new()
	panel.add_child(hbox)
	
	# Información del upgrade
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_label = Label.new()
	name_label.text = upgrade.get("name", "Upgrade")
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color.YELLOW)
	info_vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = upgrade.get("description", "Sin descripción")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_vbox.add_child(desc_label)
	
	# Botón de compra
	var buy_button = Button.new()
	var cost = upgrade.get("cost", 0)
	var currency = upgrade.get("currency", "money")
	buy_button.text = "Comprar\n%d %s" % [cost, currency]
	buy_button.custom_minimum_size = Vector2(100, 60)
	
	# Verificar si ya está comprado o si se puede comprar
	var required_key = upgrade.get("required_key", "")
	var is_purchased = game_data and game_data.upgrades.get(required_key, false)
	var can_afford = _can_afford_upgrade(upgrade)
	
	if is_purchased:
		buy_button.text = "✅ COMPRADO"
		buy_button.disabled = true
		buy_button.modulate = Color.GREEN
	elif not can_afford:
		buy_button.disabled = true
		buy_button.modulate = Color.RED
	else:
		buy_button.modulate = Color.WHITE
		# Conectar señal de compra
		buy_button.pressed.connect(_on_upgrade_purchased.bind(upgrade))
	
	hbox.add_child(buy_button)
	
	return panel


func _can_afford_upgrade(upgrade: Dictionary) -> bool:
	"""Verificar si se puede pagar un upgrade"""
	if not game_data:
		return false
	
	var cost = upgrade.get("cost", 0)
	var currency = upgrade.get("currency", "money")
	
	match currency:
		"money":
			return game_data.money >= cost
		"gems":
			return game_data.gems >= cost
		"prestige_tokens":
			return game_data.prestige_tokens >= cost
		_:
			return false


func _on_upgrade_purchased(upgrade: Dictionary):
	"""Manejar compra de upgrade"""
	if not customer_manager_ref or not customer_manager_ref.has_method("purchase_upgrade"):
		print("❌ No se puede comprar upgrade - CustomerManager no disponible")
		return
	
	print("💰 Comprando upgrade: %s" % upgrade.get("name", ""))
	customer_manager_ref.purchase_upgrade(upgrade.get("id", ""))
	
	# Actualizar display
	_setup_upgrades_display()


func _on_dev_unlock_pressed():
	"""Función para forzar desbloqueo desde botón de desarrollo"""
	print("🚧 [DEV] Botón de desbloqueo presionado - forzando unlock")
	
	if game_data:
		game_data.customer_system_unlocked = true
		print("✅ [DEV] customer_system_unlocked establecido a true")
		
		# Re-inicializar el panel
		_initialize_panel_specific()
	else:
		print("❌ [DEV] game_data no disponible para desbloquear")


func _process(_delta: float):
	"""Actualizar UI cada frame"""
	# Actualizar barra de progreso del timer
	if customer_manager_ref and has_node("MainContainer/TimerSection/TimerContainer/CustomerTimer"):
		var progress_bar = $MainContainer/TimerSection/TimerContainer/CustomerTimer
		var timer_progress = customer_manager_ref.get("customer_timer_progress") if customer_manager_ref.has_method("get") else 0.0
		progress_bar.value = timer_progress * 100.0
