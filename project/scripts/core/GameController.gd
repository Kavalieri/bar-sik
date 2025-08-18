extends Control
class_name GameController
## GameController - Controlador principal del juego (versión ligera)
## Coordina managers y maneja la UI principal

@onready var tab_navigator: Control = $TabNavigator

# Managers del juego
var game_data: GameData
var generator_manager: GeneratorManager
var production_manager: ProductionManager
var sales_manager: SalesManager
var customer_manager: CustomerManager

# Referencias a paneles UI
var generation_panel: Control
var production_panel: Control
var sales_panel: Control
var customers_panel: Control

# Timers del sistema
var save_timer: Timer

func _ready() -> void:
	print("🎮 GameController inicializado - Arquitectura modular")

	_setup_game_data()
	_setup_managers()
	_setup_ui_system()
	_setup_save_timer()

	print("✅ GameController listo - Sistema modular activo")

## Configurar datos del juego
func _setup_game_data() -> void:
	game_data = GameData.new()

	# Cargar datos guardados si existen
	if SaveSystem:
		var loaded_data = SaveSystem.load_game_data()
		if loaded_data and loaded_data.size() > 0:
			game_data.from_dict(loaded_data)
			print("💾 Datos cargados del sistema de guardado")

	print("🎯 Datos del juego configurados")

## Configurar managers
func _setup_managers() -> void:
	# Crear managers
	generator_manager = GeneratorManager.new()
	production_manager = ProductionManager.new()
	sales_manager = SalesManager.new()
	customer_manager = CustomerManager.new()

	# Agregar al árbol de nodos
	add_child(generator_manager)
	add_child(production_manager)
	add_child(sales_manager)
	add_child(customer_manager)

	# Asignar datos del juego a todos los managers
	generator_manager.set_game_data(game_data)
	production_manager.set_game_data(game_data)
	sales_manager.set_game_data(game_data)
	customer_manager.set_game_data(game_data)

	# Conectar señales de managers
	_connect_manager_signals()

	print("🏭 Managers configurados y conectados")

## Conectar señales de los managers
func _connect_manager_signals() -> void:
	# Señales de generadores
	generator_manager.generator_purchased.connect(_on_generator_purchased)
	generator_manager.resource_generated.connect(_on_resource_generated)

	# Señales de producción
	production_manager.station_purchased.connect(_on_station_purchased)
	production_manager.product_produced.connect(_on_product_produced)
	production_manager.station_unlocked.connect(_on_station_unlocked)

	# Señales de ventas
	sales_manager.item_sold.connect(_on_item_sold)

	# Señales de clientes
	customer_manager.customer_served.connect(_on_customer_served)
	customer_manager.upgrade_purchased.connect(_on_customer_upgrade_purchased)

## Configurar sistema de UI
func _setup_ui_system() -> void:
	# Obtener referencias a paneles
	generation_panel = tab_navigator.get_node("MainContainer/ContentContainer/GenerationPanel").get_child(0)
	production_panel = tab_navigator.get_node("MainContainer/ContentContainer/ProductionPanel").get_child(0)
	sales_panel = tab_navigator.get_node("MainContainer/ContentContainer/SalesPanel").get_child(0)
	customers_panel = tab_navigator.get_node("MainContainer/ContentContainer/CustomersPanel").get_child(0)

	# Conectar señales del TabNavigator
	tab_navigator.tab_changed.connect(_on_tab_changed)
	tab_navigator.pause_pressed.connect(_on_pause_pressed)
	tab_navigator.save_data_reset_requested.connect(_on_reset_data_requested)

	# Configurar paneles con datos iniciales
	_setup_panels()

	# Primera actualización de displays
	_update_all_displays()

	print("📱 Sistema UI configurado")

## Configurar paneles con managers
func _setup_panels() -> void:
	# Setup GenerationPanel
	if generation_panel.has_method("setup_resources"):
		generation_panel.setup_resources(game_data.to_dict())
		generation_panel.setup_generators(generator_manager.get_generator_definitions())
		generation_panel.generator_purchased.connect(_on_ui_generator_purchase_requested)

	# Setup ProductionPanel
	if production_panel.has_method("setup_products"):
		production_panel.setup_products(game_data.to_dict())
		production_panel.setup_stations(production_manager.get_station_definitions())
		production_panel.station_purchased.connect(_on_ui_station_purchase_requested)
		production_panel.manual_production_requested.connect(_on_ui_manual_production_requested)

	# Setup SalesPanel
	if sales_panel.has_method("item_sell_requested"):
		sales_panel.item_sell_requested.connect(_on_ui_item_sell_requested)

	# Setup CustomersPanel
	if customers_panel.has_method("setup_autosell_upgrades"):
		customers_panel.setup_autosell_upgrades(game_data.to_dict())
		customers_panel.autosell_upgrade_purchased.connect(_on_ui_customer_upgrade_requested)

## Configurar timer de guardado automático
func _setup_save_timer() -> void:
	save_timer = Timer.new()
	save_timer.wait_time = 30.0
	save_timer.autostart = true
	save_timer.timeout.connect(_save_game)
	add_child(save_timer)

	print("💾 Timer de guardado automático configurado")

## Actualizar todas las interfaces
func _update_all_displays() -> void:
	var game_dict = game_data.to_dict()

	# Actualizar display de dinero
	tab_navigator.update_money_display(game_data.money)

	# Actualizar paneles
	if generation_panel.has_method("update_resource_displays"):
		generation_panel.update_resource_displays(game_dict)
		generation_panel.update_generator_displays(generator_manager.get_generator_definitions(), game_dict)

	if production_panel.has_method("update_product_displays"):
		production_panel.update_product_displays(game_dict)
		production_panel.update_station_interfaces(production_manager.get_station_definitions(), game_dict)

	if sales_panel.has_method("update_statistics"):
		sales_panel.update_statistics(game_dict)
		sales_panel.update_sell_interfaces(game_dict)

	if customers_panel.has_method("update_customer_display"):
		customers_panel.update_customer_display(game_dict, customer_manager.get_timer_progress())

	# Verificar desbloqueos automáticamente después de cada actualización
	production_manager.check_unlock_stations()

## === EVENTOS DE MANAGERS ===

func _on_generator_purchased(generator_id: String, quantity: int) -> void:
	print("✅ Generador comprado: %dx %s" % [quantity, generator_id])
	_update_all_displays()

func _on_resource_generated(_resource_type: String, _amount: int) -> void:
	# Los parámetros se reciben pero no se usan directamente ya que 
	# la información está disponible en game_data actualizado
	# Solo actualizar recursos, no toda la UI
	if generation_panel.has_method("update_resource_displays"):
		generation_panel.update_resource_displays(game_data.to_dict())
	if production_panel.has_method("update_product_displays"):
		production_panel.update_product_displays(game_data.to_dict())

func _on_station_purchased(station_id: String) -> void:
	print("✅ Estación comprada: %s" % station_id)
	_update_all_displays()

func _on_station_unlocked(station_id: String) -> void:
	print("🔓 Estación desbloqueada: %s" % station_id)
	_update_all_displays()

func _on_product_produced(product_type: String, amount: int) -> void:
	print("🍺 Producido: %dx %s" % [amount, product_type])
	_update_all_displays()

func _on_item_sold(item_type: String, item_name: String, quantity: int, total_earned: float) -> void:
	print("💰 Vendido: %dx %s (%s) por $%.2f" % [quantity, item_name, item_type, total_earned])
	_update_all_displays()

func _on_customer_served(customer_type: String, products_bought: Array, total_earned: float) -> void:
	print("👤 %s compró %d productos por $%.2f" % [customer_type, products_bought.size(), total_earned])
	_update_all_displays()

func _on_customer_upgrade_purchased(upgrade_id: String, cost: float) -> void:
	print("⬆️ Upgrade de cliente: %s por $%.0f" % [upgrade_id, cost])
	_update_all_displays()

## === EVENTOS DE UI ===

func _on_ui_generator_purchase_requested(generator_index: int, quantity: int) -> void:
	var generator_defs = generator_manager.get_generator_definitions()
	if generator_index < generator_defs.size():
		var generator_id = generator_defs[generator_index].id
		generator_manager.purchase_generator(generator_id, quantity)

func _on_ui_station_purchase_requested(station_index: int) -> void:
	var station_defs = production_manager.get_station_definitions()
	if station_index < station_defs.size():
		var station_id = station_defs[station_index].id
		production_manager.purchase_station(station_id)

func _on_ui_manual_production_requested(station_index: int, quantity: int) -> void:
	var station_defs = production_manager.get_station_definitions()
	if station_index < station_defs.size():
		var station_id = station_defs[station_index].id
		production_manager.manual_production(station_id, quantity)

func _on_ui_item_sell_requested(item_type: String, item_name: String, quantity: int) -> void:
	sales_manager.sell_item(item_type, item_name, quantity)

func _on_ui_customer_upgrade_requested(upgrade_id: String) -> void:
	customer_manager.purchase_upgrade(upgrade_id)

## === EVENTOS DE SISTEMA ===

func _on_tab_changed(tab_name: String) -> void:
	print("📱 Cambiado a pestaña: %s" % tab_name)

func _on_pause_pressed() -> void:
	print("⏸️ Juego pausado")
	get_tree().paused = not get_tree().paused

func _on_reset_data_requested() -> void:
	print("🗑️ Resetear datos solicitado")
	game_data = GameData.new()

	# Actualizar managers con datos nuevos
	generator_manager.set_game_data(game_data)
	production_manager.set_game_data(game_data)
	sales_manager.set_game_data(game_data)
	customer_manager.set_game_data(game_data)

	_update_all_displays()

## Guardado automático
func _save_game() -> void:
	if SaveSystem:
		SaveSystem.save_data(game_data.to_dict())
		print("💾 Juego guardado automáticamente")

## Guardar al cerrar
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
		get_tree().quit()
