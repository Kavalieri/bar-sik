extends Node
class_name CustomerManager
## CustomerManager - Gestión centralizada de clientes automáticos
## Sistema de autoventa con upgrades y temporizadores

signal customer_served(customer_type: String, products_bought: Array, total_earned: float)
signal upgrade_purchased(upgrade_id: String, cost: float)

var game_data: GameData
var production_manager: ProductionManager  # Referencia para acceder a definiciones de estaciones
var customer_timer: Timer
var customer_timer_progress: float = 0.0

## Definición de upgrades de clientes
var customer_upgrades: Array[Dictionary] = [
	{
		"id": "nuevo_cliente",
		"name": "👤 Nuevo Cliente",
		"description": "Añade un cliente al grupo de compradores automáticos",
		"cost": 100.0,
		"required_key": "auto_sell_enabled"
	},
	{
		"id": "faster_customers",
		"name": "⚡ Clientes Más Rápidos",
		"description": "Reduce tiempo entre clientes en 40%",
		"cost": 500.0,
		"required_key": "faster_customers"
	},
	{
		"id": "premium_customers",
		"name": "👑 Clientes Premium",
		"description": "Los clientes pagan 50% más por los productos",
		"cost": 1000.0,
		"required_key": "premium_customers"
	},
	{
		"id": "bulk_buyers",
		"name": "📦 Compradores Mayoristas",
		"description": "Los clientes pueden comprar hasta 3 productos",
		"cost": 2500.0,
		"required_key": "bulk_buyers"
	}
]

func _ready() -> void:
	print("👥 CustomerManager inicializado")
	_setup_customer_timer()

func _process(_delta: float) -> void:
	# Actualizar progreso del timer si está activo
	if customer_timer and game_data and game_data.upgrades["auto_sell_enabled"]:
		customer_timer_progress = 1.0 - (customer_timer.time_left / customer_timer.wait_time)
		customer_timer_progress = clamp(customer_timer_progress, 0.0, 1.0)

## Configurar timer de clientes automáticos
func _setup_customer_timer() -> void:
	customer_timer = Timer.new()
	customer_timer.wait_time = 8.0
	customer_timer.autostart = false  # Solo activar cuando se compre el primer upgrade
	customer_timer.timeout.connect(_process_automatic_customer)
	add_child(customer_timer)

## Asignar datos del juego
func set_game_data(data: GameData) -> void:
	game_data = data

## Asignar referencia al ProductionManager
func set_production_manager(manager: ProductionManager) -> void:
	production_manager = manager
	_update_timer_settings()

## Actualizar configuración del timer según upgrades
func _update_timer_settings() -> void:
	if not game_data or not customer_timer:
		return

	var base_time = 8.0

	# Aplicar velocidad mejorada
	if game_data.upgrades.get("faster_customers", false):
		base_time *= 0.6  # 40% más rápido

	customer_timer.wait_time = base_time

	# Activar/desactivar timer según si está habilitada la autoventa
	if game_data.upgrades["auto_sell_enabled"] and not customer_timer.is_stopped():
		pass  # Ya está corriendo
	elif game_data.upgrades["auto_sell_enabled"]:
		customer_timer.start()
	else:
		customer_timer.stop()

## Procesar llegada de cliente automático
func _process_automatic_customer() -> void:
	if not game_data or not game_data.upgrades["auto_sell_enabled"]:
		return

	# Encontrar productos disponibles CON OFERTA HABILITADA
	var available_products = []
	var station_definitions = production_manager.get_station_definitions() if production_manager else []
	
	for product_type in game_data.products.keys():
		if game_data.products[product_type] > 0:
			# Verificar si hay alguna estación que produzca este producto y tenga oferta habilitada
			var has_offer = false
			for station_def in station_definitions:
				if station_def.get("produces", "") == product_type:
					var station_id = station_def.id
					var offer_enabled = game_data.offers.get(station_id, {}).get("enabled", false)
					if offer_enabled:
						has_offer = true
						break
			
			if has_offer:
				available_products.append(product_type)
				print("🛒 Producto disponible para clientes: %s (con oferta)" % product_type)

	if available_products.is_empty():
		print("❌ No hay productos con ofertas habilitadas")
		return

	# Elegir producto al azar de los que tienen oferta
	var chosen_product = available_products[randi() % available_products.size()]
	var base_price = GameUtils.get_product_price(chosen_product)
	
	# Aplicar multiplicador de precio de la oferta
	var price_multiplier = 1.0
	for station_def in station_definitions:
		if station_def.get("produces", "") == chosen_product:
			var station_id = station_def.id
			price_multiplier = game_data.offers.get(station_id, {}).get("price_multiplier", 1.0)
			break
	
	var final_price = base_price * price_multiplier

	# Aplicar bonus de clientes premium
	if game_data.upgrades.get("premium_customers", false):
		final_price *= 1.5  # 50% más

	print("💰 Cliente comprando %s por $%.2f (multiplicador: %.2f)" % [chosen_product, final_price, price_multiplier])

	# Determinar cantidad (bulk buyers pueden comprar más)
	var max_quantity = game_data.products[chosen_product]
	var quantity = 1
	if game_data.upgrades.get("bulk_buyers", false):
		quantity = randi_range(1, min(3, max_quantity))

	# Procesar la venta
	var total_earned = final_price * quantity
	game_data.money += total_earned
	game_data.statistics["total_money_earned"] += total_earned
	game_data.statistics["products_sold"] += quantity
	game_data.statistics["customers_served"] += 1
	game_data.products[chosen_product] -= quantity

	# Determinar tipo de cliente
	var customer_type = "Cliente Normal"
	if game_data.upgrades.get("premium_customers", false):
		customer_type = "Cliente Premium"

	var products_bought = []
	for i in quantity:
		products_bought.append(chosen_product)

	customer_served.emit(customer_type, products_bought, total_earned)

## Comprar upgrade de cliente
func purchase_upgrade(upgrade_id: String) -> bool:
	if not game_data:
		return false

	var upgrade_def = _find_upgrade_by_id(upgrade_id)
	if not upgrade_def:
		return false

	# Verificar si ya se tiene el upgrade
	if game_data.upgrades.get(upgrade_def.required_key, false):
		return false

	# Verificar dinero
	if game_data.money < upgrade_def.cost:
		return false

	# Procesar compra
	game_data.money -= upgrade_def.cost
	game_data.upgrades[upgrade_def.required_key] = true

	# Aplicar efectos específicos del upgrade
	match upgrade_id:
		"nuevo_cliente":
			game_data.upgrades["auto_sell_enabled"] = true
			customer_timer.start()
		"faster_customers":
			_update_timer_settings()

	upgrade_purchased.emit(upgrade_id, upgrade_def.cost)
	return true

## Obtener upgrades disponibles
func get_available_upgrades() -> Array[Dictionary]:
	if not game_data:
		return []

	var available = []
	for upgrade_def in customer_upgrades:
		var has_upgrade = game_data.upgrades.get(upgrade_def.required_key, false)
		if not has_upgrade:
			available.append(upgrade_def)

	return available

## Verificar si se puede comprar un upgrade
func can_purchase_upgrade(upgrade_id: String) -> bool:
	if not game_data:
		return false

	var upgrade_def = _find_upgrade_by_id(upgrade_id)
	if not upgrade_def:
		return false

	var has_upgrade = game_data.upgrades.get(upgrade_def.required_key, false)
	var can_afford = game_data.money >= upgrade_def.cost

	return not has_upgrade and can_afford

## Obtener progreso del timer de clientes
func get_timer_progress() -> float:
	return customer_timer_progress

## Obtener tiempo restante del timer
func get_timer_remaining() -> float:
	if customer_timer:
		return customer_timer.time_left
	return 0.0

## Encontrar upgrade por ID
func _find_upgrade_by_id(upgrade_id: String) -> Dictionary:
	for upgrade_def in customer_upgrades:
		if upgrade_def.id == upgrade_id:
			return upgrade_def
	return {}

## Obtener estadísticas de clientes
func get_customer_stats() -> Dictionary:
	if not game_data:
		return {}

	var stats = {
		"customers_served": game_data.statistics.get("customers_served", 0),
		"autosell_earnings": game_data.statistics.get("total_money_earned", 0),
		"frequency": customer_timer.wait_time if customer_timer else 8.0,
		"auto_sell_enabled": game_data.upgrades.get("auto_sell_enabled", false)
	}

	return stats
