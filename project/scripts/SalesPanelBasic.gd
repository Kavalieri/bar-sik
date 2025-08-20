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

func _on_update_timer_timeout():
	"""Callback del timer de actualización - actualizar inventario automáticamente"""
	if not update_in_progress and sales_manager_ref:
		refresh_all_items()
		# print("🔄 Inventario actualizado automáticamente")  # Comentado para no spam

func setup_inventory_section():
	"""Configurar sección de inventario (ingredientes y productos)"""
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
	"""Crear botón compacto de venta para un elemento del inventario"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)  # 5→8 más espaciado
	container.custom_minimum_size = Vector2(240, 160)  # 200x120→240x160 más grande para fuentes

	# Panel principal
	var main_panel = Panel.new()
	main_panel.custom_minimum_size = Vector2(240, 110)  # 200x80→240x110 más grande

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

	# Info del elemento (cantidad disponible y precio)
	var info_label = Label.new()
	var price = data.get("sell_price", 1.0)
	info_label.text = "Disponible: 0 | $%.1f c/u" % price
	info_label.add_theme_font_size_override("font_size", 16)  # 12→16 más legible
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.name = "info_label_" + item_id

	panel_vbox.add_child(title_label)
	panel_vbox.add_child(info_label)
	main_panel.add_child(panel_vbox)

	# Contenedor de botones (horizontal y compacto)
	var buttons_hbox = HBoxContainer.new()
	buttons_hbox.add_theme_constant_override("separation", 8)  # 5→8 más espacio entre botones

	# Botón principal de venta
	var sell_button = Button.new()
	sell_button.text = "VENDER"
	sell_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sell_button.custom_minimum_size = Vector2(0, 36)  # 30→36 más alto para fuente grande
	sell_button.add_theme_font_size_override("font_size", 16)  # 12→16 mejor legibilidad
	sell_button.name = "sell_button_" + item_id

	# Botón multiplicador (más pequeño)
	var multiplier_button = Button.new()
	multiplier_button.text = "x1"
	multiplier_button.custom_minimum_size = Vector2(50, 36)  # 40x30→50x36 más grande
	multiplier_button.add_theme_font_size_override("font_size", 14)  # 11→14 botón más legible
	multiplier_button.name = "multiplier_button_" + item_id

	# Conectar señales
	sell_button.pressed.connect(_on_sell_button_pressed.bind(item_id, item_type))
	multiplier_button.pressed.connect(_on_multiplier_button_pressed.bind(item_id))

	buttons_hbox.add_child(sell_button)
	buttons_hbox.add_child(multiplier_button)

	container.add_child(main_panel)
	container.add_child(buttons_hbox)

	# Guardar referencia al multiplicador actual en el estado centralizado
	button_states[item_id] = {
		"multiplier": 1,
		"sell_button": sell_button,
		"multiplier_button": multiplier_button,
		"info_label": info_label,
		"item_type": item_type
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

func _get_next_multiplier(current: int) -> int:
	"""Obtener siguiente multiplicador en secuencia x1→x5→x10→x25→x1"""
	match current:
		1: return 5
		5: return 10
		10: return 25
		25: return 1
		_: return 1

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
	"""Actualizar displays de inventario usando estado centralizado"""
	if update_in_progress:
		return

	update_in_progress = true
	for item_id in button_states.keys():
		_update_single_item_state(item_id, game_data)
	update_in_progress = false

func _update_single_item_state(item_id: String, game_data: Dictionary = {}):
	"""Actualizar estado de un elemento específico usando datos centralizados"""
	if not button_states.has(item_id):
		print("⚠️ Estado del botón no inicializado para: %s" % item_id)
		return

	# Obtener datos del juego si no se proporcionan
	if game_data.is_empty():
		game_data = get_current_game_data()

	var state = button_states[item_id]
	var item_type = state.item_type
	var multiplier = state.multiplier

	# Obtener cantidad disponible según el tipo
	var available = 0
	if item_type == "resource":
		var resources = game_data.get("resources", {})
		available = resources.get(item_id, 0)
	elif item_type == "product":
		var products = game_data.get("products", {})
		available = products.get(item_id, 0)

	# Calcular precio total
	var unit_price = get_item_sell_price(item_id, item_type)
	var total_price = unit_price * multiplier
	var can_sell = available >= multiplier

	# Actualizar UI elements
	state.info_label.text = "Disponible: %d | $%.1f (x%d = $%.1f)" % [
		available, unit_price, multiplier, total_price
	]

	# El botón está habilitado solo si hay suficiente cantidad
	state.sell_button.disabled = not can_sell
	state.sell_button.modulate = Color.WHITE if can_sell else Color.GRAY

	if can_sell:
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
