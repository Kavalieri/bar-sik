extends BasePanel
## CustomersPanel - Panel de clientes (versión simplificada sin componentes modulares)

# Señales específicas del panel
signal autosell_upgrade_purchased(upgrade_id: String)
signal automation_upgrade_purchased(upgrade_id: String)

# Estado específico del panel
var customer_manager_ref: Node = null

# Componentes modulares - DESACTIVADOS TEMPORALMENTE
var timer_cards: Array[Node] = []
var upgrades_shop: Node = null
var automation_cards: Array[Node] = []

# Referencias a contenedores específicos - VERSIÓN SIMPLIFICADA
#@onready var timer_container: VBoxContainer = $MainContainer/TimerSection/TimerContainer
#@onready var upgrades_container: VBoxContainer = $MainContainer/UpgradesSection
@onready
var automation_container: VBoxContainer = $MainContainer/AutomationSection/AutomationContainer


## Establecer referencia al CustomerManager
func set_customer_manager(manager: Node) -> void:
	customer_manager_ref = manager
	print("🔗 CustomersPanel conectado con CustomerManager")


# =============================================================================
# IMPLEMENTACIÓN DE MÉTODOS ABSTRACTOS DE BasePanel
# =============================================================================


func _initialize_panel_specific() -> void:
	"""Inicialización específica del panel de clientes"""
	_setup_modular_timers()
	_setup_modular_upgrades()
	_setup_modular_automation()
	print("✅ CustomersPanel inicializado con componentes modulares")


func _connect_panel_signals() -> void:
	"""Conectar señales específicas del panel"""
	# Las señales se conectan en los componentes modulares
	return


func _update_panel_data(game_data: Dictionary) -> void:
	"""Actualizar datos específicos del panel"""
	update_customer_displays(game_data)
	update_timer_displays(game_data)
	update_upgrade_displays(game_data)
	update_automation_displays(game_data)


func _setup_modular_timers() -> void:
	"""Configurar información de timers usando ItemListCard - DESACTIVADO"""
	print("⚠️ CustomersPanel: _setup_modular_timers desactivado temporalmente")
	return

	# CÓDIGO ORIGINAL COMENTADO PARA EVITAR COMPONENTES PROBLEMÁTICOS
	# var timer_configs = [
	#	{id = "autosell_timer", name = "Auto-Venta", icon = "⏰", action = "configure_timer"},
	#	{id = "production_timer", name = "Producción", icon = "⚗️", action = "configure_timer"},
	#	{id = "customer_timer", name = "Clientes", icon = "👥", action = "configure_timer"}
	# ]
	# for config in timer_configs:
	#	var card = ComponentsPreloader.create_item_list_card()


func _setup_modular_upgrades() -> void:
	"""Configurar tienda de upgrades usando ShopContainer - DESACTIVADO"""
	print("⚠️ CustomersPanel: _setup_modular_upgrades desactivado temporalmente")
	return

	# CÓDIGO ORIGINAL COMENTADO PARA EVITAR COMPONENTES PROBLEMÁTICOS
	upgrades_shop.setup("Mejoras Disponibles", "buy")

	# Definir upgrades disponibles
	var upgrade_configs = [
		{
			id = "autosell_basic",
			name = "Auto-Venta Básica",
			description = "Vende productos automáticamente",
			base_price = 100.0,
			icon = "🤖"
		},
		{
			id = "autosell_advanced",
			name = "Auto-Venta Avanzada",
			description = "Venta inteligente con mejor precio",
			base_price = 250.0,
			icon = "🧠"
		},
		{
			id = "customer_attraction",
			name = "Atracción de Clientes",
			description = "Atrae más clientes a tu cervecería",
			base_price = 500.0,
			icon = "🎯"
		}
	]

	# Agregar cada upgrade a la tienda
	for config in upgrade_configs:
		var card = upgrades_shop.add_item(config)

		# Configurar calculadora de costo específica usando GameUtils
		var cost_calculator = GameUtils.create_cost_calculator(
			customer_manager_ref, config.id, "get_upgrade_cost"
		)

		card.set_cost_calculator(cost_calculator)

	# CÓDIGO COMENTADO - EVITAR COMPONENTES PROBLEMÁTICOS
	# # Conectar señales de compra
	# upgrades_shop.purchase_requested.connect(_on_upgrade_purchase)

	# # Agregar tienda al contenedor
	# upgrades_container.add_child(upgrades_shop)


func _setup_modular_automation() -> void:
	"""Configurar automatización usando ItemListCard - DESACTIVADO"""
	print("⚠️ CustomersPanel: _setup_modular_automation desactivado temporalmente")
	return

	# CÓDIGO ORIGINAL COMENTADO PARA EVITAR COMPONENTES PROBLEMÁTICOS
	# # Limpiar contenedor existente
	# for child in automation_container.get_children():
	#	child.queue_free()

	# # Configuración de automatizaciones disponibles
	# var automation_configs = [
	#	{
	#		id = "auto_production",
	#		name = "Producción Automática",
	#		icon = "⚙️",
	#		action = "toggle_auto"
	#	},
	#	{id = "auto_sales", name = "Ventas Automáticas", icon = "💸", action = "toggle_auto"},
	#	{id = "auto_purchase", name = "Compras Automáticas", icon = "🛒", action = "toggle_auto"}
	# ]

	# # Crear tarjeta para cada automatización
	# for config in automation_configs:
	#	var card = ComponentsPreloader.create_item_list_card()
	#	var button_config = {text = "Activar", icon = "▶️", action = config.action}

	#	card.setup_item(config, button_config)
	#	card.action_requested.connect(_on_automation_action)
	#	automation_container.add_child(card)
	#	automation_cards.append(card)


func update_customer_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de clientes usando componentes modulares"""
	if not is_initialized:
		return

	var customers = game_data.get("customers", [])
	var satisfaction = game_data.get("customer_satisfaction", 0.0)

	# Actualizar información de clientes si hay tarjetas configuradas
	print(
		(
			"🔄 Actualizando datos de clientes: %d activos, satisfacción: %.1f%%"
			% [customers.size(), satisfaction * 100]
		)
	)


func update_timer_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de timers usando componentes modulares"""
	if not is_initialized:
		return

	var timers = game_data.get("timers", {})

	# Actualizar cada tarjeta de timer
	for i in range(timer_cards.size()):
		var card = timer_cards[i]
		if not card:
			continue

		var timer_configs = ["autosell_timer", "production_timer", "customer_timer"]
		if i < timer_configs.size():
			var timer_id = timer_configs[i]
			var timer_data = timers.get(timer_id, {})
			var remaining = timer_data.get("remaining", 0.0)

			card.update_data(
				{
					id = timer_id,
					remaining = "%.1fs" % remaining,
					status = "Activo" if remaining > 0 else "Listo"
				}
			)


func update_upgrade_displays(game_data: Dictionary) -> void:
	"""Actualiza las interfaces de upgrades usando ShopContainer"""
	if not is_initialized or not upgrades_shop:
		return

	var money = game_data.get("money", 0.0)

	# Actualizar dinero disponible en la tienda
	upgrades_shop.update_player_money(money)


func update_automation_displays(game_data: Dictionary) -> void:
	"""Actualiza el estado de automatización usando componentes modulares"""
	if not is_initialized:
		return

	var automation = game_data.get("automation", {})

	# Actualizar cada tarjeta de automatización
	for i in range(automation_cards.size()):
		var card = automation_cards[i]
		if not card:
			continue

		var automation_configs = ["auto_production", "auto_sales", "auto_purchase"]
		if i < automation_configs.size():
			var auto_id = automation_configs[i]
			var is_active = automation.get(auto_id, false)

			card.update_data(
				{
					id = auto_id,
					status = "Activo" if is_active else "Inactivo",
					efficiency = "100%" if is_active else "0%"
				}
			)

			# Actualizar botón según estado
			var button_config = {
				text = "Desactivar" if is_active else "Activar",
				icon = "⏸️" if is_active else "▶️",
				action = "toggle_auto"
			}
			card.configure_button(button_config)


# Manejadores de señales modulares


func _on_timer_action(item_id: String, action: String) -> void:
	"""Manejar acciones de timers desde ItemListCard"""
	match action:
		"configure_timer":
			print("⚙️ Configurar timer: ", item_id)
			# TODO: Implementar modal de configuración de timer
		_:
			print("⚠️ Acción no reconocida para timer: ", action)


func _on_upgrade_purchase(item_id: String, quantity: int, total_cost: float) -> void:
	"""Manejar compras de upgrades desde ShopContainer"""
	print("💎 Compra de upgrade: %s x%d por $%.2f" % [item_id, quantity, total_cost])

	# Emitir señal según tipo de upgrade
	if item_id.begins_with("autosell"):
		autosell_upgrade_purchased.emit(item_id)
	else:
		automation_upgrade_purchased.emit(item_id)


func _on_automation_action(item_id: String, action: String) -> void:
	"""Manejar acciones de automatización desde ItemListCard"""
	match action:
		"toggle_auto":
			print("🔄 Toggle automatización: ", item_id)
			# Cambiar estado de automatización
			var current_automation = current_game_data.get("automation", {})
			var is_active = current_automation.get(item_id, false)

			# TODO: Conectar con sistema de automatización real
			print("📊 Estado automatización %s: %s → %s" % [item_id, is_active, not is_active])
		_:
			print("⚠️ Acción no reconocida para automatización: ", action)


# Funciones de compatibilidad con GameController


func update_customer_display(game_data: Dictionary, timer_progress: float) -> void:
	"""Actualizar display de clientes con progreso de timer (compatibilidad GameController)"""
	# Agregar información del timer al game_data
	var enhanced_data = game_data.duplicate()
	enhanced_data["timer_progress"] = timer_progress

	# Usar función existente
	update_customer_displays(enhanced_data)
	print("🔄 Display de clientes actualizado con progreso: %.1f%%" % (timer_progress * 100))


func update_offer_interfaces(game_data: Dictionary) -> void:
	"""Actualizar interfaces de ofertas (compatibilidad GameController)"""
	if not is_initialized:
		return

	var offers = game_data.get("offers", [])
	print("🔄 Interfaces de ofertas actualizadas: %d ofertas" % offers.size())

	# TODO: Implementar actualización de interfaces de ofertas cuando estén disponibles
