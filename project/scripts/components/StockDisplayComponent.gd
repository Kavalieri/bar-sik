extends VBoxContainer
class_name StockDisplayComponent
## StockDisplayComponent - Componente reutilizable para mostrar stock con diseño profesional
## Compatible con diferentes modos y estilos visuales para idle games

signal item_selected(item_type: String, item_name: String, quantity: int)
signal action_requested(action: String, item_type: String, item_name: String, quantity: int)

@export var display_mode: DisplayMode = DisplayMode.READ_ONLY
@export var show_actions: bool = true
@export var show_prices: bool = true
@export var filter_items: Array[String] = [] # Filtrar por tipos: ["product", "ingredient"]
@export var compact_mode: bool = false # Modo compacto para espacios reducidos
@export var theme_style: String = "default" # Estilo visual

enum DisplayMode {
	READ_ONLY,        # Solo mostrar información
	SELECTABLE,       # Permitir seleccionar items
	INTERACTIVE       # Permitir acciones (vender, usar, etc.)
}

var stock_interfaces: Dictionary = {} # item_key -> controls
var current_data: Dictionary = {}

# Colores y estilos para presentación profesional
var style_colors = {
	"primary": Color(0.2, 0.6, 1.0),      # Azul primario
	"secondary": Color(0.7, 0.7, 0.7),    # Gris secundario
	"success": Color(0.2, 0.8, 0.2),      # Verde éxito
	"warning": Color(1.0, 0.8, 0.0),      # Amarillo advertencia
	"background": Color(0.1, 0.1, 0.1, 0.8), # Fondo semi-transparente
	"card": Color(0.15, 0.15, 0.15, 0.9)   # Fondo de tarjetas
}

func _ready() -> void:
	print("📦 StockDisplayComponent inicializado (modo: %s)" % DisplayMode.keys()[display_mode])
	_setup_visual_style()

func _setup_visual_style() -> void:
	"""Configura el estilo visual del componente"""
	# Configurar el contenedor principal
	add_theme_constant_override("separation", 8)

	# Panel de fondo semi-transparente para mejor legibilidad
	var bg_panel = Panel.new()
	bg_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg_panel)  # Agregar primero como hijo
	move_child(bg_panel, 0)  # Luego moverlo al fondo

## Configurar el componente
func setup(mode: DisplayMode = DisplayMode.READ_ONLY, show_actions_enabled: bool = true) -> void:
	display_mode = mode
	show_actions = show_actions_enabled
	print("📦 StockDisplayComponent configurado - Modo: %s, Acciones: %s" % [DisplayMode.keys()[mode], show_actions])

## Actualizar con datos de stock
func update_display(stock_data: Dictionary) -> void:
	current_data = stock_data
	_refresh_interfaces()

## Actualizar usando StockManager directamente
func update_from_stock_manager() -> void:
	if not StockManager:
		print("❌ StockManager no disponible")
		return

	var stock_data = StockManager.get_sellable_stock()
	update_display(stock_data)

## === INTERFAZ INTERNA ===

func _refresh_interfaces() -> void:
	# Limpiar interfaces existentes
	_clear_interfaces()

	if current_data.is_empty():
		_show_empty_message()
		return

	# Crear interfaces por categoría
	if current_data.has("products") and (filter_items.is_empty() or "product" in filter_items):
		_create_category_section("🍺 PRODUCTOS", current_data.products, "product")

	if current_data.has("ingredients") and (filter_items.is_empty() or "ingredient" in filter_items):
		_create_category_section("🌾 INGREDIENTES", current_data.ingredients, "ingredient")

func _create_category_section(title: String, items: Dictionary, item_type: String) -> void:
	if items.is_empty():
		return

	# Separador antes de nueva sección
	if get_child_count() > 0:
		var separator = HSeparator.new()
		separator.add_theme_constant_override("separation", 16)
		add_child(separator)

	# Título de la categoría con estilo profesional
	var title_container = HBoxContainer.new()
	add_child(title_container)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", style_colors.primary)
	title_container.add_child(title_label)

	# Badge con contador de items
	var count_badge = _create_count_badge(items.size())
	title_container.add_child(count_badge)

	# Espacio entre título y items
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	add_child(spacer)

	# Crear interfaz para cada item
	for item_name in items.keys():
		var item_data = items[item_name]
		_create_item_interface(item_name, item_type, item_data)

func _create_count_badge(count: int) -> Panel:
	"""Crea un badge con el contador de items"""
	var badge = Panel.new()
	badge.custom_minimum_size = Vector2(30, 20)

	# Estilo del badge
	var style = StyleBoxFlat.new()
	style.bg_color = style_colors.primary
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	badge.add_theme_stylebox_override("panel", style)

	# Número en el badge
	var count_label = Label.new()
	count_label.text = str(count)
	count_label.add_theme_font_size_override("font_size", 11)
	count_label.add_theme_color_override("font_color", Color.WHITE)
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	count_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	badge.add_child(count_label)

	return badge

func _create_item_interface(item_name: String, item_type: String, item_data: Dictionary) -> void:
	var quantity = item_data.get("quantity", 0)
	var price = item_data.get("price", 0.0)
	var emoji = item_data.get("emoji", "📦")

	# Crear tarjeta profesional para el item
	var card_panel = _create_item_card()
	add_child(card_panel)

	# Contenedor principal del item con padding
	var item_container = HBoxContainer.new()
	item_container.add_theme_constant_override("separation", 12)
	card_panel.add_child(item_container)

	# Sección izquierda: Icono e información
	var left_section = HBoxContainer.new()
	left_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_section.add_theme_constant_override("separation", 8)
	item_container.add_child(left_section)

	# Icono del item más grande y estilizado
	var icon_label = Label.new()
	icon_label.text = emoji
	icon_label.add_theme_font_size_override("font_size", 20)
	icon_label.custom_minimum_size = Vector2(32, 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_section.add_child(icon_label)

	# Información del item con mejor tipografía
	var info_section = VBoxContainer.new()
	info_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_section.add_child(info_section)

	# Nombre del item
	var name_label = Label.new()
	name_label.text = item_name.capitalize()
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", style_colors.primary)
	info_section.add_child(name_label)

	# Cantidad y precio en línea separada
	var details_text = "Cantidad: %d" % quantity
	if show_prices and price > 0:
		details_text += " • $%.2f c/u" % price

	var details_label = Label.new()
	details_label.text = details_text
	details_label.add_theme_font_size_override("font_size", 11)
	details_label.add_theme_color_override("font_color", style_colors.secondary)
	info_section.add_child(details_label)

	# Sección derecha: Controles de acción
	if show_actions:
		var actions_section = HBoxContainer.new()
		actions_section.add_theme_constant_override("separation", 4)
		item_container.add_child(actions_section)

		# Agregar controles según el modo
		match display_mode:
			DisplayMode.SELECTABLE:
				_add_selection_controls(actions_section, item_name, item_type, quantity)
			DisplayMode.INTERACTIVE:
				_add_action_controls(actions_section, item_name, item_type, quantity)

	# Guardar referencia para futuras actualizaciones
	var item_key = "%s_%s" % [item_type, item_name]
	stock_interfaces[item_key] = {
		"container": card_panel,
		"name_label": name_label,
		"details_label": details_label,
		"quantity": quantity
	}

func _create_item_card() -> Panel:
	"""Crea una tarjeta estilizada para un item"""
	var card = Panel.new()
	card.custom_minimum_size = Vector2(300, 60)

	# Estilo de tarjeta con bordes redondeados y sombra
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = style_colors.card
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = style_colors.primary.darkened(0.3)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.content_margin_left = 12
	style_box.content_margin_right = 12
	style_box.content_margin_top = 8
	style_box.content_margin_bottom = 8

	card.add_theme_stylebox_override("panel", style_box)

	return card

func _add_selection_controls(container: HBoxContainer, item_name: String, item_type: String, quantity: int) -> void:
	var select_button = _create_styled_button("✓ Seleccionar", style_colors.primary)
	select_button.custom_minimum_size = Vector2(100, 32)
	select_button.pressed.connect(func(): _on_item_selected(item_type, item_name, quantity))
	container.add_child(select_button)

func _add_action_controls(container: HBoxContainer, item_name: String, item_type: String, quantity: int) -> void:
	if not show_actions:
		return

	# Botones de acción mejorados
	var increments = [1, 5, 10, "MAX"]
	for increment in increments:
		var button: Button
		var action_quantity: int
		var button_color = style_colors.secondary

		if str(increment) == "MAX":
			action_quantity = quantity
			button = _create_styled_button("Todo (%d)" % quantity, style_colors.success)
		else:
			action_quantity = increment as int
			button = _create_styled_button("x%d" % action_quantity, button_color)

		# Deshabilitar si no hay suficiente cantidad
		if action_quantity > quantity or quantity <= 0:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5)

		button.custom_minimum_size = Vector2(50, 32)
		button.pressed.connect(func(): _on_action_requested("sell", item_type, item_name, action_quantity))
		container.add_child(button)

func _create_styled_button(text: String, color: Color) -> Button:
	"""Crea un botón con estilo profesional"""
	var button = Button.new()
	button.text = text

	# Estilo del botón
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color
	style_normal.corner_radius_top_left = 6
	style_normal.corner_radius_top_right = 6
	style_normal.corner_radius_bottom_left = 6
	style_normal.corner_radius_bottom_right = 6
	style_normal.content_margin_left = 8
	style_normal.content_margin_right = 8
	style_normal.content_margin_top = 4
	style_normal.content_margin_bottom = 4

	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = color.lightened(0.2)
	style_hover.corner_radius_top_left = 6
	style_hover.corner_radius_top_right = 6
	style_hover.corner_radius_bottom_left = 6
	style_hover.corner_radius_bottom_right = 6
	style_hover.content_margin_left = 8
	style_hover.content_margin_right = 8
	style_hover.content_margin_top = 4
	style_hover.content_margin_bottom = 4

	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = color.darkened(0.2)
	style_pressed.corner_radius_top_left = 6
	style_pressed.corner_radius_top_right = 6
	style_pressed.corner_radius_bottom_left = 6
	style_pressed.corner_radius_bottom_right = 6
	style_pressed.content_margin_left = 8
	style_pressed.content_margin_right = 8
	style_pressed.content_margin_top = 4
	style_pressed.content_margin_bottom = 4

	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_color_override("font_color", Color.WHITE)

	return button

func _show_empty_message() -> void:
	"""Muestra un mensaje elegante cuando no hay items"""
	# Panel contenedor para el mensaje
	var message_panel = Panel.new()
	message_panel.custom_minimum_size = Vector2(300, 120)
	add_child(message_panel)

	# Estilo del panel
	var style = StyleBoxFlat.new()
	style.bg_color = style_colors.background
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = style_colors.secondary
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	message_panel.add_theme_stylebox_override("panel", style)

	# Contenedor para centrar el contenido
	var content_container = VBoxContainer.new()
	content_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_container.add_theme_constant_override("separation", 8)
	message_panel.add_child(content_container)

	# Icono
	var icon_label = Label.new()
	icon_label.text = "📦"
	icon_label.add_theme_font_size_override("font_size", 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_container.add_child(icon_label)

	# Mensaje principal
	var message_label = Label.new()
	message_label.text = "No hay items disponibles"
	message_label.add_theme_font_size_override("font_size", 14)
	message_label.add_theme_color_override("font_color", style_colors.secondary)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_container.add_child(message_label)

	# Mensaje secundario según el filtro
	var hint_text = "Compra generadores o produce items para verlos aquí"
	if not filter_items.is_empty():
		if "product" in filter_items:
			hint_text = "Produce items en la pestaña 'Producción'"
		if "ingredient" in filter_items:
			hint_text = "Compra generadores en la pestaña 'Generado'"

	var hint_label = Label.new()
	hint_label.text = hint_text
	hint_label.add_theme_font_size_override("font_size", 11)
	hint_label.add_theme_color_override("font_color", style_colors.secondary.darkened(0.3))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_container.add_child(hint_label)

func _clear_interfaces() -> void:
	for child in get_children():
		child.queue_free()
	stock_interfaces.clear()

## === EVENTOS ===

func _on_item_selected(item_type: String, item_name: String, quantity: int) -> void:
	print("📦 Item seleccionado: %s %s (%d)" % [item_type, item_name, quantity])
	item_selected.emit(item_type, item_name, quantity)

func _on_action_requested(action: String, item_type: String, item_name: String, quantity: int) -> void:
	print("📦 Acción solicitada: %s - %d %s (%s)" % [action, quantity, item_name, item_type])
	action_requested.emit(action, item_type, item_name, quantity)

## === API PÚBLICA ===

## Obtener item seleccionado actual
func get_selected_item() -> Dictionary:
	# Implementar lógica de selección si es necesario
	return {}

## Filtrar por tipo de item
func set_filter(types: Array[String]) -> void:
	filter_items = types
	_refresh_interfaces()

## Actualizar un item específico
func update_item(item_type: String, item_name: String, new_quantity: int) -> void:
	var item_key = "%s:%s" % [item_type, item_name]
	if item_key in stock_interfaces:
		var interface_data = stock_interfaces[item_key]
		interface_data.quantity = new_quantity

		# Actualizar el label
		var item_data = current_data.get(item_type + "s", {}).get(item_name, {})
		var emoji = item_data.get("emoji", "📦")
		var price = item_data.get("price", 0.0)

		var info_text = "%s %s: %d" % [emoji, item_name.capitalize(), new_quantity]
		if show_prices:
			info_text += " ($%.2f c/u)" % price

		interface_data.label.text = info_text
