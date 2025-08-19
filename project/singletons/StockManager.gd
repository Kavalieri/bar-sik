extends Node
## StockManager - Singleton para gestión centralizada de inventario
## Proporciona acceso unificado a stock de ingredientes y productos desde cualquier parte

signal stock_updated(item_type: String, item_name: String, new_quantity: int)
signal stock_depleted(item_type: String, item_name: String)

var game_data: GameData

func _ready() -> void:
	print("📦 StockManager inicializado")

## Asignar referencia a GameData
func set_game_data(data: GameData) -> void:
	game_data = data
	print("📦 StockManager conectado a GameData")

## === CONSULTAS DE STOCK ===

## Obtener cantidad de un item específico
func get_stock(item_type: String, item_name: String) -> int:
	if not game_data:
		return 0

	match item_type:
		"ingredient", "resource":
			return int(game_data.resources.get(item_name, 0))
		"product":
			return int(game_data.products.get(item_name, 0))
		_:
			print("❌ StockManager: Tipo de item desconocido: %s" % item_type)
			return 0

## Obtener todo el stock de un tipo
func get_all_stock(item_type: String) -> Dictionary:
	if not game_data:
		return {}

	match item_type:
		"ingredient", "resource":
			return game_data.resources.duplicate()
		"product":
			return game_data.products.duplicate()
		_:
			return {}

## Obtener stock disponible para venta (excluye agua para ingredientes)
func get_sellable_stock() -> Dictionary:
	var sellable = {
		"products": {},
		"ingredients": {}
	}

	if not game_data:
		return sellable

	# Productos disponibles
	for product_name in game_data.products.keys():
		var quantity = int(game_data.products[product_name])
		if quantity > 0:
			sellable.products[product_name] = {
				"quantity": quantity,
				"price": GameUtils.get_product_price(product_name),
				"emoji": GameUtils.get_item_emoji(product_name)
			}

	# Ingredientes disponibles (excepto agua)
	for ingredient_name in game_data.resources.keys():
		var quantity = int(game_data.resources[ingredient_name])
		if quantity > 0 and ingredient_name != "water":
			sellable.ingredients[ingredient_name] = {
				"quantity": quantity,
				"price": GameUtils.get_ingredient_price(ingredient_name),
				"emoji": GameUtils.get_item_emoji(ingredient_name)
			}

	return sellable

## === MODIFICACIONES DE STOCK ===

## Agregar stock
func add_stock(item_type: String, item_name: String, quantity: int) -> bool:
	if not game_data or quantity <= 0:
		return false

	var old_quantity = get_stock(item_type, item_name)
	var new_quantity = old_quantity + quantity

	match item_type:
		"ingredient", "resource":
			game_data.resources[item_name] = new_quantity
		"product":
			game_data.products[item_name] = new_quantity
		_:
			return false

	stock_updated.emit(item_type, item_name, new_quantity)
	return true

## Quitar stock
func remove_stock(item_type: String, item_name: String, quantity: int) -> bool:
	if not game_data or quantity <= 0:
		return false

	var current_stock = get_stock(item_type, item_name)
	if current_stock < quantity:
		print("❌ Stock insuficiente: %s tiene %d, se requieren %d" % [item_name, current_stock, quantity])
		return false

	var new_quantity = current_stock - quantity

	match item_type:
		"ingredient", "resource":
			game_data.resources[item_name] = new_quantity
		"product":
			game_data.products[item_name] = new_quantity
		_:
			return false

	stock_updated.emit(item_type, item_name, new_quantity)

	if new_quantity == 0:
		stock_depleted.emit(item_type, item_name)

	return true

## === UTILIDADES ===

## Verificar si hay stock suficiente
func has_stock(item_type: String, item_name: String, required_quantity: int = 1) -> bool:
	return get_stock(item_type, item_name) >= required_quantity

## Obtener información completa de un item
func get_item_info(item_type: String, item_name: String) -> Dictionary:
	var quantity = get_stock(item_type, item_name)
	var price = 0.0
	var emoji = GameUtils.get_item_emoji(item_name)

	match item_type:
		"ingredient", "resource":
			price = GameUtils.get_ingredient_price(item_name)
		"product":
			price = GameUtils.get_product_price(item_name)

	return {
		"name": item_name,
		"type": item_type,
		"quantity": quantity,
		"price": price,
		"emoji": emoji,
		"available": quantity > 0
	}

## Obtener resumen completo del inventario
func get_inventory_summary() -> Dictionary:
	var summary = {
		"total_products": 0,
		"total_ingredients": 0,
		"sellable_products": 0,
		"sellable_ingredients": 0,
		"total_value": 0.0
	}

	if not game_data:
		return summary

	# Contar productos
	for product_name in game_data.products.keys():
		var qty = int(game_data.products[product_name])
		summary.total_products += qty
		if qty > 0:
			summary.sellable_products += 1
			summary.total_value += qty * GameUtils.get_product_price(product_name)

	# Contar ingredientes
	for ingredient_name in game_data.resources.keys():
		var qty = int(game_data.resources[ingredient_name])
		summary.total_ingredients += qty
		if qty > 0 and ingredient_name != "water":
			summary.sellable_ingredients += 1
			summary.total_value += qty * GameUtils.get_ingredient_price(ingredient_name)

	return summary

## === GESTIÓN DE RECETAS ===

## Verificar si se puede costear una receta
func can_afford_recipe(recipe: Dictionary, quantity: int = 1) -> bool:
	for ingredient in recipe.keys():
		var needed = recipe[ingredient] * quantity
		var available = get_stock("ingredient", ingredient)
		if available < needed:
			return false
	return true

## Consumir ingredientes de una receta usando StockManager
func consume_recipe(recipe: Dictionary, quantity: int = 1) -> bool:
	if not can_afford_recipe(recipe, quantity):
		return false

	for ingredient in recipe.keys():
		var needed = recipe[ingredient] * quantity
		var removed = remove_stock("ingredient", ingredient, needed)
		if not removed:
			# Si falla, intentar revertir (aunque es poco probable)
			print("❌ ERROR: No se pudo consumir %s para receta" % ingredient)
			return false

	return true
