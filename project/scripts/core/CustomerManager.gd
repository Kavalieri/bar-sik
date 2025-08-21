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

## Sistema de múltiples clientes
var active_customers: int = 1  # Inicia con 1 cliente
var max_customers: int = 10  # Máximo 10 clientes
var base_customer_cost: int = 25  # Costo base en gems

## Definición de upgrades de clientes (actualizados para T006-T008)
var customer_upgrades: Array[Dictionary] = [
	{
		"id": "nuevo_cliente",
		"name": "👤 Nuevo Cliente",
		"description": "Añade un cliente al grupo de compradores automáticos",
		"cost": get_next_customer_cost(),  # Dinámico
		"currency": "gems",
		"required_key": "auto_sell_enabled"
	},
	{
		"id": "faster_customers",
		"name": "⚡ Clientes Más Rápidos",
		"description": "Reduce tiempo entre clientes en 25%",
		"cost": 100,
		"currency": "gems",
		"required_key": "faster_customers"
	},
	{
		"id": "premium_customers",
		"name": "👑 Clientes Premium",
		"description": "Los clientes pagan 50% más en tokens",
		"cost": 200,
		"currency": "gems",
		"required_key": "premium_customers"
	},
	{
		"id": "bulk_buyers",
		"name": "📦 Compradores Mayoristas",
		"description": "Los clientes pueden comprar 2-3 productos",
		"cost": 500,
		"currency": "gems",
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


## Habilitar/deshabilitar el sistema de clientes
func set_enabled(enabled: bool) -> void:
	"""Activar o desactivar el sistema completo"""
	if not game_data:
		print("❌ CustomerManager: GameData no disponible")
		return

	if enabled and game_data.customer_system_unlocked:
		# Habilitar auto_sell_enabled para que funcionen los timers
		game_data.upgrades["auto_sell_enabled"] = true
		_update_timer_settings()
		print("✅ CustomerManager habilitado - sistema activo")
	else:
		# Deshabilitar timers
		if customer_timer:
			customer_timer.stop()
		print("🔒 CustomerManager deshabilitado")


## Asignar referencia al ProductionManager
func set_production_manager(manager: ProductionManager) -> void:
	production_manager = manager
	_update_timer_settings()


## T025: Actualizar configuración del timer con frecuencias optimizadas
func _update_timer_settings() -> void:
	if not game_data or not customer_timer:
		return

	# T025: Nueva configuración de timing optimizada
	# Objetivo: 20-40 tokens/hora early game, escalado hasta 360 tokens/hora premium
	var base_time = 7.0  # Base mejorada (era 8.0s)

	# T025: Aplicar velocidad mejorada - Más impacto
	if game_data.upgrades.get("faster_customers", false):
		base_time *= 0.6  # 40% más rápido (era 25%)

	# T025: Efecto de múltiples clientes - Sistema mejorado
	# Con múltiples clientes, cada uno tiene su propio ciclo efectivo
	var client_efficiency = min(active_customers, 5)  # Cap en 5 para balance
	var effective_interval = base_time / client_efficiency

	# T025: Minimum interval para prevenir spam
	effective_interval = max(effective_interval, 2.0)  # Mínimo 2 segundos

	customer_timer.wait_time = effective_interval

	# Activar/desactivar timer según configuración
	if game_data.upgrades["auto_sell_enabled"] and not customer_timer.is_stopped():
		pass  # Ya está corriendo
	elif game_data.upgrades["auto_sell_enabled"]:
		customer_timer.start()
	else:
		customer_timer.stop()

	# T025: Logging mejorado con rates esperados
	var customers_per_minute = 60.0 / effective_interval
	var expected_tokens_per_hour = (
		customers_per_minute * 60.0 * _calculate_expected_tokens_per_customer()
	)

	print(
		(
			"⚡ T025 Timer: %d clientes, intervalo: %.2fs (%.1f clientes/min, ~%.0f tokens/hora)"
			% [active_customers, effective_interval, customers_per_minute, expected_tokens_per_hour]
		)
	)


## T025: Calcular tokens esperados por cliente (para estimaciones)
func _calculate_expected_tokens_per_customer() -> float:
	"""Calcular tokens promedio esperados por cliente según upgrades actuales"""
	if not game_data:
		return 1.0

	# Base: Asumiendo producto de ~$15 promedio
	var average_product_value = 15.0
	var base_tokens = average_product_value / 5.0  # $5 = 1 token

	# Aplicar upgrades
	if game_data.upgrades.get("bulk_buyers", false):
		base_tokens += 0.5  # Promedio 1.5 items por cliente

	if game_data.upgrades.get("premium_customers", false):
		base_tokens *= 1.6  # 60% bonus

	# Bonus por múltiples clientes
	if active_customers > 1:
		var multi_client_bonus = 1.0 + (active_customers - 1) * 0.1
		base_tokens *= multi_client_bonus

	return base_tokens


## T025: Obtener estadísticas de economía de tokens
func get_token_economy_stats() -> Dictionary:
	"""Retornar estadísticas detalladas de la economía de tokens"""
	if not game_data or not customer_timer:
		return {}

	var customers_per_minute = (
		60.0 / customer_timer.wait_time if customer_timer.wait_time > 0 else 0.0
	)
	var tokens_per_customer = _calculate_expected_tokens_per_customer()
	var tokens_per_hour = customers_per_minute * 60.0 * tokens_per_customer

	return {
		"active_customers": active_customers,
		"timer_interval": customer_timer.wait_time,
		"customers_per_minute": customers_per_minute,
		"tokens_per_customer_avg": tokens_per_customer,
		"tokens_per_hour_estimated": tokens_per_hour,
		"upgrades":
		{
			"premium_customers": game_data.upgrades.get("premium_customers", false),
			"bulk_buyers": game_data.upgrades.get("bulk_buyers", false),
			"faster_customers": game_data.upgrades.get("faster_customers", false)
		},
		"performance_tier": _get_performance_tier(tokens_per_hour)
	}


## T025: Categorizar tier de performance
func _get_performance_tier(tokens_per_hour: float) -> String:
	"""Determinar el tier de performance basado en tokens/hora"""
	if tokens_per_hour < 50:
		return "Basic (Early Game)"
	elif tokens_per_hour < 150:
		return "Improved (Mid Game)"
	elif tokens_per_hour < 300:
		return "Advanced (Late Game)"
	else:
		return "Premium (Endgame)"


## T024: Calcular costo del próximo cliente con nuevo escalado
func get_next_customer_cost() -> int:
	"""Calcular costo escalado usando sistema T024"""
	# Usar el nuevo sistema de escalado para customers
	var cost = GameUtils.get_scaled_cost(
		float(base_customer_cost), active_customers + 1, "customer"
	)
	return int(cost)


## T006: Comprar nuevo cliente
func purchase_new_customer() -> bool:
	"""Comprar un cliente adicional usando gems"""
	if not game_data:
		print("❌ GameData no disponible")
		return false

	if active_customers >= max_customers:
		print("❌ Máximo de clientes alcanzado (%d/%d)" % [active_customers, max_customers])
		return false

	var cost = get_next_customer_cost()
	if not game_data.spend_gems(cost):
		print("❌ Gems insuficientes para comprar cliente (costo: %d)" % cost)
		return false

	active_customers += 1
	_update_timer_settings()  # Acelerar timer con más clientes

	print(
		"✅ Nuevo cliente! Activos: %d/%d (costo: %d gems)" % [active_customers, max_customers, cost]
	)
	return true


## T006: Obtener info de clientes
func get_customer_info() -> Dictionary:
	"""Obtener información sobre clientes para UI"""
	return {
		"active": active_customers,
		"max": max_customers,
		"next_cost": get_next_customer_cost() if active_customers < max_customers else -1,
		"can_buy_more": active_customers < max_customers
	}


## Procesar llegada de cliente automático
func _process_automatic_customer() -> void:
	if not game_data or not game_data.upgrades["auto_sell_enabled"]:
		return

	# Encontrar productos disponibles CON OFERTA HABILITADA
	var available_products = []
	var station_definitions = []
	if production_manager:
		station_definitions = production_manager.get_station_definitions()

	# Usar StockManager para obtener productos disponibles
	if not StockManager:
		print("❌ StockManager no disponible")
		return

	var sellable_stock = StockManager.get_sellable_stock()
	var products_stock = sellable_stock.get("products", {})

	for product_type in products_stock.keys():
		var stock_quantity = StockManager.get_stock("product", product_type)
		if stock_quantity > 0:
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
				print(
					(
						"🛒 Producto disponible: %s (stock: %d, con oferta)"
						% [product_type, stock_quantity]
					)
				)

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

	print(
		"💰 Cliente comprando %s por $%.2f (x%.2f)" % [chosen_product, final_price, price_multiplier]
	)

	# Determinar cantidad (bulk buyers pueden comprar más)
	var max_quantity = StockManager.get_stock("product", chosen_product)
	var quantity = 1
	if game_data.upgrades.get("bulk_buyers", false):
		quantity = randi_range(1, min(3, max_quantity))

	# Procesar la venta usando StockManager
	var removed = StockManager.remove_stock("product", chosen_product, quantity)
	if not removed:
		print("❌ ERROR: No se pudo remover stock para venta automática")
		return

	# T025: REBALANCE DE ECONOMÍA DE TOKENS - Sistema optimizado
	var total_earned = final_price * quantity

	# T025: Nueva conversión mejorada - Rate base más generoso
	# Objetivo: 1-2 tokens por cliente, escalado con upgrades
	var base_tokens = max(1, int(total_earned / 5.0))  # $5 = 1 token (era $10 = 1 token)

	# T025: Bonus base por cliente múltiple (bulk buyers)
	if game_data.upgrades.get("bulk_buyers", false) and quantity > 1:
		base_tokens += (quantity - 1)  # +1 token por item extra

	# T025: Aplicar bonus de clientes premium - Mejorado
	if game_data.upgrades.get("premium_customers", false):
		base_tokens = int(base_tokens * 1.6)  # 60% más tokens (era 50%)

	# T025: Bonus adicional por múltiples clientes activos
	if active_customers > 1:
		var multi_client_bonus = 1.0 + (active_customers - 1) * 0.1  # +10% por cliente extra
		base_tokens = int(base_tokens * multi_client_bonus)

	# T014: Aplicar bonus de prestigio (no modificado)
	var prestige_token_multiplier = game_data.get("prestige_customer_token_multiplier", 1.0)
	if prestige_token_multiplier > 1.0:
		base_tokens = int(base_tokens * prestige_token_multiplier)
		print("  ⭐ Prestigio customer bonus: x%.2f tokens" % prestige_token_multiplier)

	# Agregar tokens al GameData directamente
	game_data.add_tokens(base_tokens)

	# Actualizar estadísticas usando método de GameData (T013 - Prestigio)
	game_data.add_money(total_earned)  # Trackea total_cash_earned automáticamente
	game_data.statistics["products_sold"] += quantity
	game_data.statistics["customers_served"] += 1

	print(
		(
			"✅ Cliente pagó %d tokens por %d %s ($%.2f valor)"
			% [base_tokens, quantity, chosen_product, total_earned]
		)
	)

	# Determinar tipo de cliente
	var customer_type = "Cliente Normal"
	if game_data.upgrades.get("premium_customers", false):
		customer_type = "Cliente Premium"

	var products_bought = []
	for i in quantity:
		products_bought.append(chosen_product)

	customer_served.emit(customer_type, products_bought, total_earned)


## T008: Comprar upgrade de cliente con gems
func purchase_upgrade(upgrade_id: String) -> bool:
	if not game_data:
		print("❌ GameData no disponible")
		return false

	var upgrade_def = _find_upgrade_by_id(upgrade_id)
	if not upgrade_def:
		print("❌ Upgrade no encontrado: %s" % upgrade_id)
		return false

	# Manejar upgrade especial de nuevo cliente
	if upgrade_id == "nuevo_cliente":
		return purchase_new_customer()  # Usa el método específico T006

	# Verificar condiciones para compra
	if game_data.upgrades.get(upgrade_def.required_key, false):
		print("❌ Upgrade ya comprado: %s" % upgrade_id)
		return false

	var cost = upgrade_def.cost
	if not game_data.spend_gems(cost):
		print("❌ Gems insuficientes para %s (costo: %d)" % [upgrade_def.name, cost])
		return false

	# Procesar compra exitosa
	game_data.upgrades[upgrade_def.required_key] = true
	_apply_upgrade_effects(upgrade_id)
	upgrade_purchased.emit(upgrade_id, cost)
	print("✅ Upgrade comprado: %s por %d gems" % [upgrade_def.name, cost])
	return true


## Aplicar efectos específicos de upgrades
func _apply_upgrade_effects(upgrade_id: String) -> void:
	match upgrade_id:
		"faster_customers":
			_update_timer_settings()
			print("⚡ Clientes 25% más rápidos activado")
		"premium_customers":
			print("👑 Clientes premium activado (+50% tokens)")
		"bulk_buyers":
			print("📦 Compradores mayoristas activado (2-3 productos)")
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
