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


func set_customer_manager(manager: Node) -> void:
	customer_manager_ref = manager
	print("🔗 CustomersPanel conectado con CustomerManager")


## Mostrar panel de desbloqueo del sistema de clientes
func _show_unlock_panel() -> void:
	"""Mostrar UI de desbloqueo cuando el sistema no está activo"""
	# Limpiar contenido existente
	UIComponentsFactory.clear_container($MainContainer)

	# Crear panel de desbloqueo centrado
	var unlock_container = VBoxContainer.new()
	unlock_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	unlock_container.add_theme_constant_override("separation", 16)
	$MainContainer.add_child(unlock_container)

	# Header con título
	var header = UIComponentsFactory.create_section_header(
		"🔒 SISTEMA DE CLIENTES", "Desbloquea la automatización"
	)
	unlock_container.add_child(header)

	# Panel de información
	var info_panel = UIComponentsFactory.create_content_panel(200)
	info_panel.custom_minimum_size = Vector2(400, 200)
	unlock_container.add_child(info_panel)

	var info_vbox = VBoxContainer.new()
	info_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	info_vbox.add_theme_constant_override("margin_left", 20)
	info_vbox.add_theme_constant_override("margin_right", 20)
	info_vbox.add_theme_constant_override("margin_top", 20)
	info_vbox.add_theme_constant_override("margin_bottom", 20)
	info_vbox.add_theme_constant_override("separation", 12)
	info_panel.add_child(info_vbox)

	# Descripción del sistema
	var desc_label = Label.new()
	desc_label.text = "Los clientes automáticos comprarán tus productos y pagarán en TOKENS 🪙"
	desc_label.add_theme_font_size_override("font_size", 16)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_label)

	# Lista de beneficios
	var benefits = [
		"• Genera ingresos automáticamente",
		"• Paga en tokens (💎 → 🪙)",
		"• Comprable con mejoras de gems",
		"• Sistema escalable hasta 10 clientes"
	]

	for benefit in benefits:
		var benefit_label = Label.new()
		benefit_label.text = benefit
		benefit_label.add_theme_font_size_override("font_size", 14)
		benefit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		info_vbox.add_child(benefit_label)

	# Botón de desbloqueo
	var unlock_button = UIComponentsFactory.create_primary_button("💎 Desbloquear (50 gems)")
	unlock_button.custom_minimum_size = Vector2(300, 50)
	unlock_button.pressed.connect(_on_unlock_button_pressed)
	unlock_container.add_child(unlock_button)

	# Actualizar estado del botón
	_update_unlock_button_state(unlock_button)


## Actualizar estado del botón según gems disponibles
func _update_unlock_button_state(button: Button) -> void:
	"""Habilitar/deshabilitar botón según gems disponibles"""
	if not game_data:
		button.disabled = true
		return

	var unlock_cost = 50
	var can_afford = game_data.gems >= unlock_cost

	button.disabled = not can_afford
	if not can_afford:
		button.text = "💎 Necesitas más gems (%d/%d)" % [game_data.gems, unlock_cost]
	else:
		button.text = "💎 Desbloquear (50 gems)"


## Callback del botón de desbloqueo
func _on_unlock_button_pressed() -> void:
	"""Desbloquear sistema de clientes"""
	if not game_data:
		print("❌ Error: GameData no disponible")
		return

	var unlock_cost = 50
	if not game_data.spend_gems(unlock_cost):
		print("❌ No hay suficientes gems para desbloquear clientes")
		return

	# Activar sistema
	game_data.customer_system_unlocked = true
	print("✅ Sistema de clientes desbloqueado por %d gems" % unlock_cost)

	# Activar CustomerManager si está disponible
	if customer_manager_ref:
		customer_manager_ref.set_enabled(true)
		print("✅ CustomerManager activado")

	# Reinicializar panel para mostrar interfaz normal
	_initialize_panel_specific()

	# Emitir señal de cambio para que UI se actualice
	if has_signal("panel_data_changed"):
		emit_signal("panel_data_changed")


# =============================================================================
# IMPLEMENTACIÓN DE MÉTODOS ABSTRACTOS DE BasePanel
# =============================================================================


func _initialize_panel_specific() -> void:
	"""Inicialización específica del panel de clientes"""
	# Verificar si el sistema está desbloqueado
	if not game_data or not game_data.customer_system_unlocked:
		_show_unlock_panel()
		return

	# Si está desbloqueado, mostrar panel normal
	_setup_management_panel()  # T012: Panel de gestión simplificado
	print("✅ CustomersPanel inicializado con panel de gestión")


# T012: Configurar panel de gestión completo
func _setup_management_panel():
	"""Panel principal de gestión cuando sistema está desbloqueado"""
	# Limpiar contenido existente
	UIComponentsFactory.clear_container($MainContainer)

	# === TÍTULO PRINCIPAL ===
	var main_title = Label.new()
	main_title.text = "👥 CLIENTES AUTOMÁTICOS"
	main_title.add_theme_font_size_override("font_size", 36)
	main_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_title.add_theme_color_override("font_color", Color.GOLD)
	$MainContainer.add_child(main_title)

	# Separador
	var separator1 = HSeparator.new()
	separator1.custom_minimum_size = Vector2(0, 30)
	$MainContainer.add_child(separator1)

	# === SECCIÓN DE TIMER VISUAL ===
	_setup_timer_section()

	# Separador
	var separator2 = HSeparator.new()
	separator2.custom_minimum_size = Vector2(0, 20)
	$MainContainer.add_child(separator2)

	# === SECCIÓN DE ESTADÍSTICAS ===
	_setup_stats_section()

	# Separador
	var separator3 = HSeparator.new()
	separator3.custom_minimum_size = Vector2(0, 20)
	$MainContainer.add_child(separator3)

	# === TIENDA DE UPGRADES ===
	_setup_upgrades_shop()


# T012: Timer visual circular con countdown
func _setup_timer_section():
	"""Sección con timer visual y estadísticas de clientes"""
	var timer_title = Label.new()
	timer_title.text = "⏰ PRÓXIMA COMPRA AUTOMÁTICA"
	timer_title.add_theme_font_size_override("font_size", 20)
	timer_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_title.add_theme_color_override("font_color", Color.CYAN)
	$MainContainer.add_child(timer_title)

	# Panel del timer
	var timer_panel = Panel.new()
	timer_panel.custom_minimum_size = Vector2(0, 100)

	# Estilo del panel de timer
	var timer_panel_style = StyleBoxFlat.new()
	timer_panel_style.bg_color = Color(0.1, 0.15, 0.2, 0.9)
	timer_panel_style.corner_radius_top_left = 8
	timer_panel_style.corner_radius_top_right = 8
	timer_panel_style.corner_radius_bottom_left = 8
	timer_panel_style.corner_radius_bottom_right = 8
	timer_panel_style.border_width_left = 2
	timer_panel_style.border_width_right = 2
	timer_panel_style.border_width_top = 2
	timer_panel_style.border_width_bottom = 2
	timer_panel_style.border_color = Color.CYAN
	timer_panel.add_theme_stylebox_override("panel", timer_panel_style)

	var timer_hbox = HBoxContainer.new()
	timer_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	timer_hbox.add_theme_constant_override("margin_left", 20)
	timer_hbox.add_theme_constant_override("margin_right", 20)
	timer_hbox.add_theme_constant_override("margin_top", 20)
	timer_hbox.add_theme_constant_override("margin_bottom", 20)
	timer_hbox.add_theme_constant_override("separation", 30)

	# Progress bar como timer visual
	var timer_progress = ProgressBar.new()
	timer_progress.min_value = 0
	timer_progress.max_value = 100
	timer_progress.value = 75  # Ejemplo: 75% completado
	timer_progress.custom_minimum_size = Vector2(300, 30)
	timer_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timer_progress.name = "customer_timer_progress"

	# Label del countdown
	var countdown_label = Label.new()
	countdown_label.text = "⏰ 3.2s restantes"
	countdown_label.add_theme_font_size_override("font_size", 18)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.name = "customer_countdown_label"
	countdown_label.add_theme_color_override("font_color", Color.YELLOW)

	timer_hbox.add_child(timer_progress)
	timer_hbox.add_child(countdown_label)
	timer_panel.add_child(timer_hbox)
	$MainContainer.add_child(timer_panel)


# T012: Sección de estadísticas en tiempo real
func _setup_stats_section():
	"""Panel de estadísticas de clientes activos"""
	var stats_title = Label.new()
	stats_title.text = "📊 ESTADO DE CLIENTES"
	stats_title.add_theme_font_size_override("font_size", 20)
	stats_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_title.add_theme_color_override("font_color", Color.GREEN)
	$MainContainer.add_child(stats_title)

	# Panel de estadísticas
	var stats_panel = Panel.new()
	stats_panel.custom_minimum_size = Vector2(0, 80)

	# Estilo del panel de estadísticas
	var stats_panel_style = StyleBoxFlat.new()
	stats_panel_style.bg_color = Color(0.1, 0.2, 0.1, 0.9)
	stats_panel_style.corner_radius_top_left = 8
	stats_panel_style.corner_radius_top_right = 8
	stats_panel_style.corner_radius_bottom_left = 8
	stats_panel_style.corner_radius_bottom_right = 8
	stats_panel_style.border_width_left = 2
	stats_panel_style.border_width_right = 2
	stats_panel_style.border_width_top = 2
	stats_panel_style.border_width_bottom = 2
	stats_panel_style.border_color = Color.GREEN
	stats_panel.add_theme_stylebox_override("panel", stats_panel_style)

	var stats_hbox = HBoxContainer.new()
	stats_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stats_hbox.add_theme_constant_override("margin_left", 20)
	stats_hbox.add_theme_constant_override("margin_right", 20)
	stats_hbox.add_theme_constant_override("margin_top", 20)
	stats_hbox.add_theme_constant_override("margin_bottom", 20)
	stats_hbox.add_theme_constant_override("separation", 30)

	# Clientes activos
	var active_customers_label = Label.new()
	active_customers_label.text = "👥 Activos: 0/10"
	active_customers_label.add_theme_font_size_override("font_size", 18)
	active_customers_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	active_customers_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	active_customers_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_customers_label.name = "active_customers_label"
	active_customers_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)

	# Ingresos por minuto
	var income_label = Label.new()
	income_label.text = "🪙 Ingresos: 0 tokens/min"
	income_label.add_theme_font_size_override("font_size", 18)
	income_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	income_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	income_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	income_label.name = "customer_income_label"
	income_label.add_theme_color_override("font_color", Color.YELLOW)

	stats_hbox.add_child(active_customers_label)
	stats_hbox.add_child(income_label)
	stats_panel.add_child(stats_hbox)
	$MainContainer.add_child(stats_panel)


# T012: Tienda de upgrades simplificada
func _setup_upgrades_shop():
	"""Tienda de upgrades con BuyCards"""
	var shop_title = Label.new()
	shop_title.text = "🛒 TIENDA DE MEJORAS"
	shop_title.add_theme_font_size_override("font_size", 20)
	shop_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_title.add_theme_color_override("font_color", Color.ORANGE)
	$MainContainer.add_child(shop_title)

	# Grid para upgrades
	var upgrades_grid = GridContainer.new()
	upgrades_grid.columns = 2
	upgrades_grid.add_theme_constant_override("h_separation", 15)
	upgrades_grid.add_theme_constant_override("v_separation", 15)

	# Upgrades disponibles
	var upgrades_data = [
		{
			"id": "new_customer",
			"name": "Nuevo Cliente",
			"description": "Añade +1 cliente activo",
			"price": 25,
			"currency": "gems",
			"emoji": "👤"
		},
		{
			"id": "faster_purchases",
			"name": "Compras Rápidas",
			"description": "Clientes compran 25% más rápido",
			"price": 50,
			"currency": "gems",
			"emoji": "⚡"
		},
		{
			"id": "higher_payments",
			"name": "Mejores Pagos",
			"description": "Clientes pagan 50% más tokens",
			"price": 75,
			"currency": "gems",
			"emoji": "💰"
		},
		{
			"id": "premium_customers",
			"name": "Clientes Premium",
			"description": "Desbloquea clientes de lujo",
			"price": 100,
			"currency": "gems",
			"emoji": "⭐"
		}
	]

	for upgrade_data in upgrades_data:
		var upgrade_card = _create_upgrade_card(upgrade_data)
		upgrades_grid.add_child(upgrade_card)

	$MainContainer.add_child(upgrades_grid)


# T012: Crear upgrade card individual
func _create_upgrade_card(upgrade_data: Dictionary) -> Panel:
	"""Crear card individual para upgrade con styling profesional"""
	var card_panel = Panel.new()
	card_panel.custom_minimum_size = Vector2(280, 120)

	# Estilo del panel según tipo
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.15, 0.1, 0.2, 0.9)  # Púrpura oscuro
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color.ORANGE
	card_panel.add_theme_stylebox_override("panel", card_style)

	# Layout interno
	var card_vbox = VBoxContainer.new()
	card_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_vbox.add_theme_constant_override("margin_left", 15)
	card_vbox.add_theme_constant_override("margin_right", 15)
	card_vbox.add_theme_constant_override("margin_top", 10)
	card_vbox.add_theme_constant_override("margin_bottom", 10)
	card_vbox.add_theme_constant_override("separation", 8)

	# Título con emoji
	var title_label = Label.new()
	title_label.text = "%s %s" % [upgrade_data.emoji, upgrade_data.name]
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color.GOLD)

	# Descripción
	var desc_label = Label.new()
	desc_label.text = upgrade_data.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)

	# Botón de compra
	var buy_button = Button.new()
	buy_button.text = "💎 %d gems" % upgrade_data.price
	buy_button.custom_minimum_size = Vector2(0, 35)
	buy_button.add_theme_font_size_override("font_size", 14)
	buy_button.name = "buy_" + upgrade_data.id

	# Estilo del botón
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.1, 0.4, 0.1, 1.0)  # Verde
	button_style.corner_radius_top_left = 6
	button_style.corner_radius_top_right = 6
	button_style.corner_radius_bottom_left = 6
	button_style.corner_radius_bottom_right = 6
	buy_button.add_theme_stylebox_override("normal", button_style)

	# Conectar señal
	buy_button.pressed.connect(_on_upgrade_purchase.bind(upgrade_data.id, upgrade_data.price))

	card_vbox.add_child(title_label)
	card_vbox.add_child(desc_label)
	card_vbox.add_child(buy_button)
	card_panel.add_child(card_vbox)

	return card_panel


# T012: Manejador de compra de upgrade
func _on_upgrade_purchase(upgrade_id: String, price: int):
	"""Manejar compra de upgrade"""
	if not game_data:
		print("❌ Error: GameData no disponible")
		return

	if not game_data.spend_gems(price):
		print("❌ No hay suficientes gems para %s (cuesta %d)" % [upgrade_id, price])
		return

	print("✅ Upgrade %s comprado por %d gems" % [upgrade_id, price])

	# Aplicar efectos del upgrade
	_apply_upgrade_effect(upgrade_id)

	# Actualizar CustomerManager si está disponible
	if customer_manager_ref and customer_manager_ref.has_method("apply_upgrade"):
		customer_manager_ref.apply_upgrade(upgrade_id)

	# Emitir señal
	autosell_upgrade_purchased.emit(upgrade_id)


# T012: Aplicar efectos de upgrade
func _apply_upgrade_effect(upgrade_id: String):
	"""Aplicar efectos específicos de cada upgrade"""
	match upgrade_id:
		"new_customer":
			if game_data.has("max_customers"):
				game_data.max_customers = min(game_data.max_customers + 1, 10)
			else:
				game_data.max_customers = 1
			print("📈 Máximo de clientes aumentado a: %d" % game_data.max_customers)

		"faster_purchases":
			if game_data.has("customer_speed_multiplier"):
				game_data.customer_speed_multiplier *= 1.25
			else:
				game_data.customer_speed_multiplier = 1.25
			print("⚡ Velocidad de compra mejorada: %.2fx" % game_data.customer_speed_multiplier)

		"higher_payments":
			if game_data.has("customer_payment_multiplier"):
				game_data.customer_payment_multiplier *= 1.5
			else:
				game_data.customer_payment_multiplier = 1.5
			print("💰 Pagos de clientes mejorados: %.2fx" % game_data.customer_payment_multiplier)

		"premium_customers":
			game_data.premium_customers_unlocked = true
			print("⭐ Clientes premium desbloqueados")


func _connect_panel_signals() -> void:
	"""Conectar señales específicas del panel"""
	# Las señales se conectan en los componentes modulares
	return


func _update_panel_data(game_data: Dictionary) -> void:
	"""T012: Actualizar datos del panel de gestión"""
	_update_timer_display(game_data)
	_update_stats_display(game_data)
	_update_upgrade_buttons(game_data)


# T012: Actualizar display de timer
func _update_timer_display(game_data: Dictionary):
	"""Actualizar progress bar y countdown del timer"""
	var timer_progress = $MainContainer.find_child("customer_timer_progress", true, false)
	var countdown_label = $MainContainer.find_child("customer_countdown_label", true, false)

	if timer_progress and countdown_label:
		# Simular timer (esto se conectaría con CustomerManager)
		var time_remaining = game_data.get("customer_timer_remaining", 5.0)
		var total_time = game_data.get("customer_timer_total", 10.0)
		var progress_percent = ((total_time - time_remaining) / total_time) * 100

		timer_progress.value = progress_percent
		countdown_label.text = "⏰ %.1fs restantes" % time_remaining

		# Color coding del countdown
		if time_remaining <= 2.0:
			countdown_label.add_theme_color_override("font_color", Color.RED)
		elif time_remaining <= 5.0:
			countdown_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			countdown_label.add_theme_color_override("font_color", Color.GREEN)


# T012: Actualizar estadísticas de clientes
func _update_stats_display(game_data: Dictionary):
	"""Actualizar displays de clientes activos e ingresos"""
	var active_customers_label = $MainContainer.find_child("active_customers_label", true, false)
	var income_label = $MainContainer.find_child("customer_income_label", true, false)

	if active_customers_label:
		var active = game_data.get("active_customers", 0)
		var max_customers = game_data.get("max_customers", 10)
		active_customers_label.text = "👥 Activos: %d/%d" % [active, max_customers]

		# Color coding según capacidad
		var usage_percent = float(active) / float(max_customers)
		if usage_percent >= 0.8:
			active_customers_label.add_theme_color_override("font_color", Color.GREEN)
		elif usage_percent >= 0.5:
			active_customers_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			active_customers_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)

	if income_label:
		var base_rate = 2.5  # tokens por minuto por cliente
		var active = game_data.get("active_customers", 0)
		var multiplier = game_data.get("customer_payment_multiplier", 1.0)
		var total_income = active * base_rate * multiplier

		income_label.text = "🪙 Ingresos: %.1f tokens/min" % total_income

		# Color coding según ingresos
		if total_income >= 20:
			income_label.add_theme_color_override("font_color", Color.GREEN)
		elif total_income >= 10:
			income_label.add_theme_color_override("font_color", Color.YELLOW)
		else:
			income_label.add_theme_color_override("font_color", Color.ORANGE)


# T012: Actualizar estado de botones de upgrade
func _update_upgrade_buttons(game_data: Dictionary):
	"""Actualizar estado de botones según gems disponibles"""
	var gems = game_data.get("gems", 0)

	# Lista de upgrades y sus precios
	var upgrades = [
		{"id": "new_customer", "price": 25},
		{"id": "faster_purchases", "price": 50},
		{"id": "higher_payments", "price": 75},
		{"id": "premium_customers", "price": 100}
	]

	for upgrade in upgrades:
		var button = $MainContainer.find_child("buy_" + upgrade.id, true, false)
		if button:
			var can_afford = gems >= upgrade.price
			button.disabled = not can_afford
			button.modulate = Color.WHITE if can_afford else Color.GRAY

			if not can_afford:
				var missing = upgrade.price - gems
				button.text = "💎 %d gems (-%d)" % [upgrade.price, missing]
			else:
				button.text = "💎 %d gems" % upgrade.price


# =============================================================================
# T012 - MÉTODOS LEGACY SIMPLIFICADOS (backward compatibility)
# =============================================================================


func update_customer_displays(game_data: Dictionary):
	"""Legacy method - redirige a _update_stats_display"""
	_update_stats_display(game_data)


func update_timer_displays(game_data: Dictionary):
	"""Legacy method - redirige a _update_timer_display"""
	_update_timer_display(game_data)


func update_upgrade_displays(game_data: Dictionary):
	"""Legacy method - redirige a _update_upgrade_buttons"""
	_update_upgrade_buttons(game_data)


func update_automation_displays(game_data: Dictionary):
	"""Legacy method - no-op en T012"""
	return


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
