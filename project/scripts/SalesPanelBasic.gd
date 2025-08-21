extends Control
## SalesPanelBasic - Panel de ventas simple sin herencias complejas
## Arquitectura idéntica a ProductionPanelBasic para consistencia

# Señales
signal item_sell_requested(item_type: String, item_id: String, quantity: int)
signal sell_multiplier_changed(item_id: String, new_multiplier: int)

# Estado del panel
var sales_manager_ref: Node = null
var button_states: Dictionary = {}  # Estados centralizados de botones
var update_in_progress: bool = false  # Prevenir updates recursivos
var update_timer: Timer  # Timer para actualización en tiempo real

# Referencias
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var main_vbox: VBoxContainer = $ScrollContainer/MainVBox


func _ready():
	print("💰 SalesPanelBasic _ready() iniciado")
	setup_basic_layout()
	setup_update_timer()  # Configurar timer de actualización
	print("✅ SalesPanelBasic inicializado")


func setup_basic_layout():
	"""Configurar layout básico con elementos nativos de Godot"""
	# Limpiar contenido existente
	for child in main_vbox.get_children():
		child.queue_free()

	# === TÍTULO PRINCIPAL ===
	var main_title = Label.new()
	main_title.text = "💰 PANEL DE VENTAS"
	main_title.add_theme_font_size_override("font_size", 36)  # 24→36 mucho más grande
	main_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_title.add_theme_color_override("font_color", Color.GOLD)
	main_vbox.add_child(main_title)

	# Separador
	var separator1 = HSeparator.new()
	separator1.custom_minimum_size = Vector2(0, 30)  # 20→30 más espacio
	main_vbox.add_child(separator1)

	# === SECCIÓN DE INVENTARIO ===
	setup_inventory_section()


func setup_update_timer():
	"""Configurar timer de actualización en tiempo real"""
	update_timer = Timer.new()
	update_timer.wait_time = 1.0  # Actualizar cada segundo
	update_timer.timeout.connect(_on_update_timer_timeout)
	update_timer.autostart = false  # No iniciar hasta conectar con manager
	add_child(update_timer)
	print("⏰ Timer de actualización configurado (cada 1s)")


# T011: Configurar sección de estadísticas de ventas automáticas
func setup_sales_stats_section():
	"""Sección con indicadores de demanda de clientes y ventas automáticas"""
	# Título de estadísticas
	var stats_title = Label.new()
	stats_title.text = "📊 ESTADÍSTICAS DE VENTAS"
	stats_title.add_theme_font_size_override("font_size", 20)
	stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_title.add_theme_color_override("font_color", Color.GOLD)
	main_vbox.add_child(stats_title)

	# Panel de estadísticas
	var stats_panel = Panel.new()
	stats_panel.custom_minimum_size = Vector2(0, 80)

	# Estilo del panel de estadísticas
	var stats_panel_style = StyleBoxFlat.new()
	stats_panel_style.bg_color = Color(0.1, 0.1, 0.2, 0.9)
	stats_panel_style.corner_radius_top_left = 8
	stats_panel_style.corner_radius_top_right = 8
	stats_panel_style.corner_radius_bottom_left = 8
	stats_panel_style.corner_radius_bottom_right = 8
	stats_panel_style.border_width_left = 2
	stats_panel_style.border_width_right = 2
	stats_panel_style.border_width_top = 2
	stats_panel_style.border_width_bottom = 2
	stats_panel_style.border_color = Color.GOLD
	stats_panel.add_theme_stylebox_override("panel", stats_panel_style)

	# Layout interno del panel de estadísticas
	var stats_hbox = HBoxContainer.new()
	stats_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stats_hbox.add_theme_constant_override("margin_left", 15)
	stats_hbox.add_theme_constant_override("margin_right", 15)
	stats_hbox.add_theme_constant_override("margin_top", 10)
	stats_hbox.add_theme_constant_override("margin_bottom", 10)
	stats_hbox.add_theme_constant_override("separation", 20)

	# Clientes interesados
	var customers_label = Label.new()
	customers_label.text = "👥 Clientes: 0 interesados"
	customers_label.add_theme_font_size_override("font_size", 16)
	customers_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	customers_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	customers_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	customers_label.name = "customers_stats_label"
	customers_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)

	# Ventas automáticas
	var auto_sales_label = Label.new()
	auto_sales_label.text = "💰 Auto-ventas: 0 tokens/min"
	auto_sales_label.add_theme_font_size_override("font_size", 16)
	auto_sales_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	auto_sales_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	auto_sales_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	auto_sales_label.name = "auto_sales_stats_label"
	auto_sales_label.add_theme_color_override("font_color", Color.YELLOW)

	stats_hbox.add_child(customers_label)
	stats_hbox.add_child(auto_sales_label)
	stats_panel.add_child(stats_hbox)
	main_vbox.add_child(stats_panel)


func _on_update_timer_timeout():
	"""Callback del timer de actualización - actualizar inventario automáticamente"""
	if not update_in_progress and sales_manager_ref:
		refresh_all_items()
		# print("🔄 Inventario actualizado automáticamente")  # Comentado para no spam


func setup_inventory_section():
	"""T011: Configurar sección completa con stats y inventario"""
	# T011: Sección de estadísticas de ventas automáticas
	setup_sales_stats_section()

	# Separador
	var separator_stats = HSeparator.new()
	separator_stats.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(separator_stats)

	# Título de sección
	var section_title = Label.new()
	section_title.text = "📦 INVENTARIO DISPONIBLE"
	section_title.add_theme_font_size_override("font_size", 24)  # 18→24 más grande
	section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	section_title.add_theme_color_override("font_color", Color.CYAN)
	main_vbox.add_child(section_title)

	# === INGREDIENTES (Excepto agua) ===
	var ingredients_title = Label.new()
	ingredients_title.text = "🌾 INGREDIENTES"
	ingredients_title.add_theme_font_size_override("font_size", 20)  # 16→20 más grande
	ingredients_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ingredients_title.add_theme_color_override("font_color", Color.GREEN)
	main_vbox.add_child(ingredients_title)

	# Grid para ingredientes (más pequeño y compacto)
	var ingredients_grid = GridContainer.new()
	ingredients_grid.columns = 2  # 2 columnas para que sea más compacto
	ingredients_grid.add_theme_constant_override("h_separation", 16)  # 10→16 más separación horizontal
	ingredients_grid.add_theme_constant_override("v_separation", 16)  # 10→16 más separación vertical

	# Crear botones de venta para ingredientes (excepto agua)
	for resource_id in GameConfig.RESOURCE_DATA.keys():
		if resource_id == "water":
			continue  # Excluir agua de la venta

		var resource_data = GameConfig.RESOURCE_DATA[resource_id]
		var sell_button = create_compact_sell_button(resource_id, resource_data, "resource")
		ingredients_grid.add_child(sell_button)

	main_vbox.add_child(ingredients_grid)

	# Separador entre ingredientes y productos
	var separator2 = HSeparator.new()
	separator2.custom_minimum_size = Vector2(0, 30)  # 20→30 más espacio
	main_vbox.add_child(separator2)

	# === PRODUCTOS ===
	var products_title = Label.new()
	products_title.text = "🍺 PRODUCTOS"
	products_title.add_theme_font_size_override("font_size", 20)  # 16→20 más grande
	products_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	products_title.add_theme_color_override("font_color", Color.ORANGE)
	main_vbox.add_child(products_title)

	# Grid para productos
	var products_grid = GridContainer.new()
	products_grid.columns = 2  # 2 columnas para que sea más compacto
	products_grid.add_theme_constant_override("h_separation", 16)  # 10→16 más separación horizontal
	products_grid.add_theme_constant_override("v_separation", 16)  # 10→16 más separación vertical

	# Crear botones de venta para productos
	for product_id in GameConfig.PRODUCT_DATA.keys():
		var product_data = GameConfig.PRODUCT_DATA[product_id]
		var sell_button = create_compact_sell_button(product_id, product_data, "product")
		products_grid.add_child(sell_button)

	main_vbox.add_child(products_grid)


func create_compact_sell_button(
	item_id: String, data: Dictionary, item_type: String
) -> VBoxContainer:
	"""T011: Crear panel mejorado de venta con offer toggle y price comparison"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)  # 5→8 más espaciado
	container.custom_minimum_size = Vector2(260, 180)  # 240x160→260x180 más espacio para offers

	# T011: Panel principal con styling profesional
	var main_panel = Panel.new()
	main_panel.custom_minimum_size = Vector2(260, 130)  # 240x110→260x130 más espacio

	# T011: Estilo del panel según tipo
	var panel_style = StyleBoxFlat.new()
	if item_type == "product":
		panel_style.bg_color = Color(0.2, 0.1, 0.3, 0.9)  # Púrpura para productos
		panel_style.border_color = Color.MAGENTA
	else:
		panel_style.bg_color = Color(0.1, 0.2, 0.1, 0.9)  # Verde para ingredientes
		panel_style.border_color = Color.GREEN

	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	main_panel.add_theme_stylebox_override("panel", panel_style)

	# VBox interno para información
	var panel_vbox = VBoxContainer.new()
	panel_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_vbox.add_theme_constant_override("margin_left", 10)  # 5→10 más margen
	panel_vbox.add_theme_constant_override("margin_right", 10)  # 5→10 más margen
	panel_vbox.add_theme_constant_override("margin_top", 8)  # 5→8 más margen
	panel_vbox.add_theme_constant_override("margin_bottom", 8)  # 5→8 más margen
	panel_vbox.add_theme_constant_override("separation", 5)  # 2→5 más separación entre elementos

	# Título del elemento
	var title_label = Label.new()
	title_label.text = "%s %s" % [data.emoji, data.name]
	title_label.add_theme_font_size_override("font_size", 18)  # 14→18 más legible
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color.GOLD)

	# T011: Stock info con visual feedback
	var stock_label = Label.new()
	stock_label.text = "[Stock: 0]"
	stock_label.add_theme_font_size_override("font_size", 14)
	stock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stock_label.name = "stock_label_" + item_id
	stock_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)

	# T011: Price comparison con offer toggle
	var price_label = Label.new()
	var base_price = data.get("sell_price", 1.0)
	price_label.text = "$%.2f base" % base_price
	price_label.add_theme_font_size_override("font_size", 16)  # 12→16 más legible
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.name = "price_label_" + item_id
	price_label.add_theme_color_override("font_color", Color.WHITE)

	# T011: Offer status indicator
	var offer_status_label = Label.new()
	offer_status_label.text = "🔴 OFERTA INACTIVA"
	offer_status_label.add_theme_font_size_override("font_size", 12)
	offer_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	offer_status_label.name = "offer_status_" + item_id
	offer_status_label.add_theme_color_override("font_color", Color.GRAY)

	panel_vbox.add_child(title_label)
	panel_vbox.add_child(stock_label)  # T011: Stock display añadido
	panel_vbox.add_child(price_label)  # T011: Price comparison
	panel_vbox.add_child(offer_status_label)  # T011: Offer status
	main_panel.add_child(panel_vbox)

	# T011: Contenedor de botones mejorado
	var buttons_hbox = HBoxContainer.new()
	buttons_hbox.add_theme_constant_override("separation", 10)  # 8→10 más espacio

	# T011: Botón principal de venta estilo IdleBuyButton
	var sell_button = Button.new()
	sell_button.text = "VENDER"
	sell_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_button.custom_minimum_size = Vector2(0, 45)  # 36→45 como T009/T010
	sell_button.add_theme_font_size_override("font_size", 18)  # 16→18 como T009/T010
	sell_button.name = "sell_button_" + item_id

	# T011: Estilo del botón de venta (azul para diferenciarlo)
	var sell_button_style = StyleBoxFlat.new()
	sell_button_style.bg_color = Color(0.1, 0.3, 0.6, 1.0)  # Azul
	sell_button_style.corner_radius_top_left = 6
	sell_button_style.corner_radius_top_right = 6
	sell_button_style.corner_radius_bottom_left = 6
	sell_button_style.corner_radius_bottom_right = 6
	sell_button.add_theme_stylebox_override("normal", sell_button_style)

	# T011: Botón multiplicador consistente
	var multiplier_button = Button.new()
	multiplier_button.text = "x1"
	multiplier_button.custom_minimum_size = Vector2(70, 45)  # 50x36→70x45 como T009/T010
	multiplier_button.add_theme_font_size_override("font_size", 16)  # 14→16 como T009/T010
	multiplier_button.name = "multiplier_button_" + item_id

	# T011: Estilo del botón multiplicador (cian para diferenciarlo)
	var mult_button_style = StyleBoxFlat.new()
	mult_button_style.bg_color = Color(0.1, 0.5, 0.5, 1.0)  # Cian
	mult_button_style.corner_radius_top_left = 6
	mult_button_style.corner_radius_top_right = 6
	mult_button_style.corner_radius_bottom_left = 6
	mult_button_style.corner_radius_bottom_right = 6
	multiplier_button.add_theme_stylebox_override("normal", mult_button_style)

	# T011: Botón de offer toggle (nuevo)
	var offer_button = Button.new()
	offer_button.text = "📢"  # Emoji de altavoz para ofertas
	offer_button.custom_minimum_size = Vector2(45, 45)  # Cuadrado
	offer_button.add_theme_font_size_override("font_size", 16)
	offer_button.name = "offer_button_" + item_id

	# T011: Estilo del botón de oferta (rojo/verde según estado)
	var offer_button_style = StyleBoxFlat.new()
	offer_button_style.bg_color = Color(0.5, 0.1, 0.1, 1.0)  # Rojo inicial (inactivo)
	offer_button_style.corner_radius_top_left = 6
	offer_button_style.corner_radius_top_right = 6
	offer_button_style.corner_radius_bottom_left = 6
	offer_button_style.corner_radius_bottom_right = 6
	offer_button.add_theme_stylebox_override("normal", offer_button_style)

	# Conectar señales
	sell_button.pressed.connect(_on_sell_button_pressed.bind(item_id, item_type))
	multiplier_button.pressed.connect(_on_multiplier_button_pressed.bind(item_id))
	offer_button.pressed.connect(_on_offer_button_pressed.bind(item_id))  # T011: Nueva señal

	buttons_hbox.add_child(sell_button)
	buttons_hbox.add_child(multiplier_button)
	buttons_hbox.add_child(offer_button)  # T011: Botón de oferta añadido

	container.add_child(main_panel)
	container.add_child(buttons_hbox)

	# T011: Guardar estado completo con nuevos elementos
	button_states[item_id] = {
		"multiplier": 1,
		"offer_active": false,  # T011: Estado de oferta
		"sell_button": sell_button,
		"multiplier_button": multiplier_button,
		"offer_button": offer_button,  # T011: Botón de oferta
		"stock_label": stock_label,  # T011: Stock label
		"price_label": price_label,  # T011: Price label
		"offer_status_label": offer_status_label,  # T011: Offer status
		"item_type": item_type,
		"base_price": data.get("sell_price", 1.0)  # T011: Precio base para cálculos
	}

	return container


func _on_sell_button_pressed(item_id: String, item_type: String):
	"""Manejar venta de elemento con multiplicador"""
	if not button_states.has(item_id):
		print("❌ Estado del botón no encontrado para: %s" % item_id)
		return

	var state = button_states[item_id]
	var multiplier = state.multiplier

	print("💰 Solicitando venta: %s (%s) x%d" % [item_id, item_type, multiplier])
	item_sell_requested.emit(item_type, item_id, multiplier)


func _on_multiplier_button_pressed(item_id: String):
	"""Cambiar multiplicador de venta de forma centralizada"""
	if update_in_progress:
		print("⚠️ Update en progreso, ignorando cambio de multiplicador")
		return

	if not button_states.has(item_id):
		print("❌ Estado del botón no encontrado para: %s" % item_id)
		return

	# Actualizar estado centralizado
	var state = button_states[item_id]
	var current_multiplier = state.multiplier
	var next_multiplier = _get_next_multiplier(current_multiplier)

	state.multiplier = next_multiplier
	state.multiplier_button.text = "x%d" % next_multiplier

	print("🔢 Multiplicador cambiado para %s: x%d" % [item_id, next_multiplier])

	# Emitir señal para notificar cambio
	sell_multiplier_changed.emit(item_id, next_multiplier)

	# Actualizar solo este elemento específico INMEDIATAMENTE
	_update_single_item_state(item_id)
	print("✅ Botón actualizado inmediatamente después del cambio de multiplicador")


# T011: Nuevo manejador para botón de oferta
func _on_offer_button_pressed(item_id: String):
	"""Toggle offer status para un item específico"""
	if update_in_progress:
		print("⚠️ Update en progreso, ignorando toggle de oferta")
		return

	if not button_states.has(item_id):
		print("❌ Estado del botón no encontrado para: %s" % item_id)
		return

	# Toggle del estado de oferta
	var state = button_states[item_id]
	state.offer_active = not state.offer_active

	print(
		"📢 Toggle de oferta para %s: %s" % [item_id, "ACTIVA" if state.offer_active else "INACTIVA"]
	)

	# Actualizar UI inmediatamente
	_update_offer_display(item_id)
	print("✅ Oferta actualizada inmediatamente")


# T011: Método para actualizar display de oferta
func _update_offer_display(item_id: String):
	"""Actualizar UI elements relacionados con ofertas"""
	if not button_states.has(item_id):
		return

	var state = button_states[item_id]
	var offer_active = state.offer_active
	var base_price = state.base_price

	# Actualizar botón de oferta
	if offer_active:
		var offer_style = StyleBoxFlat.new()
		offer_style.bg_color = Color(0.1, 0.5, 0.1, 1.0)  # Verde (activo)
		offer_style.corner_radius_top_left = 6
		offer_style.corner_radius_top_right = 6
		offer_style.corner_radius_bottom_left = 6
		offer_style.corner_radius_bottom_right = 6
		state.offer_button.add_theme_stylebox_override("normal", offer_style)
	else:
		var offer_style = StyleBoxFlat.new()
		offer_style.bg_color = Color(0.5, 0.1, 0.1, 1.0)  # Rojo (inactivo)
		offer_style.corner_radius_top_left = 6
		offer_style.corner_radius_top_right = 6
		offer_style.corner_radius_bottom_left = 6
		offer_style.corner_radius_bottom_right = 6
		state.offer_button.add_theme_stylebox_override("normal", offer_style)

	# Actualizar price label con comparación
	if offer_active:
		var offer_price = base_price * 1.5  # 50% bonus
		state.price_label.text = "$%.2f → $%.2f (+50%%)" % [base_price, offer_price]
		state.price_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		state.price_label.text = "$%.2f base" % base_price
		state.price_label.add_theme_color_override("font_color", Color.WHITE)

	# Actualizar offer status label
	if offer_active:
		state.offer_status_label.text = "🟢 OFERTA ACTIVA"
		state.offer_status_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		state.offer_status_label.text = "🔴 OFERTA INACTIVA"
		state.offer_status_label.add_theme_color_override("font_color", Color.GRAY)


func _get_next_multiplier(current: int) -> int:
	"""T011: Obtener siguiente multiplicador en secuencia x1→x3→x5→x10→x1 (consistente con T010)"""
	match current:
		1:
			return 3
		3:
			return 5
		5:
			return 10
		10:
			return 1
		_:
			return 1


# Método para compatibilidad con GameController
func set_sales_manager(manager: Node):
	"""Establecer referencia al SalesManager"""
	sales_manager_ref = manager
	print("🔗 SalesPanelBasic conectado con SalesManager")
	# Activar timer de actualización cuando se conecta el manager
	if update_timer:
		update_timer.start()
		print("▶️ Timer de actualización activado")


## ===== MÉTODOS PÚBLICOS PARA INTERFAZ EXTERNA =====


func refresh_all_items():
	"""Refrescar todos los elementos - método público para GameController"""
	if sales_manager_ref:
		var game_data = get_current_game_data()
		update_inventory_displays(game_data)


func refresh_single_item(item_id: String):
	"""Refrescar un elemento específico - método público"""
	if sales_manager_ref:
		_update_single_item_state(item_id)


func get_item_multiplier(item_id: String) -> int:
	"""Obtener multiplicador actual de un elemento"""
	if button_states.has(item_id):
		return button_states[item_id].multiplier
	return 1


func set_item_multiplier(item_id: String, multiplier: int):
	"""Establecer multiplicador de un elemento (para sincronización)"""
	if button_states.has(item_id):
		button_states[item_id].multiplier = multiplier
		button_states[item_id].multiplier_button.text = "x%d" % multiplier
		_update_single_item_state(item_id)


# Métodos para actualizar datos
func update_inventory_displays(game_data: Dictionary):
	"""T011: Actualizar displays de inventario y estadísticas"""
	if update_in_progress:
		return

	update_in_progress = true
	for item_id in button_states.keys():
		_update_single_item_state(item_id, game_data)

	# T011: Actualizar estadísticas de ventas automáticas
	_update_sales_stats(game_data)
	update_in_progress = false


# T011: Actualizar estadísticas de ventas automáticas
func _update_sales_stats(game_data: Dictionary):
	"""Actualizar indicadores de demanda y ventas automáticas"""
	var customers_label = main_vbox.find_child("customers_stats_label", true, false)
	var auto_sales_label = main_vbox.find_child("auto_sales_stats_label", true, false)

	if customers_label and auto_sales_label:
		# Simular datos de clientes interesados (esto se conectaría con CustomerManager)
		var active_customers = game_data.get("active_customers", 0)
		var max_customers = game_data.get("max_customers", 10)
		var interested_customers = min(active_customers, max_customers)

		customers_label.text = (
			"👥 Clientes: %d/%d interesados" % [interested_customers, max_customers]
		)

		# Color coding para clientes
		if interested_customers >= max_customers * 0.8:
			customers_label.add_theme_color_override("font_color", Color.GREEN)
		elif interested_customers >= max_customers * 0.5:
			customers_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			customers_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)

		# Calcular ventas automáticas estimadas (tokens/min)
		var auto_sales_rate = interested_customers * 2.5  # Cada cliente ~2.5 tokens/min
		auto_sales_label.text = "💰 Auto-ventas: %.1f tokens/min" % auto_sales_rate

		# Color coding para auto-ventas
		if auto_sales_rate > 15:
			auto_sales_label.add_theme_color_override("font_color", Color.GREEN)
		elif auto_sales_rate > 5:
			auto_sales_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			auto_sales_label.add_theme_color_override("font_color", Color.ORANGE)


func _update_single_item_state(item_id: String, game_data: Dictionary = {}):
	"""T011: Actualizar estado completo con stock display y offer status"""
	if not button_states.has(item_id):
		print("⚠️ Estado del botón no inicializado para: %s" % item_id)
		return

	# Obtener datos del juego si no se proporcionan
	if game_data.is_empty():
		game_data = get_current_game_data()

	var state = button_states[item_id]
	var item_type = state.item_type
	var multiplier = state.multiplier
	var offer_active = state.offer_active

	# Obtener cantidad disponible según el tipo
	var available = 0
	if item_type == "resource":
		var resources = game_data.get("resources", {})
		available = resources.get(item_id, 0)
	elif item_type == "product":
		var products = game_data.get("products", {})
		available = products.get(item_id, 0)

	# T011: Actualizar stock label con color coding
	state.stock_label.text = "[Stock: %d]" % available
	if available > 50:
		state.stock_label.add_theme_color_override("font_color", Color.GREEN)
	elif available > 10:
		state.stock_label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		state.stock_label.add_theme_color_override("font_color", Color.RED)

	# Calcular precio (base o con oferta)
	var base_price = state.base_price
	var unit_price = base_price * (1.5 if offer_active else 1.0)
	var total_price = unit_price * multiplier
	var can_sell = available >= multiplier

	# T011: Actualizar price label con comparación
	_update_offer_display(item_id)

	# El botón está habilitado solo si hay suficiente cantidad
	state.sell_button.disabled = not can_sell
	state.sell_button.modulate = Color.WHITE if can_sell else Color.GRAY

	if can_sell:
		if offer_active:
			state.sell_button.text = "VENDER x%d (OFERTA)" % multiplier
		else:
			state.sell_button.text = "VENDER x%d" % multiplier
	else:
		state.sell_button.text = "NO DISPONIBLE"


func get_item_sell_price(item_id: String, item_type: String) -> float:
	"""Obtener precio de venta de un elemento"""
	if item_type == "resource":
		var resource_data = GameConfig.RESOURCE_DATA.get(item_id, {})
		return resource_data.get("sell_price", 1.0)
	if item_type == "product":
		var product_data = GameConfig.PRODUCT_DATA.get(item_id, {})
		return product_data.get("sell_price", 5.0)

	return 1.0


func get_current_game_data() -> Dictionary:
	"""Obtener datos actuales del juego"""
	if sales_manager_ref and sales_manager_ref.has_method("get_game_data"):
		return sales_manager_ref.get_game_data()

	# Fallback usando singleton GameManager
	if GameManager and GameManager.has_method("get_game_data"):
		var game_data = GameManager.get_game_data()
		return {
			"money": game_data.money,
			"resources": game_data.resources.duplicate(),
			"products": game_data.products.duplicate()
		}

	return {"money": 0, "resources": {}, "products": {}}


## === GESTIÓN DE VISIBILIDAD ===


func _notification(what):
	"""Manejar notificaciones de visibilidad para optimizar rendimiento"""
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if update_timer:
			if visible and sales_manager_ref:
				if update_timer.is_stopped():
					update_timer.start()
					print("▶️ Timer reactivado - panel visible")
			else:
				if not update_timer.is_stopped():
					update_timer.stop()
					print("⏸️ Timer pausado - panel no visible")
