class_name BasePanel extends ScrollContainer
## BasePanel - Clase base abstracta para todos los paneles del juego
## Implementa funcionalidad común y template method pattern
##
## Elimina duplicación de código entre GenerationPanel, ProductionPanel,
## SalesPanel y CustomersPanel mediante herencia y métodos abstractos.

# =============================================================================
# SEÑALES COMUNES
# =============================================================================

signal panel_ready

# =============================================================================
# ESTADO COMÚN DE PANELES
# =============================================================================

var is_initialized: bool = false
var current_game_data: Dictionary = {}

# Referencias a contenedores principales (cada panel debe configurar)
@onready var main_container: VBoxContainer

# =============================================================================
# TEMPLATE METHOD PATTERN - Flujo de inicialización estandarizado
# =============================================================================


func _ready():
	"""Template method - Define el flujo de inicialización común"""
	if not is_initialized:
		call_deferred("_initialize_complete_panel")


func _initialize_complete_panel():
	"""Inicialización completa del panel usando template method"""
	_initialize_base_components()
	_initialize_panel_specific()
	_connect_base_signals()
	_connect_panel_signals()
	is_initialized = true
	panel_ready.emit()


# Métodos del template - implementados en la clase base
func _initialize_base_components():
	"""Inicializar componentes comunes a todos los paneles"""
	# Configuración base del scroll container
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	follow_focus = true


func _connect_base_signals():
	"""Conectar señales comunes a todos los paneles"""
	# Señales de gamedata actualizado
	if GameEvents.has_signal("game_data_updated"):
		GameEvents.game_data_updated.connect(_on_game_data_updated)


# =============================================================================
# FUNCIONALIDAD COMÚN DE PANELES
# =============================================================================


func update_with_game_data(game_data: Dictionary):
	"""Actualizar panel con datos del juego - Template method"""
	if not is_initialized:
		return

	current_game_data = game_data
	_update_panel_data(game_data)


func _on_game_data_updated(game_data: Dictionary):
	"""Callback común para actualización de datos del juego"""
	update_with_game_data(game_data)


# =============================================================================
# UTILIDADES COMUNES
# =============================================================================


func is_manager_valid(manager_ref: Node) -> bool:
	"""Validación robusta de referencias a managers"""
	return manager_ref != null and is_instance_valid(manager_ref)


func clear_container_children(container: Node):
	"""Limpiar todos los hijos de un contenedor de forma segura"""
	if not is_instance_valid(container):
		return

	for child in container.get_children():
		if is_instance_valid(child):
			child.queue_free()


# =============================================================================
# MÉTODOS ABSTRACTOS - DEBEN IMPLEMENTARSE EN PANELES HIJOS
# =============================================================================


func _initialize_panel_specific():
	"""ABSTRACTO: Inicializar componentes específicos del panel"""
	var script_name = str(get_script().resource_path)
	push_error("BasePanel: _initialize_panel_specific() debe implementarse en " + script_name)


func _connect_panel_signals():
	"""ABSTRACTO: Conectar señales específicas del panel"""
	var script_name = str(get_script().resource_path)
	push_error("BasePanel: _connect_panel_signals() debe implementarse en " + script_name)


func _update_panel_data(_game_data: Dictionary):
	"""ABSTRACTO: Actualizar datos específicos del panel"""
	var script_name = str(get_script().resource_path)
	push_error("BasePanel: _update_panel_data() debe implementarse en " + script_name)
