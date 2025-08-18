extends Node
## GameManager - Singleton global para acceso a managers
## Facilita comunicación entre sistemas sin dependencias circulares

# Referencias globales a managers (se asignan desde GameController)
var generator_manager: GeneratorManager
var production_manager: ProductionManager
var sales_manager: SalesManager
var customer_manager: CustomerManager
var game_data: GameData

## Registrar managers (llamado desde GameController)
func register_managers(
	gen_mgr: GeneratorManager,
	prod_mgr: ProductionManager,
	sales_mgr: SalesManager,
	customer_mgr: CustomerManager,
	data: GameData
) -> void:
	generator_manager = gen_mgr
	production_manager = prod_mgr
	sales_manager = sales_mgr
	customer_manager = customer_mgr
	game_data = data

	print("🌐 GameManager: Managers registrados globalmente")

## === ACCESO RÁPIDO A DATOS COMUNES ===

func get_money() -> float:
	return game_data.money if game_data else 0.0

func get_resource(resource_name: String) -> int:
	return game_data.resources.get(resource_name, 0) if game_data else 0

func get_product(product_name: String) -> int:
	return game_data.products.get(product_name, 0) if game_data else 0

func has_upgrade(upgrade_name: String) -> bool:
	return game_data.upgrades.get(upgrade_name, false) if game_data else false

## === ACCIONES RÁPIDAS ===

func quick_sell_all_products() -> float:
	if not sales_manager or not game_data or not StockManager:
		return 0.0

	var total_earned = 0.0
	var sellable_stock = StockManager.get_sellable_stock()
	var products_stock = sellable_stock.get("products", {})

	for product_name in products_stock.keys():
		var quantity = StockManager.get_stock("product", product_name)
		if quantity > 0:
			if sales_manager.sell_item("product", product_name, quantity):
				total_earned += quantity * GameUtils.get_product_price(product_name)
				var earned = quantity * GameUtils.get_product_price(product_name)
				print("💰 Quick-sell: %dx %s por $%.2f" % [quantity, product_name, earned])

	return total_earned

func can_craft_recipe(recipe: Dictionary) -> bool:
	if not game_data or not StockManager:
		return false

	return StockManager.can_afford_recipe(recipe)

## === DEBUG Y DESARROLLO ===

func debug_add_money(amount: float) -> void:
	if game_data:
		game_data.money += amount
		print("🐛 DEBUG: Añadido $%.0f (Total: $%.0f)" % [amount, game_data.money])

func debug_add_resources(resource_name: String, amount: int) -> void:
	if game_data and StockManager:
		StockManager.add_stock("ingredient", resource_name, amount)
		print("🐛 DEBUG: Añadido %dx %s (usando StockManager)" % [amount, resource_name])
	else:
		print("❌ DEBUG: GameManager o StockManager no disponible")

func debug_unlock_all_stations() -> void:
	if production_manager:
		for station_def in production_manager.get_station_definitions():
			station_def.unlocked = true
		print("🐛 DEBUG: Todas las estaciones desbloqueadas")

## === INFORMACIÓN DE ESTADO ===

func get_game_stats() -> Dictionary:
	if not game_data:
		return {}

	return {
		"money": game_data.money,
		"total_resources": _count_total_resources(),
		"total_products": _count_total_products(),
		"total_generators": _count_total_generators(),
		"total_stations": _count_total_stations(),
		"upgrades_owned": _count_upgrades_owned()
	}

func _count_total_resources() -> int:
	var total = 0
	for amount in game_data.resources.values():
		total += amount
	return total

func _count_total_products() -> int:
	var total = 0
	for amount in game_data.products.values():
		total += amount
	return total

func _count_total_generators() -> int:
	var total = 0
	for amount in game_data.generators.values():
		total += amount
	return total

func _count_total_stations() -> int:
	var total = 0
	for amount in game_data.stations.values():
		total += amount
	return total

func _count_upgrades_owned() -> int:
	var total = 0
	for owned in game_data.upgrades.values():
		if owned:
			total += 1
	return total
