extends ScrollContainer
## SalesPanel - Panel de ventas MODULAR Y PROFESIONAL
## Gestiona la venta de productos e ingredientes con UI coherente

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
	print("💰 SalesPanel inicializando con sistema modular...")
	call_deferred("_initialize_panel")

func _initialize_panel() -> void:
	"""Inicialización completa del panel con tema coherente"""
	_create_sections()
	_apply_consistent_theming()
	is_initialized = true
	print("✅ SalesPanel inicializado con tema profesional")

func _apply_consistent_theming() -> void:
	"""Aplicar tema coherente a todo el panel"""
	# Aplicar responsive design
	UIComponentsFactory.make_responsive(self)

	# Animación de entrada para el contenido
	UIComponentsFactory.animate_fade_in(main_container, 0.5)

func _create_sections() -> void:
	"""Crear secciones del panel con componentes modulares"""
	_create_products_section()
	_add_section_separator()
	_create_ingredients_section()
	_add_section_separator()
	_create_statistics_section()

func _create_products_section() -> void:
	"""Crear sección de productos con componentes profesionales"""
	UIComponentsFactory.clear_container(products_container)

	var header = UIComponentsFactory.create_section_header(
		"💰 VENTAS DE PRODUCTOS",
		"Vende productos fabricados por dinero"
	)
	products_container.add_child(header)

	# Panel de contenido profesional
	var content_panel = UIComponentsFactory.create_content_panel(120)
	products_container.add_child(content_panel)

	# Lista scrolleable para productos
	var products_scroll = UIComponentsFactory.create_scrollable_list()
	content_panel.add_child(products_scroll)

func _add_section_separator() -> void:
	"""Añadir separador visual profesional"""
	var separator = UIComponentsFactory.create_section_separator()
	main_container.add_child(separator)

func _create_ingredients_section() -> void:
	"""Crear sección de ingredientes con componentes profesionales"""
	UIComponentsFactory.clear_container(ingredients_container)

	var header = UIComponentsFactory.create_section_header(
		"🌾 VENTAS DE INGREDIENTES",
		"Vende ingredientes sobrantes"
	)
	ingredients_container.add_child(header)

	# Panel de contenido profesional
	var content_panel = UIComponentsFactory.create_content_panel(120)
	ingredients_container.add_child(content_panel)

func _create_statistics_section() -> void:
	"""Crear sección de estadísticas con tarjetas profesionales"""
	UIComponentsFactory.clear_container(stats_container)

	var header = UIComponentsFactory.create_section_header(
		"📊 ESTADÍSTICAS DE VENTAS",
		"Resumen de rendimiento"
	)
	stats_container.add_child(header)

	# Crear tarjetas de estadísticas
	var stats_grid = GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", UITheme.Spacing.MEDIUM)
	stats_grid.add_theme_constant_override("v_separation", UITheme.Spacing.MEDIUM)
	stats_container.add_child(stats_grid)

	# Tarjetas individuales
	var money_card = UIComponentsFactory.create_stats_card(
		"Dinero Total", "$0", "💰"
	)
	var products_card = UIComponentsFactory.create_stats_card(
		"Productos Vendidos", "0", "📦"
	)
	var ingredients_card = UIComponentsFactory.create_stats_card(
		"Ingredientes Vendidos", "0", "🌾"
	)
	var customers_card = UIComponentsFactory.create_stats_card(
		"Clientes Atendidos", "0", "👤"
	)

	stats_grid.add_child(money_card)
	stats_grid.add_child(products_card)
	stats_grid.add_child(ingredients_card)
	stats_grid.add_child(customers_card)

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
	var card = UIComponentsFactory.create_content_panel(80)

	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", UITheme.Spacing.SMALL)
	card.add_child(hbox)

	# Información del item
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var name_label = Label.new()
	name_label.text = "%s %s" % [GameUtils.get_item_emoji(item_name), item_name.capitalize()]
	name_label.add_theme_font_size_override("font_size", 18)  # Aumentado para móvil
	info_vbox.add_child(name_label)

	var amount_label = Label.new()
	amount_label.text = "📦 %s" % GameUtils.format_large_number(amount)  # Icono + texto más corto
	amount_label.add_theme_font_size_override("font_size", 16)  # Aumentado para móvil
	amount_label.modulate = Color.GRAY
	info_vbox.add_child(amount_label)

	var price_label = Label.new()
	var unit_price = _get_sell_price(item_type, item_name)
	price_label.text = "💰 $%.2f c/u" % unit_price  # Icono + texto más corto
	price_label.add_theme_font_size_override("font_size", 16)  # Aumentado para móvil
	price_label.modulate = Color.GREEN
	info_vbox.add_child(price_label)

	# Botones de venta (HORIZONTAL)
	var button_hbox = HBoxContainer.new()
	button_hbox.add_theme_constant_override("separation", 4)
	hbox.add_child(button_hbox)

	var quantities = [1, 5, 10, "Todo"]
	for qty in quantities:
		var button = UIComponentsFactory.create_primary_button("")
		button.set_custom_minimum_size(Vector2(85, 55))  # Tamaño móvil más grande
		button.add_theme_font_size_override("font_size", 16)  # Fuente móvil
		var sell_amount = amount if str(qty) == "Todo" else min(qty as int, amount)
		var total_price = unit_price * sell_amount

		# Usar iconos en los botones
		var qty_icon = "🛍️" if str(qty) == "Todo" else "📦"
		button.text = "%s %s\n💰 $%s" % [qty_icon, str(qty), GameUtils.format_large_number(total_price)]
		button.disabled = sell_amount <= 0
		button.pressed.connect(_on_sell_requested.bind(item_type, item_name, sell_amount))

		button_hbox.add_child(button)

	return card

func _get_sell_price(item_type: String, item_name: String) -> float:
	"""Obtiene el precio de venta de un item"""
	# Precios base por tipo (SIN AGUA - no se puede vender)
	var base_prices = {
		"ingredient": {
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
