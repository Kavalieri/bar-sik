extends Node
## GameManager - Controlador principal del juego idle
## Coordina todos los sistemas y maneja el bucle principal de gameplay

# Referencias a los managers
@onready var resource_manager: ResourceManager
# ELIMINADO: @onready var currency_manager: CurrencyManager - Refactor: currencies en GameData

# Estado del juego
var game_state: Dictionary = {
	"is_playing": false,
	"is_paused": false,
	"start_time": 0,
	"total_playtime": 0,
	"clicks_total": 0,
	"beverages_sold": 0
}

# Configuración de generación automática
var auto_generation_timers: Dictionary = {}

# Configuración base del juego
const BASE_CLICK_POWER = 1
const AUTO_GENERATION_INTERVAL = 1.0  # segundos


func _ready() -> void:
	print("🎮 GameManager inicializado")

	# Crear instancias de los managers
	resource_manager = ResourceManager.new()
	# ELIMINADO: currency_manager = CurrencyManager.new() - Refactor: currencies en GameData

	# Añadirlos al árbol
	add_child(resource_manager)
	# ELIMINADO: add_child(currency_manager)

	# Conectar señales importantes
	_connect_signals()

	# Cargar datos guardados
	_load_game_data()

	# Configurar generación automática
	_setup_auto_generation()


func _connect_signals() -> void:
	# Conectar eventos de recursos
	resource_manager.recipe_completed.connect(_on_beverage_completed)
	resource_manager.resource_changed.connect(_on_resource_changed)

	# Conectar eventos de monedas
	currency_manager.currency_changed.connect(_on_currency_changed)

	# Conectar eventos globales del juego
	GameEvents.game_started.connect(_on_game_started)
	GameEvents.game_paused.connect(_on_game_paused)
	GameEvents.game_resumed.connect(_on_game_resumed)


## Manejar click del jugador para generar recursos
func handle_player_click(resource_id: String) -> bool:
	if not game_state.is_playing or game_state.is_paused:
		return false

	# Verificar que el recurso esté desbloqueado
	if not resource_manager.is_resource_unlocked(resource_id):
		return false

	# Generar recurso
	var amount_generated = get_click_power(resource_id)
	var success = resource_manager.add_resource(resource_id, amount_generated)

	if success:
		game_state.clicks_total += 1

		# Efectos visuales/audio podrían ir aquí
		GameEvents.emit_custom_event(
			"resource_clicked", {"resource_id": resource_id, "amount": amount_generated}
		)

	return success


## Obtener poder de click actual (con upgrades)
func get_click_power(resource_id: String) -> int:
	var base_power = BASE_CLICK_POWER

	# TODO: Aplicar bonificaciones de upgrades
	# base_power *= UpgradeManager.get_click_multiplier(resource_id)

	return base_power


## Intentar hacer una bebida
func try_make_beverage(beverage_id: String) -> bool:
	if not game_state.is_playing or game_state.is_paused:
		return false

	return resource_manager.make_beverage(beverage_id)


## Vender una bebida completada
func sell_beverage(beverage_id: String, quantity: int = 1) -> int:
	var beverage_data = resource_manager.get_beverage_data(beverage_id)
	if beverage_data.is_empty():
		return 0

	var base_price = beverage_data.price
	var total_income = currency_manager.sell_beverage(beverage_id, base_price, quantity)

	game_state.beverages_sold += quantity

	# Notificar venta
	GameEvents.emit_custom_event(
		"beverage_sold", {"beverage_id": beverage_id, "quantity": quantity, "income": total_income}
	)

	return total_income


## Configurar generación automática
func _setup_auto_generation() -> void:
	# Timer para generar recursos automáticamente
	var auto_timer = Timer.new()
	auto_timer.wait_time = AUTO_GENERATION_INTERVAL
	auto_timer.timeout.connect(_on_auto_generation_tick)
	auto_timer.autostart = true
	add_child(auto_timer)


## Tick de generación automática
func _on_auto_generation_tick() -> void:
	if not game_state.is_playing or game_state.is_paused:
		return

	# Generar recursos automáticamente (cuando tengamos upgrades de auto-generación)
	for resource_id in resource_manager.get_unlocked_resources():
		var auto_power = get_auto_generation_power(resource_id)
		if auto_power > 0:
			resource_manager.add_resource(resource_id, auto_power)


## Obtener poder de generación automática
func get_auto_generation_power(resource_id: String) -> int:
	# TODO: Implementar sistema de upgrades de auto-generación
	# Por ahora devuelve 0 (sin auto-generación hasta que se compren upgrades)
	return 0


## Iniciar el juego
func start_game() -> void:
	game_state.is_playing = true
	game_state.start_time = Time.get_unix_time_from_system()

	GameEvents.emit_game_started()
	print("🎮 Juego iniciado")


## Pausar el juego
func pause_game() -> void:
	if not game_state.is_playing:
		return

	game_state.is_paused = true
	GameEvents.emit_game_paused()
	print("⏸️ Juego pausado")


## Reanudar el juego
func resume_game() -> void:
	if not game_state.is_paused:
		return

	game_state.is_paused = false
	GameEvents.emit_game_resumed()
	print("▶️ Juego reanudado")


## Obtener estadísticas del juego
func get_game_stats() -> Dictionary:
	var current_time = Time.get_unix_time_from_system()
	var session_time = 0

	if game_state.is_playing:
		session_time = current_time - game_state.start_time

	return {
		"total_playtime": game_state.total_playtime + session_time,
		"clicks_total": game_state.clicks_total,
		"beverages_sold": game_state.beverages_sold,
		"cash_earned": currency_manager.get_total_earned("cash"),
		"tokens_earned": currency_manager.get_total_earned("tokens"),
		"resources_unlocked": resource_manager.get_unlocked_resources().size(),
		"session_time": session_time
	}


## Guardar datos del juego
func save_game() -> void:
	var save_data = {
		"game_state": game_state,
		"resources": resource_manager.get_save_data(),
		"currencies": currency_manager.get_save_data(),
		"timestamp": Time.get_unix_time_from_system()
	}

	SaveSystem.set_game_data("bar_sik_save", save_data)

	if AppConfig.is_debug:
		print("💾 Juego guardado")


## Cargar datos del juego
func _load_game_data() -> void:
	var save_data = SaveSystem.get_game_data("bar_sik_save", {})

	if save_data.is_empty():
		print("📄 No hay datos guardados, comenzando juego nuevo")
		return

	# Cargar estado del juego
	if save_data.has("game_state"):
		game_state = save_data.game_state

	# Cargar datos de recursos
	if save_data.has("resources"):
		resource_manager.load_save_data(save_data.resources)

	# Cargar datos de monedas
	if save_data.has("currencies"):
		currency_manager.load_save_data(save_data.currencies)

	print("💾 Datos del juego cargados")


## Auto-guardado periódico
func _ready_auto_save() -> void:
	var auto_save_timer = Timer.new()
	auto_save_timer.wait_time = 30.0  # Auto-guardar cada 30 segundos
	auto_save_timer.timeout.connect(save_game)
	auto_save_timer.autostart = true
	add_child(auto_save_timer)


## Callbacks de eventos


func _on_game_started() -> void:
	pass  # Lógica adicional cuando inicia el juego


func _on_game_paused() -> void:
	save_game()  # Guardar al pausar


func _on_game_resumed() -> void:
	pass  # Lógica adicional cuando se reanuda


func _on_beverage_completed(beverage_id: String, amount: int) -> void:
	# Auto-vender bebidas por ahora (más adelante podríamos tener inventario)
	sell_beverage(beverage_id, amount)


func _on_resource_changed(resource_id: String, old_amount: int, new_amount: int) -> void:
	# Lógica adicional cuando cambian los recursos
	pass


func _on_currency_changed(currency_type: String, old_amount: int, new_amount: int) -> void:
	# Verificar desbloqueos basados en dinero
	_check_resource_unlocks()


## Verificar si se pueden desbloquear recursos
func _check_resource_unlocks() -> void:
	var cash = currency_manager.get_currency_amount("cash")

	for resource_id in ResourceManager.RESOURCE_DATA:
		var resource_data = ResourceManager.RESOURCE_DATA[resource_id]

		if not resource_manager.is_resource_unlocked(resource_id):
			if cash >= resource_data.unlock_cost:
				# Por ahora auto-desbloquear, más adelante será mediante compra
				resource_manager.unlock_resource(resource_id)


## API pública para la UI


func get_unlocked_resources() -> Array:
	return resource_manager.get_unlocked_resources()


func get_resource_amount(resource_id: String) -> int:
	return resource_manager.get_resource_amount(resource_id)


func get_resource_data(resource_id: String) -> Dictionary:
	return resource_manager.get_resource_data(resource_id)


func get_currency_amount(currency_type: String) -> int:
	return currency_manager.get_currency_amount(currency_type)


func get_currency_display(currency_type: String) -> Dictionary:
	return currency_manager.get_currency_display(currency_type)


func get_available_beverages() -> Array:
	return resource_manager.get_available_beverages()


func get_beverage_data(beverage_id: String) -> Dictionary:
	return resource_manager.get_beverage_data(beverage_id)
