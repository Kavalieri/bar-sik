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
var customers_panel: Control

# Variables de sistema
var resource_timer: Timer
var production_timers: Dictionary = {}
var customer_timer: Timer
var save_timer: Timer
var customer_timer_progress: float = 0.0  # Para mostrar progreso del próximo cliente

# Sistema de generación de ingredientes
var resource_generators: Array[Dictionary] = [
	{
		"id": "water_collector",
		"name": "💧 Recolector de Agua",
		"owned": 0,
		"base_cost": 10.0,
		"produces": "water",
		"production_rate": 2.0,
		"description": "Recolecta agua cada 2 segundos"
	},
	{
		"id": "barley_farm",
		"name": "🌾 Granja de Cebada",
		"owned": 0,
		"base_cost": 100.0,
		"produces": "barley",
		"production_rate": 1.0,
		"description": "Genera cebada cada 3 segundos"
	},
	{
		"id": "hops_farm",
		"name": "🌿 Granja de Lúpulo",
		"owned": 0,
		"base_cost": 1000.0,
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
		"base_cost": 500.0,
		"recipe": {"barley": 2, "hops": 1, "water": 3},
		"produces": "basic_beer",
		"production_time": 10.0,
		"unlocked": false,
		"description": "Convierte ingredientes en cerveza básica\n🌾x2 + 🌿x1 + 💧x3 → 🍺"
	},
	{
		"id": "bar_station",
		"name": "🍹 Estación de Bar",
		"owned": 0,
		"base_cost": 2500.0,
		"recipe": {"basic_beer": 2, "water": 1},
		"produces": "premium_beer",
		"production_time": 15.0,
		"unlocked": false,
		"description": "Mejora cerveza básica a premium\n🍺x2 + 💧x1 → 🍹"
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


func _process(_delta: float) -> void:
	# Actualizar progreso del timer de clientes
	if customer_timer and game_data["upgrades"]["auto_sell_enabled"]:
		customer_timer_progress = 1.0 - (customer_timer.time_left / customer_timer.wait_time)
		customer_timer_progress = clamp(customer_timer_progress, 0.0, 1.0)


func _setup_modular_system() -> void:
	# Obtener referencias a los paneles
	generation_panel = (
		tab_navigator.get_node("MainContainer/ContentContainer/GenerationPanel").get_child(0)
	)
	production_panel = (
		tab_navigator.get_node("MainContainer/ContentContainer/ProductionPanel").get_child(0)
	)
	sales_panel = tab_navigator.get_node("MainContainer/ContentContainer/SalesPanel").get_child(0)
	customers_panel = tab_navigator.get_node("MainContainer/ContentContainer/CustomersPanel").get_child(0)

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
	production_panel.manual_production_requested.connect(_on_manual_production_requested)

	sales_panel.item_sell_requested.connect(_on_item_sell_requested)

	customers_panel.setup_autosell_upgrades(game_data)
	customers_panel.autosell_upgrade_purchased.connect(_on_autosell_upgrade_purchased)


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
		"resources": {"barley": 0, "hops": 0, "water": 0, "yeast": 0},
		"products": {"basic_beer": 0, "premium_beer": 0, "cocktail": 0},
		"generators": {"water_collector": 0, "barley_farm": 0, "hops_farm": 0},
		"stations": {"brewery": 1, "bar_station": 0},
		"upgrades": {
			"auto_sell_enabled": false,
			"auto_sell_speed": 1.0,
			"auto_sell_efficiency": 1.0,
			"manager_level": 0,  # Nivel de manager de ventas
			"faster_customers": false,  # Clientes llegan más rápido
			"premium_customers": false,  # Clientes pagan más
			"bulk_buyers": false  # Clientes compran en lote
		},
		"milestones": {
			# Hitos de edificios desbloqueados
			"generators": {},
			"stations": {}
		},
		"statistics": {
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
			# Producción manual ahora - no iniciar timer automático
			# _start_production_timer(station.id)
			pass

	# Timer para clientes automáticos (cada 8 segundos)
	customer_timer = Timer.new()
	customer_timer.wait_time = 8.0
	customer_timer.autostart = true
	customer_timer.timeout.connect(_process_automatic_customers)
	add_child(customer_timer)

	# Timer de auto-guardado (cada 30 segundos)
	save_timer = Timer.new()
	save_timer.wait_time = 30.0
	save_timer.autostart = true
	save_timer.timeout.connect(_save_game)
	add_child(save_timer)


func _update_all_displays() -> void:
	# Actualizar display de dinero en el TabNavigator
	tab_navigator.update_money_display(game_data["money"])

	# Actualizar cada panel según esté visible
	generation_panel.update_resource_displays(game_data)
	generation_panel.update_generator_displays(resource_generators, game_data)

	production_panel.update_product_displays(game_data)
	production_panel.update_station_interfaces(production_stations, game_data)

	sales_panel.update_statistics(game_data)
	sales_panel.update_sell_interfaces(game_data)

	customers_panel.update_customer_display(game_data, customer_timer_progress)


func _update_resources_only() -> void:
	# Actualizar solo las cantidades de recursos, no los costos
	generation_panel.update_resource_displays(game_data)
	production_panel.update_product_displays(game_data)


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

	# Verificar desbloqueos automáticos después de generar recursos
	_check_and_unlock_stations()
	_update_resources_only()


func _on_generator_purchased(generator_index: int, quantity: int) -> void:
	var generator = resource_generators[generator_index]
	var total_cost = _get_bulk_generator_cost(generator_index, quantity)

	if game_data["money"] >= total_cost:
		game_data["money"] -= total_cost
		var current_owned = game_data["generators"].get(generator.id, 0)
		game_data["generators"][generator.id] = current_owned + quantity

		print(
			"✅ Comprado: %dx %s (Total: %d) por $%.0f" %
			[quantity, generator.name, game_data["generators"][generator.id], total_cost]
		)

		if GameEvents:
			GameEvents.generator_purchased.emit(generator.id, game_data["generators"][generator.id])

		_update_all_displays()
	else:
		print("❌ Dinero insuficiente para %dx %s (Costo: $%.0f)" % [quantity, generator.name, total_cost])


func _get_bulk_generator_cost(generator_index: int, quantity: int) -> float:
	var generator = resource_generators[generator_index]
	var owned = game_data["generators"].get(generator.id, 0)
	var total_cost = 0.0

	# Calcular costo acumulativo para compras múltiples
	for i in range(quantity):
		var cost = generator.base_cost * pow(1.15, owned + i)
		total_cost += cost

	return total_cost


## SISTEMA 2: PRODUCCIÓN DE BEBIDAS
func _on_station_purchased(station_index: int) -> void:
	var station = production_stations[station_index]
	var cost = _get_station_cost(station_index)

	if game_data["money"] >= cost:
		game_data["money"] -= cost
		game_data["stations"][station.id] = game_data["stations"].get(station.id, 0) + 1

		print("✅ Comprado: %s (Total: %d)" % [station.name, game_data["stations"][station.id]])
		# Producción manual ahora - no iniciar timer automático
		# _start_production_timer(station.id)
		_update_all_displays()
	else:
		print("❌ Dinero insuficiente para %s" % station.name)


func _on_manual_production_requested(station_index: int, quantity: int) -> void:
	var station = production_stations[station_index]
	var owned = game_data["stations"].get(station.id, 0)

	if owned <= 0:
		print("⚠️ No tienes %s para producir" % station.name)
		return

	var successful_productions = 0

	# Intentar producir la cantidad solicitada
	for i in range(quantity):
		# Verificar ingredientes para una unidad
		var can_produce = true
		for ingredient in station.recipe.keys():
			var needed = station.recipe[ingredient]
			var available = game_data["resources"].get(ingredient, 0)
			if available < needed:
				can_produce = false
				break

		if can_produce:
			# Consumir ingredientes
			for ingredient in station.recipe.keys():
				var needed = station.recipe[ingredient]
				game_data["resources"][ingredient] -= needed

			# Producir producto
			game_data["products"][station.produces] = game_data["products"].get(station.produces, 0) + 1
			successful_productions += 1
		else:
			break  # No más ingredientes disponibles

	if successful_productions > 0:
		print("🍺 Producido: +%d %s" % [successful_productions, station.produces])

		if GameEvents:
			GameEvents.product_crafted.emit(station.produces, successful_productions, station.recipe)

		_update_all_displays()
	else:
		print("⚠️ Ingredientes insuficientes para producir %s" % station.produces)


func _check_and_unlock_stations() -> void:
	# Verificar desbloqueos automáticos basados en recursos
	for station in production_stations:
		if not station.get("unlocked", true):
			# Cervecería se desbloquea cuando tienes al menos 5 de cada ingrediente
			if station.id == "brewery":
				var has_barley = game_data["resources"].get("barley", 0) >= 5
				var has_hops = game_data["resources"].get("hops", 0) >= 5
				var has_water = game_data["resources"].get("water", 0) >= 10

				if has_barley and has_hops and has_water:
					station.unlocked = true
					print("🔓 ¡Cervecería desbloqueada! Ya puedes producir cerveza.")
					_update_all_displays()

			# Bar Station se desbloquea cuando tienes 10+ cervezas básicas
			elif station.id == "bar_station":
				var has_basic_beer = game_data["products"].get("basic_beer", 0) >= 10

				if has_basic_beer:
					station.unlocked = true
					print("🔓 ¡Estación de Bar desbloqueada! Ahora puedes hacer cerveza premium.")
					_update_all_displays()


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
func _on_item_sell_requested(item_type: String, item_name: String, quantity: int) -> void:
	var available = 0
	var price = 0.0

	if item_type == "product":
		available = game_data["products"].get(item_name, 0)
		price = _get_product_price(item_name)
	elif item_type == "ingredient":
		available = game_data["resources"].get(item_name, 0)
		price = _get_ingredient_price(item_name)

	# Verificar que hay suficiente cantidad
	var actual_quantity = min(quantity, available)
	if actual_quantity <= 0:
		print("⚠️ No hay suficiente %s para vender" % item_name)
		return

	var total_earned = actual_quantity * price

	# Actualizar inventario y estadísticas
	if item_type == "product":
		game_data["products"][item_name] -= actual_quantity
		game_data["statistics"]["products_sold"] += actual_quantity
	elif item_type == "ingredient":
		game_data["resources"][item_name] -= actual_quantity

	game_data["money"] += total_earned
	game_data["statistics"]["total_money_earned"] += total_earned

	# Log de venta
	var emoji = "💰" if item_type == "product" else "🌾"
	print("%s Vendido: %dx %s por $%.2f" % [emoji, actual_quantity, item_name, total_earned])

	# Emitir evento
	if GameEvents:
		var event_type = "venta_" + item_type + "s"
		GameEvents.money_earned.emit(total_earned, event_type)

	_update_all_displays()


func _on_upgrade_purchased(upgrade_id: String) -> void:
	var cost = 0.0
	var upgrade_name = ""

	match upgrade_id:
		"enable_autosell":
			cost = 1000.0
			upgrade_name = "Manager de Ventas"
		"speed_upgrade_1":
			cost = 2500.0
			upgrade_name = "Velocidad de Venta +1"
		"efficiency_upgrade_1":
			cost = 5000.0
			upgrade_name = "Eficiencia de Venta +1"

	if game_data["money"] >= cost:
		game_data["money"] -= cost

		match upgrade_id:
			"enable_autosell":
				game_data["upgrades"]["auto_sell_enabled"] = true
				game_data["upgrades"]["manager_level"] = 1
				print("🤖 ¡Manager de Ventas contratado! Ventas automáticas habilitadas")
			"speed_upgrade_1":
				game_data["upgrades"]["auto_sell_speed"] *= 1.2  # 20% más rápido
				game_data["upgrades"]["speed_upgrade_1"] = true
				customer_timer.wait_time = max(1.0, customer_timer.wait_time * 0.8)  # Reducir tiempo
				print("⚡ ¡Velocidad de venta mejorada! Clientes llegan 20% más rápido")
			"efficiency_upgrade_1":
				game_data["upgrades"]["auto_sell_efficiency"] *= 1.25  # 25% más eficiente
				game_data["upgrades"]["efficiency_upgrade_1"] = true
				print("💰 ¡Eficiencia mejorada! Los productos se venden por 25% más")

		print("✅ Upgrade comprado: %s por $%.0f" % [upgrade_name, cost])
		_update_all_displays()
	else:
		print("❌ Dinero insuficiente para %s (Costo: $%.0f)" % [upgrade_name, cost])


func _on_autosell_upgrade_purchased(upgrade_id: String) -> void:
	var cost = 0.0
	var upgrade_name = ""

	match upgrade_id:
		"nuevo_cliente":
			cost = 100.0
			upgrade_name = "Nuevo Cliente"
		"faster_customers":
			cost = 500.0
			upgrade_name = "Clientes Más Rápidos"
		"premium_customers":
			cost = 1000.0
			upgrade_name = "Clientes Premium"
		"bulk_buyers":
			cost = 2500.0
			upgrade_name = "Compradores en Lote"

	if game_data["money"] >= cost:
		game_data["money"] -= cost

		match upgrade_id:
			"nuevo_cliente":
				game_data["upgrades"]["auto_sell_enabled"] = true
				customer_timer.wait_time = 10.0  # Clientes cada 10 segundos
				print("👤 ¡Primer cliente añadido! Las ventas automáticas comenzarán pronto")
			"faster_customers":
				game_data["upgrades"]["faster_customers"] = true
				customer_timer.wait_time = max(3.0, customer_timer.wait_time * 0.6)  # 40% más rápido
				print("⚡ ¡Clientes más rápidos! Llegan 40% más frecuentemente")
			"premium_customers":
				game_data["upgrades"]["premium_customers"] = true
				print("💎 ¡Clientes Premium! Pagan 50% más por los productos")
			"bulk_buyers":
				game_data["upgrades"]["bulk_buyers"] = true
				print("📦 ¡Compradores en Lote! Pueden comprar múltiples productos")

		print("✅ Upgrade de Clientes comprado: %s por $%.0f" % [upgrade_name, cost])
		_update_all_displays()
	else:
		print("❌ Dinero insuficiente para %s (Costo: $%.0f)" % [upgrade_name, cost])


func _process_automatic_customers() -> void:
	# Solo funciona si la autoventa está habilitada
	if not game_data["upgrades"]["auto_sell_enabled"]:
		return

	# Verificar si hay productos disponibles
	var product_types = []
	for product_type in game_data["products"].keys():
		if game_data["products"][product_type] > 0:
			product_types.append(product_type)

	if product_types.size() > 0:
		var chosen_product = product_types[randi() % product_types.size()]
		var base_price = _get_product_price(chosen_product)
		var final_price = base_price

		# Aplicar bonus de clientes premium
		if game_data["upgrades"].get("premium_customers", false):
			final_price *= 1.5  # 50% más

		# Determinar cantidad (bulk buyers pueden comprar más)
		var quantity = 1
		if game_data["upgrades"].get("bulk_buyers", false):
			quantity = randi_range(1, min(3, game_data["products"][chosen_product]))

		# Procesar la venta
		var total_earned = final_price * quantity
		game_data["money"] += total_earned
		game_data["statistics"]["total_money_earned"] += total_earned
		game_data["statistics"]["products_sold"] += quantity
		game_data["statistics"]["customers_served"] += 1
		game_data["products"][chosen_product] -= quantity

		var customer_type = "🤖 Cliente"
		if game_data["upgrades"].get("premium_customers", false):
			customer_type = "💎 Cliente Premium"
		if quantity > 1:
			customer_type += " (Lote)"

		print("%s compró: %dx%s por $%.2f" % [customer_type, quantity, chosen_product, total_earned])

		if GameEvents:
			GameEvents.money_earned.emit(total_earned, "cliente_automatico")

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


func _get_ingredient_price(ingredient_type: String) -> float:
	# Precios muy bajos para ingredientes (aproximadamente 10-20% del valor de productos)
	match ingredient_type:
		"barley":
			return 0.5
		"hops":
			return 0.8
		"water":
			return 0.1
		"yeast":
			return 1.0
		_:
			return 0.2


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


## GESTIÓN DE GUARDADO
func _on_reset_data_requested() -> void:
	print("🗑️ Reseteando datos del juego...")
	if Router:
		Router.reset_save_data()


func _on_new_slot_requested(slot_name: String) -> void:
	print("💾 Creando nuevo slot: ", slot_name)
	if Router:
		Router.create_new_save_slot(slot_name)
