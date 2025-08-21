extends Control

class_name AutomationPanel

## T022 - Panel de Control de Automatización
## UI completa para configurar auto-producción y auto-venta

# Referencias a nodos UI
@onready
var auto_production_container: VBoxContainer = $MainContainer/ScrollContainer/VBoxContainer/AutoProductionSection/ProductionContainer
@onready
var auto_sell_container: VBoxContainer = $MainContainer/ScrollContainer/VBoxContainer/AutoSellSection/SellContainer
@onready
var global_settings_container: VBoxContainer = $MainContainer/ScrollContainer/VBoxContainer/GlobalSection/SettingsContainer

# Referencias a controles globales
@onready
var smart_priority_toggle: CheckBox = $MainContainer/ScrollContainer/VBoxContainer/GlobalSection/SettingsContainer/SmartPriorityToggle
@onready
var smart_pricing_toggle: CheckBox = $MainContainer/ScrollContainer/VBoxContainer/GlobalSection/SettingsContainer/SmartPricingToggle
@onready
var threshold_slider: HSlider = $MainContainer/ScrollContainer/VBoxContainer/GlobalSection/SettingsContainer/ThresholdContainer/ThresholdSlider
@onready
var threshold_label: Label = $MainContainer/ScrollContainer/VBoxContainer/GlobalSection/SettingsContainer/ThresholdContainer/ThresholdLabel

# Referencias a managers
var automation_manager: AutomationManager
var game_controller: GameController

# Datos de configuración
var station_toggles: Dictionary = {}
var product_toggles: Dictionary = {}

# Lista de estaciones y productos disponibles
var available_stations: Array[String] = ["brewery", "bar_station", "distillery"]
var available_products: Array[String] = ["beer", "cocktail", "whiskey"]


func _ready():
	print("🎛️ AutomationPanel inicializado")
	_setup_references()
	_setup_ui_components()
	_setup_signals()
	_load_current_settings()


func _setup_references():
	"""Obtener referencias a managers"""
	# El AutomationPanel busca GameController en el árbol de nodos
	var current = get_parent()
	while current and not current is GameController:
		current = current.get_parent()

	if current:
		game_controller = current
		automation_manager = game_controller.automation_manager
		print("🎛️ Referencias a managers configuradas")
	else:
		print("⚠️ No se pudo encontrar GameController")


func _setup_ui_components():
	"""Crear componentes UI dinámicos"""
	_create_production_toggles()
	_create_sell_toggles()
	_setup_global_controls()


func _create_production_toggles():
	"""Crear toggles para auto-producción por estación"""
	print("🏭 Creando controles de auto-producción")

	for station_id in available_stations:
		var station_control = _create_station_toggle(station_id)
		auto_production_container.add_child(station_control)

		var toggle = station_control.get_node("Toggle")
		station_toggles[station_id] = toggle
		toggle.toggled.connect(_on_production_toggle_changed.bind(station_id))


func _create_sell_toggles():
	"""Crear toggles para auto-venta por producto"""
	print("💰 Creando controles de auto-venta")

	for product in available_products:
		var product_control = _create_product_toggle(product)
		auto_sell_container.add_child(product_control)

		var toggle = product_control.get_node("Toggle")
		product_toggles[product] = toggle
		toggle.toggled.connect(_on_sell_toggle_changed.bind(product))


func _create_station_toggle(station_id: String) -> Control:
	"""Crear control individual para estación"""
	var container = HBoxContainer.new()

	# Icono de estación
	var icon_label = Label.new()
	icon_label.text = _get_station_icon(station_id)
	icon_label.custom_minimum_size = Vector2(30, 0)
	container.add_child(icon_label)

	# Nombre de estación
	var name_label = Label.new()
	name_label.text = _get_station_name(station_id)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(name_label)

	# Status indicator
	var status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "⏸️ Parado"
	status_label.custom_minimum_size = Vector2(80, 0)
	container.add_child(status_label)

	# Toggle switch
	var toggle = CheckBox.new()
	toggle.name = "Toggle"
	toggle.text = ""
	container.add_child(toggle)

	return container


func _create_product_toggle(product: String) -> Control:
	"""Crear control individual para producto"""
	var container = VBoxContainer.new()

	# Header con producto
	var header = HBoxContainer.new()

	# Icono y nombre del producto
	var icon_label = Label.new()
	icon_label.text = _get_product_icon(product)
	icon_label.custom_minimum_size = Vector2(30, 0)
	header.add_child(icon_label)

	var name_label = Label.new()
	name_label.text = _get_product_name(product)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)

	# Toggle switch
	var toggle = CheckBox.new()
	toggle.name = "Toggle"
	toggle.text = ""
	header.add_child(toggle)

	container.add_child(header)

	# Info panel con métricas
	var info_panel = _create_product_info_panel(product)
	info_panel.name = "InfoPanel"
	container.add_child(info_panel)

	return container


func _create_product_info_panel(product: String) -> Control:
	"""Crear panel de información para producto"""
	var panel = VBoxContainer.new()
	panel.modulate = Color(0.8, 0.8, 0.8, 1.0)  # Más tenue

	# Stock level
	var stock_label = Label.new()
	stock_label.name = "StockLabel"
	stock_label.text = "📦 Stock: 0/100 (0%)"
	panel.add_child(stock_label)

	# Price info
	var price_label = Label.new()
	price_label.name = "PriceLabel"
	price_label.text = "💰 Precio: $8.50 (1.0x)"
	panel.add_child(price_label)

	# Will sell indicator
	var sell_label = Label.new()
	sell_label.name = "SellLabel"
	sell_label.text = "🤖 No venderá (stock bajo)"
	panel.add_child(sell_label)

	return panel


func _setup_global_controls():
	"""Configurar controles globales"""
	# Threshold slider
	threshold_slider.min_value = 0.5
	threshold_slider.max_value = 1.0
	threshold_slider.step = 0.05
	threshold_slider.value = 0.8

	threshold_slider.value_changed.connect(_on_threshold_changed)


func _setup_signals():
	"""Conectar señales"""
	if automation_manager:
		automation_manager.automation_config_changed.connect(_on_automation_config_changed)


func _load_current_settings():
	"""Cargar configuraciones actuales"""
	if not automation_manager:
		return

	# Cargar estado de auto-producción
	for station_id in available_stations:
		if station_toggles.has(station_id):
			var enabled = automation_manager.is_auto_production_enabled(station_id)
			station_toggles[station_id].set_pressed_no_signal(enabled)
			_update_station_status(station_id, enabled)

	# Cargar estado de auto-venta
	for product in available_products:
		if product_toggles.has(product):
			var enabled = automation_manager.is_auto_sell_enabled(product)
			product_toggles[product].set_pressed_no_signal(enabled)

	# Cargar configuraciones globales
	var status = automation_manager.get_automation_status()
	smart_priority_toggle.set_pressed_no_signal(status.get("smart_priority", true))
	threshold_slider.set_value_no_signal(status.get("sell_threshold", 0.8))

	# Smart pricing desde game_data
	if game_controller and game_controller.game_data:
		var smart_pricing_enabled = game_controller.game_data.upgrades.get("smart_pricing", false)
		smart_pricing_toggle.set_pressed_no_signal(smart_pricing_enabled)

	_update_all_displays()
	print("🎛️ Configuraciones actuales cargadas")


# =============================================================================
# EVENT HANDLERS
# =============================================================================


func _on_production_toggle_changed(station_id: String, enabled: bool):
	"""Manejar cambio en toggle de producción"""
	if automation_manager:
		automation_manager.enable_auto_production(station_id, enabled)
		_update_station_status(station_id, enabled)
		print("🏭 Auto-producción %s: %s" % [station_id, "ON" if enabled else "OFF"])


func _on_sell_toggle_changed(product: String, enabled: bool):
	"""Manejar cambio en toggle de venta"""
	if automation_manager:
		automation_manager.enable_auto_sell(product, enabled)
		_update_product_info(product)
		print("💰 Auto-venta %s: %s" % [product, "ON" if enabled else "OFF"])


func _on_threshold_changed(value: float):
	"""Manejar cambio en threshold slider"""
	if automation_manager:
		automation_manager.set_auto_sell_threshold(value)
		threshold_label.text = "Umbral: %.0f%%" % (value * 100)
		_update_all_product_info()
		print("🎚️ Threshold actualizado: %.1f" % value)


func _on_automation_config_changed(setting: String, enabled: bool):
	"""Manejar cambio en configuración de automatización"""
	print("⚙️ Config cambiada: %s = %s" % [setting, enabled])
	_update_all_displays()


func _on_smart_priority_toggled(enabled: bool):
	"""Manejar toggle de prioridad inteligente"""
	if automation_manager:
		automation_manager.set_smart_production_priority(enabled)
		print("🧠 Smart Priority: %s" % ("ON" if enabled else "OFF"))


func _on_smart_pricing_toggled(enabled: bool):
	"""Manejar toggle de pricing inteligente"""
	if automation_manager:
		automation_manager.set_smart_pricing_enabled(enabled)
		print("💡 Smart Pricing: %s" % ("ON" if enabled else "OFF"))


# =============================================================================
# UPDATE FUNCTIONS
# =============================================================================


func _update_all_displays():
	"""Actualizar todos los displays"""
	_update_all_station_status()
	_update_all_product_info()
	_update_threshold_display()


func _update_all_station_status():
	"""Actualizar estado de todas las estaciones"""
	for station_id in available_stations:
		var enabled = station_toggles.get(station_id, CheckBox.new()).button_pressed
		_update_station_status(station_id, enabled)


func _update_station_status(station_id: String, enabled: bool):
	"""Actualizar status visual de estación"""
	var station_control = _find_station_control(station_id)
	if not station_control:
		return

	var status_label = station_control.get_node("StatusLabel")
	if enabled:
		status_label.text = "🤖 Activo"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "⏸️ Parado"
		status_label.modulate = Color.GRAY


func _update_all_product_info():
	"""Actualizar info de todos los productos"""
	for product in available_products:
		_update_product_info(product)


func _update_product_info(product: String):
	"""Actualizar información detallada de producto"""
	if not automation_manager:
		return

	var product_control = _find_product_control(product)
	if not product_control:
		return

	var info_panel = product_control.get_node("InfoPanel")
	var status = automation_manager.get_auto_sell_status(product)

	# Stock info
	var stock_label = info_panel.get_node("StockLabel")
	var stock_ratio = status.get("stock_ratio", 0.0)
	var stock_text = "📦 Stock: %.0f%% " % (stock_ratio * 100)
	if stock_ratio >= 0.9:
		stock_text += "(LLENO)"
		stock_label.modulate = Color.RED
	elif stock_ratio >= 0.7:
		stock_text += "(Alto)"
		stock_label.modulate = Color.YELLOW
	else:
		stock_text += "(OK)"
		stock_label.modulate = Color.GREEN
	stock_label.text = stock_text

	# Price info
	var price_label = info_panel.get_node("PriceLabel")
	var multiplier = status.get("offer_multiplier", 1.0)
	price_label.text = "💰 Oferta: %.1fx" % multiplier
	if multiplier >= 1.5:
		price_label.modulate = Color.GREEN
	elif multiplier >= 1.2:
		price_label.modulate = Color.YELLOW
	else:
		price_label.modulate = Color.RED

	# Sell prediction
	var sell_label = info_panel.get_node("SellLabel")
	var will_sell = status.get("will_sell", false)
	if will_sell:
		sell_label.text = "🤖 VENDERÁ automáticamente"
		sell_label.modulate = Color.GREEN
	else:
		sell_label.text = "⏸️ No cumple criterios"
		sell_label.modulate = Color.GRAY


func _update_threshold_display():
	"""Actualizar display del threshold"""
	var current_threshold = threshold_slider.value
	threshold_label.text = "Umbral: %.0f%%" % (current_threshold * 100)


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


func _find_station_control(station_id: String) -> Control:
	"""Encontrar control de estación por ID"""
	for child in auto_production_container.get_children():
		# Verificar por posición o por algún identificador
		var index = available_stations.find(station_id)
		if child.get_index() == index:
			return child
	return null


func _find_product_control(product: String) -> Control:
	"""Encontrar control de producto por ID"""
	for child in auto_sell_container.get_children():
		var index = available_products.find(product)
		if child.get_index() == index:
			return child
	return null


func _get_station_icon(station_id: String) -> String:
	"""Obtener icono para estación"""
	match station_id:
		"brewery":
			return "🍺"
		"bar_station":
			return "🍸"
		"distillery":
			return "🥃"
		_:
			return "🏭"


func _get_station_name(station_id: String) -> String:
	"""Obtener nombre legible para estación"""
	match station_id:
		"brewery":
			return "Cervecería"
		"bar_station":
			return "Bar Station"
		"distillery":
			return "Destilería"
		_:
			return station_id.capitalize()


func _get_product_icon(product: String) -> String:
	"""Obtener icono para producto"""
	match product:
		"beer":
			return "🍺"
		"cocktail":
			return "🍸"
		"whiskey":
			return "🥃"
		_:
			return "🍶"


func _get_product_name(product: String) -> String:
	"""Obtener nombre legible para producto"""
	match product:
		"beer":
			return "Cerveza"
		"cocktail":
			return "Cocktail"
		"whiskey":
			return "Whiskey"
		_:
			return product.capitalize()


# =============================================================================
# PUBLIC INTERFACE
# =============================================================================


func show_panel():
	"""Mostrar el panel"""
	show()
	_load_current_settings()
	print("🎛️ Panel de automatización mostrado")


func hide_panel():
	"""Ocultar el panel"""
	hide()
	print("🎛️ Panel de automatización ocultado")


func refresh_data():
	"""Refrescar todos los datos del panel"""
	_load_current_settings()
	print("🔄 Datos del panel actualizados")
