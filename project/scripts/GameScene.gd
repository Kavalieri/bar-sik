extends Control
## GameScene - Escena principal del idle game BAR-SIK
## Sistema económico de 3 fases: Generación → Producción → Venta

# Referencias a los nodos de UI principales
@onready var pause_button: Button = $MainContainer/TopPanel/PauseButton
@onready var currency_container: HBoxContainer = $MainContainer/TopPanel/CurrencyContainer
@onready
var resource_container: VBoxContainer = $MainContainer/ResourcesPanel/ResourceSection/ScrollContainer/ResourceContainer
@onready
var beverage_container: VBoxContainer = $MainContainer/ResourcesPanel/BeveragePanel/ScrollContainer/BeverageContainer
@onready
var stats_container: VBoxContainer = $MainContainer/StatsPanel/ScrollContainer/StatsContainer

# Datos principales del juego
var game_data: Dictionary = {}

# Sistema de generación de ingredientes
var resource_generators: Array[Dictionary] = [
	{
		"id": "barley_farm",
		"name": "🌾 Granja de Cebada",
		"owned": 0,
		"base_cost": 10.0,
		"produces": "barley",
		"production_rate": 1.0,
		"description": "Genera cebada cada 3 segundos"
	},
	{
		"id": "hops_farm",
		"name": "🌿 Granja de Lúpulo",
		"owned": 0,
		"base_cost": 25.0,
		"produces": "hops",
		"production_rate": 1.0,
		"description": "Genera lúpulo cada 5 segundos"
	}
]

# Sistema de producción (convertir ingredientes en productos)
var production_stations: Array[Dictionary] = [
	{
		"id": "brewery",
		"name": "🍺 Cervecería",
		"owned": 0,
		"base_cost": 100.0,
		"recipe": {"barley": 2, "hops": 1, "water": 3},
		"produces": "basic_beer",
		"production_time": 10.0,
		"description": "Convierte ingredientes en cerveza básica"
	},
	{
		"id": "bar_station",
		"name": "🍹 Estación de Bar",
		"owned": 0,
		"base_cost": 200.0,
		"recipe": {"basic_beer": 1, "hops": 2},
		"produces": "premium_beer",
		"production_time": 15.0,
		"description": "Mejora cerveza básica a premium"
	}
]

# UI Labels y botones
var money_label: Label
var resource_labels: Dictionary = {}
var product_labels: Dictionary = {}
var generator_buttons: Array[Button] = []
var station_buttons: Array[Button] = []

# Timers y sistemas
var resource_timer: Timer
var production_timers: Dictionary = {}
var customer_timer: Timer


func _ready() -> void:
	print("🍺 GameScene cargado - Sistema económico 3 fases")

	# Configurar botón de pausa
	if pause_button:
		pause_button.text = "⏸️ Pausa"
		pause_button.pressed.connect(_on_pause_pressed)

	# Inicializar sistemas
	_load_game_data()
	_setup_ui()
	_setup_timers()
	_setup_auto_save()
	_connect_events()
	_update_all_displays()

	print("🎮 Sistema económico BAR-SIK inicializado")


func _load_game_data() -> void:
	if SaveSystem:
		game_data = SaveSystem.load_game_data()
	else:
		game_data = _get_default_game_data()


func _get_default_game_data() -> Dictionary:
	return {
		"money": 50.0,
		"resources": {"barley": 0, "hops": 0, "water": 10, "yeast": 0},  # Recurso gratis inicial
		"products": {"basic_beer": 0, "premium_beer": 0, "cocktail": 0},
		"generators": {"barley_farm": 0, "hops_farm": 0},
		"stations": {"brewery": 0, "bar_station": 0},
		"statistics":
		{
			"total_money_earned": 0.0,
			"products_sold": 0,
			"customers_served": 0,
			"resources_generated": 0
		}
	}


func _setup_ui() -> void:
	# Display de dinero
	money_label = Label.new()
	money_label.add_theme_font_size_override("font_size", 20)
	currency_container.add_child(money_label)

	# Displays de recursos
	var resource_title = Label.new()
	resource_title.text = "📦 INGREDIENTES"
	resource_title.add_theme_font_size_override("font_size", 16)
	resource_container.add_child(resource_title)

	for resource_name in game_data["resources"].keys():
		var label = Label.new()
		resource_labels[resource_name] = label
		resource_container.add_child(label)

	# Separador
	var separator1 = HSeparator.new()
	resource_container.add_child(separator1)

	# Botones de generadores
	var generators_title = Label.new()
	generators_title.text = "🏭 GENERADORES"
	generators_title.add_theme_font_size_override("font_size", 16)
	resource_container.add_child(generators_title)

	for i in range(resource_generators.size()):
		var button = Button.new()
		button.pressed.connect(_on_generator_purchased.bind(i))
		resource_container.add_child(button)
		generator_buttons.append(button)

	# Displays de productos y estaciones
	var products_title = Label.new()
	products_title.text = "🍺 PRODUCTOS"
	products_title.add_theme_font_size_override("font_size", 16)
	beverage_container.add_child(products_title)

	for product_name in game_data["products"].keys():
		var label = Label.new()
		product_labels[product_name] = label
		beverage_container.add_child(label)

	# Separador
	var separator2 = HSeparator.new()
	beverage_container.add_child(separator2)

	# Botones de estaciones de producción
	var stations_title = Label.new()
	stations_title.text = "⚙️ ESTACIONES"
	stations_title.add_theme_font_size_override("font_size", 16)
	beverage_container.add_child(stations_title)

	for i in range(production_stations.size()):
		var button = Button.new()
		button.pressed.connect(_on_station_purchased.bind(i))
		beverage_container.add_child(button)
		station_buttons.append(button)

	# Botón de venta manual
	var separator3 = HSeparator.new()
	beverage_container.add_child(separator3)

	var sell_button = Button.new()
	sell_button.text = "💰 VENDER PRODUCTOS\n(Click manual)"
	sell_button.add_theme_font_size_override("font_size", 16)
	sell_button.pressed.connect(_on_manual_sell)
	beverage_container.add_child(sell_button)

	# Panel de estadísticas
	_setup_stats_panel()


func _setup_stats_panel() -> void:
	var stats = [
		"💰 Dinero total: $0",
		"🌾 Recursos generados: 0",
		"🍺 Productos fabricados: 0",
		"💸 Productos vendidos: 0",
		"👥 Clientes atendidos: 0"
	]

	for stat_text in stats:
		var stat_label = Label.new()
		stat_label.text = stat_text
		stat_label.add_theme_font_size_override("font_size", 14)
		stats_container.add_child(stat_label)


func _setup_timers() -> void:
	# Timer para generar recursos
	resource_timer = Timer.new()
	resource_timer.wait_time = 3.0
	resource_timer.autostart = true
	resource_timer.timeout.connect(_generate_resources)
	add_child(resource_timer)

	# Timer para clientes automáticos
	customer_timer = Timer.new()
	customer_timer.wait_time = 8.0
	customer_timer.autostart = true
	customer_timer.timeout.connect(_process_automatic_customers)
	add_child(customer_timer)


func _connect_events() -> void:
	if GameEvents:
		GameEvents.resource_generated.connect(_on_resource_generated)
		GameEvents.product_crafted.connect(_on_product_crafted)
		GameEvents.money_earned.connect(_on_money_earned)


func _on_pause_pressed() -> void:
	print("⏸️ Juego pausado")
	_save_game()
	Router.goto_scene("pause")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_pause_pressed()


## SISTEMA 1: GENERACIÓN DE RECURSOS
func _generate_resources() -> void:
	for i in range(resource_generators.size()):
		var generator = resource_generators[i]
		var owned_count = game_data["generators"].get(generator.id, 0)

		if owned_count > 0:
			var resource_type = generator.produces
			var amount = int(generator.production_rate * owned_count)

			game_data["resources"][resource_type] += amount
			game_data["statistics"]["resources_generated"] += amount

			if GameEvents:
				GameEvents.resource_generated.emit(resource_type, amount)

			print("🌾 Generado: +%d %s" % [amount, resource_type])

	_update_all_displays()


func _on_generator_purchased(generator_index: int) -> void:
	var generator = resource_generators[generator_index]
	var cost = _get_generator_cost(generator_index)

	if game_data["money"] >= cost:
		game_data["money"] -= cost
		game_data["generators"][generator.id] = game_data["generators"].get(generator.id, 0) + 1

		print(
			"✅ Comprado: %s (Total: %d)" % [generator.name, game_data["generators"][generator.id]]
		)

		if GameEvents:
			GameEvents.generator_purchased.emit(generator.id, game_data["generators"][generator.id])

		_update_all_displays()
	else:
		print("❌ Dinero insuficiente para %s" % generator.name)


## SISTEMA 2: PRODUCCIÓN DE PRODUCTOS
func _on_station_purchased(station_index: int) -> void:
	var station = production_stations[station_index]
	var cost = _get_station_cost(station_index)

	if game_data["money"] >= cost:
		game_data["money"] -= cost
		game_data["stations"][station.id] = game_data["stations"].get(station.id, 0) + 1

		print("✅ Comprado: %s (Total: %d)" % [station.name, game_data["stations"][station.id]])
		_start_production_timer(station.id)
		_update_all_displays()
	else:
		print("❌ Dinero insuficiente para %s" % station.name)


func _start_production_timer(station_id: String) -> void:
	var station = _find_station_by_id(station_id)
	if not station:
		return

	if not production_timers.has(station_id):
		var timer = Timer.new()
		timer.wait_time = station.production_time
		timer.autostart = true
		timer.timeout.connect(_produce_item.bind(station_id))
		add_child(timer)
		production_timers[station_id] = timer


func _produce_item(station_id: String) -> void:
	var station = _find_station_by_id(station_id)
	if not station:
		return

	var owned_count = game_data["stations"].get(station_id, 0)
	if owned_count == 0:
		return

	# Verificar si tenemos los ingredientes necesarios
	if _can_produce(station):
		# Consumir ingredientes
		_consume_ingredients(station)

		# Producir el producto
		var product_type = station.produces
		game_data["products"][product_type] += 1

		print("🍺 Producido: +1 %s" % product_type)

		if GameEvents:
			GameEvents.product_crafted.emit(product_type, 1, station.recipe)

		_update_all_displays()


func _can_produce(station: Dictionary) -> bool:
	for ingredient in station.recipe.keys():
		var required = station.recipe[ingredient]
		var available = 0

		# Buscar en recursos o productos
		if game_data["resources"].has(ingredient):
			available = game_data["resources"][ingredient]
		elif game_data["products"].has(ingredient):
			available = game_data["products"][ingredient]

		if available < required:
			return false

	return true


func _consume_ingredients(station: Dictionary) -> void:
	for ingredient in station.recipe.keys():
		var required = station.recipe[ingredient]

		if game_data["resources"].has(ingredient):
			game_data["resources"][ingredient] -= required
		elif game_data["products"].has(ingredient):
			game_data["products"][ingredient] -= required


## SISTEMA 3: VENTA DE PRODUCTOS
func _on_manual_sell() -> void:
	var products_sold = 0
	var total_earned = 0.0

	# Vender todos los productos disponibles
	for product_type in game_data["products"].keys():
		var available = game_data["products"][product_type]
		if available > 0:
			var price = _get_product_price(product_type)
			var earned = available * price

			game_data["money"] += earned
			game_data["statistics"]["total_money_earned"] += earned
			game_data["statistics"]["products_sold"] += available
			game_data["products"][product_type] = 0

			total_earned += earned
			products_sold += available

			print("💰 Vendido: %dx %s por $%.2f" % [available, product_type, earned])

	if products_sold > 0:
		game_data["statistics"]["customers_served"] += 1
		print("💸 Total venta manual: $%.2f (%d productos)" % [total_earned, products_sold])

		if GameEvents:
			GameEvents.sale_completed.emit("manual", products_sold, total_earned)
	else:
		print("❌ No hay productos para vender")

	_update_all_displays()


func _process_automatic_customers() -> void:
	# Clientes automáticos compran productos aleatoriamente
	if randf() < 0.3:  # 30% de posibilidad de cliente
		var product_types = []
		for product_type in game_data["products"].keys():
			if game_data["products"][product_type] > 0:
				product_types.append(product_type)

		if product_types.size() > 0:
			var chosen_product = product_types[randi() % product_types.size()]
			var price = _get_product_price(chosen_product)

			game_data["money"] += price
			game_data["statistics"]["total_money_earned"] += price
			game_data["statistics"]["products_sold"] += 1
			game_data["statistics"]["customers_served"] += 1
			game_data["products"][chosen_product] -= 1

			print("🤖 Cliente automático compró: %s por $%.2f" % [chosen_product, price])

			if GameEvents:
				GameEvents.sale_completed.emit(chosen_product, 1, price)

			_update_all_displays()


## FUNCIONES HELPER
func _find_station_by_id(station_id: String) -> Dictionary:
	for station in production_stations:
		if station.id == station_id:
			return station
	return {}


func _get_generator_cost(generator_index: int) -> float:
	var generator = resource_generators[generator_index]
	var owned = game_data["generators"].get(generator.id, 0)
	return generator.base_cost * pow(1.15, owned)


func _get_station_cost(station_index: int) -> float:
	var station = production_stations[station_index]
	var owned = game_data["stations"].get(station.id, 0)
	return station.base_cost * pow(1.2, owned)


func _get_product_price(product_type: String) -> float:
	match product_type:
		"basic_beer":
			return 5.0
		"premium_beer":
			return 15.0
		"cocktail":
			return 25.0
		_:
			return 1.0


## FUNCIONES DE UI Y ACTUALIZACIÓN
func _update_all_displays() -> void:
	_update_money_display()
	_update_resource_displays()
	_update_product_displays()
	_update_generator_buttons()
	_update_station_buttons()
	_update_stats_panel()


func _update_money_display() -> void:
	if money_label:
		money_label.text = "💰 $%.2f" % game_data["money"]


func _update_resource_displays() -> void:
	for resource_name in resource_labels.keys():
		var label = resource_labels[resource_name]
		var amount = game_data["resources"].get(resource_name, 0)
		var icon = _get_resource_icon(resource_name)
		label.text = "%s %s: %d" % [icon, resource_name.capitalize(), amount]


func _update_product_displays() -> void:
	for product_name in product_labels.keys():
		var label = product_labels[product_name]
		var amount = game_data["products"].get(product_name, 0)
		var icon = _get_product_icon(product_name)
		var price = _get_product_price(product_name)
		label.text = (
			"%s %s: %d ($%.1f c/u)"
			% [icon, product_name.replace("_", " ").capitalize(), amount, price]
		)


func _update_generator_buttons() -> void:
	for i in range(generator_buttons.size()):
		if i < resource_generators.size():
			var generator = resource_generators[i]
			var button = generator_buttons[i]
			var cost = _get_generator_cost(i)
			var owned = game_data["generators"].get(generator.id, 0)
			var can_afford = game_data["money"] >= cost

			button.text = (
				"%s\nCosto: $%.0f\nPropiedad: %d\n%s"
				% [generator.name, cost, owned, generator.description]
			)
			button.disabled = not can_afford


func _update_station_buttons() -> void:
	for i in range(station_buttons.size()):
		if i < production_stations.size():
			var station = production_stations[i]
			var button = station_buttons[i]
			var cost = _get_station_cost(i)
			var owned = game_data["stations"].get(station.id, 0)
			var can_afford = game_data["money"] >= cost

			var recipe_text = ""
			for ingredient in station.recipe.keys():
				recipe_text += "%dx %s " % [station.recipe[ingredient], ingredient]

			button.text = (
				"%s\nCosto: $%.0f\nPropiedad: %d\nReceta: %s\n%s"
				% [station.name, cost, owned, recipe_text, station.description]
			)
			button.disabled = not can_afford


func _update_stats_panel() -> void:
	if stats_container.get_child_count() >= 5:
		var stats_labels = stats_container.get_children()
		stats_labels[0].text = (
			"💰 Dinero total: $%.0f" % game_data["statistics"]["total_money_earned"]
		)
		stats_labels[1].text = (
			"🌾 Recursos generados: %d" % game_data["statistics"]["resources_generated"]
		)
		stats_labels[2].text = "🍺 Productos fabricados: %d" % _count_total_products_made()
		stats_labels[3].text = "💸 Productos vendidos: %d" % game_data["statistics"]["products_sold"]
		stats_labels[4].text = (
			"👥 Clientes atendidos: %d" % game_data["statistics"]["customers_served"]
		)


func _get_resource_icon(resource_name: String) -> String:
	match resource_name:
		"barley":
			return "🌾"
		"hops":
			return "🌿"
		"water":
			return "💧"
		"yeast":
			return "🦠"
		_:
			return "📦"


func _get_product_icon(product_name: String) -> String:
	match product_name:
		"basic_beer":
			return "🍺"
		"premium_beer":
			return "🍻"
		"cocktail":
			return "🍹"
		_:
			return "🥤"


func _count_total_products_made() -> int:
	var total = 0
	for amount in game_data["products"].values():
		total += amount
	total += game_data["statistics"]["products_sold"]
	return total


## EVENTOS Y GUARDADO
func _on_resource_generated(resource_type: String, amount: int) -> void:
	print("📦 Evento: Recurso generado - %s: +%d" % [resource_type, amount])


func _on_product_crafted(product_type: String, amount: int, _ingredients_used: Dictionary) -> void:
	print("🍺 Evento: Producto fabricado - %s: +%d" % [product_type, amount])


func _on_money_earned(amount: float, source: String) -> void:
	print("💰 Evento: Dinero ganado - +$%.2f de %s" % [amount, source])


func _save_game() -> void:
	if SaveSystem:
		SaveSystem.save_game_data(game_data)
	elif GameEvents:
		GameEvents.save_data_requested.emit()


## Guardado automático cada 30 segundos
func _setup_auto_save() -> void:
	var auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 30.0
	auto_save_timer.autostart = true
	auto_save_timer.timeout.connect(_save_game)
	add_child(auto_save_timer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
