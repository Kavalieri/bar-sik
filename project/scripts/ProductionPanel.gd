extends ScrollContainer
## ProductionPanel - Panel de producción manual y crafteo
## Maneja los productos fabricados, estaciones y producción manual por clicks

@onready var product_container: VBoxContainer = $MainContainer/ProductsSection/ProductContainer
@onready var production_container: VBoxContainer = $MainContainer/ProductionSection/ProductionContainer
@onready var station_container: VBoxContainer = $MainContainer/StationsSection/StationContainer

# Variables de UI
var product_labels: Dictionary = {}
var station_buttons: Array[Button] = []

# Señales para comunicación con GameScene
signal station_purchased(station_index: int)
signal manual_production_requested(station_index: int, quantity: int)


func _ready() -> void:
	print("🍺 ProductionPanel inicializado")


func setup_products(game_data: Dictionary) -> void:
	# Limpiar contenido existente
	_clear_product_labels()

	# Crear labels para productos
	for product_name in game_data["products"].keys():
		var label = Label.new()
		product_labels[product_name] = label
		product_container.add_child(label)


func setup_stations(production_stations: Array[Dictionary]) -> void:
	# Limpiar botones existentes
	_clear_station_buttons()

	# Crear botones para estaciones
	for i in range(production_stations.size()):
		var button = Button.new()
		button.pressed.connect(_on_station_purchased.bind(i))
		station_container.add_child(button)
		station_buttons.append(button)


func setup_production_interfaces(production_stations: Array[Dictionary]) -> void:
	# Limpiar contenido existente  
	_clear_production_interfaces()
	
	# Crear interfaces de producción para cada estación
	for i in range(production_stations.size()):
		var station = production_stations[i]
		var station_container_v = VBoxContainer.new()
		production_container.add_child(station_container_v)
		
		# Label con información de la estación
		var info_label = Label.new()
		info_label.text = "%s\nReceta: %s" % [station.name, _format_recipe(station.recipe)]
		station_container_v.add_child(info_label)
		
		# Contenedor horizontal para botones de producción
		var button_container = HBoxContainer.new()
		station_container_v.add_child(button_container)
		
		# Botones de producción por incrementos
		var increments = [1, 5, 10, 50]
		for increment in increments:
			var button = Button.new()
			button.text = str(increment)
			button.pressed.connect(_on_manual_production.bind(i, increment))
			button_container.add_child(button)
		
		# Separador
		var separator = HSeparator.new()
		station_container_v.add_child(separator)


func _format_recipe(recipe: Dictionary) -> String:
	var recipe_parts = []
	for ingredient in recipe.keys():
		recipe_parts.append("%dx %s" % [recipe[ingredient], ingredient])
	return " + ".join(recipe_parts)


func update_product_displays(game_data: Dictionary) -> void:
	for product_name in product_labels.keys():
		var label = product_labels[product_name]
		var amount = game_data["products"].get(product_name, 0)
		var icon = _get_product_icon(product_name)
		var price = _get_product_price(product_name)
		label.text = (
			"%s %s: %d ($%.1f c/u)"
			% [icon, product_name.replace("_", " ").capitalize(), amount, price]
		)


func update_production_interfaces(production_stations: Array[Dictionary], game_data: Dictionary) -> void:
	# Actualizar cada interfaz de producción
	var production_interfaces = production_container.get_children()
	
	for i in range(min(production_interfaces.size(), production_stations.size())):
		var station = production_stations[i]
		var interface_container = production_interfaces[i]
		var owned = game_data["stations"].get(station.id, 0)
		
		# Actualizar info label (primer hijo)
		var info_label = interface_container.get_child(0) as Label
		info_label.text = "%s (Propiedad: %d)\nReceta: %s → %s" % [
			station.name, owned, _format_recipe(station.recipe), station.produces
		]
		
		# Actualizar botones de producción (segundo hijo es el HBoxContainer)
		var button_container = interface_container.get_child(1) as HBoxContainer
		var buttons = button_container.get_children()
		
		for j in range(buttons.size()):
			var button = buttons[j] as Button
			var increment = int(button.text)
			var can_produce = owned > 0 and _can_afford_production(station, game_data, increment)
			
			button.text = "%d\n%s" % [increment, station.produces.replace("_", " ")]
			button.disabled = not can_produce


func _can_afford_production(station: Dictionary, game_data: Dictionary, quantity: int) -> bool:
	# Verificar si hay suficientes ingredientes para la receta
	for ingredient in station.recipe.keys():
		var needed = station.recipe[ingredient] * quantity
		var available = game_data["resources"].get(ingredient, 0)
		if available < needed:
			return false
	return true


func _on_manual_production(station_index: int, quantity: int) -> void:
	manual_production_requested.emit(station_index, quantity)


func _clear_production_interfaces() -> void:
	for child in production_container.get_children():
		child.queue_free()


func update_station_buttons(production_stations: Array[Dictionary], game_data: Dictionary) -> void:
	for i in range(station_buttons.size()):
		if i < production_stations.size():
			var station = production_stations[i]
			var button = station_buttons[i]
			var cost = _calculate_station_cost(station, game_data)
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


func _calculate_station_cost(station: Dictionary, game_data: Dictionary) -> float:
	var owned = game_data["stations"].get(station.id, 0)
	return station.base_cost * pow(1.2, owned)


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


func _clear_product_labels() -> void:
	for child in product_container.get_children():
		child.queue_free()
	product_labels.clear()


func _clear_station_buttons() -> void:
	for child in station_container.get_children():
		child.queue_free()
	station_buttons.clear()


func _on_station_purchased(station_index: int) -> void:
	station_purchased.emit(station_index)
