extends VBoxContainer
class_name OffersComponent
## OffersComponent - Componente especializado para gestionar ofertas de productos
## Integra con StockDisplayComponent y ProductionManager para ofertas automáticas

signal offer_toggled(station_id: String, enabled: bool)
signal offer_price_requested(station_id: String)

@onready var title_label: Label
@onready var description_label: Label
@onready var offers_container: VBoxContainer

var offer_interfaces: Dictionary = {} # station_id -> controls
var station_definitions: Array = []
var current_offers_data: Dictionary = {}

func _ready() -> void:
	print("🏪 OffersComponent inicializado")
	_setup_base_ui()

## Configuración inicial
func _setup_base_ui() -> void:
	# Título
	title_label = Label.new()
	title_label.text = "🏪 OFERTAS AUTOMÁTICAS"
	title_label.add_theme_font_size_override("font_size", 16)
	add_child(title_label)

	# Descripción
	description_label = Label.new()
	description_label.text = "Configura productos para venta automática a clientes"
	description_label.modulate = Color.GRAY
	add_child(description_label)

	# Separador
	var separator = HSeparator.new()
	add_child(separator)

	# Contenedor de ofertas
	offers_container = VBoxContainer.new()
	add_child(offers_container)

## Configurar ofertas con datos de estaciones
func setup_offers(stations: Array, offers_data: Dictionary, game_data: Dictionary) -> void:
	station_definitions = stations
	current_offers_data = offers_data
	print("🏪 Configurando ofertas para %d estaciones" % stations.size())

	_refresh_offer_interfaces(game_data)

## Actualizar ofertas con nuevos datos
func update_offers(offers_data: Dictionary, game_data: Dictionary) -> void:
	current_offers_data = offers_data
	_update_existing_interfaces(game_data)

## === INTERFAZ INTERNA ===

func _refresh_offer_interfaces(game_data: Dictionary) -> void:
	_clear_offer_interfaces()

	var stations_with_offers = 0

	for station_def in station_definitions:
		var station_id = station_def.id
		var owned = game_data.get("stations", {}).get(station_id, 0)

		# Solo mostrar estaciones que el jugador posee
		if owned <= 0:
			continue

		# Solo mostrar si puede producir productos (no ingredientes)
		if not _station_produces_products(station_def):
			continue

		_create_station_offer_interface(station_def, game_data)
		stations_with_offers += 1

	if stations_with_offers == 0:
		_show_no_stations_message()

func _create_station_offer_interface(station_def: Dictionary, game_data: Dictionary) -> void:
	var station_id = station_def.id
	var station_name = station_def.name

	print("🏪 Creando interfaz de ofertas para: %s" % station_name)

	# Contenedor principal de la estación
	var station_container = VBoxContainer.new()
	station_container.add_theme_constant_override("separation", 5)
	offers_container.add_child(station_container)

	# Header con información de la estación
	var header_container = HBoxContainer.new()
	station_container.add_child(header_container)

	# Nombre de la estación
	var station_label = Label.new()
	station_label.text = station_name
	station_label.add_theme_font_size_override("font_size", 14)
	station_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_container.add_child(station_label)

	# Stock actual de productos de esta estación
	var stock_label = Label.new()
	stock_label.text = _get_station_stock_summary(station_def, game_data)
	stock_label.modulate = Color.GRAY
	stock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header_container.add_child(stock_label)

	# Controles de oferta
	var controls_container = HBoxContainer.new()
	controls_container.add_theme_constant_override("separation", 10)
	station_container.add_child(controls_container)

	# Checkbox para habilitar/deshabilitar
	var offer_checkbox = CheckBox.new()
	offer_checkbox.text = "Venta automática"
	var offer_data = current_offers_data.get(station_id, {})
	offer_checkbox.button_pressed = offer_data.get("enabled", false)
	offer_checkbox.toggled.connect(func(enabled: bool): _on_offer_toggled(station_id, enabled))
	controls_container.add_child(offer_checkbox)

	# Botón de configuración de precio
	var price_button = Button.new()
	var multiplier = offer_data.get("price_multiplier", 1.0)
	price_button.text = _get_price_button_text(multiplier)
	price_button.custom_minimum_size = Vector2(120, 30)
	price_button.pressed.connect(func(): _on_price_requested(station_id))
	controls_container.add_child(price_button)

	# Indicador de estado
	var status_label = Label.new()
	status_label.text = _get_offer_status_text(offer_data, game_data, station_def)
	status_label.modulate = _get_offer_status_color(offer_data, game_data, station_def)
	controls_container.add_child(status_label)

	# Separador entre estaciones
	var separator = HSeparator.new()
	separator.modulate = Color.GRAY * 0.5
	station_container.add_child(separator)

	# Guardar referencias para actualizar después
	offer_interfaces[station_id] = {
		"container": station_container,
		"checkbox": offer_checkbox,
		"price_button": price_button,
		"stock_label": stock_label,
		"status_label": status_label,
		"station_def": station_def
	}

func _update_existing_interfaces(game_data: Dictionary) -> void:
	for station_id in offer_interfaces.keys():
		var interface = offer_interfaces[station_id]
		var offer_data = current_offers_data.get(station_id, {})
		var station_def = interface.station_def

		# Actualizar checkbox
		interface.checkbox.button_pressed = offer_data.get("enabled", false)

		# Actualizar botón de precio
		var multiplier = offer_data.get("price_multiplier", 1.0)
		interface.price_button.text = _get_price_button_text(multiplier)

		# Actualizar stock
		interface.stock_label.text = _get_station_stock_summary(station_def, game_data)

		# Actualizar estado
		interface.status_label.text = _get_offer_status_text(offer_data, game_data, station_def)
		interface.status_label.modulate = _get_offer_status_color(offer_data, game_data, station_def)

func _clear_offer_interfaces() -> void:
	for child in offers_container.get_children():
		child.queue_free()
	offer_interfaces.clear()

func _show_no_stations_message() -> void:
	var message_label = Label.new()
	message_label.text = "🏭 No hay estaciones de producción disponibles\n💡 Compra estaciones en la pestaña 'Producción'"
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.modulate = Color.GRAY
	offers_container.add_child(message_label)

## === UTILIDADES ===

func _station_produces_products(station_def: Dictionary) -> bool:
	"""Verifica si una estación produce productos (no solo ingredientes)"""
	var recipes = station_def.get("recipes", [])
	for recipe in recipes:
		var output = recipe.get("output", {})
		for output_type in output.keys():
			# Verificar si el output está en la lista de productos
			if StockManager and StockManager.game_data:
				if output_type in StockManager.game_data.products:
					return true
	return false

func _get_station_stock_summary(station_def: Dictionary, game_data: Dictionary) -> String:
	"""Obtiene resumen de stock para productos de esta estación"""
	var products = []
	var recipes = station_def.get("recipes", [])

	for recipe in recipes:
		var output = recipe.get("output", {})
		for product_name in output.keys():
			if product_name in game_data.get("products", {}):
				var quantity = game_data.products.get(product_name, 0)
				var emoji = GameUtils.get_item_emoji(product_name)
				products.append("%s%d" % [emoji, quantity])

	return products[0] if products.size() > 0 else "Sin productos"

func _get_price_button_text(multiplier: float) -> String:
	"""Convierte multiplicador a texto del botón"""
	if multiplier <= 0.8:
		return "💸 Precio Bajo (-20%)"
	if multiplier >= 1.2:
		return "💰 Precio Alto (+20%)"
	return "💵 Precio Normal"

func _get_offer_status_text(offer_data: Dictionary, game_data: Dictionary, station_def: Dictionary) -> String:
	"""Obtiene texto de estado de la oferta"""
	if not offer_data.get("enabled", false):
		return "⚫ Desactivado"

	# Verificar si hay stock disponible
	var has_stock = false
	var recipes = station_def.get("recipes", [])
	for recipe in recipes:
		var output = recipe.get("output", {})
		for product_name in output.keys():
			if game_data.get("products", {}).get(product_name, 0) > 0:
				has_stock = true
				break
		if has_stock:
			break

	if has_stock:
		return "🟢 Activo"
	return "🟡 Sin stock"

func _get_offer_status_color(offer_data: Dictionary, game_data: Dictionary, station_def: Dictionary) -> Color:
	"""Obtiene color de estado de la oferta"""
	if not offer_data.get("enabled", false):
		return Color.GRAY

	# Verificar stock igual que en _get_offer_status_text
	var has_stock = false
	var recipes = station_def.get("recipes", [])
	for recipe in recipes:
		var output = recipe.get("output", {})
		for product_name in output.keys():
			if game_data.get("products", {}).get(product_name, 0) > 0:
				has_stock = true
				break
		if has_stock:
			break

	return Color.GREEN if has_stock else Color.YELLOW

## === EVENTOS ===

func _on_offer_toggled(station_id: String, enabled: bool) -> void:
	print("🏪 Oferta toggled: %s = %s" % [station_id, enabled])
	offer_toggled.emit(station_id, enabled)

func _on_price_requested(station_id: String) -> void:
	print("💰 Precio solicitado para: %s" % station_id)
	offer_price_requested.emit(station_id)

## === API PÚBLICA ===

## Obtener estado actual de ofertas
func get_offers_summary() -> Dictionary:
	var summary = {
		"total_stations": offer_interfaces.size(),
		"active_offers": 0,
		"stations_with_stock": 0
	}

	for station_id in offer_interfaces.keys():
		var offer_data = current_offers_data.get(station_id, {})
		if offer_data.get("enabled", false):
			summary.active_offers += 1

	return summary

## Habilitar/deshabilitar todas las ofertas
func toggle_all_offers(enabled: bool) -> void:
	for station_id in offer_interfaces.keys():
		var interface = offer_interfaces[station_id]
		interface.checkbox.button_pressed = enabled
		_on_offer_toggled(station_id, enabled)
