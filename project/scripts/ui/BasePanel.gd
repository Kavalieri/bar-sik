class_name BasePanel
extends Control
## BasePanel - ELIMINADOR MAESTRO DE DUPLICACIÓN
## Clase padre para todos los paneles del juego

# Señales comunes estandarizadas
signal panel_ready
signal data_updated(data: Dictionary)
signal error_occurred(message: String)

# Referencias estándar (elimina duplicación de @onready)
@onready var main_vbox: VBoxContainer
@onready var scroll_container: ScrollContainer

# Estado común anti-duplicación
var manager_ref: Node = null
var button_states: Dictionary = {}
var update_in_progress: bool = false
var is_initialized: bool = false


func _ready():
	"""Patrón _ready() estandarizado - ELIMINA 39 DUPLICACIONES"""
	await get_tree().process_frame

	print("🚀 %s _ready() iniciado" % get_script().get_path().get_file())

	# Pipeline estándar anti-duplicación
	initialize_references()
	setup_common_layout()
	connect_common_signals()
	initialize_specific_content()
	post_initialization()

	is_initialized = true
	panel_ready.emit()
	print("✅ %s inicializado correctamente" % name)


# === MÉTODOS ANTI-DUPLICACIÓN ===


func setup_common_layout():
	"""Layout común para evitar duplicación de containers"""
	create_main_containers()
	apply_common_styling()


func create_main_containers():
	"""Containers estándar - elimina duplicación de VBox/ScrollContainer"""
	if not scroll_container:
		scroll_container = ScrollContainer.new()
		scroll_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(scroll_container)

	if not main_vbox:
		main_vbox = VBoxContainer.new()
		main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		main_vbox.add_theme_constant_override("separation", 12)
		scroll_container.add_child(main_vbox)


func apply_common_styling():
	"""Estilos comunes - elimina duplicación de theme overrides"""
	if main_vbox:
		main_vbox.add_theme_constant_override("margin_left", 16)
		main_vbox.add_theme_constant_override("margin_right", 16)
		main_vbox.add_theme_constant_override("margin_top", 16)
		main_vbox.add_theme_constant_override("margin_bottom", 16)


# === UTILIDADES ANTI-DUPLICACIÓN ===


func create_section_title(text: String, color: Color = Color.GOLD, size: int = 24) -> Label:
	"""Título de sección estandarizado - elimina duplicación de Labels"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func create_standard_button(text: String, button_size: Vector2 = Vector2(120, 40)) -> Button:
	"""Botón estandarizado - elimina duplicación de Button creation"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = button_size
	button.add_theme_font_size_override("font_size", 16)
	return button


func safe_connect_signal(signal_obj: Signal, callable_obj: Callable):
	"""Conexión segura de señales - elimina duplicación de .connect()"""
	if not signal_obj.is_connected(callable_obj):
		signal_obj.connect(callable_obj)


func clean_children(container: Node):
	"""Limpieza segura de hijos - ELIMINA CÓDIGO DUPLICADO EN 7+ ARCHIVOS"""
	if not is_instance_valid(container):
		return

	for child in container.get_children():
		if is_instance_valid(child):
			child.queue_free()


# === MÉTODOS VIRTUALES (OVERRIDE EN HIJOS) ===


func initialize_references():
	"""Override: Inicializar referencias específicas del panel"""
	pass


func connect_common_signals():
	"""Override: Conectar señales específicas del panel"""
	pass


func initialize_specific_content():
	"""Override: Contenido específico del panel"""
	pass


func post_initialization():
	"""Override: Post-procesamiento específico del panel"""
	pass


# === GETTERS COMUNES ===


func get_current_game_data() -> Dictionary:
	"""Getter estandarizado de game_data - elimina duplicación"""
	if manager_ref and manager_ref.has_method("get_game_data"):
		return manager_ref.get_game_data()

	# Fallback a GameManager singleton
	if GameManager and GameManager.has_method("get_game_data"):
		var game_data = GameManager.get_game_data()
		return {
			"money": game_data.money,
			"resources": game_data.resources.duplicate(),
			"products": game_data.products.duplicate(),
			"stations": game_data.stations.duplicate()
		}

	return {"money": 0, "resources": {}, "products": {}, "stations": {}}
