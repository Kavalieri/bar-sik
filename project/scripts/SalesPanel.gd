extends BasePanel
## SalesPanel - Panel de ventas usando componentes modulares
## Implementa Scene Composition con ShopContainer e ItemListCard

# Señales específicas del panel
signal item_sell_requested(item_type: String, item_name: String, quantity: int)

# Estado específico del panel
var sales_manager_ref: Node = null

# Componentes modulares
var products_shop: Node = null
var ingredients_shop: Node = null
var stats_cards: Array[Node] = []

# Referencias a contenedores específicos
@onready var products_container: VBoxContainer = $MainContainer/SalesSection/ProductsContainer
@onready var ingredients_container: VBoxContainer = $MainContainer/SalesSection/IngredientsContainer
@onready var stats_container: VBoxContainer = $MainContainer/StatisticsSection/StatsContainer


## Establecer referencia al SalesManager
func set_sales_manager(manager: Node) -> void:
	sales_manager_ref = manager
	print("🔗 SalesPanel conectado con SalesManager")


# =============================================================================
# IMPLEMENTACIÓN DE MÉTODOS ABSTRACTOS DE BasePanel
# =============================================================================


func _initialize_panel_specific() -> void:
	"""Inicialización específica del panel de ventas"""
	_setup_modular_products()
	_setup_modular_ingredients()
	_setup_modular_stats()
	print("✅ SalesPanel inicializado con componentes modulares")


func _connect_panel_signals() -> void:
	"""Conectar señales específicas del panel"""
	# Las señales se conectan en los componentes modulares
	return


func _update_panel_data(game_data: Dictionary) -> void:
	"""Actualizar datos específicos del panel"""
	update_sales_displays(game_data)

	# Actualizar dinero en las tiendas
	var money = game_data["money"] if game_data.has("money") else 0.0
	if products_shop:
		products_shop.update_player_money(money)
	if ingredients_shop:
		ingredients_shop.update_player_money(money)


func _setup_modular_products() -> void:
	"""Configurar tienda de productos usando ShopContainer"""
	# Limpiar contenedor existente
	for child in products_container.get_children():
		child.queue_free()

	# Crear ShopContainer para productos
	products_shop = ComponentsPreloader.create_shop_container()
	products_shop.setup("Venta de Productos", "sell")

	# Definir productos disponibles para venta
	var product_configs = [
		{
			id = "beer",
			name = "Cerveza Artesanal",
			description = "Tu cerveza premium casera",
			base_price = 8.0,
			icon = "🍺"
		},
		{
			id = "light_beer",
			name = "Cerveza Ligera",
			description = "Versión suave de tu cerveza",
			base_price = 6.0,
			icon = "🍻"
		},
		{
			id = "wheat_beer",
			name = "Cerveza de Trigo",
			description = "Cerveza especial de trigo",
			base_price = 10.0,
			icon = "🌾"
		}
	]

	# Agregar cada producto a la tienda
	for config in product_configs:
		var card = products_shop.add_item(config)

		# Configurar calculadora de precio de venta usando GameUtils
		var price_calculator = GameUtils.create_cost_calculator(
			sales_manager_ref, config.id, "get_sell_price"
		)

		card.set_cost_calculator(price_calculator)

	# Conectar señales de venta
	products_shop.sell_requested.connect(_on_product_sell)

	# Agregar tienda al contenedor
	products_container.add_child(products_shop)


func _setup_modular_ingredients() -> void:
	"""Configurar tienda de ingredientes usando ShopContainer"""
	# Limpiar contenedor existente
	for child in ingredients_container.get_children():
		child.queue_free()

	# Crear ShopContainer para ingredientes
	ingredients_shop = ComponentsPreloader.create_shop_container()
	ingredients_shop.setup("Venta de Ingredientes", "sell")

	# Definir ingredientes disponibles para venta
	var ingredient_configs = [
		{
			id = "barley",
			name = "Cebada Extra",
			description = "Vende tu exceso de cebada",
			base_price = 1.5,
			icon = "🌾"
		},
		{
			id = "hops",
			name = "Lúpulo Premium",
			description = "Vende lúpulo de alta calidad",
			base_price = 2.0,
			icon = "🌿"
		},
		{
			id = "water",
			name = "Agua Pura",
			description = "Vende agua filtrada",
			base_price = 0.5,
			icon = "💧"
		}
	]

	# Agregar cada ingrediente a la tienda
	for config in ingredient_configs:
		var card = ingredients_shop.add_item(config)

		# Configurar calculadora de precio de venta usando GameUtils
		var price_calculator = GameUtils.create_cost_calculator(
			sales_manager_ref, config.id, "get_ingredient_sell_price"
		)

		card.set_cost_calculator(price_calculator)

	# Conectar señales de venta
	ingredients_shop.sell_requested.connect(_on_ingredient_sell)

	# Agregar tienda al contenedor
	ingredients_container.add_child(ingredients_shop)


func _setup_modular_stats() -> void:
	"""Configurar estadísticas de ventas usando ItemListCard"""
	# Limpiar contenedor existente
	for child in stats_container.get_children():
		child.queue_free()
	stats_cards.clear()

	# Definir estadísticas disponibles
	var stats_configs = [
		{id = "total_sales", name = "Ventas Totales", icon = "💰", action = "view_details"},
		{id = "daily_revenue", name = "Ingresos Diarios", icon = "📈", action = "view_details"},
		{id = "best_product", name = "Producto Estrella", icon = "⭐", action = "view_details"},
		{id = "profit_margin", name = "Margen de Ganancia", icon = "📊", action = "view_details"}
	]

	# Crear tarjeta para cada estadística
	for config in stats_configs:
		var card = ComponentsPreloader.create_item_list_card()
		var button_config = {text = "Detalles", icon = "🔍", action = config.action}

		card.setup_item(config, button_config)
		card.action_requested.connect(_on_stats_action)
		stats_container.add_child(card)
		stats_cards.append(card)


func update_sales_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de ventas usando componentes modulares"""
	if not is_initialized:
		return

	var sales_data = game_data["sales"] if game_data.has("sales") else {}
	var total_sales = sales_data["total"] if sales_data.has("total") else 0.0
	var recent_sales = sales_data["recent"] if sales_data.has("recent") else []

	# Actualizar información de ventas si hay tarjetas configuradas
	print(
		(
			"🔄 Actualizando datos de ventas: $%.2f total, %d recientes"
			% [total_sales, recent_sales.size()]
		)
	)


func update_stats_displays(game_data: Dictionary) -> void:
	"""Actualiza las estadísticas usando componentes modulares"""
	if not is_initialized:
		return

	var sales_stats = game_data["sales_stats"] if game_data.has("sales_stats") else {}

	# Actualizar cada tarjeta de estadística
	for i in range(stats_cards.size()):
		var card = stats_cards[i]
		if not card:
			continue

		var stats_configs = ["total_sales", "daily_revenue", "best_product", "profit_margin"]
		if i < stats_configs.size():
			var stat_id = stats_configs[i]
			var stat_value = sales_stats[stat_id] if sales_stats.has(stat_id) else "N/A"

			card.update_data({id = stat_id, value = str(stat_value), status = "Actualizado"})


func update_sell_interfaces(game_data: Dictionary) -> void:
	"""Actualizar interfaces de venta (compatibilidad con GameController)"""
	if not is_initialized:
		return

	# Reutilizar lógica existente
	update_sales_displays(game_data)
	update_stats_displays(game_data)
	print("🔄 Interfaces de venta actualizadas")


func update_statistics(game_data: Dictionary) -> void:
	"""Alias para update_stats_displays (compatibilidad con GameController)"""
	update_stats_displays(game_data)


# Manejadores de señales modulares


func _on_product_sell(item_id: String, quantity: int, total_income: float) -> void:
	"""Manejar ventas de productos desde ShopContainer"""
	print("💰 Venta de producto: %s x%d por $%.2f" % [item_id, quantity, total_income])
	item_sell_requested.emit("product", item_id, quantity)


func _on_ingredient_sell(item_id: String, quantity: int, total_income: float) -> void:
	"""Manejar ventas de ingredientes desde ShopContainer"""
	print("🌿 Venta de ingrediente: %s x%d por $%.2f" % [item_id, quantity, total_income])
	item_sell_requested.emit("ingredient", item_id, quantity)


func _on_stats_action(item_id: String, action: String) -> void:
	"""Manejar acciones de estadísticas desde ItemListCard"""
	match action:
		"view_details":
			print("📊 Ver detalles de estadística: ", item_id)
			# TODO: Implementar modal de detalles de estadística
		_:
			print("⚠️ Acción no reconocida para estadística: ", action)
