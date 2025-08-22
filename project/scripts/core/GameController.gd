extends Control
class_name GameController
## GameController - Coordinador principal del juego (versión ligera)
## Coordina managers y maneja la UI principal

# Escenas precargadas
const PAUSE_MENU_SCENE = preload("res://scenes/PauseMenu.tscn")
const PRESTIGE_PANEL_SCENE = preload("res://scenes/ui/PrestigePanel.tscn")
const MISSIONS_PANEL_SCENE = preload("res://scenes/MissionsPanel.tscn")  # T019
const AUTOMATION_PANEL_SCENE = preload("res://scenes/ui/AutomationPanel.tscn")  # T022

@onready var tab_navigator: Control = $TabNavigator

# Managers del juego
var game_data: GameData
var generator_manager: GeneratorManager
var production_manager: ProductionManager
var sales_manager: SalesManager
var customer_manager: CustomerManager
var prestige_manager: PrestigeManager  # T013 - Sistema de Prestigio
var achievement_manager: AchievementManager  # T017 - Sistema de Logros
var mission_manager: MissionManager  # T018 - Sistema de Misiones Diarias
var automation_manager: AutomationManager  # T020 - Sistema de Automatización
var offline_progress_manager: OfflineProgressManager  # T023 - Progreso Offline
var daily_reward_manager: DailyRewardManager  # T026 - Sistema de recompensas diarias
# T028 - Performance Optimization Managers
var performance_manager: PerformanceManager
var object_pool_manager: ObjectPoolManager
var tick_manager: TickManager
# ELIMINADO: var currency_manager: CurrencyManager - Refactor: currencies en GameData

# Referencias a paneles UI
var generation_panel: Control
var production_panel: Control
var sales_panel: Control
var customers_panel: Control

# Timers del sistema
var save_timer: Timer
var gems_timer: Timer  # T014 - Diamond Bonus timer

# Cache para sistema reactivo
var cached_money: float = 0.0

# T023 - Control de progreso offline
var _check_offline_progress_after_load: bool = false


func _ready() -> void:
	print_rich("[color=yellow]🎮 GameController._ready() iniciado[/color]")

	# Info de debugging sin breakpoints automáticos
	debug_game_info("GameController._ready inicio")

	_setup_game_data()
	_setup_managers()
	_setup_state_manager()  # NUEVO: Sistema de estado centralizado
	_setup_ui_system()
	_setup_save_timer()
	_setup_gems_timer()  # T014 - Diamond Bonus timer

	# TEMPORAL: Debug del sistema de generación
	var debug_generator = preload("res://scripts/DebugGeneratorTest.gd").new()
	add_child(debug_generator)
	add_to_group("game_controller")  # Para que DebugGeneratorTest pueda encontrarnos

	# TEMPORAL: Resumen de reparaciones del sistema
	var repair_summary = preload("res://scripts/SystemRepairSummary.gd").new()
	add_child(repair_summary)

	print_rich("[color=green]✅ GameController listo - Sistema modular activo[/color]")
	debug_game_state()

	# T023 - Verificar progreso offline después de la inicialización completa
	if _check_offline_progress_after_load:
		call_deferred("_process_offline_progress")
		_check_offline_progress_after_load = false


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

			# T023 - Verificar progreso offline después de cargar
			_check_offline_progress_after_load = true

	print("🎯 Datos del juego configurados")


## Configurar managers
func _setup_managers() -> void:
	# Crear managers
	generator_manager = GeneratorManager.new()
	production_manager = ProductionManager.new()
	sales_manager = SalesManager.new()
	customer_manager = CustomerManager.new()
	prestige_manager = PrestigeManager.new()  # T013 - Sistema de Prestigio
	achievement_manager = AchievementManager.new()  # T017 - Sistema de Logros
	mission_manager = MissionManager.new()  # T018 - Sistema de Misiones Diarias
	automation_manager = AutomationManager.new()  # T020 - Sistema de Automatización
	offline_progress_manager = OfflineProgressManager.new()  # T023 - Progreso Offline
	# ELIMINADO: currency_manager - Refactor: currencies en GameData

	# Agregar al árbol de nodos
	add_child(generator_manager)
	add_child(production_manager)
	add_child(sales_manager)
	add_child(customer_manager)
	add_child(prestige_manager)  # T013 - Sistema de Prestigio
	add_child(achievement_manager)  # T017 - Sistema de Logros
	add_child(mission_manager)  # T018 - Sistema de Misiones Diarias
	add_child(automation_manager)  # T020 - Sistema de Automatización
	add_child(offline_progress_manager)  # T023 - Progreso Offline
	add_child(daily_reward_manager)  # T026 - Sistema de recompensas diarias
	# ELIMINADO: add_child(currency_manager)

	# Asignar datos del juego a todos los managers
	generator_manager.set_game_data(game_data)
	production_manager.set_game_data(game_data)
	sales_manager.set_game_data(game_data)
	customer_manager.set_game_data(game_data)
	prestige_manager.set_game_data(game_data)  # T013 - Sistema de Prestigio
	achievement_manager.set_game_data(game_data)  # T017 - Sistema de Logros
	mission_manager.set_game_data(game_data)  # T018 - Sistema de Misiones Diarias
	automation_manager.set_game_data(game_data)  # T020 - Sistema de Auto-Producción
	offline_progress_manager.set_game_data(game_data)  # T023 - Progreso Offline
	daily_reward_manager.set_game_data(game_data)  # T026 - Sistema de recompensas diarias
	# ELIMINADO: currency_manager.set_game_data(game_data) - Ya no existe
	# Para acceder a definiciones de estaciones
	customer_manager.set_production_manager(production_manager)

	# T020 - Conectar AutomationManager con otros managers
	automation_manager.set_managers(production_manager, sales_manager)
	print("🤖 AutomationManager conectado con managers")

	# T023 - Conectar OfflineProgressManager con managers necesarios
	offline_progress_manager.set_managers(automation_manager, customer_manager, generator_manager)
	print("📴 OfflineProgressManager conectado con managers")

	# Configurar StockManager singleton
	StockManager.set_game_data(game_data)
	print("📦 StockManager configurado con GameData")

	# T013 - Cargar datos de prestigio en el PrestigeManager
	prestige_manager.load_prestige_data_from_game_data()
	print("🌟 PrestigeManager datos cargados desde GameData")

	# T014 - Aplicar bonificaciones de prestige al cargar
	if prestige_manager.active_star_bonuses.size() > 0:
		prestige_manager._apply_all_star_bonuses()
		print(
			"⭐ Bonificaciones aplicadas: %d activas" % prestige_manager.active_star_bonuses.size()
		)

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

	# T013 - Señales de prestigio
	prestige_manager.prestige_available.connect(_on_prestige_available)
	prestige_manager.prestige_completed.connect(_on_prestige_completed)
	prestige_manager.star_bonus_applied.connect(_on_star_bonus_applied)

	# T017 - Señales del sistema de logros
	achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)

	# T018 - Señales del sistema de misiones
	mission_manager.mission_completed.connect(_on_mission_completed)
	mission_manager.daily_missions_reset.connect(_on_daily_missions_reset)

	# T020-T021 - Señales del sistema de automatización
	automation_manager.auto_production_started.connect(_on_auto_production_started)
	automation_manager.auto_sell_triggered.connect(_on_auto_sell_triggered)
	automation_manager.automation_config_changed.connect(_on_automation_config_changed)

	# ELIMINADO: Señales de currency - Refactor: currencies en GameData, sin signals


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
	tab_navigator.prestige_requested.connect(_on_prestige_button_pressed)  # T015
	tab_navigator.missions_requested.connect(show_missions_panel)  # T019
	tab_navigator.automation_requested.connect(show_automation_panel)  # T022

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
		if (
			generation_panel.has_signal("generator_purchased")
			and not generation_panel.generator_purchased.is_connected(
				_on_ui_generator_purchase_requested
			)
		):
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


## T014 - Configurar timer de gemas por hora (Diamond Bonus)
func _setup_gems_timer() -> void:
	gems_timer = Timer.new()
	gems_timer.wait_time = 3600.0  # 1 hora = 3600 segundos
	gems_timer.autostart = true
	gems_timer.timeout.connect(_on_gems_timer_timeout)
	add_child(gems_timer)

	print("💎 Timer de gemas por hora configurado (Diamond Bonus)")


func _on_gems_timer_timeout() -> void:
	"""Otorgar gemas por hora si Diamond Bonus está activo"""
	var gems_per_hour = game_data.get("prestige_gems_per_hour", 0.0)
	if gems_per_hour > 0:
		var gems_to_add = int(gems_per_hour)
		game_data.add_gems(gems_to_add)
		print("💎 Diamond Bonus: +%d gemas por hora de juego" % gems_to_add)
		# TODO: Mostrar notification en UI


## Actualizar todas las interfaces
func _update_all_displays() -> void:
	var game_dict = game_data.to_dict()

	# NUEVO: Actualizar GameStateManager (sistema reactivo)
	GameStateManager.update_game_state(game_dict)
	cached_money = game_data.money

	# Actualizar display de dinero (legacy)
	tab_navigator.update_money_display(game_data.money)

	# REFACTOR: Actualizar displays de triple currency directamente desde GameData
	if tab_navigator.has_method("update_all_currencies"):
		tab_navigator.update_all_currencies(int(game_data.money), game_data.tokens, game_data.gems)

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

	# T017 - Notificar al Achievement Manager sobre compra de generadores
	achievement_manager.notify_generator_purchased(generator_id, quantity)

	# T018 - Notificar al Mission Manager sobre compra de generadores
	mission_manager.notify_generator_purchased(quantity)


func _on_resource_generated(resource_type: String, amount: int) -> void:
	"""Maneja la generación de recursos en tiempo real"""
	print("🔄 Recurso generado: %dx %s" % [amount, resource_type])

	# La actualización real la maneja _on_stock_updated que se dispara desde StockManager
	# Solo necesitamos actualizar el dinero por si hay ventas automáticas
	tab_navigator.update_money_display(game_data.money)

	# T017 - Notificar al Achievement Manager sobre recursos generados
	achievement_manager.notify_resource_generated(resource_type, amount)

	# T018 - Notificar al Mission Manager sobre recursos generados
	mission_manager.notify_resource_generated(resource_type, amount)


func _on_station_purchased(station_id: String) -> void:
	print("✅ Estación comprada: %s" % station_id)
	_update_all_displays()

	# T017 - Notificar al Achievement Manager sobre compra de estaciones
	achievement_manager.notify_station_purchased(station_id)

	# T018 - Notificar al Mission Manager sobre compra de estaciones
	mission_manager.notify_station_purchased()


func _on_station_unlocked(station_id: String) -> void:
	print("🔓 Estación desbloqueada: %s" % station_id)
	_update_all_displays()


func _on_product_produced(product_type: String, amount: int) -> void:
	print("🍺 Producido: %dx %s" % [amount, product_type])
	_update_all_displays()

	# T017 - Notificar al Achievement Manager sobre producción
	achievement_manager.notify_product_produced(product_type, amount)

	# T018 - Notificar al Mission Manager sobre producción
	mission_manager.notify_product_produced(amount)


func _on_item_sold(
	item_type: String, item_name: String, quantity: int, total_earned: float
) -> void:
	print("💰 Vendido: %dx %s (%s) por $%.2f" % [quantity, item_name, item_type, total_earned])
	_update_all_displays()

	# T017 - Notificar al Achievement Manager sobre ventas
	achievement_manager.notify_item_sold(item_type, quantity, total_earned)

	# T018 - Notificar al Mission Manager sobre ventas manuales
	mission_manager.notify_manual_sale(total_earned)
	mission_manager.notify_money_earned(total_earned)

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

	# T017 - Notificar al Achievement Manager sobre clientes servidos
	achievement_manager.notify_customer_served(customer_type, products_bought.size(), total_earned)

	# T018 - Notificar al Mission Manager sobre clientes servidos
	mission_manager.notify_customer_served()
	mission_manager.notify_money_earned(total_earned)

	# MEJORA: Guardar después de ventas importantes (>$5)
	if total_earned >= 5.0:
		_save_game_immediate()


func _on_customer_upgrade_purchased(upgrade_id: String, cost: float) -> void:
	print("⬆️ Upgrade de cliente: %s por $%.0f" % [upgrade_id, cost])
	_update_all_displays()

	# T017 - Notificar al Achievement Manager sobre upgrades comprados
	achievement_manager.notify_upgrade_purchased(upgrade_id, cost)

	_save_game_immediate()  # MEJORA: Siempre guardar después de upgrades


# T013 - Handlers del PrestigeManager
func _on_prestige_available(stars_to_gain: int) -> void:
	"""Manejar cuando el prestigio está disponible"""
	print("🌟 Prestigio disponible - Stars a ganar: %d" % stars_to_gain)
	# TODO: Mostrar notification o highlight en UI


func _on_prestige_completed(stars_gained: int, total_stars: int) -> void:
	"""Manejar cuando se completa un prestigio"""
	print("✨ Prestigio completado - Ganadas: %d | Total: %d stars" % [stars_gained, total_stars])
	_update_all_displays()

	# T017 - Notificar al Achievement Manager sobre prestigio completado
	achievement_manager.notify_prestige_completed(stars_gained, total_stars)

	_save_game_immediate()  # Guardar inmediatamente después de prestigio
	# TODO: Mostrar panel de celebración/resumen


func _on_star_bonus_applied(bonus_id: String, effect_value: float) -> void:
	"""Manejar cuando se aplica una bonificación de star"""
	print("⭐ Star bonus aplicado: %s (valor: %.2f)" % [bonus_id, effect_value])
	_update_all_displays()  # Actualizar UI para reflejar bonificaciones


# T017 - Signal handler para logros desbloqueados
func _on_achievement_unlocked(_achievement_id: String, achievement_data: Dictionary) -> void:
	"""Manejar cuando se desbloquea un logro"""
	print("🏆 Logro desbloqueado: %s - %s" % [achievement_data.name, achievement_data.description])

	# Aplicar recompensas del logro
	if achievement_data.has("token_reward") and achievement_data.token_reward > 0:
		game_data.add_tokens(achievement_data.token_reward)
		print("💰 +%d tokens por logro" % achievement_data.token_reward)

	if achievement_data.has("gem_reward") and achievement_data.gem_reward > 0:
		game_data.add_gems(achievement_data.gem_reward)
		print("💎 +%d gemas por logro" % achievement_data.gem_reward)

	_update_all_displays()
	_save_game_immediate()  # Guardar progreso de logros
	# TODO: Mostrar notification visual de logro desbloqueado


# T018 - Signal handlers para misiones
func _on_mission_completed(_mission_id: String, mission_data: Dictionary) -> void:
	"""Manejar cuando se completa una misión diaria"""
	print("📋 Misión completada: %s - %s" % [mission_data.name, mission_data.description])

	# La recompensa ya fue aplicada por el MissionManager
	_update_all_displays()
	_save_game_immediate()  # Guardar progreso de misiones
	# TODO: Mostrar notification visual de misión completada


func _on_daily_missions_reset() -> void:
	"""Manejar cuando se resetean las misiones diarias"""
	print("📅 Misiones diarias reseteadas - Nuevas misiones disponibles")
	_update_all_displays()
	# TODO: Mostrar notification de nuevas misiones disponibles


## === T020 - EVENTOS DE AUTOMATIZACIÓN ===


func _on_auto_production_started(station_id: String, product_id: String, quantity: int) -> void:
	"""Manejar cuando se inicia auto-producción"""
	print("🤖 Auto-producción iniciada: %s produciendo %s x%d" % [station_id, product_id, quantity])
	_update_all_displays()


func _on_auto_sell_triggered(product_id: String, quantity: int, earnings: float) -> void:
	"""Manejar cuando se dispara auto-venta"""
	print("💰 Auto-venta ejecutada: %s x%d por %.2f monedas" % [product_id, quantity, earnings])
	_update_all_displays()


func _on_automation_config_changed(setting_type: String, enabled: bool) -> void:
	"""Manejar cuando cambia configuración de automatización"""
	print("⚙️ Automatización configurada: %s = %s" % [setting_type, enabled])
	# Guardar configuración
	_save_game_data()


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
	print("⏸️ Pausa solicitada desde TabNavigator")

	# Buscar menú de pausa existente antes de crear uno nuevo
	var existing_pause_menu = get_node_or_null("PauseMenuOverlay")
	if existing_pause_menu:
		print("⏸️ Menú de pausa ya existe, removiendo...")
		existing_pause_menu.queue_free()

	if not get_tree().paused:
		print("⏸️ Juego pausado")
		get_tree().paused = true
		_show_pause_menu()


# T015 - Handler para botón de prestigio del TabNavigator
func _on_prestige_button_pressed() -> void:
	"""Manejar click del botón de prestigio"""
	print("⭐ Botón de prestigio presionado desde TabNavigator")
	show_prestige_panel()


func _show_pause_menu() -> void:
	# Cargar y mostrar el menú de pausa
	var pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	pause_menu_instance.name = "PauseMenuOverlay"
	pause_menu_instance.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	# Añadir como overlay (encima de todo)
	add_child(pause_menu_instance)

	print("⏸️ Menú de pausa mostrado")


# T015 - Mostrar panel de prestigio
func show_prestige_panel() -> void:
	"""Mostrar panel de prestigio"""
	print("🌟 Mostrando panel de prestigio...")

	# Verificar que no haya otro panel ya abierto
	var existing_panel = get_node_or_null("PrestigePanelOverlay")
	if existing_panel:
		existing_panel.queue_free()
		print("🗑️ Panel de prestigio anterior removido")

	# Crear instancia del panel
	var prestige_panel_instance = PRESTIGE_PANEL_SCENE.instantiate()
	prestige_panel_instance.name = "PrestigePanelOverlay"
	prestige_panel_instance.process_mode = Node.PROCESS_MODE_ALWAYS

	# Configurar con managers
	prestige_panel_instance.setup_with_managers(prestige_manager, game_data)

	# Conectar señales del panel
	prestige_panel_instance.prestige_requested.connect(_on_prestige_requested)
	prestige_panel_instance.bonus_purchase_requested.connect(_on_bonus_purchase_requested)
	prestige_panel_instance.panel_closed.connect(_on_prestige_panel_closed)

	# Añadir como overlay (encima de todo)
	add_child(prestige_panel_instance)

	# Mostrar con animación
	prestige_panel_instance.show_panel()

	print("✅ Panel de prestigio mostrado")


# T019 - Función para mostrar panel de misiones y logros
func show_missions_panel():
	"""Mostrar el panel de misiones y logros"""
	print("🎮 Mostrando panel de misiones y logros")

	# Crear instancia del panel
	var missions_panel_instance = MISSIONS_PANEL_SCENE.instantiate()
	missions_panel_instance.name = "MissionsPanelOverlay"
	missions_panel_instance.process_mode = Node.PROCESS_MODE_ALWAYS

	# Configurar con managers
	missions_panel_instance.setup_managers(mission_manager, achievement_manager)

	# Conectar señales del panel
	missions_panel_instance.panel_closed.connect(_on_missions_panel_closed)

	# Añadir como overlay (encima de todo)
	add_child(missions_panel_instance)

	# Mostrar panel
	missions_panel_instance.show_panel()

	print("✅ Panel de misiones mostrado")


func _on_missions_panel_closed():
	"""Manejar cierre del panel de misiones"""
	print("🎮 Panel de misiones cerrado")

	# Buscar y eliminar el panel overlay
	var missions_overlay = get_node_or_null("MissionsPanelOverlay")
	if missions_overlay:
		missions_overlay.queue_free()


# T022 - Panel de automatización
func show_automation_panel():
	"""Mostrar el panel de automatización"""
	print("🎛️ Mostrando panel de automatización")

	# Crear instancia del panel
	var automation_panel_instance = AUTOMATION_PANEL_SCENE.instantiate()
	automation_panel_instance.name = "AutomationPanelOverlay"
	automation_panel_instance.process_mode = Node.PROCESS_MODE_ALWAYS

	# Configurar con managers (el panel obtendrá las referencias por sí mismo)
	# automation_panel_instance ya tiene acceso a GameController via singleton

	# Conectar señal de cierre si existe
	if automation_panel_instance.has_signal("panel_closed"):
		automation_panel_instance.panel_closed.connect(_on_automation_panel_closed)

	# Añadir como overlay (encima de todo)
	add_child(automation_panel_instance)

	# Mostrar panel
	automation_panel_instance.show_panel()

	print("✅ Panel de automatización mostrado")


func _on_automation_panel_closed():
	"""Manejar cierre del panel de automatización"""
	print("🎛️ Panel de automatización cerrado")

	# Buscar y eliminar el panel overlay
	var automation_overlay = get_node_or_null("AutomationPanelOverlay")
	if automation_overlay:
		automation_overlay.queue_free()


func _on_prestige_requested() -> void:
	"""Manejar solicitud de prestigio"""
	print("⭐ Prestigio solicitado por el usuario")

	if prestige_manager and prestige_manager.can_prestige():
		var stars_gained = prestige_manager.perform_prestige()
		print("🌟 Prestigio realizado - Stars ganadas: %d" % stars_gained)

		# Actualizar displays
		_update_all_displays()

		# Guardar inmediatamente
		_save_game_immediate()

		# Cerrar panel de prestigio si está abierto
		var prestige_panel = get_node_or_null("PrestigePanelOverlay")
		if prestige_panel:
			prestige_panel.queue_free()
	else:
		print("❌ No se puede realizar prestigio")


func _on_bonus_purchase_requested(bonus_id: String) -> void:
	"""Manejar compra de bonificación de prestigio"""
	print("🛒 Compra de bonus solicitada: %s" % bonus_id)

	if prestige_manager:
		var success = prestige_manager.purchase_star_bonus(bonus_id)
		if success:
			print("✅ Bonus comprado: %s" % bonus_id)
			# Actualizar displays
			_update_all_displays()
			# Guardar inmediatamente
			_save_game_immediate()
		else:
			print("❌ No se pudo comprar bonus: %s" % bonus_id)


func _on_prestige_panel_closed() -> void:
	"""Manejar cierre del panel de prestigio"""
	print("🌟 Panel de prestigio cerrado")
	var prestige_panel = get_node_or_null("PrestigePanelOverlay")
	if prestige_panel:
		prestige_panel.queue_free()


func _on_reset_data_requested() -> void:
	print("🗑️ Resetear datos solicitado")

	# PASO 1: Crear nuevos datos
	game_data = GameData.new()

	# PASO 2: Actualizar todos los managers con datos frescos
	generator_manager.set_game_data(game_data)
	production_manager.set_game_data(game_data)
	sales_manager.set_game_data(game_data)
	customer_manager.set_game_data(game_data)
	# ELIMINADO: currency_manager.set_game_data(game_data) - Ya no existe

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
		# Actualizar el timestamp de last_close_time antes de guardar
		game_data.gameplay_data["last_close_time"] = Time.get_unix_time_from_system()
		_save_game()
		get_tree().quit()


## === T023 - OFFLINE PROGRESS SYSTEM ===


func _process_offline_progress():
	"""Procesar cálculo de progreso offline después de cargar datos"""
	print("📴 Iniciando cálculo de progreso offline...")

	if not offline_progress_manager:
		print("⚠️ OfflineProgressManager no disponible")
		return

	# Verificar y calcular progreso offline
	var progress_data = offline_progress_manager.check_offline_progress()

	if progress_data.is_empty():
		print("📴 No hay progreso offline significativo")
		return

	# Mostrar resumen de progreso offline
	_show_offline_progress_summary(progress_data)

	# Actualizar displays después de aplicar progreso offline
	call_deferred("_update_all_displays")


func _show_offline_progress_summary(progress_data: Dictionary):
	"""Mostrar resumen visual del progreso offline"""
	print("📴 ═══ PROGRESO OFFLINE ═══")
	print("📴 Tiempo ausente: %.1f horas" % progress_data.offline_hours)
	print("📴 Eficiencia: %.0f%%" % (progress_data.efficiency * 100))

	# Log detallado en consola
	if progress_data.resources_generated.size() > 0:
		print("📴 🔋 Recursos generados:")
		for resource in progress_data.resources_generated:
			var amount = progress_data.resources_generated[resource]
			if amount > 0:
				print("📴   +%d %s" % [amount, resource])

	if progress_data.products_produced.size() > 0:
		print("📴 🏭 Productos creados:")
		for product in progress_data.products_produced:
			var amount = progress_data.products_produced[product]
			if amount > 0:
				print("📴   +%d %s" % [amount, product])

	if progress_data.customers_served > 0:
		print("📴 👥 Clientes servidos: %d" % progress_data.customers_served)
		print("📴 🪙 Tokens ganados: %d (incluye bonus)" % progress_data.tokens_earned)

	if progress_data.catch_up_bonus > 0:
		print("📴 🎁 Bonus de regreso: %d tokens" % progress_data.catch_up_bonus)

	print("📴 ═══ FIN PROGRESO OFFLINE ═══")

	# Mostrar diálogo visual bonito
	_create_offline_progress_dialog(progress_data)


## Crear diálogo visual del progreso offline
func _create_offline_progress_dialog(progress_data: Dictionary) -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "🏠 ¡Bienvenido de vuelta!"

	# Construir mensaje atractivo
	var message = "Has estado ausente por %.1f horas\n\n" % progress_data.offline_hours
	message += "🎮 Tu negocio siguió funcionando...\n\n"

	# Mostrar eficiencia
	message += "⚙️ Eficiencia offline: %.0f%%\n\n" % (progress_data.efficiency * 100)

	# Recursos generados
	if progress_data.resources_generated.size() > 0:
		message += "⚡ RECURSOS GENERADOS:\n"
		for resource in progress_data.resources_generated:
			var amount = progress_data.resources_generated[resource]
			if amount > 0:
				message += "   • %s: +%d\n" % [resource.capitalize(), amount]
		message += "\n"

	# Productos producidos
	if progress_data.products_produced.size() > 0:
		message += "🍺 PRODUCTOS CREADOS:\n"
		for product in progress_data.products_produced:
			var amount = progress_data.products_produced[product]
			if amount > 0:
				message += "   • %s: +%d\n" % [product.capitalize(), amount]
		message += "\n"

	# Clientes y tokens
	if progress_data.customers_served > 0:
		message += "👥 CLIENTES ATENDIDOS: %d\n" % progress_data.customers_served
		message += "🪙 TOKENS GANADOS: %d\n" % progress_data.tokens_earned
		if progress_data.catch_up_bonus > 0:
			message += "🎁 BONUS DE REGRESO: +%d tokens\n" % progress_data.catch_up_bonus
		message += "\n"

	message += "🚀 ¡Continúa construyendo tu imperio!\n"
	message += "¡Tu negocio te esperaba! 🍻"

	dialog.dialog_text = message
	dialog.ok_button_text = "¡Continuar!"

	# Agregar al árbol y mostrar
	add_child(dialog)
	dialog.popup_centered(Vector2i(500, 400))

	# Auto-limpiar cuando se cierre
	dialog.tree_exited.connect(dialog.queue_free)


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
		production_panel.update_station_displays(
			{
				"stations": stations,
				"money": cached_money,
				"resources": game_data.resources if game_data else {}
			}
		)


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


## === CALLBACKS ELIMINADOS ===
## CurrencyManager eliminado - currencies ahora en GameData directamente
## Sin signals, sin callbacks, updates directos en _update_all_displays()

# ═════════════════════════════════════════════════════════════════════════════════════
# T026: ACCESO PÚBLICO PARA DAILY REWARD MANAGER
# ═════════════════════════════════════════════════════════════════════════════════════


## Acceso público al AchievementManager para DailyRewardManager
func get_achievement_manager() -> AchievementManager:
	return achievement_manager
