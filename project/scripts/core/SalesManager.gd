extends Node
class_name SalesManager
## SalesManager - Gestión centralizada de ventas (Sistema Modular)
## Usa StockManager para operaciones de inventario

signal item_sold(item_type: String, item_name: String, quantity: int, total_earned: float)

var game_data: GameData


func _ready() -> void:
	print("💰 SalesManager inicializado - Sistema modular")


## Asignar datos del juego
func set_game_data(data: GameData) -> void:
	game_data = data


## Vender producto o ingrediente usando StockManager
func sell_item(item_type: String, item_name: String, quantity: int) -> bool:
	print("� SalesManager.sell_item() - Sistema modular:")
	print("   - Tipo: %s, Item: %s, Cantidad: %d" % [item_type, item_name, quantity])

	if not game_data:
		print("❌ ERROR: game_data es null")
		return false

	if not StockManager:
		print("❌ ERROR: StockManager no disponible")
		return false

	# Verificar stock disponible usando StockManager
	var available_stock = StockManager.get_stock(item_type, item_name)
	print("   - Stock disponible: %d" % available_stock)

	if available_stock <= 0:
		print("❌ No hay stock disponible")
		return false

	# Calcular cantidad real a vender
	var actual_quantity = min(quantity, available_stock)
	print("   - Vendiendo: %d unidades" % actual_quantity)

	# Obtener precio
	var price = get_item_price(item_type, item_name)
	var total_earned = actual_quantity * price
	print("   - Precio unitario: $%.2f, Total: $%.2f" % [price, total_earned])

	# Remover stock usando StockManager
	var removed = StockManager.remove_stock(item_type, item_name, actual_quantity)
	if not removed:
		print("❌ ERROR: No se pudo remover stock")
		return false

	# Actualizar dinero y estadísticas
	game_data.money += total_earned
	game_data.statistics["total_money_earned"] += total_earned

	if item_type == "product":
		game_data.statistics["products_sold"] += actual_quantity

	print("   - ✅ Venta completada. Dinero: $%.2f" % game_data.money)

	# Emitir señal
	item_sold.emit(item_type, item_name, actual_quantity, total_earned)
	return true


## Obtener precio de un ítem
func get_item_price(item_type: String, item_name: String) -> float:
	if item_type == "product":
		return GameUtils.get_product_price(item_name)
	if item_type == "ingredient" or item_type == "resource":
		return GameUtils.get_ingredient_price(item_name)
	return 0.0


## Verificar si un ítem se puede vender usando StockManager
func can_sell_item(item_type: String, item_name: String, quantity: int = 1) -> bool:
	if not StockManager:
		return false
	return StockManager.get_stock(item_type, item_name) >= quantity


## Obtener inventario disponible para venta desde StockManager
func get_sellable_inventory() -> Dictionary:
	if not StockManager:
		return {"products": {}, "ingredients": {}}

	return StockManager.get_sellable_stock()

## Obtener datos actuales del juego (compatibilidad con SalesPanelBasic)
func get_game_data() -> Dictionary:
	"""Obtener datos actuales del juego para SalesPanelBasic"""
	if not game_data:
		return {
			"money": 0.0,
			"resources": {},
			"products": {}
		}

	return {
		"money": game_data.money,
		"resources": game_data.resources.duplicate(),
		"products": game_data.products.duplicate()
	}
