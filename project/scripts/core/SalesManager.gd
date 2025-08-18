extends Node
class_name SalesManager
## SalesManager - Gestión centralizada de ventas
## Manejo de ventas manuales e inventario

signal item_sold(item_type: String, item_name: String, quantity: int, total_earned: float)

var game_data: GameData

func _ready() -> void:
	print("💰 SalesManager inicializado")

## Asignar datos del juego
func set_game_data(data: GameData) -> void:
	game_data = data

## Vender producto o ingrediente
func sell_item(item_type: String, item_name: String, quantity: int) -> bool:
	print("🔥 SalesManager.sell_item() llamado:")
	print("   - Tipo: %s, Item: %s, Cantidad: %d" % [item_type, item_name, quantity])
	print("   - game_data válido: %s" % (game_data != null))

	if not game_data:
		print("❌ ERROR: game_data es null")
		return false
	
	# DEBUGGING: Mostrar estado completo del inventory
	print("   - 📦 Estado actual del inventario:")
	print("     • Productos: %s" % game_data.products)
	print("     • Recursos: %s" % game_data.resources)
	print("     • Dinero actual: $%.2f" % game_data.money)

	var available = 0
	var price = 0.0

	if item_type == "product":
		available = game_data.products.get(item_name, 0)
		price = GameUtils.get_product_price(item_name)
		print("   - Producto: %s disponible, precio: $%.2f" % [available, price])
	elif item_type == "ingredient":
		available = game_data.resources.get(item_name, 0)
		price = GameUtils.get_ingredient_price(item_name)
		print("   - Ingrediente: %s disponible, precio: $%.2f" % [available, price])
	else:
		print("❌ ERROR: Tipo de item desconocido: %s" % item_type)
		return false

	# Verificar disponibilidad
	var actual_quantity = min(quantity, available)
	print("   - Cantidad solicitada: %d, disponible: %d, vendiendo: %d" % [quantity, available, actual_quantity])

	if actual_quantity <= 0:
		print("❌ ERROR: No hay cantidad disponible para vender")
		return false

	var total_earned = actual_quantity * price
	print("   - Total ganado: $%.2f" % total_earned)

	# Actualizar inventario
	if item_type == "product":
		game_data.products[item_name] -= actual_quantity
		game_data.statistics["products_sold"] += actual_quantity
		print("   - ✅ Producto vendido. Nuevo inventario: %d" % game_data.products[item_name])
	elif item_type == "ingredient":
		game_data.resources[item_name] -= actual_quantity
		print("   - ✅ Ingrediente vendido. Nuevo inventario: %d" % game_data.resources[item_name])

	# Actualizar dinero y estadísticas
	game_data.money += total_earned
	game_data.statistics["total_money_earned"] += total_earned
	print("   - ✅ Dinero actualizado: $%.2f" % game_data.money)

	item_sold.emit(item_type, item_name, actual_quantity, total_earned)
	print("   - ✅ Señal item_sold emitida")
	return true

## Obtener precio de un ítem
func get_item_price(item_type: String, item_name: String) -> float:
	if item_type == "product":
		return GameUtils.get_product_price(item_name)
	elif item_type == "ingredient":
		return GameUtils.get_ingredient_price(item_name)
	return 0.0

## Verificar si un ítem se puede vender
func can_sell_item(item_type: String, item_name: String, quantity: int = 1) -> bool:
	if not game_data:
		return false

	var available = 0
	if item_type == "product":
		available = game_data.products.get(item_name, 0)
	elif item_type == "ingredient":
		available = game_data.resources.get(item_name, 0)

	return available >= quantity

## Obtener inventario disponible para venta
func get_sellable_inventory() -> Dictionary:
	if not game_data:
		return {"products": {}, "ingredients": {}}

	var sellable = {
		"products": {},
		"ingredients": {}
	}

	# Productos disponibles
	for product_name in game_data.products.keys():
		var quantity = game_data.products[product_name]
		if quantity > 0:
			sellable.products[product_name] = {
				"quantity": quantity,
				"price": GameUtils.get_product_price(product_name),
				"icon": GameUtils.get_product_icon(product_name)
			}

	# Ingredientes disponibles (excepto agua que no se vende)
	for ingredient_name in game_data.resources.keys():
		var quantity = game_data.resources[ingredient_name]
		if quantity > 0 and ingredient_name != "water":
			sellable.ingredients[ingredient_name] = {
				"quantity": quantity,
				"price": GameUtils.get_ingredient_price(ingredient_name),
				"icon": GameUtils.get_resource_icon(ingredient_name)
			}

	return sellable
