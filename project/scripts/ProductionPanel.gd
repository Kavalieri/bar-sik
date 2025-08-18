extends ScrollContainer
## ProductionPanel - Panel de producción y crafteo
## Maneja los productos fabricados y las estaciones de producción

@onready var product_container: VBoxContainer = $MainContainer/ProductsSection/ProductContainer
@onready var station_container: VBoxContainer = $MainContainer/StationsSection/StationContainer

# Variables de UI
var product_labels: Dictionary = {}
var station_buttons: Array[Button] = []

# Señales para comunicación con GameScene
signal station_purchased(station_index: int)


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
