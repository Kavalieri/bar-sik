extends ScrollContainer
## CustomersPanel - Panel de clientes limpio y modular
## Maneja sistema de clientes, upgrades y automatización

# Referencias a contenedores
@onready var main_container: VBoxContainer = $MainContainer
@onready var timer_container: VBoxContainer = $MainContainer/TimerSection/TimerContainer
@onready var upgrades_container: VBoxContainer = $MainContainer/UpgradesSection/UpgradesContainer
@onready var automation_container: VBoxContainer = (
	$MainContainer/AutomationSection/AutomationContainer
)

# Estado del panel
var is_initialized: bool = false
var timer_label: Label
var timer_progress: ProgressBar
var upgrade_buttons: Array[Control] = []

# Señales
signal autosell_upgrade_purchased(upgrade_id: String)
signal automation_upgrade_purchased(upgrade_id: String)

func _ready() -> void:
	print("👥 CustomersPanel inicializando...")
	call_deferred("_initialize_panel")

func _initialize_panel() -> void:
	"""Inicialización completa del panel"""
	_create_sections()
	is_initialized = true
	print("✅ CustomersPanel inicializado correctamente")

func _create_sections() -> void:
	"""Crear secciones del panel"""
	_create_timer_section()
	_create_upgrades_section()
	_create_automation_section()

func _create_timer_section() -> void:
	"""Crear sección de temporizador de cliente"""
	_clear_container(timer_container)
	var header = UIStyleManager.create_section_header("⏰ PRÓXIMO CLIENTE")
	timer_container.add_child(header)

	# Panel para el timer
	var timer_panel = UIStyleManager.create_styled_panel()
	timer_panel.set_custom_minimum_size(Vector2(0, 80))
	timer_container.add_child(timer_panel)

	var timer_vbox = VBoxContainer.new()
	timer_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	timer_vbox.add_theme_constant_override("separation", 8)
	timer_panel.add_child(timer_vbox)

	# Label del timer
	timer_label = Label.new()
	timer_label.text = "Esperando cliente..."
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 14)
	timer_vbox.add_child(timer_label)

	# Barra de progreso
	timer_progress = ProgressBar.new()
	timer_progress.set_custom_minimum_size(Vector2(0, 20))
	timer_progress.value = 0
	timer_progress.max_value = 100
	timer_vbox.add_child(timer_progress)

func _create_upgrades_section() -> void:
	"""Crear sección de upgrades"""
	_clear_container(upgrades_container)
	var header = UIStyleManager.create_section_header(
		"🛒 MEJORAS DE AUTOVENTA",
		"Mejora la velocidad y eficiencia de ventas automáticas"
	)
	upgrades_container.add_child(header)

func _create_automation_section() -> void:
	"""Crear sección de automatización"""
	_clear_container(automation_container)
	var header = UIStyleManager.create_section_header(
		"⚙️ AUTOMATIZACIÓN AVANZADA",
		"Sistemas automáticos para tu negocio"
	)
	automation_container.add_child(header)

func setup_autosell_upgrades(game_data: Dictionary) -> void:
	"""Configura los upgrades de autoventa"""
	if not is_initialized:
		call_deferred("setup_autosell_upgrades", game_data)
		return

	_clear_upgrade_buttons()

	# Crear upgrades básicos
	var upgrades = [
		{
			"id": "sell_speed_1",
			"name": "🚀 Velocidad de Venta +",
			"description": "Aumenta la velocidad de venta automática",
			"cost": 100.0,
			"unlocked": true
		},
		{
			"id": "sell_efficiency_1",
			"name": "💎 Eficiencia de Venta +",
			"description": "Mejora los precios de venta automática",
			"cost": 250.0,
			"unlocked": true
		},
		{
			"id": "customer_attraction_1",
			"name": "📢 Atracción de Clientes +",
			"description": "Atrae clientes más frecuentemente",
			"cost": 500.0,
			"unlocked": true
		}
	]

	for upgrade in upgrades:
		var interface = _create_upgrade_interface(upgrade)
		upgrades_container.add_child(interface)
		upgrade_buttons.append(interface)

func _create_upgrade_interface(upgrade: Dictionary) -> Control:
	"""Crea la interface para un upgrade"""
	var card = UIStyleManager.create_styled_panel()
	card.set_custom_minimum_size(Vector2(0, 100))

	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 12)
	card.add_child(hbox)

	# Información del upgrade
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_label = Label.new()
	name_label.text = upgrade.get("name", "Upgrade")
	name_label.add_theme_font_size_override("font_size", 14)
	info_vbox.add_child(name_label)

	var desc_label = Label.new()
	desc_label.text = upgrade.get("description", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.modulate = Color.GRAY
	info_vbox.add_child(desc_label)

	var cost_label = Label.new()
	cost_label.text = "Costo: $%s" % GameUtils.format_large_number(upgrade.get("cost", 0))
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.modulate = Color.GREEN
	info_vbox.add_child(cost_label)

	# Botón de compra
	var button = UIStyleManager.create_styled_button("Comprar")
	button.set_custom_minimum_size(Vector2(80, 60))
	button.pressed.connect(_on_upgrade_purchase_requested.bind(upgrade.get("id", "")))
	hbox.add_child(button)

	return card

func update_customer_display(game_data: Dictionary, timer_progress_value: float) -> void:
	"""Actualiza la visualización del cliente"""
	if not is_initialized:
		return

	# Actualizar timer
	if timer_label:
		var time_left = (1.0 - timer_progress_value) * 30  # Asumiendo 30 segundos por cliente
		timer_label.text = "Próximo cliente en %.1f segundos" % time_left

	if timer_progress:
		timer_progress.value = timer_progress_value * 100

func update_upgrade_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de upgrades"""
	if not is_initialized:
		return

	var money = game_data.get("money", 0.0)
	var upgrades_owned = game_data.get("upgrades", {})

	for i in range(upgrade_buttons.size()):
		var interface = upgrade_buttons[i]
		var hbox = interface.get_child(0) as HBoxContainer
		if not hbox or hbox.get_child_count() < 2:
			continue

		var button = hbox.get_child(1) as Button
		if not button:
			continue

		# Obtener ID del upgrade (asumiendo que está en el metadata)
		var upgrade_id = button.get_meta("upgrade_id", "")
		var is_owned = upgrades_owned.has(upgrade_id)

		if is_owned:
			button.text = "✅ Comprado"
			button.disabled = true
			button.modulate = Color.GRAY
		else:
			# Actualizar disponibilidad basada en dinero
			var cost = 100.0 + (i * 150.0)  # Costo incremental
			var can_afford = money >= cost
			button.disabled = not can_afford
			button.modulate = Color.WHITE if can_afford else Color.GRAY

# Métodos de eventos
func _on_upgrade_purchase_requested(upgrade_id: String) -> void:
	"""Maneja la solicitud de compra de upgrade"""
	autosell_upgrade_purchased.emit(upgrade_id)

# Funciones de utilidad
func _clear_container(container: Container) -> void:
	"""Limpia un contenedor de forma segura"""
	if not container:
		return
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _clear_upgrade_buttons() -> void:
	"""Limpia los botones de upgrade"""
	for button in upgrade_buttons:
		if button:
			button.queue_free()
	upgrade_buttons.clear()
