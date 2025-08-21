extends VBoxContainer
# class_name ShopContainer  # Comentado temporalmente para evitar conflictos RefCounted
## Contenedor modular para tiendas con controles de cantidad globales
## Gestiona múltiples BuyCards con cantidad sincronizada

# Señales
signal purchase_requested(item_id: String, quantity: int)
signal sell_requested(item_id: String, quantity: int)

# Configuración
var shop_type: String = "buy"  # "buy" o "sell"
var current_quantity: int = 1
var player_money: float = 0.0

# Estado
var buy_cards: Array[Panel] = []  # Cambiado de BuyCard a Panel temporalmente
var is_initialized: bool = false

# Recursos precargados
const BuyCardScene = preload("res://scenes/ui/components/BuyCard.tscn")

# Referencias a elementos internos
@onready var title_label: Label = $HeaderSection/TitleLabel
@onready var item_grid: GridContainer = $ContentSection/ScrollContainer/ItemGrid
@onready var total_label: Label = $StatusBar/TotalLabel
@onready var affordability_label: Label = $StatusBar/AffordabilityLabel
@onready var quantity_input: SpinBox = $StatusBar/QuantityControls/QuantityInput
@onready var buy_button: Button = $StatusBar/QuantityControls/BuyButton

# Referencias a botones de cantidad
@onready var x1_button: Button = $HeaderSection/QuantityControls/x1_Button
@onready var x5_button: Button = $HeaderSection/QuantityControls/x5_Button
@onready var x10_button: Button = $HeaderSection/QuantityControls/x10_Button
@onready var x25_button: Button = $HeaderSection/QuantityControls/x25_Button
@onready var x50_button: Button = $HeaderSection/QuantityControls/x50_Button

# Flag para verificar si los nodos están disponibles
var nodes_ready: bool = false


func _ready() -> void:
	# Verificar que todos los nodos estén disponibles
	nodes_ready = _verify_nodes()

	_setup_quantity_buttons()
	is_initialized = true
	print("🛍️ ShopContainer inicializado")


func _verify_nodes() -> bool:
	"""Verificar que todos los nodos necesarios estén disponibles"""
	var all_present = true

	if not title_label:
		print("⚠️ ShopContainer: title_label no encontrado")
		all_present = false
	if not item_grid:
		print("⚠️ ShopContainer: item_grid no encontrado")
		all_present = false
	if not total_label:
		print("⚠️ ShopContainer: total_label no encontrado")
		all_present = false
	if not affordability_label:
		print("⚠️ ShopContainer: affordability_label no encontrado")
		all_present = false
	if not quantity_input:
		print("⚠️ ShopContainer: quantity_input no encontrado")
		all_present = false
	if not buy_button:
		print("⚠️ ShopContainer: buy_button no encontrado")
		all_present = false
	if not x1_button:
		print("⚠️ ShopContainer: x1_button no encontrado")
		all_present = false
	if not x5_button:
		print("⚠️ ShopContainer: x5_button no encontrado")
		all_present = false
	if not x10_button:
		print("⚠️ ShopContainer: x10_button no encontrado")
		all_present = false
	if not x25_button:
		print("⚠️ ShopContainer: x25_button no encontrado")
		all_present = false
	if not x50_button:
		print("⚠️ ShopContainer: x50_button no encontrado")
		all_present = false

	return all_present


## Configurar el contenedor de tienda
func setup(title: String, mode: String = "buy") -> void:
	"""
	Configura el contenedor de tienda
	title: Título de la sección
	mode: "buy" o "sell"
	"""
	if not nodes_ready:
		print("⚠️ ShopContainer: Los nodos no están listos, reintentando verificación...")
		nodes_ready = _verify_nodes()

	if not nodes_ready:
		print("❌ ShopContainer: No se puede configurar, nodos faltantes")
		return

	shop_type = mode
	title_label.text = title
	_update_ui_for_mode()


## Agregar un item a la tienda
func add_item(item_data: Dictionary) -> Panel:
	"""
	Agrega un item a la tienda
	item_data debe contener: id, name, description, base_price, cost_calculator (opcional)
	"""
	var buy_card = BuyCardScene.instantiate() as Panel

	# Configurar la tarjeta
	buy_card.setup(item_data, shop_type)

	# Configurar calculadora de costo si se proporciona
	var cost_calc = item_data.get("cost_calculator", null)
	if cost_calc != null:
		buy_card.set_cost_calculator(cost_calc)

	# Establecer cantidad inicial
	buy_card.set_quantity(current_quantity)

	# Conectar señales
	if shop_type == "buy":
		buy_card.item_purchased.connect(_on_item_purchased)
	else:
		buy_card.item_sold.connect(_on_item_sold)

	# Agregar al grid
	item_grid.add_child(buy_card)
	buy_cards.append(buy_card)

	_update_status_bar()
	return buy_card


## Remover todos los items
func clear_items() -> void:
	"""Remueve todas las tarjetas de la tienda"""
	for card in buy_cards:
		if card and is_instance_valid(card):
			card.queue_free()
	buy_cards.clear()
	_update_status_bar()


## Actualizar dinero del jugador
func update_player_money(money: float) -> void:
	"""Actualiza el dinero disponible y la asequibilidad de todos los items"""
	player_money = money
	for card in buy_cards:
		if card and is_instance_valid(card):
			var cost = card.get_current_cost()
			card.set_affordability(money >= cost)
	_update_status_bar()


## Actualizar disponibilidad de un item específico
func update_item_availability(item_id: String, is_available: bool) -> void:
	"""Actualiza la disponibilidad de un item específico"""
	for card in buy_cards:
		if card and is_instance_valid(card) and card.item_id == item_id:
			card.set_availability(is_available)


## Obtener tarjeta por ID
func get_card_by_id(item_id: String) -> Panel:
	"""Retorna la tarjeta con el ID especificado"""
	for card in buy_cards:
		if card and is_instance_valid(card) and card.item_id == item_id:
			return card
	return null


# Funciones privadas


func _setup_quantity_buttons() -> void:
	"""Configura los botones de cantidad"""
	if not nodes_ready:
		print("⚠️ ShopContainer: Nodos no listos en _setup_quantity_buttons")
		return

	# Crear ButtonGroup para que solo uno esté presionado
	var button_group = ButtonGroup.new()

	var buttons = [
		{button = x1_button, quantity = 1},
		{button = x5_button, quantity = 5},
		{button = x10_button, quantity = 10},
		{button = x25_button, quantity = 25},
		{button = x50_button, quantity = 50}
	]

	for btn_data in buttons:
		var button = btn_data.button
		var quantity = btn_data.quantity

		button.button_group = button_group
		button.toggled.connect(_on_quantity_button_toggled.bind(quantity))

	# x1 por defecto
	x1_button.button_pressed = true


func _update_ui_for_mode() -> void:
	"""Actualiza la UI según el modo (buy/sell)"""
	if not title_label:
		print("⚠️ ShopContainer: title_label no disponible en _update_ui_for_mode")
		return

	if shop_type == "buy":
		title_label.text = "🛒 " + title_label.text.strip_edges()
	else:
		title_label.text = "💰 " + title_label.text.strip_edges()


func _update_status_bar() -> void:
	"""Actualiza la barra de estado con totales"""
	if not nodes_ready:
		print("⚠️ ShopContainer: Nodos no listos en _update_status_bar")
		return

	var total_cost = 0.0
	var affordable_items = 0

	for card in buy_cards:
		if card and is_instance_valid(card):
			total_cost += card.get_current_cost()
			if card.is_affordable and card.is_available:
				affordable_items += 1

	total_label.text = "Total: $%s" % GameUtils.format_large_number(total_cost)

	# Actualizar estado de asequibilidad
	if buy_cards.is_empty():
		affordability_label.text = "📦 Sin items"
		affordability_label.modulate = Color.GRAY
	elif affordable_items == buy_cards.size():
		affordability_label.text = "✅ Todo disponible"
		affordability_label.modulate = Color.GREEN
	elif affordable_items > 0:
		affordability_label.text = "⚠️ Algunos disponibles"
		affordability_label.modulate = Color.YELLOW
	else:
		affordability_label.text = "❌ Nada disponible"
		affordability_label.modulate = Color.RED


# Manejadores de señales


func _on_quantity_button_toggled(quantity: int, button_pressed: bool) -> void:
	"""Maneja el cambio de cantidad global"""
	if not button_pressed:
		return

	current_quantity = quantity
	print("🔢 Cantidad global actualizada: x%d" % quantity)

	# Actualizar todas las tarjetas
	for card in buy_cards:
		if card and is_instance_valid(card):
			card.set_quantity(current_quantity)

	_update_status_bar()


func _on_item_purchased(item_id: String, quantity: int) -> void:
	"""Retransmite la señal de compra"""
	purchase_requested.emit(item_id, quantity)


func _on_item_sold(item_id: String, quantity: int) -> void:
	"""Retransmite la señal de venta"""
	sell_requested.emit(item_id, quantity)
