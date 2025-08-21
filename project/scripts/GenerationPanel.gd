extends BasePanel
## GenerationPanel - Panel de generación usando componentes modulares
## Implementa Scene Composition con BuyCard y ItemListCard

# Helpers
const LayoutFixHelper = preload("res://scripts/ui/LayoutFixHelper.gd")

# Señales específicas del panel
signal generator_purchased(generator_index: int, quantity: int)

# Estado específico del panel
var generator_manager_ref: Node = null

# Componentes modulares
var resources_cards: Array[Node] = []
var generators_shop: Node = null

# Referencias a contenedores específicos
@onready var resources_container: HBoxContainer = $MainContainer/ResourcesSection/ResourceContainer
@onready var generators_container: VBoxContainer = $MainContainer/GeneratorsSection


## Establecer referencia al GeneratorManager para cálculos precisos
func set_generator_manager(manager: Node) -> void:
	generator_manager_ref = manager
	print("🔗 GenerationPanel conectado con GeneratorManager")


# =============================================================================
# IMPLEMENTACIÓN DE MÉTODOS ABSTRACTOS DE BasePanel
# =============================================================================


func _initialize_panel_specific() -> void:
	"""Inicialización específica del panel de generación"""
	_setup_modular_resources()
	_setup_modular_generators()
	print("✅ GenerationPanel inicializado con componentes modulares")


func _connect_panel_signals() -> void:
	"""Conectar señales específicas del panel"""
	if generator_purchased.is_connected(_on_generator_purchased):
		return
	generator_purchased.connect(_on_generator_purchased)


func _update_panel_data(game_data: Dictionary) -> void:
	"""Actualizar datos específicos del panel"""
	update_resource_displays(game_data)

	# Obtener definiciones desde el generator_manager si está disponible
	var generator_definitions = []
	if generator_manager_ref and generator_manager_ref.has_method("get_generator_definitions"):
		generator_definitions = generator_manager_ref.get_generator_definitions()

	update_generator_displays(generator_definitions, game_data)


# =============================================================================
# FUNCIONALIDAD ESPECÍFICA DEL PANEL
# =============================================================================


func _setup_modular_resources() -> void:
	"""Configurar tarjetas de recursos usando ItemListCard"""
	# Limpiar contenedor existente
	for child in resources_container.get_children():
		child.queue_free()
	resources_cards.clear()

	# Configurar contenedor padre para layout mobile (horizontal)
	LayoutFixHelper.configure_parent_container(resources_container)

	# Usar datos reales de GameConfig en lugar de hardcoded
	var resource_configs = []
	for resource_id in GameConfig.RESOURCE_DATA.keys():
		var data = GameConfig.RESOURCE_DATA[resource_id]
		resource_configs.append(
			{id = resource_id, name = data.name, icon = data.emoji, action = "view_details"}
		)

	# Crear tarjeta para cada recurso
	for config in resource_configs:
		var card = ComponentsPreloader.create_item_list_card()
		var button_config = {text = "Ver", icon = "👁️", action = config.action}

		card.setup_item(config, button_config)
		card.action_requested.connect(_on_resource_action)

		# Aplicar fix de layout
		LayoutFixHelper.configure_dynamic_component(card)

		resources_container.add_child(card)
		resources_cards.append(card)

	# Forzar actualización de layout
	LayoutFixHelper.force_layout_update(resources_container)


func _setup_modular_generators() -> void:
	"""Configurar tienda de generadores usando ShopContainer"""
	# Limpiar contenedor existente
	for child in generators_container.get_children():
		child.queue_free()

	# Configurar contenedor padre como VERTICAL para mobile
	LayoutFixHelper.configure_parent_container(generators_container)
	# Forzar orientación vertical para mobile
	if generators_container is VBoxContainer:
		generators_container.add_theme_constant_override("separation", 12)

	# Crear ShopContainer para generadores
	generators_shop = ComponentsPreloader.create_shop_container()
	generators_shop.setup("Generadores Disponibles", "buy")

	# Aplicar fix de layout para ShopContainer
	LayoutFixHelper.configure_dynamic_component(generators_shop)

	# Usar datos reales de GameConfig en lugar de hardcoded
	for generator_id in GameConfig.GENERATOR_DATA.keys():
		var generator_data = GameConfig.GENERATOR_DATA[generator_id]
		var config = {
			id = generator_id,
			name = generator_data.name,
			description = generator_data.description,
			base_price = generator_data.base_price,
			icon = generator_data.emoji
		}

		var card = generators_shop.add_item(config)

		# Configurar calculadora de costo específica usando GameUtils
		var cost_calculator = GameUtils.create_cost_calculator(
			generator_manager_ref, generator_id, "get_generator_cost"
		)

		card.set_cost_calculator(cost_calculator)

	# Conectar señales de la tienda
	generators_shop.purchase_requested.connect(_on_generator_purchase)

	# Agregar tienda al contenedor
	generators_container.add_child(generators_shop)

	# Forzar actualización de layout
	LayoutFixHelper.force_layout_update(generators_container)


func update_resource_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de recursos usando componentes modulares"""
	if not is_initialized:
		return

	var resources = game_data.get("resources", {})

	# Actualizar cada tarjeta de recurso
	for i in range(resources_cards.size()):
		var card = resources_cards[i]
		if not card:
			continue

		var resource_configs = ["barley", "hops", "water", "yeast"]
		if i < resource_configs.size():
			var resource_id = resource_configs[i]
			var amount = resources.get(resource_id, 0)

			card.update_data(
				{
					id = resource_id,
					amount = GameUtils.format_large_number(amount),
					status = "Disponible" if amount > 0 else "Agotado"
				}
			)


func update_generator_displays(generator_definitions: Array, game_data: Dictionary) -> void:
	"""Actualiza las interfaces de generadores usando ShopContainer"""
	if not is_initialized or not generators_shop:
		return

	var money = game_data.get("money", 0.0)

	# Actualizar dinero disponible en la tienda
	generators_shop.update_player_money(money)

	# Usar generator_definitions para obtener información actualizada si está disponible
	if generator_definitions.size() > 0:
		print(
			(
				"🔄 Actualizando displays con %d definiciones de generadores"
				% generator_definitions.size()
			)
		)


# Manejadores de señales modulares


func _on_resource_action(item_id: String, action: String) -> void:
	"""Manejar acciones de recursos desde ItemListCard"""
	match action:
		"view_details":
			print("👁️ Ver detalles de recurso: ", item_id)
			# TODO: Implementar modal de detalles de recurso
		_:
			print("⚠️ Acción no reconocida para recurso: ", action)


func _on_generator_purchase(item_id: String, quantity: int, total_cost: float) -> void:
	"""Manejar compras de generadores desde ShopContainer"""
	print("🛒 Compra solicitada: %s x%d por $%.2f" % [item_id, quantity, total_cost])

	# Buscar índice del generador para mantener compatibilidad
	var generator_configs = ["barley_farm", "hops_farm", "water_collector"]
	var generator_index = generator_configs.find(item_id)

	if generator_index >= 0:
		generator_purchased.emit(generator_index, quantity)
	else:
		print("⚠️ Generador no encontrado: ", item_id)


# Manejador para mantener compatibilidad con BasePanel
func _on_generator_purchased(_generator_index: int, _quantity: int) -> void:
	"""Manejador interno para la señal generator_purchased"""
	# Implementación futura para lógica adicional tras compra
