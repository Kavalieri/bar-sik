extends Control
## TabNavigator - Sistema de navegación por pestañas para BAR-SIK
## Maneja la navegación entre GenerationPanel, ProductionPanel y SalesPanel

@onready var pause_button: Button = $MainContainer/TopPanel/PauseButton
@onready var currency_container: HBoxContainer = $MainContainer/TopPanel/CurrencyContainer

# Botones de pestañas
@onready var generation_tab: Button = $MainContainer/TabButtons/GenerationTab
@onready var production_tab: Button = $MainContainer/TabButtons/ProductionTab
@onready var sales_tab: Button = $MainContainer/TabButtons/SalesTab

# Paneles de contenido
@onready var generation_panel: Control = $MainContainer/ContentContainer/GenerationPanel
@onready var production_panel: Control = $MainContainer/ContentContainer/ProductionPanel
@onready var sales_panel: Control = $MainContainer/ContentContainer/SalesPanel

# Variables para el sistema
var current_tab: String = "generation"
var money_label: Label

# Señales para comunicación con GameScene
signal tab_changed(tab_name: String)
signal pause_pressed


func _ready() -> void:
	print("🔄 TabNavigator inicializado")
	_setup_ui()
	_connect_signals()
	_show_tab("generation")


func _setup_ui() -> void:
	# Setup dinero display
	money_label = Label.new()
	money_label.add_theme_font_size_override("font_size", 20)
	currency_container.add_child(money_label)

	# Setup pause button
	pause_button.pressed.connect(_on_pause_pressed)


func _connect_signals() -> void:
	# Conectar botones de pestañas
	generation_tab.pressed.connect(_on_generation_tab_pressed)
	production_tab.pressed.connect(_on_production_tab_pressed)
	sales_tab.pressed.connect(_on_sales_tab_pressed)


func _show_tab(tab_name: String) -> void:
	# Ocultar todos los paneles
	generation_panel.visible = false
	production_panel.visible = false
	sales_panel.visible = false

	# Deseleccionar todos los botones
	generation_tab.button_pressed = false
	production_tab.button_pressed = false
	sales_tab.button_pressed = false

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

	current_tab = tab_name
	tab_changed.emit(tab_name)
	print("📱 Cambiado a pestaña: %s" % tab_name)


func update_money_display(amount: float) -> void:
	if money_label:
		money_label.text = "💰 $%.2f" % amount


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


func _on_pause_pressed() -> void:
	pause_pressed.emit()
