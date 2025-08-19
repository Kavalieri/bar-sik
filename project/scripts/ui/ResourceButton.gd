extends Button
## ResourceButton - Botón especializado para recursos del juego idle
## Muestra información del recurso, cantidad y permite interacción

# class_name ResourceButton  # Comentado temporalmente para evitar conflictos

@export var resource_type: String = ""
@export var show_quantity: bool = true
@export var show_generation_rate: bool = false

@onready var resource_icon: TextureRect = $HBoxContainer/ResourceIcon
@onready var resource_info: VBoxContainer = $HBoxContainer/ResourceInfo
@onready var resource_name_label: Label = $HBoxContainer/ResourceInfo/ResourceName
@onready var quantity_label: Label = $HBoxContainer/ResourceInfo/QuantityLabel
@onready var rate_label: Label = $HBoxContainer/ResourceInfo/RateLabel

signal resource_clicked(resource_type: String)

var current_quantity: float = 0.0
var generation_rate: float = 0.0


func _ready() -> void:
	pressed.connect(_on_pressed)

	if resource_type != "":
		setup_resource(resource_type)


func setup_resource(type: String) -> void:
	resource_type = type

	# Obtener datos del recurso desde la constante
	if ResourceManager.RESOURCE_DATA.has(resource_type):
		var data = ResourceManager.RESOURCE_DATA[resource_type]
		resource_name_label.text = data.name

		# Configurar icono basado en el tipo
		_set_resource_icon(resource_type)

	update_display()


func _set_resource_icon(type: String) -> void:
	# Usar emojis desde los datos del recurso
	var icon_text = "🥤"  # Default

	if ResourceManager.RESOURCE_DATA.has(type):
		var data = ResourceManager.RESOURCE_DATA[type]
		if data.has("emoji"):
			icon_text = data.emoji

	# Crear una etiqueta temporal para mostrar el emoji
	if resource_icon.get_child_count() == 0:
		var emoji_label = Label.new()
		emoji_label.text = icon_text
		emoji_label.add_theme_font_size_override("font_size", 32)
		emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		resource_icon.add_child(emoji_label)


func update_display() -> void:
	if !is_node_ready():
		return

	# Para componente UI, usar datos estáticos por ahora
	if show_quantity:
		current_quantity = 0.0  # Placeholder
		quantity_label.text = _format_number(current_quantity)
		quantity_label.visible = true
	else:
		quantity_label.visible = false

	# Mostrar datos del recurso
	if show_generation_rate and ResourceManager.RESOURCE_DATA.has(resource_type):
		var data = ResourceManager.RESOURCE_DATA[resource_type]
		if data.has("base_generation"):
			generation_rate = float(data.base_generation)
			rate_label.text = "+" + _format_number(generation_rate) + "/s"
			rate_label.visible = true
		else:
			rate_label.visible = false
	else:
		rate_label.visible = false

	# Actualizar estado del botón
	_update_button_state()


func _update_button_state() -> void:
	# El botón está habilitado si el recurso está desbloqueado
	if ResourceManager.RESOURCE_DATA.has(resource_type):
		var data = ResourceManager.RESOURCE_DATA[resource_type]
		var is_unlocked = data.get("unlocked", false)
		disabled = !is_unlocked

		# Cambiar estilo visual según el estado
		if is_unlocked:
			modulate = Color.WHITE
		else:
			modulate = Color(0.7, 0.7, 0.7)


func _format_number(number: float) -> String:
	if number >= 1000000000:
		return "%.1fB" % (number / 1000000000.0)
	elif number >= 1000000:
		return "%.1fM" % (number / 1000000.0)
	elif number >= 1000:
		return "%.1fK" % (number / 1000.0)
	else:
		return str(int(number))


func _on_pressed() -> void:
	print("🎯 Recurso clickeado: ", resource_type)
	resource_clicked.emit(resource_type)

	# Efectos visuales del click
	_play_click_effect()


func _play_click_effect() -> void:
	# Efecto de scale temporal
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

	scale = Vector2(0.95, 0.95)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)


# Actualizar automáticamente el display
func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 30 == 0:  # Cada 0.5 segundos aproximadamente
		update_display()
