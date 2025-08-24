class_name AutomationManager
extends Node

## T020-T021 - Sistema de Automatización Avanzada
## Auto-producción inteligente (T020) + Auto-venta inteligente (T021)

# Señales para notificar eventos de automatización
signal auto_production_started(station_id: String, product: String, amount: int)  # T020
signal auto_sell_triggered(product: String, amount: int, earnings: float)  # T021
signal automation_config_changed(setting: String, enabled: bool)  # T021

# Referencia a GameData y otros managers
var game_data: GameData
var production_manager: ProductionManager
var sales_manager: SalesManager

# Configuración de automatización
var auto_production_enabled: Dictionary = {}  # Por estación
var auto_sell_enabled: Dictionary = {}  # Por producto
var smart_production_priority: bool = true  # Producir lo más rentable primero
var auto_sell_threshold: float = 0.8  # Vender cuando storage > 80%

# Cache para optimización
var last_production_check: float = 0.0
var last_sell_check: float = 0.0
var production_check_interval: float = 2.0  # Verificar cada 2 segundos
var sell_check_interval: float = 1.0  # Verificar cada segundo

# Configuraciones por defecto
var default_auto_production_stations: Array[String] = ["brewery", "bar_station", "distillery"]
var default_auto_sell_products: Array[String] = ["beer", "cocktail", "whiskey"]


func _ready():
	print("🤖 AutomationManager inicializado")
	_init_default_settings()


func set_game_data(data: GameData) -> void:
	"""Asignar referencia a GameData"""
	game_data = data
	print("🤖 AutomationManager conectado con GameData")


func set_managers(prod_manager: ProductionManager, sale_manager: SalesManager) -> void:
	"""Asignar referencias a otros managers"""
	production_manager = prod_manager
	sales_manager = sale_manager
	print("🤖 AutomationManager conectado con ProductionManager y SalesManager")


func _init_default_settings():
	"""Inicializar configuraciones por defecto"""
	# Auto-producción deshabilitada por defecto para todas las estaciones
	for station_id in default_auto_production_stations:
		auto_production_enabled[station_id] = false

	# Auto-venta deshabilitada por defecto para todos los productos
	for product_id in default_auto_sell_products:
		auto_sell_enabled[product_id] = false

	print("🤖 Configuraciones de automatización inicializadas")


func _process(delta):
	"""Proceso principal de automatización"""
	var current_time = Time.get_ticks_msec() / 1000.0

	# Verificar auto-producción
	if current_time - last_production_check > production_check_interval:
		_process_auto_production()
		last_production_check = current_time

	# Verificar auto-venta
	if current_time - last_sell_check > sell_check_interval:
		_process_auto_sell()
		last_sell_check = current_time


# =============================================================================
# AUTO-PRODUCTION SYSTEM - T020
# =============================================================================


func _process_auto_production():
	"""Procesar auto-producción inteligente"""
	if not production_manager or not game_data:
		return

	var stations_to_produce = _get_production_queue()

	for station_data in stations_to_produce:
		var station_id = station_data.station_id
		var product = station_data.product

		if _can_auto_produce(station_id, product):
			_trigger_auto_production(station_id, product)


func _get_production_queue() -> Array:
	"""Obtener cola de producción ordenada por prioridad"""
	var queue = []

	# Recopilar todas las estaciones habilitadas
	for station_id in auto_production_enabled:
		if not auto_production_enabled[station_id]:
			continue

		if not game_data.stations.has(station_id) or game_data.stations[station_id] <= 0:
			continue

		var product = _get_station_product(station_id)
		if product.is_empty():
			continue

		var priority_score = _calculate_production_priority(station_id, product)

		queue.append({"station_id": station_id, "product": product, "priority": priority_score})

	# Ordenar por prioridad si está habilitado
	if smart_production_priority:
		queue.sort_custom(_compare_production_priority)

	return queue


func _compare_production_priority(a: Dictionary, b: Dictionary) -> bool:
	"""Comparar prioridad de producción (mayor prioridad primero)"""
	return a.priority > b.priority


func _calculate_production_priority(station_id: String, product: String) -> float:
	"""Calcular prioridad de producción basada en rentabilidad y demanda"""
	var priority: float = 0.0

	# Factor 1: Rentabilidad (precio de venta vs costo de recursos)
	var product_price = _get_product_base_price(product)
	var production_cost = _get_production_cost(station_id)
	var profit_margin = (product_price - production_cost) / max(1.0, production_cost)
	priority += profit_margin * 100.0

	# Factor 2: Nivel de stock (menos stock = mayor prioridad)
	var current_stock = StockManager.get_stock("product", product)
	var max_stock = _get_max_product_storage(product)
	var stock_ratio = float(current_stock) / max(1.0, float(max_stock))
	priority += (1.0 - stock_ratio) * 50.0

	# Factor 3: Oferta activa (productos con oferta tienen mayor prioridad)
	if _has_active_offer(product):
		var offer_multiplier = _get_offer_multiplier(product)
		priority += offer_multiplier * 25.0

	return priority


func _can_auto_produce(station_id: String, product: String) -> bool:
	"""Verificar si se puede auto-producir en una estación"""
	# Verificar si la estación está habilitada para auto-producción
	if not auto_production_enabled.get(station_id, false):
		return false

	# Verificar si hay espacio en el almacenamiento
	var current_stock = StockManager.get_stock("product", product)
	var max_stock = _get_max_product_storage(product)
	if current_stock >= max_stock * auto_sell_threshold:  # No producir si >80% lleno
		return false

	# Verificar si hay recursos suficientes
	if not _has_sufficient_resources(station_id):
		return false

	return true


func _trigger_auto_production(station_id: String, product: String):
	"""Ejecutar auto-producción"""
	if production_manager and production_manager.has_method("manual_production"):
		var success = production_manager.manual_production(station_id, 1)
		if success:
			auto_production_started.emit(station_id, product, 1)
			print("🤖 Auto-producción: %s en %s" % [product, station_id])


func _has_sufficient_resources(station_id: String) -> bool:
	"""Verificar si hay recursos suficientes para producir"""
	var recipe = _get_station_recipe(station_id)
	if recipe.is_empty():
		return false

	for resource_type in recipe:
		var required = recipe[resource_type]
		var available = StockManager.get_stock("resource", resource_type)
		if available < required:
			return false

	return true


# =============================================================================
# AUTO-SELL SYSTEM - T021
# =============================================================================


func _process_auto_sell():
	"""Procesar auto-venta inteligente"""
	if not sales_manager or not game_data:
		return

	for product in auto_sell_enabled:
		if not auto_sell_enabled[product]:
			continue

		if _should_auto_sell(product):
			_trigger_auto_sell(product)


func _should_auto_sell(product: String) -> bool:
	"""Determinar si se debe vender automáticamente un producto - T021 SMART AUTO-SELL"""
	# Verificar nivel de stock
	var current_stock = StockManager.get_stock("product", product)
	var max_stock = _get_max_product_storage(product)
	var stock_ratio = float(current_stock) / max(1.0, float(max_stock))

	# T021 CRITERIO 1: Solo vender si inventario casi lleno (>90% por defecto)
	var sell_threshold = _get_smart_sell_threshold(product)
	if stock_ratio < sell_threshold:
		return false

	# Solo vender si hay stock suficiente
	if current_stock <= 0:
		return false

	# T021 CRITERIO 2: Smart pricing - no vender si precio está muy bajo
	var price_score = _calculate_price_attractiveness(product)
	if price_score < 1.2:  # Solo vender si precio es al menos 20% mejor que base
		return false

	# T021 CRITERIO 3: Verificar si hay oferta activa (mejorado)
	if not _has_profitable_offer(product):
		return false

	return true


func _trigger_auto_sell(product: String):
	"""Ejecutar auto-venta - T021 SMART BATCH SELLING"""
	var current_stock = StockManager.get_stock("product", product)
	if current_stock <= 0:
		return

	# T021 MEJORA: Cantidad inteligente basada en demanda y stock
	var amount_to_sell = _calculate_smart_sell_quantity(product, current_stock)

	if sales_manager and sales_manager.has_method("sell_product"):
		var earnings = sales_manager.sell_product(product, amount_to_sell)
		if earnings > 0:
			auto_sell_triggered.emit(product, amount_to_sell, earnings)
			print(
				(
					"🤖 Auto-venta SMART: %dx %s por $%.2f (%.1fx multiplicador)"
					% [amount_to_sell, product, earnings, _get_offer_multiplier(product)]
				)
			)


# =============================================================================
# T021 - SMART AUTO-SELL FUNCTIONS
# =============================================================================


func _get_smart_sell_threshold(product: String) -> float:
	"""Obtener threshold personalizado por producto"""
	# Productos con alta demanda pueden tener threshold menor
	var base_threshold = 0.9  # 90% por defecto

	# Ajustar según ofertas activas
	var offer_multiplier = _get_offer_multiplier(product)
	if offer_multiplier >= 2.0:  # Ofertas muy buenas
		base_threshold = 0.7  # Vender antes (70%)
	elif offer_multiplier >= 1.5:  # Ofertas buenas
		base_threshold = 0.8  # Vender antes (80%)

	return base_threshold


func _calculate_price_attractiveness(product: String) -> float:
	"""Calcular qué tan atractivo es el precio actual"""
	var base_price = _get_base_product_price(product)
	var current_multiplier = _get_offer_multiplier(product)

	# Considerar también la demanda de clientes
	var demand_factor = _get_customer_demand_factor(product)

	return current_multiplier * demand_factor


func _has_profitable_offer(product: String) -> bool:
	"""Verificar si hay una oferta rentable activa"""
	var offer_multiplier = _get_offer_multiplier(product)
	var min_profitable_multiplier = 1.2  # Al menos 20% de ganancia extra

	# Ajustar según configuración del jugador
	if game_data and game_data.upgrades.has("smart_pricing"):
		min_profitable_multiplier = 1.1  # Menos exigente si tiene upgrade

	return offer_multiplier >= min_profitable_multiplier


func _calculate_smart_sell_quantity(product: String, current_stock: int) -> int:
	"""Calcular cantidad inteligente para vender"""
	var base_amount = min(10, max(1, int(current_stock * 0.25)))  # 25% o máximo 10

	# Ajustar según oferta
	var offer_multiplier = _get_offer_multiplier(product)
	if offer_multiplier >= 2.0:  # Oferta muy buena - vender más
		base_amount = min(20, int(current_stock * 0.5))
	elif offer_multiplier <= 1.2:  # Oferta regular - vender menos
		base_amount = min(5, int(current_stock * 0.15))

	# Ajustar según demanda de clientes
	var demand = _get_customer_demand_factor(product)
	if demand >= 1.5:  # Alta demanda
		base_amount = int(base_amount * 1.3)

	return max(1, base_amount)


func _get_customer_demand_factor(product: String) -> float:
	"""Calcular factor de demanda de clientes para un producto"""
	# Por ahora factor base, expandible con estadísticas futuras
	var base_demand = 1.0

	# Productos más populares tienen mayor demanda
	match product:
		"beer":
			base_demand = 1.2  # Cerveza siempre popular
		"cocktail":
			base_demand = 1.4  # Cocktails premium
		"whiskey":
			base_demand = 1.1  # Whiskey nicho pero estable
		_:
			base_demand = 1.0

	# TODO: En el futuro, usar estadísticas reales de ventas de clientes
	return base_demand


# =============================================================================
# CONFIGURATION FUNCTIONS
# =============================================================================


func enable_auto_production(station_id: String, enabled: bool = true):
	"""Habilitar/deshabilitar auto-producción para una estación"""
	auto_production_enabled[station_id] = enabled
	automation_config_changed.emit("auto_production_" + station_id, enabled)
	print(
		"🤖 Auto-producción %s para %s" % ["habilitada" if enabled else "deshabilitada", station_id]
	)


func enable_auto_sell(product: String, enabled: bool = true):
	"""Habilitar/deshabilitar auto-venta para un producto"""
	auto_sell_enabled[product] = enabled
	automation_config_changed.emit("auto_sell_" + product, enabled)
	print("🤖 Auto-venta %s para %s" % ["habilitada" if enabled else "deshabilitada", product])


func set_smart_production_priority(enabled: bool):
	"""Habilitar/deshabilitar priorización inteligente"""
	smart_production_priority = enabled
	automation_config_changed.emit("smart_priority", enabled)


func set_auto_sell_threshold(threshold: float):
	"""Configurar threshold para auto-venta (0.0-1.0)"""
	auto_sell_threshold = clamp(threshold, 0.1, 1.0)
	automation_config_changed.emit("sell_threshold", threshold > 0.5)


# T021 - ADVANCED CONFIGURATION FUNCTIONS


func set_product_auto_sell_config(product: String, enabled: bool, custom_threshold: float = -1.0):
	"""Configuración avanzada de auto-venta por producto"""
	auto_sell_enabled[product] = enabled

	# TODO: Implementar thresholds personalizados por producto en futuro
	if custom_threshold > 0:
		print("⚠️ Custom thresholds por producto serán implementados en T022")

	automation_config_changed.emit("auto_sell_" + product, enabled)
	print("🤖 Auto-venta configurada para %s: %s" % [product, "ON" if enabled else "OFF"])


func set_smart_pricing_enabled(enabled: bool):
	"""Habilitar/deshabilitar pricing inteligente"""
	# Guardar en game_data como upgrade
	if game_data:
		game_data.upgrades["smart_pricing"] = enabled

	automation_config_changed.emit("smart_pricing", enabled)
	print("🧠 Smart Pricing %s" % ["activado" if enabled else "desactivado"])


func get_auto_sell_status(product: String) -> Dictionary:
	"""Obtener estado completo de auto-venta para un producto"""
	var current_stock = StockManager.get_stock("product", product)
	var max_stock = _get_max_product_storage(product)
	var stock_ratio = float(current_stock) / max(1.0, float(max_stock))
	var threshold = _get_smart_sell_threshold(product)
	var price_score = _calculate_price_attractiveness(product)

	return {
		"enabled": auto_sell_enabled.get(product, false),
		"will_sell": _should_auto_sell(product),
		"stock_ratio": stock_ratio,
		"threshold": threshold,
		"price_score": price_score,
		"offer_multiplier": _get_offer_multiplier(product),
		"demand_factor": _get_customer_demand_factor(product)
	}


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================


func _get_station_product(station_id: String) -> String:
	"""Obtener el producto que produce una estación"""
	match station_id:
		"brewery":
			return "beer"
		"bar_station":
			return "cocktail"
		"distillery":
			return "whiskey"
		_:
			return ""


func _get_station_recipe(station_id: String) -> Dictionary:
	"""Obtener la receta de recursos para una estación"""
	match station_id:
		"brewery":
			return {"barley": 2, "hops": 1, "water": 1}
		"bar_station":
			return {"barley": 1, "water": 2}
		"distillery":
			return {"barley": 3, "water": 1}
		_:
			return {}


func _get_product_base_price(product: String) -> float:
	"""Obtener precio base de un producto"""
	if not game_data or not game_data.products.has(product):
		return 1.0

	return game_data.products[product].get("base_price", 1.0)


func _get_production_cost(station_id: String) -> float:
	"""Calcular costo de producción basado en recursos necesarios"""
	var recipe = _get_station_recipe(station_id)
	var total_cost: float = 0.0

	for resource in recipe:
		var amount = recipe[resource]
		var resource_value = 0.1  # Valor estimado por recurso
		total_cost += amount * resource_value

	return total_cost


func _get_max_product_storage(product: String) -> int:
	"""Obtener capacidad máxima de almacenamiento para un producto"""
	# Por ahora usar límites fijos, en el futuro podría ser configurable
	match product:
		"beer", "cocktail":
			return 200
		"whiskey":
			return 100
		_:
			return 50


func _has_active_offer(product: String) -> bool:
	"""Verificar si un producto tiene oferta activa"""
	if not game_data or not game_data.offers.has(product):
		return false

	return game_data.offers[product].get("enabled", false)


func _get_offer_multiplier(product: String) -> float:
	"""Obtener multiplicador de precio por oferta"""
	if not _has_active_offer(product):
		return 1.0

	return game_data.offers[product].get("price_multiplier", 1.0)


func _get_base_product_price(product: String) -> float:
	"""Obtener precio base de un producto"""
	# Precios base estándar - podrían venir de ProductionManager en futuro
	match product:
		"beer":
			return 8.5
		"cocktail":
			return 12.0
		"whiskey":
			return 15.0
		_:
			return 5.0


func is_auto_production_enabled(station_id: String) -> bool:
	"""Verificar si auto-producción está habilitada para una estación"""
	return auto_production_enabled.get(station_id, false)


func is_auto_sell_enabled(product: String) -> bool:
	"""Verificar si auto-venta está habilitada para un producto"""
	return auto_sell_enabled.get(product, false)


func get_automation_status() -> Dictionary:
	"""Obtener estado completo de automatización"""
	return {
		"auto_production": auto_production_enabled.duplicate(),
		"auto_sell": auto_sell_enabled.duplicate(),
		"smart_priority": smart_production_priority,
		"sell_threshold": auto_sell_threshold
	}


# Funciones para guardado/carga
func save_automation_data() -> Dictionary:
	"""Preparar datos de automatización para guardado"""
	return {
		"auto_production_enabled": auto_production_enabled,
		"auto_sell_enabled": auto_sell_enabled,
		"smart_production_priority": smart_production_priority,
		"auto_sell_threshold": auto_sell_threshold
	}


func load_automation_data(data: Dictionary):
	"""Cargar datos de automatización desde archivo"""
	auto_production_enabled = data.get("auto_production_enabled", {})
	auto_sell_enabled = data.get("auto_sell_enabled", {})
	smart_production_priority = data.get("smart_production_priority", true)
	auto_sell_threshold = data.get("auto_sell_threshold", 0.8)

	print("🤖 Configuraciones de automatización cargadas")
