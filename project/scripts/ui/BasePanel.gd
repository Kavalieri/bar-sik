extends ScrollContainer
class_name BasePanel
## BasePanel - Clase base para todos los paneles de la UI
## Proporciona funcionalidad común y estructura consistente

# Referencias a contenedores principales (deben ser definidas por las subclases)
@onready var main_container: VBoxContainer

# Estado de inicialización
var is_initialized: bool = false
var pending_setup_calls: Array = []

# Señales comunes
signal panel_ready

func _ready() -> void:
	# Esperar un frame para asegurar que todos los nodos estén listos
	call_deferred("_initialize_panel")

func _initialize_panel() -> void:
	"""Inicialización base del panel"""
	if not _validate_structure():
		push_error("Panel structure validation failed for " + name)
		return

	_setup_base_styling()
	_create_sections()
	is_initialized = true

	# Procesar llamadas pendientes
	for call_data in pending_setup_calls:
		match call_data.method:
			"setup_data":
				_setup_data_internal(call_data.args[0])
			"update_displays":
				_update_displays_internal(call_data.args[0])

	pending_setup_calls.clear()
	panel_ready.emit()

	print("✅ Panel inicializado: %s" % name)

func _validate_structure() -> bool:
	"""Valida que la estructura del panel sea correcta"""
	if not main_container:
		main_container = get_node_or_null("MainContainer")
		if not main_container:
			push_error("MainContainer no encontrado en " + name)
			return false
	return true

func _setup_base_styling() -> void:
	"""Configura el estilo base del panel"""
	# Configurar el ScrollContainer
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	set_horizontal_scroll_mode(ScrollContainer.SCROLL_MODE_DISABLED)
	set_vertical_scroll_mode(ScrollContainer.SCROLL_MODE_AUTO)

func _create_sections() -> void:
	"""Crear secciones del panel - debe ser sobrescrita por subclases"""
	pass

# Métodos públicos con validación de inicialización
func setup_data(data: Dictionary) -> void:
	"""Configura los datos del panel"""
	if not is_initialized:
		pending_setup_calls.append({"method": "setup_data", "args": [data]})
		return
	_setup_data_internal(data)

func update_displays(data: Dictionary) -> void:
	"""Actualiza las visualizaciones del panel"""
	if not is_initialized:
		pending_setup_calls.append({"method": "update_displays", "args": [data]})
		return
	_update_displays_internal(data)

# Métodos internos - deben ser sobrescritos por subclases
func _setup_data_internal(data: Dictionary) -> void:
	"""Implementación interna de setup_data"""
	pass

func _update_displays_internal(data: Dictionary) -> void:
	"""Implementación interna de update_displays"""
	pass

# Utilidades comunes
func clear_container(container: Container) -> void:
	"""Limpia un contenedor de forma segura"""
	if not container:
		return

	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func create_section_header(title: String, subtitle: String = "") -> Control:
	"""Crea un header de sección consistente"""
	return UIStyleManager.create_section_header(title, subtitle)

func create_styled_card() -> Control:
	"""Crea una tarjeta con estilo consistente"""
	return UIStyleManager.create_styled_panel()

func add_separator_to_container(container: Container, height: int = 16) -> void:
	"""Agrega un separador a un contenedor"""
	var separator = VSeparator.new()
	separator.set_custom_minimum_size(Vector2(0, height))
	separator.modulate = Color.TRANSPARENT
	container.add_child(separator)
