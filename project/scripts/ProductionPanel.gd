extends ScrollContainer
## ProductionPanel - Panel de producción limpio y modular
## Maneja estaciones de producción y crafteo de productos

# Referencias a contenedores
@onready var main_container: VBoxContainer = $MainContainer
@onready var products_container: VBoxContainer = $MainContainer/ProductsSection/ProductContainer
@onready var stations_container: VBoxContainer = $MainContainer/StationsSection/StationContainer

# Estado del panel
var is_initialized: bool = false
var product_labels: Dictionary = {}
var station_interfaces: Array[Control] = []

# Señales
signal station_purchased(station_index: int)
signal manual_production_requested(station_index: int, quantity: int)
signal offer_toggled(station_index: int, enabled: bool)
signal offer_price_requested(station_index: int)

func _ready() -> void:
	print("🍺 ProductionPanel inicializando...")
	call_deferred("_initialize_panel")

func _initialize_panel() -> void:
	"""Inicialización completa del panel"""
	_create_sections()
	is_initialized = true
	print("✅ ProductionPanel inicializado correctamente")

func _create_sections() -> void:
	"""Crear secciones del panel"""
	_create_products_section()
	_create_stations_section()

func _create_products_section() -> void:
	"""Crear sección de productos"""
	_clear_container(products_container)
	var header = UIStyleManager.create_section_header("🍺 PRODUCTOS FABRICADOS")
	products_container.add_child(header)

func _create_stations_section() -> void:
	"""Crear sección de estaciones"""
	_clear_container(stations_container)
	var header = UIStyleManager.create_section_header(
		"⚙️ ESTACIONES DE PRODUCCIÓN",
		"Compra estaciones para fabricar productos"
	)
	stations_container.add_child(header)

func setup_products(game_data: Dictionary) -> void:
	"""Configura los productos del juego"""
	if not is_initialized:
		call_deferred("setup_products", game_data)
		return

	product_labels.clear()

	# Crear cards para productos
	for product_name in game_data["products"].keys():
		var product_card = UIStyleManager.create_styled_panel()
		product_card.set_custom_minimum_size(Vector2(0, 50))

		var label = Label.new()
		label.text = "%s: 0" % product_name.capitalize()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)

		product_card.add_child(label)
		products_container.add_child(product_card)
		product_labels[product_name] = label

func setup_stations(production_stations: Array[Dictionary]) -> void:
	"""Configura las estaciones de producción"""
	if not is_initialized:
		call_deferred("setup_stations", production_stations)
		return

	_clear_station_interfaces()

	# Crear interface para cada estación
	for i in range(production_stations.size()):
		var station = production_stations[i]
		var interface = _create_station_interface(station, i)
		stations_container.add_child(interface)
		station_interfaces.append(interface)

func _create_station_interface(station: Dictionary, index: int) -> Control:
	"""Crea una interface limpia para una estación"""
	var card = UIStyleManager.create_styled_panel()
	card.set_custom_minimum_size(Vector2(0, 140))

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	# Título
	var title_label = Label.new()
	title_label.text = station.get("name", "Estación")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(title_label)

	# Información
	var info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.text = _format_station_info(station, 0, false)
	vbox.add_child(info_label)

	# Botón de compra
	var purchase_button = UIStyleManager.create_styled_button("Comprar Estación\n$0")
	purchase_button.set_custom_minimum_size(Vector2(0, 35))
	purchase_button.pressed.connect(_on_station_purchase_requested.bind(index))
	vbox.add_child(purchase_button)

	# Separador
	_add_separator_to_container(vbox, 4)

	# Botones de producción manual
	var production_label = Label.new()
	production_label.text = "🔨 Producción:"
	production_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(production_label)

	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 4)
	var quantities = [1, 5, 10, 25]

	for quantity in quantities:
		var button = UIStyleManager.create_styled_button("×%d" % quantity)
		button.set_custom_minimum_size(Vector2(50, 25))
		button.add_theme_font_size_override("font_size", 11)
		button.pressed.connect(_on_manual_production_requested.bind(index, quantity))
		button_container.add_child(button)

	vbox.add_child(button_container)

	return card

func _format_station_info(station: Dictionary, owned: int, unlocked: bool) -> String:
	"""Formatea la información de estación"""
	var cost = station.get("cost", 100.0)
	var description = station.get("description", "")
	var status = "🔓 Disponible" if unlocked else "🔒 Bloqueada"

	if owned > 0:
		status = "✅ Poseída (×%d)" % owned

	return "%s • $%.0f\n%s" % [status, cost, description]

func update_product_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de productos"""
	if not is_initialized:
		return

	for product_name in product_labels.keys():
		if product_name in game_data["products"]:
			var amount = game_data["products"][product_name]
			var label = product_labels[product_name]
			if label:
				label.text = "%s: %s" % [
					product_name.capitalize(),
					GameUtils.format_large_number(amount)
				]

func update_station_interfaces(production_stations: Array[Dictionary], game_data: Dictionary) -> void:
	"""Actualiza las interfaces de estaciones"""
	if not is_initialized:
		return

	var stations_owned = game_data.get("stations", {})
	var money = game_data.get("money", 0.0)

	for i in range(min(station_interfaces.size(), production_stations.size())):
		var interface = station_interfaces[i]
		var station = production_stations[i]
		var station_id = station.get("id", "")
		var owned_count = stations_owned.get(station_id, 0)
		var is_unlocked = station.get("unlocked", true)

		_update_station_interface(interface, station, owned_count, is_unlocked, money)

func _update_station_interface(interface: Control, station: Dictionary, owned: int, unlocked: bool, money: float) -> void:
	"""Actualiza una interface específica de estación"""
	var vbox = interface.get_child(0) as VBoxContainer
	if not vbox or vbox.get_child_count() < 3:
		return

	# Actualizar información (segundo elemento)
	var info_label = vbox.get_child(1) as Label
	if info_label:
		info_label.text = _format_station_info(station, owned, unlocked)

	# Actualizar botón de compra (tercer elemento)
	var purchase_button = vbox.get_child(2) as Button
	if purchase_button:
		var cost = station.get("cost", 100.0)
		var can_afford = money >= cost
		var can_buy = unlocked and can_afford

		purchase_button.text = "Comprar Estación\n$%s" % GameUtils.format_large_number(cost)
		purchase_button.disabled = not can_buy
		purchase_button.modulate = Color.WHITE if can_buy else Color.GRAY

		if not unlocked:
			purchase_button.text = "🔒 BLOQUEADA\nRequisitos no cumplidos"

# Métodos de eventos
func _on_station_purchase_requested(station_index: int) -> void:
	"""Maneja la solicitud de compra de estación"""
	station_purchased.emit(station_index)

func _on_manual_production_requested(station_index: int, quantity: int) -> void:
	"""Maneja la solicitud de producción manual"""
	manual_production_requested.emit(station_index, quantity)

# Funciones de utilidad
func _clear_container(container: Container) -> void:
	"""Limpia un contenedor de forma segura"""
	if not container:
		return
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _clear_station_interfaces() -> void:
	"""Limpia las interfaces de estaciones"""
	for interface in station_interfaces:
		if interface:
			interface.queue_free()
	station_interfaces.clear()

func _add_separator_to_container(container: Container, height: int = 16) -> void:
	"""Agrega un separador a un contenedor"""
	var separator = VSeparator.new()
	separator.set_custom_minimum_size(Vector2(0, height))
	separator.modulate = Color.TRANSPARENT
	container.add_child(separator)
