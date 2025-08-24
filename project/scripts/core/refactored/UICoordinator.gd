extends Control
class_name UICoordinator
## Coordinador especializado para UI del juego
## Maneja paneles, navegación y actualizaciones de display

signal panel_changed(panel_name: String)
signal modal_requested(modal_type: String)

# Referencias a paneles principales
@onready var tab_navigator: Control = $"../TabNavigator"

var panels: Dictionary = {}
var current_panel: String = ""
var modal_stack: Array[Control] = []

# Cache para actualizaciones eficientes
var last_update_time: float = 0.0
var update_frequency: float = 0.1  # 10 FPS para UI

func _ready():
	print("🎨 UICoordinator inicializando...")
	call_deferred("_setup_panels")
	print("✅ UICoordinator listo")

func _setup_panels():
	"""Configurar referencias a paneles principales"""
	if not tab_navigator:
		push_warning("⚠️ TabNavigator no encontrado en UICoordinator")
		return
	
	# Buscar paneles automáticamente
	_discover_panels()
	_connect_panel_signals()
	print("📋 %d paneles registrados" % panels.size())

func _discover_panels():
	"""Descubrir paneles disponibles automáticamente"""
	var panel_nodes = tab_navigator.get_children()
	for node in panel_nodes:
		if node.has_method("initialize_specific_content"):
			panels[node.name.to_lower()] = node
			print("🔍 Panel descubierto: %s" % node.name)

func _connect_panel_signals():
	"""Conectar señales de paneles si existen"""
	for panel_name in panels:
		var panel = panels[panel_name]
		if panel.has_signal("content_updated"):
			if not panel.is_connected("content_updated", _on_panel_content_updated):
				panel.connect("content_updated", _on_panel_content_updated.bind(panel_name))

func switch_to_panel(panel_name: String):
	"""Cambiar a un panel específico"""
	if panel_name == current_panel:
		return
	
	if panel_name in panels:
		current_panel = panel_name
		panel_changed.emit(panel_name)
		_update_panel_visibility()
		print("📋 Cambio a panel: %s" % panel_name)
	else:
		push_warning("⚠️ Panel no encontrado: %s" % panel_name)

func _update_panel_visibility():
	"""Actualizar visibilidad de paneles"""
	for name in panels:
		var panel = panels[name]
		panel.visible = (name == current_panel)

func update_all_displays():
	"""Actualizar displays de todos los paneles activos"""
	var current_time = Time.get_time_dict_from_system()
	var time_float = current_time.hour * 3600 + current_time.minute * 60 + current_time.second + current_time.millisecond / 1000.0
	
	if time_float - last_update_time < update_frequency:
		return
	
	last_update_time = time_float
	
	for panel_name in panels:
		var panel = panels[panel_name]
		if panel.visible and panel.has_method("update_display"):
			panel.update_display()

func show_modal(modal_type: String, data: Dictionary = {}):
	"""Mostrar modal específico"""
	modal_requested.emit(modal_type)
	print("🪟 Modal solicitado: %s" % modal_type)

func _on_panel_content_updated(panel_name: String):
	"""Callback cuando el contenido de un panel se actualiza"""
	print("🔄 Panel actualizado: %s" % panel_name)

func get_panel(panel_name: String) -> Control:
	"""Obtener referencia a un panel específico"""
	return panels.get(panel_name.to_lower())

func is_panel_active(panel_name: String) -> bool:
	"""Verificar si un panel está activo"""
	return current_panel == panel_name.to_lower()

func refresh_panel(panel_name: String):
	"""Refrescar un panel específico"""
	var panel = get_panel(panel_name)
	if panel and panel.has_method("refresh_content"):
		panel.refresh_content()
