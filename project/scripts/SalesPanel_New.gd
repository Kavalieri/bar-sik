extends ScrollContainer
## SalesPanel - Panel de ventas limpio y modular
## Gestiona la venta de productos e ingredientes

# Referencias a contenedores
@onready var main_container: VBoxContainer = $MainContainer
@onready var products_container: VBoxContainer = $MainContainer/SalesSection/ProductsContainer
@onready var ingredients_container: VBoxContainer = $MainContainer/SalesSection/IngredientsContainer
@onready var stats_container: VBoxContainer = $MainContainer/StatisticsSection/StatsContainer

# Estado del panel
var is_initialized: bool = false
var product_buttons: Array[Control] = []
var ingredient_buttons: Array[Control] = []
var stats_labels: Array[Label] = []

# Señales
signal item_sell_requested(item_type: String, item_name: String, quantity: int)

func _ready() -> void:
	print("💰 SalesPanel inicializando...")
	call_deferred("_initialize_panel")

func _initialize_panel() -> void:
	"""Inicialización completa del panel"""
	_create_sections()
	is_initialized = true
	print("✅ SalesPanel inicializado correctamente")

func _create_sections() -> void:
	"""Crear secciones del panel"""
	_create_products_section()
	_create_ingredients_section()
	_create_statistics_section()

func _create_products_section() -> void:
	"""Crear sección de productos"""
	_clear_container(products_container)
	var header = UIStyleManager.create_section_header(
		"💰 VENTAS DE PRODUCTOS",
		"Vende productos fabricados por dinero"
	)
	products_container.add_child(header)

func _create_ingredients_section() -> void:
	"""Crear sección de ingredientes"""
	_clear_container(ingredients_container)
	var header = UIStyleManager.create_section_header(
		"🌾 VENTAS DE INGREDIENTES",
		"Vende ingredientes sobrantes"
	)
	ingredients_container.add_child(header)

func _create_statistics_section() -> void:
	"""Crear sección de estadísticas"""
	_clear_container(stats_container)
	var header = UIStyleManager.create_section_header("📊 ESTADÍSTICAS DE VENTAS")
	stats_container.add_child(header)

	# Crear panel para estadísticas
	var stats_panel = UIStyleManager.create_styled_panel()
	stats_panel.set_custom_minimum_size(Vector2(0, 100))
	stats_container.add_child(stats_panel)

	var stats_vbox = VBoxContainer.new()
	stats_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stats_panel.add_child(stats_vbox)

	# Crear labels de estadísticas
	var stat_names = [
		"💰 Dinero total ganado: $0.00",
		"📦 Productos vendidos: 0",
		"🌾 Ingredientes vendidos: 0",
		"👤 Clientes atendidos: 0"
	]

	for stat_name in stat_names:
		var label = Label.new()
		label.text = stat_name
		label.add_theme_font_size_override("font_size", 12)
		stats_vbox.add_child(label)
		stats_labels.append(label)

func setup_sell_interfaces(game_data: Dictionary) -> void:
	"""Configura las interfaces de venta"""
	if not is_initialized:
		call_deferred("setup_sell_interfaces", game_data)
		return

	_setup_product_interfaces(game_data.get("products", {}))
	_setup_ingredient_interfaces(game_data.get("resources", {}))

func _setup_product_interfaces(products: Dictionary) -> void:
	"""Configura interfaces de venta de productos"""
	_clear_product_buttons()

	for product_name in products.keys():
		var amount = products[product_name]
		if amount > 0:  # Solo mostrar productos disponibles
			var interface = _create_sell_interface("product", product_name, amount)
			products_container.add_child(interface)
			product_buttons.append(interface)

func _setup_ingredient_interfaces(ingredients: Dictionary) -> void:
	"""Configura interfaces de venta de ingredientes"""
	_clear_ingredient_buttons()

	for ingredient_name in ingredients.keys():
		var amount = ingredients[ingredient_name]
		if amount > 0:  # Solo mostrar ingredientes disponibles
			var interface = _create_sell_interface("ingredient", ingredient_name, amount)
			ingredients_container.add_child(interface)
			ingredient_buttons.append(interface)

func _create_sell_interface(item_type: String, item_name: String, amount: int) -> Control:
	"""Crea una interface de venta para un item"""
	var card = UIStyleManager.create_styled_panel()
	card.set_custom_minimum_size(Vector2(0, 80))

	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)

	# Información del item
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_label = Label.new()
	name_label.text = "%s %s" % [GameUtils.get_item_emoji(item_name), item_name.capitalize()]
	name_label.add_theme_font_size_override("font_size", 14)
	info_vbox.add_child(name_label)

	var amount_label = Label.new()
	amount_label.text = "Disponible: %s" % GameUtils.format_large_number(amount)
	amount_label.add_theme_font_size_override("font_size", 12)
	amount_label.modulate = Color.GRAY
	info_vbox.add_child(amount_label)

	var price_label = Label.new()
	var unit_price = _get_sell_price(item_type, item_name)
	price_label.text = "Precio: $%.2f cada uno" % unit_price
	price_label.add_theme_font_size_override("font_size", 12)
	price_label.modulate = Color.GREEN
	info_vbox.add_child(price_label)

	# Botones de venta
	var button_vbox = VBoxContainer.new()
	button_vbox.add_theme_constant_override("separation", 4)
	hbox.add_child(button_vbox)

	var quantities = [1, 5, 10, "Todo"]
	for qty in quantities:
		var button = UIStyleManager.create_styled_button("")
		button.set_custom_minimum_size(Vector2(60, 18))
		button.add_theme_font_size_override("font_size", 10)

		var sell_amount = amount if qty == "Todo" else min(qty as int, amount)
		var total_price = unit_price * sell_amount

		button.text = "%s\n$%s" % [str(qty), GameUtils.format_large_number(total_price)]
		button.disabled = sell_amount <= 0
		button.pressed.connect(_on_sell_requested.bind(item_type, item_name, sell_amount))

		button_vbox.add_child(button)

	return card

func _get_sell_price(item_type: String, item_name: String) -> float:
	"""Obtiene el precio de venta de un item"""
	# Precios base por tipo
	var base_prices = {
		"ingredient": {
			"water": 0.1,
			"barley": 0.5,
			"hops": 1.0,
			"yeast": 2.0
		},
		"product": {
			"basic_beer": 3.0,
			"premium_beer": 5.0,
			"cocktail": 7.0
		}
	}

	return base_prices.get(item_type, {}).get(item_name, 1.0)

func update_sell_interfaces(game_data: Dictionary) -> void:
	"""Actualiza las interfaces de venta"""
	if not is_initialized:
		return

	setup_sell_interfaces(game_data)

func update_statistics(game_data: Dictionary) -> void:
	"""Actualiza las estadísticas"""
	if not is_initialized:
		return

	var stats = game_data.get("statistics", {})
	if stats_labels.size() >= 4:
		stats_labels[0].text = "💰 Dinero total ganado: $%s" % GameUtils.format_large_number(stats.get("total_money_earned", 0))
		stats_labels[1].text = "📦 Productos vendidos: %s" % GameUtils.format_large_number(stats.get("products_sold", 0))
		stats_labels[2].text = "🌾 Ingredientes vendidos: %s" % GameUtils.format_large_number(stats.get("ingredients_sold", 0))
		stats_labels[3].text = "👤 Clientes atendidos: %s" % GameUtils.format_large_number(stats.get("customers_served", 0))

# Métodos de eventos
func _on_sell_requested(item_type: String, item_name: String, amount: int) -> void:
	"""Maneja la solicitud de venta"""
	item_sell_requested.emit(item_type, item_name, amount)

# Funciones de utilidad
func _clear_container(container: Container) -> void:
	"""Limpia un contenedor de forma segura"""
	if not container:
		return
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _clear_product_buttons() -> void:
	"""Limpia los botones de productos"""
	for button in product_buttons:
		if button:
			button.queue_free()
	product_buttons.clear()

func _clear_ingredient_buttons() -> void:
	"""Limpia los botones de ingredientes"""
	for button in ingredient_buttons:
		if button:
			button.queue_free()
	ingredient_buttons.clear()
