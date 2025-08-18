extends Control
## GameScene - Escena principal del idle game BAR-SIK
## Sistema económico de 3 fases: Generación → Producción → Venta
## Ahora usa sistema modular con TabNavigator y paneles separados

# Referencias al sistema de navegación
@onready var tab_navigator: Control = $TabNavigator

# Datos principales del juego
var game_data: Dictionary = {}

# Referencias a los paneles individuales
var generation_panel: Control
var production_panel: Control
var sales_panel: Control

# Variables de sistema
var resource_timer: Timer
var production_timers: Dictionary = {}
var customer_timer: Timer

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
		"base_cost": 250.0,
		"recipe": {"basic_beer": 2, "water": 1},
		"produces": "premium_beer",
		"production_time": 15.0,
		"description": "Mejora cerveza básica a premium"
	}
]


func _ready() -> void:
	print("🍺 GameScene cargado - Sistema económico 3 fases")

	# Cargar datos del juego
	_load_game_data()

	# Setup del sistema modular
	_setup_modular_system()

	# Setup de timers
	_setup_timers()

	# Inicialización inicial
	_update_all_displays()

	print("✅ GameScene configurado con sistema modular")


func _setup_modular_system() -> void:
	# Obtener referencias a los paneles
	generation_panel = (
		tab_navigator.get_node("MainContainer/ContentContainer/GenerationPanel").get_child(0)
	)
	production_panel = (
		tab_navigator.get_node("MainContainer/ContentContainer/ProductionPanel").get_child(0)
	)
	sales_panel = tab_navigator.get_node("MainContainer/ContentContainer/SalesPanel").get_child(0)

	# Conectar señales del TabNavigator
	tab_navigator.tab_changed.connect(_on_tab_changed)
	tab_navigator.pause_pressed.connect(_on_pause_pressed)
	tab_navigator.save_data_reset_requested.connect(_on_reset_data_requested)
	tab_navigator.new_save_slot_requested.connect(_on_new_slot_requested)

	# Setup de cada panel
	generation_panel.setup_resources(game_data)
	generation_panel.setup_generators(resource_generators)
	generation_panel.generator_purchased.connect(_on_generator_purchased)

	production_panel.setup_products(game_data)
	production_panel.setup_stations(production_stations)
	production_panel.station_purchased.connect(_on_station_purchased)

	sales_panel.manual_sell_requested.connect(_on_manual_sell)


func _load_game_data() -> void:
	if SaveSystem:
		var loaded_data = SaveSystem.load_game_data()
		if loaded_data.is_empty():
			print("⚠️ Datos cargados vacíos, usando por defecto")
			game_data = _get_default_game_data()
		else:
			# Asegurar que todas las claves necesarias existen
			var default_data = _get_default_game_data()
			game_data = _merge_with_defaults(loaded_data, default_data)
	else:
		game_data = _get_default_game_data()

	# Debug: verificar estructura
	print("🔍 Debug - game_data keys: ", game_data.keys())
	print("🔍 Debug - stations exists: ", game_data.has("stations"))
	if game_data.has("stations"):
		print("🔍 Debug - stations content: ", game_data["stations"])


func _merge_with_defaults(loaded: Dictionary, defaults: Dictionary) -> Dictionary:
	var result = defaults.duplicate(true)
	for key in loaded.keys():
		if (
			result.has(key)
			and typeof(result[key]) == TYPE_DICTIONARY
			and typeof(loaded[key]) == TYPE_DICTIONARY
		):
			# Mergear diccionarios anidados
			for nested_key in loaded[key].keys():
				result[key][nested_key] = loaded[key][nested_key]
		else:
			result[key] = loaded[key]
	return result


func _get_default_game_data() -> Dictionary:
	return {
		"money": 50.0,
		"resources": {"barley": 0, "hops": 0, "water": 10, "yeast": 0},  # Recurso gratis inicial
		"products": {"basic_beer": 0, "premium_beer": 0, "cocktail": 0},
		"generators": {"barley_farm": 0, "hops_farm": 0},
		"stations": {"brewery": 1, "bar_station": 0},  # Comienza con 1 cervecería desbloqueada
		"statistics":
		{
			"total_money_earned": 0.0,
			"products_sold": 0,
			"customers_served": 0,
			"resources_generated": 0
		}
	}


func _setup_timers() -> void:
	# Timer para generación de recursos (cada 3 segundos)
	resource_timer = Timer.new()
	resource_timer.wait_time = 3.0
	resource_timer.autostart = true
	resource_timer.timeout.connect(_generate_resources)
	add_child(resource_timer)

	# Iniciar timers de producción para estaciones que ya están compradas
	for station_id in production_stations:
		var station = station_id
		var owned_count = game_data["stations"].get(station.id, 0)
		if owned_count > 0:
			_start_production_timer(station.id)

	# Timer para clientes automáticos (cada 8 segundos)
	customer_timer = Timer.new()
	customer_timer.wait_time = 8.0
	customer_timer.autostart = true
	customer_timer.timeout.connect(_process_automatic_customers)
	add_child(customer_timer)


func _update_all_displays() -> void:
	# Actualizar display de dinero en el TabNavigator
	tab_navigator.update_money_display(game_data["money"])

	# Actualizar cada panel según esté visible
	generation_panel.update_resource_displays(game_data)
	generation_panel.update_generator_buttons(resource_generators, game_data)

	production_panel.update_product_displays(game_data)
	production_panel.update_station_buttons(production_stations, game_data)

	sales_panel.update_statistics(game_data)
	sales_panel.update_manual_sell_button(game_data)


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

	_update_all_displays()


func _on_generator_purchased(generator_index: int) -> void:
	var generator = resource_generators[generator_index]
	var cost = _get_generator_cost(generator_index)

	if game_data["money"] >= cost:
		game_data["money"] -= cost
		game_data["generators"][generator.id] = (game_data["generators"].get(generator.id, 0) + 1)

		print(
			"✅ Comprado: %s (Total: %d)" % [generator.name, game_data["generators"][generator.id]]
		)

		if GameEvents:
			GameEvents.generator_purchased.emit(generator.id, game_data["generators"][generator.id])

		_update_all_displays()
	else:
		print("❌ Dinero insuficiente para %s" % generator.name)


## SISTEMA 2: PRODUCCIÓN DE BEBIDAS
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

	if production_timers.has(station_id):
		production_timers[station_id].queue_free()

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
			GameEvents.money_earned.emit(total_earned, "venta_manual")

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
				GameEvents.money_earned.emit(price, "cliente_automatico")

			_update_all_displays()


## FUNCIONES AUXILIARES
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
			return 12.0
		"cocktail":
			return 20.0
		_:
			return 1.0


## EVENTOS DEL SISTEMA
func _on_tab_changed(tab_name: String) -> void:
	print("🔄 Cambiado a pestaña: %s" % tab_name)
	# Actualizar displays cuando se cambie de pestaña
	_update_all_displays()


func _on_pause_pressed() -> void:
	print("⏸️ Pausa presionada")
	if Router:
		Router.goto_scene("main_menu")


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


# Auto-guardado cada 30 segundos
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()


func _timer() -> void:
	# Timer de auto-guardado
	var save_timer = Timer.new()
	save_timer.wait_time = 30.0
	save_timer.autostart = true
	save_timer.timeout.connect(_save_game)


## GESTIÓN DE GUARDADO
func _on_reset_data_requested() -> void:
	print("🗑️ Reseteando datos del juego...")
	if Router:
		Router.reset_save_data()


func _on_new_slot_requested(slot_name: String) -> void:
	print("💾 Creando nuevo slot: ", slot_name)
	if Router:
		Router.create_new_save_slot(slot_name)
	add_child(save_timer)
