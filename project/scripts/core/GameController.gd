extends Control
class_name GameController
## GameController - Coordinador principal del juego (versión ligera)
## Coordina managers y maneja la UI principal

# Escenas precargadas
const PAUSE_MENU_SCENE = preload("res://scenes/PauseMenu.tscn")

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

# Cache para sistema reactivo
var cached_money: float = 0.0


func _ready() -> void:
	print_rich("[color=yellow]🎮 GameController._ready() iniciado[/color]")

	# Info de debugging sin breakpoints automáticos
	debug_game_info("GameController._ready inicio")

	_setup_game_data()
	_setup_managers()
	_setup_state_manager()  # NUEVO: Sistema de estado centralizado
	_setup_ui_system()
	_setup_save_timer()

	# TEMPORAL: Debug del sistema de generación
	var debug_generator = preload("res://scripts/DebugGeneratorTest.gd").new()
	add_child(debug_generator)
	add_to_group("game_controller")  # Para que DebugGeneratorTest pueda encontrarnos

	# TEMPORAL: Resumen de reparaciones del sistema
	var repair_summary = preload("res://scripts/SystemRepairSummary.gd").new()
	add_child(repair_summary)

	print_rich("[color=green]✅ GameController listo - Sistema modular activo[/color]")
	debug_game_state()


## === DEBUGGING FUNCTIONS ===


# Función para mostrar info sin breakpoints automáticos
func debug_game_info(location: String):
	print_rich("[color=cyan]📍 DEBUG INFO: %s[/color]" % location)
	print_stack()


# Función para inspeccionar variables en vivo
func debug_game_state():
	print_rich("[color=cyan]📊 ESTADO DEL JUEGO COMPLETO[/color]")
	print_rich("💰 Dinero: %s" % game_data.money)
	print_rich("🌾 Recursos: %s" % game_data.resources)
	print_rich("🏭 Generadores: %s" % game_data.generators)
	print_rich("🏢 Estaciones: %s" % game_data.stations)
	print_rich("📊 Estadísticas: %s" % game_data.statistics)
	print_rich("🎯 Upgrades: %s" % game_data.upgrades)


# Función para pausar y mostrar info (inteligente)
func debug_pause_and_inspect(location: String, force: bool = false):
	print_rich("[color=red]⏸️  DEBUG INFO en: %s[/color]" % location)
	print_stack()

	# Solo breakpoint si está forzado o la variable de entorno está activa
	if force or OS.has_environment("GODOT_DEBUG_BREAKPOINTS"):
		print_rich("[color=yellow]🛑 BREAKPOINT ACTIVADO - VS Code tomará control[/color]")
		breakpoint  # ¡Pausa aquí y VS Code lo detecta!
	else:
		print_rich("[color=cyan]ℹ️  Breakpoint deshabilitado (modo normal)[/color]")


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
	customer_manager.set_production_manager(production_manager)  # Para acceder a definiciones de estaciones

	# Configurar StockManager singleton
	StockManager.set_game_data(game_data)
	print("📦 StockManager configurado con GameData")

	# CRÍTICO: Conectar señal de StockManager para actualizaciones en tiempo real
	StockManager.stock_updated.connect(_on_stock_updated)

	# Conectar señales de managers
	_connect_manager_signals()

	print("🏭 Managers configurados y conectados")


## Configurar sistema de estado centralizado
func _setup_state_manager() -> void:
	"""Configura el GameStateManager para gestión reactiva de estado"""

	# Conectar señales de cambio de estado
	GameStateManager.money_changed.connect(_on_money_changed)
	GameStateManager.resources_changed.connect(_on_resources_changed)
	GameStateManager.generators_changed.connect(_on_generators_changed)
	GameStateManager.stations_changed.connect(_on_stations_changed)

	print("🔄 GameStateManager configurado - Sistema reactivo activo")


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
	generation_panel = (
		tab_navigator.get_node("MainContainer/ContentContainer/GenerationPanel").get_child(0)
	)
	production_panel = (
		tab_navigator.get_node("MainContainer/ContentContainer/ProductionPanel").get_child(0)
	)
	sales_panel = tab_navigator.get_node("MainContainer/ContentContainer/SalesPanel").get_child(0)
	customers_panel = (
		tab_navigator.get_node("MainContainer/ContentContainer/CustomersPanel").get_child(0)
	)

	# Configurar GameStateManager con referencias a paneles
	GameStateManager.setup_panel_references(
		{
			"generation": generation_panel,
			"production": production_panel,
			"sales": sales_panel,
			"customers": customers_panel,
			"tab_navigator": tab_navigator
		}
	)

	# Inicializar estado en GameStateManager
	GameStateManager.update_game_state(game_data.to_dict())

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
	print("🔧 _setup_panels iniciado")

	# Setup GenerationPanel (nueva arquitectura modular)
	if generation_panel and generation_panel.has_method("set_generator_manager"):
		print("📦 Conectando GenerationPanel con GeneratorManager...")
		generation_panel.set_generator_manager(generator_manager)
		print("✅ GeneratorManager conectado a GenerationPanel")

		# Reconectar señal si no está conectada y existe
		if (generation_panel.has_signal("generator_purchased") and
			not generation_panel.generator_purchased.is_connected(_on_ui_generator_purchase_requested)):
			generation_panel.generator_purchased.connect(_on_ui_generator_purchase_requested)
			print("✅ Señal generator_purchased reconectada")
	else:
		print("⚠️ GenerationPanel no tiene método set_generator_manager o es null")

	# Setup ProductionPanel (nueva arquitectura modular)
	if production_panel.has_method("set_production_manager"):
		print("🔧 Conectando ProductionPanel con ProductionManager...")
		production_panel.set_production_manager(production_manager)
		print("✅ ProductionManager conectado a ProductionPanel")

		# Conectar señales solo si existen y no están ya conectadas
		if (
			production_panel.has_signal("station_purchased")
			and not production_panel.station_purchased.is_connected(
				_on_ui_station_purchase_requested
			)
		):
			production_panel.station_purchased.connect(_on_ui_station_purchase_requested)
		if (
			production_panel.has_signal("manual_production_requested")
			and not production_panel.manual_production_requested.is_connected(
				_on_ui_manual_production_requested
			)
		):
			production_panel.manual_production_requested.connect(_on_ui_manual_production_requested)

	# Setup SalesPanel (nueva arquitectura modular)
	if sales_panel.has_method("set_sales_manager"):
		print("💰 Conectando SalesPanel con SalesManager...")
		sales_panel.set_sales_manager(sales_manager)
		print("✅ SalesManager conectado a SalesPanel")

		# Conectar señales si existen
		if (
			sales_panel.has_signal("item_sell_requested")
			and not sales_panel.item_sell_requested.is_connected(_on_ui_item_sell_requested)
		):
			sales_panel.item_sell_requested.connect(_on_ui_item_sell_requested)
			print("✅ Señal item_sell_requested conectada")

	# Setup CustomersPanel (nueva arquitectura modular)
	if customers_panel.has_method("set_customer_manager"):
		print("� Conectando CustomersPanel con CustomerManager...")
		customers_panel.set_customer_manager(customer_manager)
		print("✅ CustomerManager conectado a CustomersPanel")

		# Conectar señales si existen
		if (
			customers_panel.has_signal("autosell_upgrade_purchased")
			and not customers_panel.autosell_upgrade_purchased.is_connected(
				_on_ui_customer_upgrade_requested
			)
		):
			customers_panel.autosell_upgrade_purchased.connect(_on_ui_customer_upgrade_requested)
			print("✅ Señal autosell_upgrade_purchased conectada")


## Configurar timer de guardado automático
func _setup_save_timer() -> void:
	save_timer = Timer.new()
	save_timer.wait_time = 10.0  # MEJORA: 30s → 10s para menor pérdida de progreso
	save_timer.autostart = true
	save_timer.timeout.connect(_save_game)
	add_child(save_timer)

	print("💾 Timer de guardado automático configurado (cada 10s)")


## Actualizar todas las interfaces
func _update_all_displays() -> void:
	var game_dict = game_data.to_dict()

	# NUEVO: Actualizar GameStateManager (sistema reactivo)
	GameStateManager.update_game_state(game_dict)
	cached_money = game_data.money

	# Actualizar display de dinero
	tab_navigator.update_money_display(game_data.money)

	# Actualizar paneles
	if generation_panel.has_method("update_resource_displays"):
		generation_panel.update_resource_displays(game_dict)
		if generation_panel.has_method("update_generator_displays"):
			generation_panel.update_generator_displays(game_dict)

	if production_panel.has_method("update_product_displays"):
		production_panel.update_product_displays(game_dict)
		if production_panel.has_method("update_station_displays"):
			production_panel.update_station_displays(game_dict)

	if sales_panel.has_method("update_inventory_displays"):
		sales_panel.update_inventory_displays(game_dict)

	if customers_panel.has_method("update_customer_display"):
		customers_panel.update_customer_display(game_dict, customer_manager.get_timer_progress())

	# Actualizar interfaces de ofertas en CustomersPanel
	if customers_panel.has_method("update_offer_interfaces"):
		customers_panel.update_offer_interfaces(game_dict)

	# NOTA: check_unlock_stations() se llama desde otros lugares para evitar recursión infinita


## Actualizar solo el panel de generadores (para recursos generados)
func _update_generation_panel() -> void:
	if generation_panel.has_method("update_resource_displays"):
		var game_dict = game_data.to_dict()
		generation_panel.update_resource_displays(game_dict)
		generation_panel.update_generator_displays(
			generator_manager.get_generator_definitions(), game_dict
		)


## === EVENTOS DE MANAGERS ===


func _on_generator_purchased(generator_id: String, quantity: int) -> void:
	print("✅ Generador comprado: %dx %s" % [quantity, generator_id])
	_update_all_displays()


func _on_resource_generated(resource_type: String, amount: int) -> void:
	"""Maneja la generación de recursos en tiempo real"""
	print("🔄 Recurso generado: %dx %s" % [amount, resource_type])

	# La actualización real la maneja _on_stock_updated que se dispara desde StockManager
	# Solo necesitamos actualizar el dinero por si hay ventas automáticas
	tab_navigator.update_money_display(game_data.money)


func _on_station_purchased(station_id: String) -> void:
	print("✅ Estación comprada: %s" % station_id)
	_update_all_displays()


func _on_station_unlocked(station_id: String) -> void:
	print("🔓 Estación desbloqueada: %s" % station_id)
	_update_all_displays()


func _on_product_produced(product_type: String, amount: int) -> void:
	print("🍺 Producido: %dx %s" % [amount, product_type])
	_update_all_displays()


func _on_item_sold(
	item_type: String, item_name: String, quantity: int, total_earned: float
) -> void:
	print("💰 Vendido: %dx %s (%s) por $%.2f" % [quantity, item_name, item_type, total_earned])
	_update_all_displays()
	# MEJORA: Guardar después de ventas importantes (>$10)
	if total_earned >= 10.0:
		_save_game_immediate()


func _on_customer_served(
	customer_type: String, products_bought: Array, total_earned: float
) -> void:
	print(
		"👤 %s compró %d productos por $%.2f" % [customer_type, products_bought.size(), total_earned]
	)
	_update_all_displays()
	# MEJORA: Guardar después de ventas importantes (>$5)
	if total_earned >= 5.0:
		_save_game_immediate()


func _on_customer_upgrade_purchased(upgrade_id: String, cost: float) -> void:
	print("⬆️ Upgrade de cliente: %s por $%.0f" % [upgrade_id, cost])
	_update_all_displays()
	_save_game_immediate()  # MEJORA: Siempre guardar después de upgrades


## === EVENTOS DE UI ===


func _on_ui_generator_purchase_requested(generator_id: String, quantity: int) -> void:
	"""Manejar solicitud de compra de generador desde UI (usando ID directamente)"""
	print("🛒 UI solicitó compra de generador: %s x%d" % [generator_id, quantity])
	var success = generator_manager.purchase_generator(generator_id, quantity)

	# Actualizar UI inmediatamente después de compra exitosa
	if success:
		print("🔄 Actualizando UI después de compra de generador")
		_update_all_displays()
		_save_game_immediate()  # MEJORA: Guardar inmediatamente después de compra crítica
	else:
		print("❌ No se pudo completar la compra: %s x%d" % [generator_id, quantity])


func _on_ui_station_purchase_requested(station_id: String, multiplier: int = 1) -> void:
	print("🏭 Procesando compra de estación: %s x%d" % [station_id, multiplier])
	var success = production_manager.purchase_station(station_id)
	if success:
		print("✅ Estación comprada: %s" % station_id)
		_save_game_immediate()  # MEJORA: Guardar inmediatamente después de compra crítica
	else:
		print("❌ No se pudo completar la compra de estación: %s" % station_id)


func _on_ui_manual_production_requested(station_index: int, quantity: int) -> void:
	var station_defs = production_manager.get_station_definitions()
	if station_index < station_defs.size():
		var station_id = station_defs[station_index].id
		production_manager.manual_production(station_id, quantity)


func _on_ui_item_sell_requested(item_type: String, item_name: String, quantity: int) -> void:
	print("💰 GameController recibió solicitud de venta:")
	print("   - Item: %s (%s)" % [item_name, item_type])
	print("   - Cantidad: %d" % quantity)
	print("   - Llamando sales_manager.sell_item()...")
	sales_manager.sell_item(item_type, item_name, quantity)
	print("   - ✅ Venta procesada")


func _on_ui_customer_upgrade_requested(upgrade_id: String) -> void:
	customer_manager.purchase_upgrade(upgrade_id)


## === EVENTOS DE SISTEMA ===


func _on_tab_changed(tab_name: String) -> void:
	print("📱 Cambiado a pestaña: %s" % tab_name)


func _on_pause_pressed() -> void:
	print("⏸️ Botón pausa presionado")

	if get_tree().paused:
		# Si ya está pausado, reanudar
		print("▶️ Reanudando juego")
		get_tree().paused = false
		# Remover menú de pausa si existe
		var pause_menu = get_node_or_null("PauseMenuOverlay")
		if pause_menu:
			pause_menu.queue_free()
	else:
		# Pausar y mostrar menú
		print("⏸️ Juego pausado")
		get_tree().paused = true
		_show_pause_menu()


func _show_pause_menu() -> void:
	# Cargar y mostrar el menú de pausa
	var pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	pause_menu_instance.name = "PauseMenuOverlay"
	pause_menu_instance.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Añadir como overlay (encima de todo)
	add_child(pause_menu_instance)

	print("⏸️ Menú de pausa mostrado")


func _on_reset_data_requested() -> void:
	print("🗑️ Resetear datos solicitado")

	# PASO 1: Crear nuevos datos
	game_data = GameData.new()

	# PASO 2: Actualizar todos los managers con datos frescos
	generator_manager.set_game_data(game_data)
	production_manager.set_game_data(game_data)
	sales_manager.set_game_data(game_data)
	customer_manager.set_game_data(game_data)

	# PASO 3: Actualizar StockManager también
	StockManager.set_game_data(game_data)

	# PASO 4: Re-configurar paneles con datos frescos
	_setup_panels()

	# PASO 5: Guardar inmediatamente
	_save_game()

	# PASO 6: Actualizar UI
	_update_all_displays()
	print("✅ Datos reseteados, paneles reconfigurados y guardados automáticamente")


## Guardado automático
func _save_game() -> void:
	if SaveSystem:
		SaveSystem.save_game_data_with_encryption(game_data.to_dict())
		print("💾 Juego guardado automáticamente con encriptación")


## Guardado inmediato para eventos críticos
func _save_game_immediate() -> void:
	if SaveSystem:
		SaveSystem.save_game_data_immediate()
		print("💾 Guardado inmediato realizado")


## Guardar al cerrar
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
		get_tree().quit()


## === CALLBACKS DE OFERTAS ===


func _on_ui_offer_toggled(station_index: int, enabled: bool) -> void:
	print("🛒 GameController - Oferta toggled:")
	print("   - Estación: %d, Habilitada: %s" % [station_index, enabled])

	# Obtener la definición de la estación para conocer su ID
	var station_defs = production_manager.get_station_definitions()
	if station_index < station_defs.size():
		var station_id = station_defs[station_index].id
		print("   - ID de estación: %s" % station_id)

		# Actualizar GameData
		if game_data.offers.has(station_id):
			game_data.offers[station_id]["enabled"] = enabled
			print(
				"   - ✅ Oferta %s para %s" % ["ACTIVADA" if enabled else "DESACTIVADA", station_id]
			)
		else:
			print("   - ❌ ERROR: ID de estación no encontrado en ofertas")


func _on_ui_offer_price_requested(station_index: int) -> void:
	print("💰 GameController - Configuración de precio solicitada:")
	print("   - Estación: %d" % station_index)

	# Obtener la definición de la estación
	var station_defs = production_manager.get_station_definitions()
	if station_index < station_defs.size():
		var station_id = station_defs[station_index].id
		var current_multiplier = game_data.offers.get(station_id, {}).get("price_multiplier", 1.0)

		print("   - ID de estación: %s" % station_id)
		print("   - Multiplicador actual: %.2f" % current_multiplier)

		# TODO: Aquí se podría abrir un diálogo para configurar el precio
		# Por ahora, alternar entre valores comunes
		var new_multiplier = (
			1.2 if current_multiplier <= 1.0 else (0.8 if current_multiplier >= 1.5 else 1.0)
		)
		game_data.offers[station_id]["price_multiplier"] = new_multiplier

		print("   - ✅ Nuevo multiplicador: %.2f" % new_multiplier)
		_update_all_displays()  # Actualizar UI para mostrar el cambio


## === CALLBACKS PARA CUSTOMERSPANEL ===


func _on_ui_offer_toggled_customers(station_id: String, enabled: bool) -> void:
	"""Callback para toggle de ofertas desde CustomersPanel"""
	print("🏪 GameController - Oferta toggled desde CustomersPanel:")
	print("   - Estación ID: %s" % station_id)
	print("   - Habilitado: %s" % enabled)

	# Actualizar GameData
	if game_data.offers.has(station_id):
		game_data.offers[station_id]["enabled"] = enabled
		print("   - ✅ Oferta actualizada en GameData")

		# Actualizar ambos paneles para mantener sincronización
		_update_all_displays()
		print("   - ✅ Paneles sincronizados")
	else:
		print("   - ❌ ERROR: Estación no encontrada en ofertas")


## === MANEJADORES DE SEÑALES REACTIVAS ===


func _on_money_changed(new_amount: float) -> void:
	"""Reacciona a cambios de dinero actualizando solo affordability"""
	# Actualizar display de dinero en tab navigator
	if tab_navigator:
		tab_navigator.update_money_display(new_amount)


func _on_resources_changed(resources: Dictionary) -> void:
	"""Reacciona a cambios de recursos"""
	if generation_panel and generation_panel.has_method("update_resource_displays"):
		generation_panel.update_resource_displays({"resources": resources})


func _on_generators_changed(generators: Dictionary) -> void:
	"""Reacciona a cambios de generadores"""
	if generation_panel and generation_panel.has_method("update_generator_displays"):
		generation_panel.update_generator_displays(
			{"generators": generators, "money": cached_money}
		)


func _on_stations_changed(stations: Dictionary) -> void:
	"""Reacciona a cambios de estaciones"""
	if production_panel and production_panel.has_method("update_station_displays"):
		production_panel.update_station_displays({
			"stations": stations,
			"money": cached_money,
			"resources": game_data.resources if game_data else {}
		})


func _on_ui_offer_price_requested_customers(station_id: String) -> void:
	"""Callback para cambio de precio desde CustomersPanel"""
	print("💰 GameController - Cambio de precio desde CustomersPanel:")
	print("   - Estación ID: %s" % station_id)

	if game_data.offers.has(station_id):
		var current_multiplier = game_data.offers[station_id].get("price_multiplier", 1.0)
		print("   - Multiplicador actual: %.2f" % current_multiplier)

		# Alternar entre valores: Normal (1.0) -> Alto (1.2) -> Bajo (0.8) -> Normal
		var new_multiplier: float
		if current_multiplier <= 0.8:
			new_multiplier = 1.0  # Bajo -> Normal
		elif current_multiplier <= 1.0:
			new_multiplier = 1.2  # Normal -> Alto
		else:
			new_multiplier = 0.8  # Alto -> Bajo

		game_data.offers[station_id]["price_multiplier"] = new_multiplier
		print("   - ✅ Nuevo multiplicador: %.2f" % new_multiplier)

		# Actualizar ambos paneles para mantener sincronización
		_update_all_displays()
		print("   - ✅ Paneles sincronizados")
	else:
		print("   - ❌ ERROR: Estación no encontrada en ofertas")


## === MANEJADORES DE ACTUALIZACIÓN EN TIEMPO REAL ===


func _on_stock_updated(item_type: String, item_name: String, new_quantity: int) -> void:
	"""Maneja actualizaciones de stock en tiempo real desde StockManager"""
	print("📦 Stock actualizado: %s %s = %d" % [item_type, item_name, new_quantity])

	# Actualizar solo la pestaña de generación si es un recurso/ingrediente
	if item_type in ["ingredient", "resource"]:
		if generation_panel and generation_panel.has_method("update_resource_displays"):
			# Crear datos mínimos para la actualización
			var minimal_data = {"resources": game_data.resources}
			generation_panel.update_resource_displays(minimal_data)
			print("✅ GenerationPanel actualizado con nuevo stock de %s" % item_name)

	# Si es un producto, actualizar SalesPanel
	elif item_type == "product":
		if sales_panel and sales_panel.has_method("update_inventory_displays"):
			var minimal_data = {
				"products": game_data.products,
				"resources": game_data.resources,
				"money": game_data.money
			}
			sales_panel.update_inventory_displays(minimal_data)
			print("✅ SalesPanelBasic actualizado con nuevo stock de %s" % item_name)
