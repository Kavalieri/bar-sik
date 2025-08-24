extends Control
## CurrencyDisplay - Componente UI para mostrar monedas del juego
## Muestra cantidad actual de una moneda específica

# class_name CurrencyDisplay  # Comentado temporalmente para evitar conflictos

@export var currency_type: String = "cash"
@export var show_icon: bool = true
@export var show_label: bool = true

@onready var currency_icon: Label = $HBoxContainer/CurrencyIcon
@onready var currency_amount: Label = $HBoxContainer/CurrencyAmount
@onready var currency_label: Label = $HBoxContainer/CurrencyLabel

var current_amount: float = 0.0


func _ready() -> void:
	# Asegurar que los nodos estén listos antes de configurar
	await get_tree().process_frame
	setup_currency(currency_type)


func setup_currency(type: String) -> void:
	currency_type = type

	# Verificar que los nodos existan antes de usarlos
	if not currency_icon or not currency_label:
		print("WARNING: CurrencyDisplay nodes not ready yet")
		return

	# Configurar icono y etiqueta según el tipo
	match currency_type:
		"cash":
			currency_icon.text = "💵"
			currency_label.text = "Cash"
		"tokens":
			currency_icon.text = "🪙"
			currency_label.text = "Tokens"
		"stars":
			currency_icon.text = "⭐"
			currency_label.text = "Stars"
		"gems":
			currency_icon.text = "💎"
			currency_label.text = "Gems"
		_:
			currency_icon.text = "🪙"
			currency_label.text = "Currency"

	# Configurar visibilidad
	currency_icon.visible = show_icon
	currency_label.visible = show_label

	update_display()


func update_display() -> void:
	if !is_node_ready() or not currency_amount:
		return

	# Por ahora mostrar valor placeholder
	current_amount = 0.0
	currency_amount.text = _format_currency(current_amount)


func _format_currency(amount: float) -> String:
	if amount >= 1000000000000:
		return "%.2fT" % (amount / 1000000000000.0)
	elif amount >= 1000000000:
		return "%.2fB" % (amount / 1000000000.0)
	elif amount >= 1000000:
		return "%.2fM" % (amount / 1000000.0)
	elif amount >= 1000:
		return "%.2fK" % (amount / 1000.0)
	else:
		return str(int(amount))


# Actualizar automáticamente
func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 60 == 0:  # Cada segundo aproximadamente
		update_display()


# Métodos para actualizar externamente
func set_amount(amount: float) -> void:
	current_amount = amount
	update_display()


func add_amount(amount: float) -> void:
	current_amount += amount
	update_display()

	# Efecto visual de incremento
	_play_increment_effect()


func _play_increment_effect() -> void:
	# Efecto de color temporal
	var original_color = currency_amount.modulate
	currency_amount.modulate = Color.GREEN

	var tween = create_tween()
	tween.tween_property(currency_amount, "modulate", original_color, 0.3)
