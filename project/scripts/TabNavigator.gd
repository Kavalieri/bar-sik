extends Control
## TabNavigator - Sistema de navegación por pestañas para BAR-SIK
## Maneja la navegación entre GenerationPanel, ProductionPanel y SalesPanel

# Preloads
const CurrencyDisplay = preload("res://scripts/ui/CurrencyDisplay.gd")

@onready var pause_button: Button = $MainContainer/TopPanel/PauseButton
@onready var save_menu_button: MenuButton = $MainContainer/TopPanel/SaveMenuButton
@onready var prestige_button: Button = $MainContainer/TopPanel/PrestigeButton
@onready var missions_button: Button = $MainContainer/TopPanel/MissionsButton  # T019
@onready var automation_button: Button = $MainContainer/TopPanel/AutomationButton  # T022
@onready var achievements_button: Button = $MainContainer/TopPanel/AchievementsButton  # T029
@onready var currency_container: HBoxContainer = $MainContainer/TopPanel/CurrencyContainer

# Botones de pestañas (ahora en la parte inferior)
@onready var generation_tab: Button = $MainContainer/BottomNavigation/GenerationTab
@onready var production_tab: Button = $MainContainer/BottomNavigation/ProductionTab
@onready var sales_tab: Button = $MainContainer/BottomNavigation/SalesTab
@onready var customers_tab: Button = $MainContainer/BottomNavigation/CustomersTab

# Paneles de contenido
@onready var generation_panel: Control = $MainContainer/ContentContainer/GenerationPanel
@onready var production_panel: Control = $MainContainer/ContentContainer/ProductionPanel
@onready var sales_panel: Control = $MainContainer/ContentContainer/SalesPanel
@onready var customers_panel: Control = $MainContainer/ContentContainer/CustomersPanel

# Variables para el sistema
var current_tab: String = "generation"
var money_label: Label  # LEGACY - mantener por compatibilidad
var cash_display: Control
var tokens_display: Control
var gems_display: Control

# Señales para comunicación con GameScene
signal tab_changed(tab_name: String)
signal pause_pressed
signal save_data_reset_requested
signal new_save_slot_requested(slot_name: String)
signal prestige_requested  # T015 - Señal para mostrar panel de prestigio
signal missions_requested  # T019 - Señal para mostrar panel de misiones y logros
signal automation_requested  # T022 - Señal para mostrar panel de automatización
signal achievements_requested  # T029 - Señal para mostrar panel de achievements


func _ready() -> void:
	print("🔄 TabNavigator inicializado")
	_setup_ui()
	_connect_signals()
	_show_tab("generation")


func _setup_ui() -> void:
	# Setup triple currency displays (T004)
	_setup_currency_displays()

	# Setup botones con tamaños móviles
	_setup_mobile_friendly_tabs()

	# Setup pause button
	pause_button.pressed.connect(_on_pause_pressed)

	# T015 - Setup prestige button
	prestige_button.pressed.connect(_on_prestige_pressed)

	# T019 - Setup missions button
	missions_button.pressed.connect(_on_missions_pressed)

	# T022 - Setup automation button
	automation_button.pressed.connect(_on_automation_pressed)

	# T029 - Setup achievements button
	achievements_button.pressed.connect(_on_achievements_pressed)

	# Setup menú de guardado
	_setup_save_menu()


func _setup_currency_displays() -> void:
	"""T004 - Configurar displays de triple moneda"""
	print("💰 T004 - Configurando triple currency display")

	# Limpiar container
	for child in currency_container.get_children():
		child.queue_free()

	# Crear displays usando el componente CurrencyDisplay
	cash_display = CurrencyDisplay.new()
	cash_display.setup_currency("cash")
	cash_display.show_label = false  # Solo mostrar icono y cantidad para ahorrar espacio
	currency_container.add_child(cash_display)

	tokens_display = CurrencyDisplay.new()
	tokens_display.setup_currency("tokens")
	tokens_display.show_label = false
	currency_container.add_child(tokens_display)

	gems_display = CurrencyDisplay.new()
	gems_display.setup_currency("gems")
	gems_display.show_label = false
	currency_container.add_child(gems_display)

	# Mantener money_label legacy para compatibilidad
	money_label = Label.new()
	money_label.add_theme_font_size_override("font_size", 28)
	money_label.visible = false  # Oculto porque usamos CurrencyDisplay
	currency_container.add_child(money_label)

	print("✅ T004 - Triple currency display configurado")


func _setup_mobile_friendly_tabs() -> void:
	"""Configurar tabs con tamaños móviles"""
	var tab_buttons = [generation_tab, production_tab, sales_tab, customers_tab]

	for button in tab_buttons:
		if button:
			button.set_custom_minimum_size(Vector2(0, 60))  # Altura móvil
			button.add_theme_font_size_override("font_size", 16)  # Fuente móvil

	# Botón de pausa más grande
	pause_button.set_custom_minimum_size(Vector2(50, 50))
	pause_button.add_theme_font_size_override("font_size", 20)


func _connect_signals() -> void:
	# Conectar botones de pestañas
	generation_tab.pressed.connect(_on_generation_tab_pressed)
	production_tab.pressed.connect(_on_production_tab_pressed)
	sales_tab.pressed.connect(_on_sales_tab_pressed)
	customers_tab.pressed.connect(_on_customers_tab_pressed)


func _show_tab(tab_name: String) -> void:
	# Ocultar todos los paneles
	generation_panel.visible = false
	production_panel.visible = false
	sales_panel.visible = false
	customers_panel.visible = false

	# Deseleccionar todos los botones
	generation_tab.button_pressed = false
	production_tab.button_pressed = false
	sales_tab.button_pressed = false
	customers_tab.button_pressed = false

	# Mostrar panel seleccionado y activar botón
	match tab_name:
		"generation":
			generation_panel.visible = true
			generation_tab.button_pressed = true
		"production":
			production_panel.visible = true
			production_tab.button_pressed = true
		"sales":
			sales_panel.visible = true
			sales_tab.button_pressed = true
		"customers":
			customers_panel.visible = true
			customers_tab.button_pressed = true

	current_tab = tab_name
	tab_changed.emit(tab_name)
	print("📱 Cambiado a pestaña: %s" % tab_name)


func update_money_display(amount: float) -> void:
	# Legacy method - mantener compatibilidad actualizando cash display
	update_currency_display("cash", int(amount))


## T004 - Métodos para triple currency display
func update_currency_display(currency_type: String, amount: int) -> void:
	"""Actualizar display de una moneda específica"""
	match currency_type:
		"cash":
			if cash_display and cash_display.has_method("set_amount"):
				cash_display.set_amount(float(amount))
		"tokens":
			if tokens_display and tokens_display.has_method("set_amount"):
				tokens_display.set_amount(float(amount))
		"gems":
			if gems_display and gems_display.has_method("set_amount"):
				gems_display.set_amount(float(amount))

	# También actualizar money_label legacy si es cash
	if currency_type == "cash" and money_label:
		money_label.text = "💰 $%s" % GameUtils.format_large_number(amount)


func update_all_currencies(cash: int, tokens: int, gems: int) -> void:
	"""T004 - Actualizar todos los displays de currency de una vez"""
	update_currency_display("cash", cash)
	update_currency_display("tokens", tokens)
	update_currency_display("gems", gems)


func get_current_panel() -> Control:
	match current_tab:
		"generation":
			return generation_panel
		"production":
			return production_panel
		"sales":
			return sales_panel
	return generation_panel


# Eventos de botones
func _on_generation_tab_pressed() -> void:
	_show_tab("generation")


func _on_production_tab_pressed() -> void:
	_show_tab("production")


func _on_sales_tab_pressed() -> void:
	_show_tab("sales")


func _on_customers_tab_pressed() -> void:
	_show_tab("customers")


func _on_pause_pressed() -> void:
	print("⏸️ Botón pausa presionado")
	pause_pressed.emit()


# T015 - Handler para botón de prestigio
func _on_prestige_pressed() -> void:
	"""Emitir señal para mostrar panel de prestigio"""
	print("⭐ Botón de prestigio presionado")
	prestige_requested.emit()


# T019 - Signal handler para botón de misiones
func _on_missions_pressed() -> void:
	"""Emitir señal para mostrar panel de misiones y logros"""
	print("🎮 Botón de misiones presionado")
	missions_requested.emit()


# T022 - Signal handler para botón de automatización
func _on_automation_pressed() -> void:
	"""Emitir señal para mostrar panel de automatización"""
	print("🎛️ Botón de automatización presionado")
	automation_requested.emit()


# T029 - Signal handler para botón de achievements
func _on_achievements_pressed() -> void:
	"""Emitir señal para mostrar panel de achievements"""
	print("🏆 Botón de achievements presionado")
	achievements_requested.emit()


## MENÚ DE GUARDADO
func _setup_save_menu() -> void:
	var popup = save_menu_button.get_popup()

	# Limpiar opciones existentes
	popup.clear()

	# Agregar opciones del menú
	popup.add_item("🗑️ Resetear Datos", 0)
	popup.add_separator()
	popup.add_item("💾 Nuevo Slot", 1)
	popup.add_item("🔄 Cargar Slot 1", 2)
	popup.add_item("🔄 Cargar Slot 2", 3)
	popup.add_separator()
	popup.add_item("📁 Guardar Manualmente", 4)

	# Conectar señal del popup
	popup.id_pressed.connect(_on_save_menu_option_selected)


func _on_save_menu_option_selected(id: int) -> void:
	match id:
		0:  # Resetear datos
			_confirm_reset_data()
		1:  # Nuevo slot
			_request_new_slot()
		2:  # Cargar slot 1
			_load_slot(1)
		3:  # Cargar slot 2
			_load_slot(2)
		4:  # Guardar manualmente
			_save_current_data()


func _confirm_reset_data() -> void:
	print("🗑️ Solicitando reset de datos...")
	# Emitir señal para que GameScene maneje el reset
	save_data_reset_requested.emit()


func _request_new_slot() -> void:
	print("💾 Solicitando nuevo slot...")
	new_save_slot_requested.emit("Nuevo Slot")


func _load_slot(slot_id: int) -> void:
	print("🔄 Cargando slot: ", slot_id)
	if Router:
		Router.switch_save_slot(slot_id)


func _save_current_data() -> void:
	print("📁 Guardando datos manualmente...")
	if GameEvents:
		GameEvents.save_data_requested.emit()
