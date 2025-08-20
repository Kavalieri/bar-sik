extends Panel
# class_name ItemListCard  # Comentado temporalmente para evitar conflictos RefCounted
## Componente genérico de lista con botón contextual
## Reutilizable para cualquier tipo de elemento con acción personalizable

# Señales
signal action_requested(item_id: String, action: String, data: Dictionary)

# Configuración del item
var item_id: String = ""
var item_data: Dictionary = {}
var button_config: Dictionary = {}

# Referencias a elementos internos
@onready var name_label: Label = $CardContainer/ItemInfo/NameLabel
@onready var amount_label: Label = $CardContainer/ItemInfo/AmountLabel
@onready var description_label: Label = $CardContainer/ItemInfo/DescriptionLabel
@onready var action_button: Button = $CardContainer/ActionButton

# Flag para verificar si los nodos están disponibles
var nodes_ready: bool = false


func _ready() -> void:
	# Verificar que todos los nodos estén disponibles
	nodes_ready = _verify_nodes()

	if action_button:
		action_button.pressed.connect(_on_action_button_pressed)
	else:
		print("⚠️ ItemListCard: action_button no encontrado en _ready")


func _verify_nodes() -> bool:
	"""Verificar que todos los nodos necesarios estén disponibles"""
	var all_present = true

	if not name_label:
		print("⚠️ ItemListCard: name_label no encontrado")
		all_present = false
	if not amount_label:
		print("⚠️ ItemListCard: amount_label no encontrado")
		all_present = false
	if not description_label:
		print("⚠️ ItemListCard: description_label no encontrado")
		all_present = false
	if not action_button:
		print("⚠️ ItemListCard: action_button no encontrado")
		all_present = false

	return all_present


## Configurar el item de la lista
func setup_item(data: Dictionary, btn_config: Dictionary) -> void:
	"""
	Configura el item de la lista
	data: {id, name, amount, description, ...}
	btn_config: {text, icon, action, color (opcional)}
	"""
	if not nodes_ready:
		print("⚠️ ItemListCard: Los nodos no están listos, reintentando verificación...")
		nodes_ready = _verify_nodes()

	if not nodes_ready:
		print("❌ ItemListCard: No se pueden configurar los datos, nodos faltantes")
		return

	item_id = data.get("id", "")
	item_data = data.duplicate()
	button_config = btn_config.duplicate()

	# Configurar información del item - sin validaciones adicionales ya que nodes_ready=true
	name_label.text = "%s %s" % [data.get("icon", "📦"), data.get("name", "Item")]

	var amount = data.get("amount", 0)
	amount_label.text = "📦 Cantidad: %s" % GameUtils.format_large_number(amount)

	description_label.text = data.get("description", "Sin descripción")

	# Configurar botón
	_setup_action_button()


## Actualizar datos del item
func update_data(new_data: Dictionary) -> void:
	"""Actualiza los datos del item manteniendo la configuración del botón"""
	var old_amount = item_data.get("amount", 0)
	item_data.merge(new_data)

	# Actualizar solo si los datos cambiaron
	var new_amount = item_data.get("amount", 0)
	if new_amount != old_amount:
		amount_label.text = "📦 Cantidad: %s" % GameUtils.format_large_number(new_amount)

	# Actualizar otros campos si cambiaron
	if new_data.has("name"):
		name_label.text = "%s %s" % [item_data.get("icon", "📦"), item_data.get("name", "Item")]

	if new_data.has("description"):
		description_label.text = item_data.get("description", "Sin descripción")


## Configurar el botón de acción
func configure_button(btn_config: Dictionary) -> void:
	"""
	Configura el botón de acción
	btn_config: {text, icon, action, color (opcional), enabled (opcional)}
	"""
	button_config = btn_config.duplicate()
	_setup_action_button()


## Habilitar/deshabilitar el botón
func set_button_enabled(enabled: bool) -> void:
	"""Habilita o deshabilita el botón de acción"""
	action_button.disabled = not enabled
	action_button.modulate = Color.WHITE if enabled else Color.GRAY


# Funciones privadas


func _setup_action_button() -> void:
	"""Configura el botón según la configuración"""
	if not action_button:
		print("⚠️ ItemListCard: action_button no encontrado")
		return

	var text = button_config.get("text", "Acción")
	var icon = button_config.get("icon", "⚙️")
	var enabled = button_config.get("enabled", true)

	action_button.text = "%s %s" % [icon, text]
	action_button.disabled = not enabled

	# Aplicar color personalizado si se especifica
	var color = button_config.get("color", Color.WHITE)
	action_button.modulate = color if enabled else Color.GRAY


func _on_action_button_pressed() -> void:
	"""Maneja el clic del botón de acción"""
	var action = button_config.get("action", "default")
	action_requested.emit(item_id, action, item_data)
	print("🎯 Acción '%s' solicitada para: %s" % [action, item_id])
