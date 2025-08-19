extends BasePanel
## ProductionPanel - Panel de producción usando componentes modulares
## Implementa Scene Composition con ShopContainer e ItemListCard

# Señales específicas del panel
signal station_purchased(station_index: int)
signal manual_production_requested(station_index: int, quantity: int)
signal offer_toggled(station_index: int, enabled: bool)
signal offer_price_requested(station_index: int)

# Estado específico del panel
var production_manager_ref: Node = null

# Componentes modulares
var products_cards: Array[Node] = []
var stations_shop: Node = null
var recipes_cards: Array[Node] = []

# Referencias a contenedores específicos
@onready var products_container: VBoxContainer = $MainContainer/ProductsSection/ProductContainer
@onready var stations_container: VBoxContainer = $MainContainer/StationsSection
@onready var recipes_container: VBoxContainer = $MainContainer/RecipesSection/RecipeContainer


## Establecer referencia al ProductionManager
func set_production_manager(manager: Node) -> void:
	production_manager_ref = manager
	print("🔗 ProductionPanel conectado con ProductionManager")


# =============================================================================
# IMPLEMENTACIÓN DE MÉTODOS ABSTRACTOS DE BasePanel
# =============================================================================


func _initialize_panel_specific() -> void:
	"""Inicialización específica del panel de producción"""
	_setup_modular_products()
	_setup_modular_stations()
	_setup_modular_recipes()
	print("✅ ProductionPanel inicializado con componentes modulares")


func _connect_panel_signals() -> void:
	"""Conectar señales específicas del panel"""
	# Las señales se conectan en los componentes modulares
	return


func _update_panel_data(game_data: Dictionary) -> void:
	"""Actualizar datos específicos del panel"""
	update_product_displays(game_data)
	update_station_displays(game_data)
	update_recipe_displays(game_data)


func _setup_modular_products() -> void:
	"""Configurar tarjetas de productos usando ItemListCard"""
	# Limpiar contenedor existente
	for child in products_container.get_children():
		child.queue_free()
	products_cards.clear()

	# Definir productos disponibles
	var product_configs = [
		{id = "beer", name = "Cerveza", icon = "🍺", action = "view_stats"},
		{id = "light_beer", name = "Cerveza Ligera", icon = "🍻", action = "view_stats"},
		{id = "wheat_beer", name = "Cerveza de Trigo", icon = "🌾", action = "view_stats"},
		{id = "premium_beer", name = "Cerveza Premium", icon = "👑", action = "view_stats"}
	]

	# Crear tarjeta para cada producto
	for config in product_configs:
		var card = ComponentsPreloader.create_item_list_card()
		var button_config = {text = "Stats", icon = "📊", action = config.action}

		card.setup_item(config, button_config)
		card.action_requested.connect(_on_product_action)
		products_container.add_child(card)
		products_cards.append(card)


func _setup_modular_stations() -> void:
	"""Configurar tienda de estaciones usando ShopContainer"""
	# Limpiar contenedor existente
	for child in stations_container.get_children():
		child.queue_free()

	# Crear ShopContainer para estaciones
	stations_shop = ComponentsPreloader.create_shop_container()
	stations_shop.setup("Estaciones de Producción", "buy")

	# Definir estaciones disponibles
	var station_configs = [
		{
			id = "brewery_station",
			name = "Estación Cervecera",
			description = "Produce cerveza automáticamente",
			base_price = 50.0,
			icon = "⚗️"
		},
		{
			id = "fermentation_tank",
			name = "Tanque de Fermentación",
			description = "Fermenta ingredientes en cerveza",
			base_price = 75.0,
			icon = "🛢️"
		},
		{
			id = "bottling_machine",
			name = "Máquina Embotelladora",
			description = "Embotella cerveza producida",
			base_price = 100.0,
			icon = "🍾"
		}
	]

	# Agregar cada estación a la tienda
	for i in range(station_configs.size()):
		var config = station_configs[i]
		var card = stations_shop.add_item(config)

		# Configurar calculadora de costo específica usando GameUtils
		var cost_calculator = GameUtils.create_cost_calculator(
			production_manager_ref, config.id, "get_station_cost"
		)

		card.set_cost_calculator(cost_calculator)

	# Conectar señales de la tienda
	stations_shop.purchase_requested.connect(_on_station_purchase)

	# Agregar tienda al contenedor
	stations_container.add_child(stations_shop)


func _setup_modular_recipes() -> void:
	"""Configurar lista de recetas usando ItemListCard"""
	# Limpiar contenedor existente
	for child in recipes_container.get_children():
		child.queue_free()
	recipes_cards.clear()

	# Definir recetas usando GameConfig centralizado
	var recipe_configs = []
	for product_id in GameConfig.PRODUCT_DATA.keys():
		var data = GameConfig.PRODUCT_DATA[product_id]
		recipe_configs.append(
			{id = product_id, name = "Receta: " + data.name, icon = "📋", action = "toggle_recipe"}
		)

	# Crear tarjeta para cada receta
	for config in recipe_configs:
		var card = ComponentsPreloader.create_item_list_card()
		var button_config = {text = "Activar", icon = "▶️", action = config.action}

		card.setup_item(config, button_config)
		card.action_requested.connect(_on_recipe_action)
		recipes_container.add_child(card)
		recipes_cards.append(card)


func update_product_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de productos usando componentes modulares"""
	if not is_initialized:
		return

	var products = game_data.get("products", {})

	# Actualizar cada tarjeta de producto
	for i in range(products_cards.size()):
		var card = products_cards[i]
		if not card:
			continue

		var product_configs = ["beer", "light_beer", "wheat_beer", "premium_beer"]
		if i < product_configs.size():
			var product_id = product_configs[i]
			var amount = products.get(product_id, 0)

			card.update_data(
				{
					id = product_id,
					amount = GameUtils.format_large_number(amount),
					status = "En stock" if amount > 0 else "Agotado"
				}
			)


func update_station_displays(game_data: Dictionary) -> void:
	"""Actualiza las interfaces de estaciones usando ShopContainer"""
	if not is_initialized or not stations_shop:
		return

	var money = game_data.get("money", 0.0)

	# Actualizar dinero disponible en la tienda
	stations_shop.update_player_money(money)


func update_station_interfaces(station_definitions: Array, game_data: Dictionary) -> void:
	"""Alias para update_station_displays con definiciones adicionales"""
	update_station_displays(game_data)

	# Usar station_definitions para información adicional si es necesario
	if station_definitions.size() > 0:
		print("🔄 Actualizando interfaces de estaciones con %d definiciones" % [
			station_definitions.size()
		])


func update_recipe_displays(game_data: Dictionary) -> void:
	"""Actualiza el estado de las recetas usando componentes modulares"""
	if not is_initialized:
		return

	var active_recipes = game_data.get("active_recipes", {})

	# Actualizar cada tarjeta de receta
	for i in range(recipes_cards.size()):
		var card = recipes_cards[i]
		if not card:
			continue

		var recipe_configs = ["basic_beer", "light_beer", "wheat_beer"]
		if i < recipe_configs.size():
			var recipe_id = recipe_configs[i]
			var is_active = active_recipes.has(recipe_id)

			card.update_data(
				{
					id = recipe_id,
					status = "Activa" if is_active else "Inactiva",
					progress = str(active_recipes.get(recipe_id, {}).get("progress", 0)) + "%"
				}
			)

			# Actualizar botón según estado
			var button_config = {
				text = "Pausar" if is_active else "Activar",
				icon = "⏸️" if is_active else "▶️",
				action = "toggle_recipe"
			}
			card.configure_button(button_config)


# Manejadores de señales modulares


func _on_product_action(item_id: String, action: String) -> void:
	"""Manejar acciones de productos desde ItemListCard"""
	match action:
		"view_stats":
			print("📊 Ver estadísticas de producto: ", item_id)
			# TODO: Implementar modal de estadísticas de producto
		_:
			print("⚠️ Acción no reconocida para producto: ", action)


func _on_station_purchase(item_id: String, quantity: int, total_cost: float) -> void:
	"""Manejar compras de estaciones desde ShopContainer"""
	print("🏭 Compra de estación solicitada: %s x%d por $%.2f" % [item_id, quantity, total_cost])

	# Buscar índice de la estación para mantener compatibilidad
	var station_configs = ["brewery_station", "fermentation_tank", "bottling_machine"]
	var station_index = station_configs.find(item_id)

	if station_index >= 0:
		station_purchased.emit(station_index)
	else:
		print("⚠️ Estación no encontrada: ", item_id)


func _on_recipe_action(item_id: String, action: String) -> void:
	"""Manejar acciones de recetas desde ItemListCard"""
	match action:
		"toggle_recipe":
			print("🔄 Toggle receta: ", item_id)
			# Buscar índice de la receta para mantener compatibilidad
			var recipe_configs = ["basic_beer", "light_beer", "wheat_beer"]
			var recipe_index = recipe_configs.find(item_id)

			if recipe_index >= 0:
				var current_recipes = current_game_data.get("active_recipes", {})
				if current_recipes.has(item_id):
					# Pausar receta activa
					print("⏸️ Pausando receta: ", item_id)
				else:
					# Activar receta
					print("▶️ Activando receta: ", item_id)
					manual_production_requested.emit(recipe_index, 1)
		_:
			print("⚠️ Acción no reconocida para receta: ", action)
