extends ScrollContainer
## SalesPanel - Panel de ventas y estadísticas granulares
## Permite vender productos e ingredientes por cantidades específicas

@onready var products_container: VBoxContainer = $MainContainer/SalesSection/ProductsContainer
@onready var ingredients_container: VBoxContainer = $MainContainer/SalesSection/IngredientsContainer
@onready var stats_container: VBoxContainer = $MainContainer/StatisticsSection/StatsContainer

# Variables de UI
var stats_labels: Array[Label] = []
var product_sell_buttons: Dictionary = {}
var ingredient_sell_buttons: Dictionary = {}

# Señales para comunicación con GameScene
signal item_sell_requested(item_type: String, item_name: String, quantity: int)
# item_type será "product" o "ingredient"


func _ready() -> void:
	print("💰 SalesPanel inicializado")
	_setup_ui()


func _setup_ui() -> void:
	# Crear labels para estadísticas
	_setup_statistics()


func _setup_statistics() -> void:
	# Crear labels para las estadísticas principales
	var stat_names = [
		"💰 Dinero total ganado: $0",
		"🌾 Recursos generados: 0",
		"🍺 Productos fabricados: 0",
		"💸 Productos vendidos: 0",
		"👥 Clientes atendidos: 0"
	]

	for stat_text in stat_names:
		var label = Label.new()
		label.text = stat_text
		stats_container.add_child(label)
		stats_labels.append(label)


func create_sell_interface_for_item(item_name: String, item_type: String, quantity: int, price: float) -> void:
	if quantity <= 0:
		return
	
	var container = ingredients_container if item_type == "ingredient" else products_container
	
	# Crear contenedor horizontal para cada ítem
	var item_container = HBoxContainer.new()
	container.add_child(item_container)
	
	# Label con información del ítem
	var info_label = Label.new()
	var emoji = _get_item_emoji(item_name)
	info_label.text = "%s %s: %d ($%.2f c/u)" % [emoji, item_name.capitalize(), quantity, price]
	info_label.custom_minimum_size = Vector2(200, 0)
	item_container.add_child(info_label)
	
	# Botones de venta por incrementos
	var increments = [1, 5, 10, "MAX"]
	for increment in increments:
		var button = Button.new()
		var sell_quantity = increment if increment != "MAX" else quantity
		
		if increment == "MAX":
			button.text = "TODO"
		else:
			button.text = str(increment)
		
		# Deshabilitar si no hay suficiente cantidad
		if increment != "MAX" and increment > quantity:
			button.disabled = true
		
		button.pressed.connect(func(): _on_sell_button_pressed(item_name, item_type, sell_quantity))
		item_container.add_child(button)


func _get_item_emoji(item_name: String) -> String:
	match item_name:
		"barley": return "🌾"
		"hops": return "🌿" 
		"water": return "💧"
		"yeast": return "🦠"
		"basic_beer": return "🍺"
		"premium_beer": return "🍻"
		"cocktail": return "🍹"
		_: return "📦"


func _on_sell_button_pressed(item_name: String, item_type: String, quantity: int) -> void:
	item_sell_requested.emit(item_type, item_name, quantity)


func update_sell_interfaces(game_data: Dictionary) -> void:
	# Limpiar interfaces existentes
	_clear_sell_interfaces()
	
	# Crear interfaces para productos
	for product_name in game_data["products"].keys():
		var quantity = game_data["products"][product_name]
		if quantity > 0:
			var price = _get_product_price(product_name)
			create_sell_interface_for_item(product_name, "product", quantity, price)
	
	# Crear interfaces para ingredientes (excepto agua)
	for ingredient_name in game_data["resources"].keys():
		var quantity = game_data["resources"][ingredient_name]
		if quantity > 0 and ingredient_name != "water":
			var price = _get_ingredient_price(ingredient_name)
			create_sell_interface_for_item(ingredient_name, "ingredient", quantity, price)


func _clear_sell_interfaces() -> void:
	# Limpiar contenedores (excepto labels)
	for child in products_container.get_children():
		if child.name != "ProductsLabel":
			child.queue_free()
	
	for child in ingredients_container.get_children():
		if child.name != "IngredientsLabel":
			child.queue_free()


func update_statistics(game_data: Dictionary) -> void:
	if stats_container.get_child_count() >= 5:
		var stats_labels = stats_container.get_children()
		stats_labels[0].text = (
			"💰 Dinero total ganado: $%.0f" % game_data["statistics"]["total_money_earned"]
		)
		stats_labels[1].text = (
			"🌾 Recursos generados: %d" % game_data["statistics"]["resources_generated"]
		)
		stats_labels[2].text = "🍺 Productos fabricados: %d" % _count_total_products_made(game_data)
		stats_labels[3].text = "💸 Productos vendidos: %d" % game_data["statistics"]["products_sold"]
		stats_labels[4].text = (
			"👥 Clientes atendidos: %d" % game_data["statistics"]["customers_served"]
		)


func _count_total_products_made(game_data: Dictionary) -> int:
	var total = 0
	for amount in game_data["products"].values():
		total += amount
	total += game_data["statistics"]["products_sold"]
	return total


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
