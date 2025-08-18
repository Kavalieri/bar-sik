extends ScrollContainer
## SalesPanel - Panel de ventas y estadísticas
## Maneja las ventas de productos y muestra estadísticas del juego

@onready var manual_sell_button: Button = $MainContainer/SalesSection/ManualSellButton
@onready var sell_ingredients_button: Button = $MainContainer/SalesSection/SellIngredientsButton
@onready var stats_container: VBoxContainer = $MainContainer/StatisticsSection/StatsContainer

# Variables de UI
var stats_labels: Array[Label] = []

# Señales para comunicación con GameScene
signal manual_sell_requested
signal sell_ingredients_requested


func _ready() -> void:
	print("💰 SalesPanel inicializado")
	_setup_ui()


func _setup_ui() -> void:
	# Conectar botón de venta manual
	manual_sell_button.pressed.connect(_on_manual_sell_pressed)
	
	# Conectar botón de venta de ingredientes
	sell_ingredients_button.pressed.connect(_on_sell_ingredients_pressed)

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


func update_manual_sell_button(game_data: Dictionary) -> void:
	var has_products = false
	for amount in game_data["products"].values():
		if amount > 0:
			has_products = true
			break

	manual_sell_button.disabled = not has_products

	if has_products:
		var total_value = 0.0
		var product_count = 0

		for product_type in game_data["products"].keys():
			var amount = game_data["products"][product_type]
			if amount > 0:
				var price = _get_product_price(product_type)
				total_value += amount * price
				product_count += amount

		manual_sell_button.text = (
			"💸 VENTA MANUAL\n%d productos por $%.2f" % [product_count, total_value]
		)
	else:
		manual_sell_button.text = "💸 VENTA MANUAL\n(No hay productos para vender)"


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


func _on_manual_sell_pressed() -> void:
	manual_sell_requested.emit()


func _on_sell_ingredients_pressed() -> void:
	sell_ingredients_requested.emit()


func update_sell_ingredients_button(game_data: Dictionary) -> void:
	var has_ingredients = false
	var total_value = 0.0
	var ingredient_count = 0

	for ingredient_type in game_data["resources"].keys():
		var amount = game_data["resources"][ingredient_type]
		if amount > 0 and ingredient_type != "water":  # No contar agua
			has_ingredients = true
			var price = _get_ingredient_price(ingredient_type)
			total_value += amount * price
			ingredient_count += amount

	sell_ingredients_button.disabled = not has_ingredients

	if has_ingredients:
		sell_ingredients_button.text = (
			"🌾 VENDER INGREDIENTES\n%d ingredientes por $%.2f" % [ingredient_count, total_value]
		)
	else:
		sell_ingredients_button.text = "🌾 VENDER INGREDIENTES\n(No hay ingredientes para vender)"


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
