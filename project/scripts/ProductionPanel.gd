extends ScrollContainer
## ProductionPanel - Panel de producción MODULAR Y PROFESIONAL
## Maneja estaciones de producción y crafteo de productos con UI coherente

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
	print("🍺 ProductionPanel inicializando con sistema modular...")
	call_deferred("_initialize_panel")

func _initialize_panel() -> void:
	"""Inicialización completa del panel con tema coherente"""
	_create_sections()
	_apply_consistent_theming()
	is_initialized = true
	print("✅ ProductionPanel inicializado con tema profesional")

func _apply_consistent_theming() -> void:
	"""Aplicar tema coherente a todo el panel"""
	# Aplicar responsive design
	UIComponentsFactory.make_responsive(self)

	# Animación de entrada para el contenido
	UIComponentsFactory.animate_fade_in(main_container, 0.4)

func _create_sections() -> void:
	"""Crear secciones del panel con componentes modulares"""
	_create_products_section()
	_add_section_separator()
	_create_stations_section()

func _add_section_separator() -> void:
	"""Añadir separador visual profesional"""
	var separator = UIComponentsFactory.create_section_separator()
	main_container.add_child(separator)

func _create_products_section() -> void:
	"""Crear sección de productos con componentes profesionales"""
	UIComponentsFactory.clear_container(products_container)

	var header = UIComponentsFactory.create_section_header(
		"🍺 PRODUCTOS FABRICADOS",
		"Inventario de productos terminados"
	)
	products_container.add_child(header)

	# Panel de contenido profesional
	var content_panel = UIComponentsFactory.create_content_panel(150)
	products_container.add_child(content_panel)

func _create_stations_section() -> void:
	"""Crear sección de estaciones con componentes profesionales"""
	UIComponentsFactory.clear_container(stations_container)

	var header = UIComponentsFactory.create_section_header(
		"⚙️ ESTACIONES DE PRODUCCIÓN",
		"Compra y gestiona estaciones de fabricación"
	)
	stations_container.add_child(header)

	# Lista scrolleable para estaciones
	var stations_scroll = UIComponentsFactory.create_scrollable_list()
	stations_container.add_child(stations_scroll)

func setup_products(game_data: Dictionary) -> void:
	"""Configura los productos del juego"""
	if not is_initialized:
		call_deferred("setup_products", game_data)
		return

	product_labels.clear()

	# Crear cards para productos
	for product_name in game_data["products"].keys():
		var product_card = UIComponentsFactory.create_content_panel(50)

		var label = Label.new()
		label.text = "%s %s: 0" % [GameUtils.get_item_emoji(product_name), product_name.capitalize()]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18)  # Aumentado para móvil

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
	var card = UIComponentsFactory.create_content_panel(140)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", UITheme.Spacing.SMALL)
	card.add_child(vbox)

	# Título
	var title_label = Label.new()
	title_label.text = station.get("name", "Estación")
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 18)  # Aumentado para móvil
	vbox.add_child(title_label)

	# Información
	var info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_size_override("font_size", 16)  # Aumentado para móvil
	info_label.text = _format_station_info(station, 0, false)
	vbox.add_child(info_label)

	# Botón de compra IdleBuyButton para estaciones
	var idle_button = preload("res://scripts/ui/IdleBuyButton.gd").new()

	# Configurar calculadora de costo para estaciones
	var cost_calculator = func(_station_id: String, quantity: int) -> float:
		# Las estaciones tienen precio fijo (no escalado como generadores)
		return station.base_cost * quantity

	idle_button.setup(station.id, station.name, station.base_cost, cost_calculator)
	idle_button.purchase_requested.connect(_on_station_purchase_idle_wrapper.bind(index))

	# Establecer affordability inicial (será actualizada después)
	idle_button.set_affordability(true)  # Se actualizará en update_station_interfaces
	vbox.add_child(idle_button)

	# Separador
	_add_separator_to_container(vbox, 4)

	# Botones de producción manual
	var production_label = Label.new()
	production_label.text = "🔨 Producción:"
	production_label.add_theme_font_size_override("font_size", 16)  # Aumentado para móvil
	vbox.add_child(production_label)

	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 8)  # Más espacio
	var quantities = [1, 5, 10, 25]

	for quantity in quantities:
		var button = UIComponentsFactory.create_primary_button("×%d" % quantity)
		button.set_custom_minimum_size(Vector2(70, 50))  # Más grande para móvil
		button.add_theme_font_size_override("font_size", 16)  # Fuente móvil
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
	var purchase_element = vbox.get_child(2)

	# Verificar si es IdleBuyButton o Button tradicional
	if purchase_element.get_script() and purchase_element.get_script().get_global_name() == "IdleBuyButton":
		var idle_button = purchase_element
		idle_button.update_cost_display()
		var current_cost = idle_button.get_current_cost()
		var can_afford = money >= current_cost
		var can_buy = unlocked and can_afford
		idle_button.set_affordability(can_buy)

		if not unlocked:
			idle_button.main_button.text = "🔒 BLOQUEADA\nRequisitos no cumplidos"
	else:
		# Compatibilidad con botones tradicionales
		var purchase_button = purchase_element as Button
		if purchase_button:
			var cost = station.get("base_cost", 100.0)
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

func _on_station_purchase_idle_wrapper(item_id: String, quantity: int, station_index: int) -> void:
	"""Wrapper para IdleBuyButton de estaciones"""
	print("🏭 Compra de estación solicitada: %d (%s) x%d" % [station_index, item_id, quantity])
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
