extends Panel
# class_name BuyCard  # Comentado temporalmente para evitar conflictos RefCounted
## Componente reutilizable de tarjeta de compra/venta
## Completamente autónomo y configurable

# Configuración del item
var item_id: String = ""
var base_price: float = 0.0
var current_quantity: int = 1
var cost_calculator: Callable
var card_type: String = "buy"  # "buy" o "sell"

# Estado
var is_affordable: bool = true
var is_available: bool = true

# Señales
signal item_purchased(item_id: String, quantity: int)
signal item_sold(item_id: String, quantity: int)

# Referencias a elementos internos
@onready var item_icon: TextureRect = $CardContainer/ItemIcon
@onready var title_label: Label = $CardContainer/TitleLabel
@onready var info_label: Label = $CardContainer/InfoLabel
@onready var price_label: Label = $CardContainer/PriceLabel
@onready var action_button: Button = $CardContainer/BuyButton


func _ready() -> void:
	action_button.pressed.connect(_on_action_button_pressed)


## Configurar la tarjeta con datos del item
func setup(item_data: Dictionary, card_mode: String = "buy") -> void:
	"""
	Configura la tarjeta con los datos del item
	item_data debe contener: id, name, description, base_price, icon_path (opcional)
	card_mode: "buy" o "sell"
	"""
	item_id = item_data.get("id", "")
	base_price = item_data.get("base_price", 0.0)
	card_type = card_mode

	# Configurar textos
	title_label.text = item_data.get("name", "Item")
	info_label.text = item_data.get("description", "Sin descripción")

	# Configurar icono si está disponible
	var icon_path = item_data.get("icon_path", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		item_icon.texture = load(icon_path)
	else:
		# Usar emoji por defecto basado en el tipo
		var emoji = GameUtils.get_item_emoji(item_id)
		# Crear texture desde emoji (esto requeriría un sistema de emoji a texture)
		item_icon.visible = false  # Por ahora ocultar hasta implementar emoji-to-texture

	# Configurar botón según el modo
	_setup_action_button()
	update_price_display()


## Configurar calculadora de costo personalizada
func set_cost_calculator(calculator: Callable) -> void:
	"""Establece una función personalizada para calcular el costo"""
	cost_calculator = calculator


## Actualizar la cantidad global (viene del ShopContainer)
func set_quantity(quantity: int) -> void:
	"""Establece la cantidad a comprar/vender"""
	current_quantity = max(1, quantity)
	update_price_display()


## Actualizar si el item es asequible
func set_affordability(can_afford: bool) -> void:
	"""Establece si el item puede ser comprado/vendido"""
	is_affordable = can_afford
	_update_button_state()


## Actualizar si el item está disponible
func set_availability(is_avail: bool) -> void:
	"""Establece si el item está disponible"""
	is_available = is_avail
	_update_button_state()


## Actualizar visualización del precio
func update_price_display() -> void:
	"""Actualiza la visualización del precio según la cantidad"""
	var total_price = _calculate_total_price()
	var price_text = ""

	if card_type == "buy":
		price_text = "💰 $%s" % GameUtils.format_large_number(total_price)
		if current_quantity > 1:
			price_text += " (x%d)" % current_quantity
	else:  # sell
		price_text = "💸 $%s" % GameUtils.format_large_number(total_price)
		if current_quantity > 1:
			price_text += " (x%d)" % current_quantity

	price_label.text = price_text


## Obtener el costo actual
func get_current_cost() -> float:
	"""Retorna el costo actual del item"""
	return _calculate_total_price()


# Funciones privadas


func _setup_action_button() -> void:
	"""Configura el botón según el tipo de tarjeta"""
	if card_type == "buy":
		action_button.text = "🛒 Comprar"
	elif card_type == "sell":
		action_button.text = "💰 Vender"


func _calculate_total_price() -> float:
	"""Calcula el precio total según la cantidad"""
	if cost_calculator.is_valid():
		return cost_calculator.call(item_id, current_quantity)

	return base_price * current_quantity


func _update_button_state() -> void:
	"""Actualiza el estado visual del botón"""
	var is_enabled = is_affordable and is_available

	action_button.disabled = not is_enabled

	# Actualizar colores y texto
	if not is_available:
		action_button.modulate = Color.GRAY
		action_button.text = "❌ No disponible"
	elif not is_affordable:
		action_button.modulate = Color.RED
		if card_type == "buy":
			action_button.text = "💸 Sin dinero"
		else:
			action_button.text = "📦 Sin stock"
	else:
		action_button.modulate = Color.WHITE
		_setup_action_button()


func _on_action_button_pressed() -> void:
	"""Maneja el clic del botón de acción"""
	if not (is_affordable and is_available):
		return

	if card_type == "buy":
		item_purchased.emit(item_id, current_quantity)
	else:  # sell
		item_sold.emit(item_id, current_quantity)

	print("🎯 %s: %s x%d" % [card_type.capitalize(), item_id, current_quantity])
