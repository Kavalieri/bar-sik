extends ScrollContainer
## CustomersPanel - Panel de gestión de clientes y autoventa
## Maneja el sistema de clientes automáticos, upgrades y temporizadores

@onready var customer_timer_container: VBoxContainer = $MainContainer/TimerSection/TimerContainer
@onready var customer_timer_label: Label = $MainContainer/TimerSection/TimerContainer/CustomerTimerLabel
@onready var customer_timer_bar: ProgressBar = $MainContainer/TimerSection/TimerContainer/CustomerTimerBar
@onready var customer_status_label: Label = $MainContainer/TimerSection/TimerContainer/CustomerStatusLabel

@onready var upgrades_container: VBoxContainer = $MainContainer/UpgradesSection/UpgradesContainer
@onready var automation_container: VBoxContainer = $MainContainer/AutomationSection/AutomationContainer
@onready var stats_container: VBoxContainer = $MainContainer/StatsSection/StatsContainer

# Variables de UI
var upgrade_buttons: Array[Button] = []
var automation_buttons: Array[Button] = []
var customer_stats_labels: Array[Label] = []

# Señales para comunicación con GameScene
signal autosell_upgrade_purchased(upgrade_id: String)
signal automation_upgrade_purchased(upgrade_id: String)


func _ready() -> void:
	print("👥 CustomersPanel inicializado")
	_setup_ui()


func _setup_ui() -> void:
	# Configurar barra de progreso del cliente
	customer_timer_bar.min_value = 0.0
	customer_timer_bar.max_value = 1.0
	customer_timer_bar.value = 0.0

	# Crear labels para estadísticas de clientes
	_setup_customer_statistics()


func _setup_customer_statistics() -> void:
	var stat_names = [
		"👥 Clientes totales atendidos: 0",
		"💰 Ganancias por autoventa: $0",
		"⏱️ Frecuencia actual: 8.0s",
		"🎯 Próxima mejora disponible: Activar autoventa"
	]

	for stat_text in stat_names:
		var label = Label.new()
		label.text = stat_text
		stats_container.add_child(label)
		customer_stats_labels.append(label)


func update_customer_timer(progress: float, time_remaining: float, max_time: float) -> void:
	customer_timer_bar.value = progress
	customer_timer_label.text = "⏰ Próxima venta automática en: %.1fs" % time_remaining

	# Cambiar color de la barra según el progreso
	if progress < 0.3:
		customer_timer_bar.modulate = Color.RED
	elif progress < 0.7:
		customer_timer_bar.modulate = Color.YELLOW
	else:
		customer_timer_bar.modulate = Color.GREEN


func update_customer_status(has_autosell: bool, products_available: int) -> void:
	if not has_autosell:
		customer_status_label.text = "🚫 Autoventa desactivada - Los clientes no compran automáticamente"
		customer_status_label.modulate = Color.GRAY
	elif products_available > 0:
		customer_status_label.text = "✅ Listo para venta automática (%d productos disponibles)" % products_available
		customer_status_label.modulate = Color.GREEN
	else:
		customer_status_label.text = "⚠️ Sin productos para vender automáticamente"
		customer_status_label.modulate = Color.ORANGE


func setup_autosell_upgrades(game_data: Dictionary) -> void:
	# Limpiar upgrades existentes
	_clear_upgrade_buttons()

	var autosell_upgrades = [
		{
			"id": "nuevo_cliente",
			"name": "👤 Nuevo Cliente",
			"description": "Añade un cliente al grupo de compradores automáticos",
			"cost": 100.0,
			"required_key": "autosell_enabled"
		},
		{
			"id": "faster_customers",
			"name": "⚡ Clientes Más Rápidos",
			"description": "Reduce tiempo entre clientes a 6s",
			"cost": 500.0,
			"required_key": "customer_speed_1"
		},
		{
			"id": "premium_customers",
			"name": "👑 Clientes Premium",
			"description": "Los clientes pagan 50% más",
			"cost": 1000.0,
			"required_key": "customer_premium"
		},
		{
			"id": "bulk_buyers",
			"name": "📦 Compradores Mayoristas",
			"description": "Los clientes compran hasta 3 productos",
			"cost": 2500.0,
			"required_key": "customer_bulk"
		}
	]

	for upgrade in autosell_upgrades:
		var has_upgrade = game_data.get("upgrades", {}).get(upgrade.required_key, false)

		if not has_upgrade:
			_create_upgrade_button(upgrade, game_data)


func _create_upgrade_button(upgrade: Dictionary, game_data: Dictionary) -> void:
	var button_container = VBoxContainer.new()
	upgrades_container.add_child(button_container)

	# Label con información del upgrade
	var info_label = Label.new()
	info_label.text = "%s\n%s\nCosto: $%.0f" % [upgrade.name, upgrade.description, upgrade.cost]
	button_container.add_child(info_label)

	# Botón de compra
	var buy_button = Button.new()
	buy_button.text = "COMPRAR"
	var can_afford = game_data["money"] >= upgrade.cost
	buy_button.disabled = not can_afford

	if not can_afford:
		buy_button.text = "DINERO INSUFICIENTE"

	buy_button.pressed.connect(func(): _on_upgrade_purchased(upgrade.id))
	button_container.add_child(buy_button)

	# Separador
	var separator = HSeparator.new()
	button_container.add_child(separator)


func update_customer_statistics(game_data: Dictionary) -> void:
	if customer_stats_labels.size() >= 4:
		var stats = game_data.get("statistics", {})
		var upgrades = game_data.get("upgrades", {})

		customer_stats_labels[0].text = "👥 Clientes totales atendidos: %d" % stats.get("customers_served", 0)
		customer_stats_labels[1].text = "💰 Ganancias por autoventa: $%.0f" % stats.get("autosell_earnings", 0)

		var frequency = 8.0
		if upgrades.get("customer_speed_1", false):
			frequency = 6.0
		customer_stats_labels[2].text = "⏱️ Frecuencia actual: %.1fs" % frequency

		# Determinar próxima mejora
		var next_upgrade = ""
		if not upgrades.get("autosell_enabled", false):
			next_upgrade = "Activar autoventa"
		elif not upgrades.get("customer_speed_1", false):
			next_upgrade = "Clientes más rápidos"
		elif not upgrades.get("customer_premium", false):
			next_upgrade = "Clientes premium"
		elif not upgrades.get("customer_bulk", false):
			next_upgrade = "Compradores mayoristas"
		else:
			next_upgrade = "¡Todas desbloqueadas!"

		customer_stats_labels[3].text = "🎯 Próxima mejora: %s" % next_upgrade


func _on_upgrade_purchased(upgrade_id: String) -> void:
	autosell_upgrade_purchased.emit(upgrade_id)


func _clear_upgrade_buttons() -> void:
	for child in upgrades_container.get_children():
		child.queue_free()
	upgrade_buttons.clear()


func update_customer_display(game_data: Dictionary, timer_progress: float) -> void:
	# Actualizar timer y estado
	var timer_time = 8.0  # tiempo base
	if game_data["upgrades"].get("faster_customers", false):
		timer_time *= 0.6  # 40% más rápido

	update_customer_timer(timer_progress, timer_time * (1.0 - timer_progress), timer_time)

	# Contar productos disponibles
	var products_available = 0
	for product_type in game_data["products"].keys():
		products_available += game_data["products"][product_type]

	update_customer_status(game_data["upgrades"]["auto_sell_enabled"], products_available)
	update_customer_statistics(game_data)
