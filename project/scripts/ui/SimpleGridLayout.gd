extends Control
## SimpleGridLayout - Cuadrícula simple y robusta para interfaces
## Sin experimentos, solo funcionalidad que garantiza que funcione

# Configuración de la cuadrícula
@export var columns: int = 2
@export var spacing: int = 12
@export var margin: int = 16

# Contenedor principal
var main_container: VBoxContainer
var grid_container: GridContainer

func _ready():
	setup_layout()

func setup_layout():
	"""Configurar la cuadrícula base"""
	# Crear contenedor principal vertical
	main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", spacing)

	# Añadir márgenes
	main_container.add_theme_constant_override("margin_left", margin)
	main_container.add_theme_constant_override("margin_right", margin)
	main_container.add_theme_constant_override("margin_top", margin)
	main_container.add_theme_constant_override("margin_bottom", margin)

	add_child(main_container)

	# Crear cuadrícula
	grid_container = GridContainer.new()
	grid_container.name = "GridContainer"
	grid_container.columns = columns
	grid_container.add_theme_constant_override("h_separation", spacing)
	grid_container.add_theme_constant_override("v_separation", spacing)
	grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_container.size_flags_vertical = Control.SIZE_EXPAND_FILL

	main_container.add_child(grid_container)

	print("✅ SimpleGridLayout configurado: %d columnas, spacing %d" % [columns, spacing])

func add_title(text: String) -> Label:
	"""Agregar título a la cuadrícula"""
	var title = Label.new()
	title.text = text
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Insertar título antes de la cuadrícula
	main_container.add_child(title)
	main_container.move_child(title, 0)

	return title

func add_simple_button(text: String, icon: String = "") -> Button:
	"""Agregar botón simple a la cuadrícula"""
	var button = Button.new()

	# Configurar texto e icono
	if icon.length() > 0:
		button.text = "%s %s" % [icon, text]
	else:
		button.text = text

	# Configurar tamaño mínimo
	button.custom_minimum_size = Vector2(120, 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL

	grid_container.add_child(button)
	return button

func add_info_panel(title: String, content: String, icon: String = "") -> Panel:
	"""Agregar panel de información a la cuadrícula"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(150, 80)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Crear contenedor interno
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	vbox.add_theme_constant_override("margin_left", 8)
	vbox.add_theme_constant_override("margin_right", 8)
	vbox.add_theme_constant_override("margin_top", 8)
	vbox.add_theme_constant_override("margin_bottom", 8)

	# Título del panel
	var title_label = Label.new()
	title_label.text = "%s %s" % [icon, title] if icon.length() > 0 else title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Contenido del panel
	var content_label = Label.new()
	content_label.text = content
	content_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content_label.size_flags_vertical = Control.SIZE_EXPAND_FILL

	vbox.add_child(title_label)
	vbox.add_child(content_label)
	panel.add_child(vbox)

	grid_container.add_child(panel)
	return panel

func set_columns(new_columns: int):
	"""Cambiar número de columnas dinámicamente"""
	columns = new_columns
	if grid_container:
		grid_container.columns = columns
		print("📐 Cuadrícula actualizada a %d columnas" % columns)

func clear_grid():
	"""Limpiar toda la cuadrícula"""
	if grid_container:
		for child in grid_container.get_children():
			child.queue_free()
		print("🧹 Cuadrícula limpiada")

# Configuraciones predefinidas para diferentes pantallas
func setup_mobile():
	"""Configuración optimizada para mobile"""
	set_columns(1)
	spacing = 16
	margin = 20
	if grid_container:
		grid_container.add_theme_constant_override("h_separation", spacing)
		grid_container.add_theme_constant_override("v_separation", spacing)
	print("📱 Configuración mobile aplicada")

func setup_tablet():
	"""Configuración optimizada para tablet"""
	set_columns(2)
	spacing = 12
	margin = 16
	if grid_container:
		grid_container.add_theme_constant_override("h_separation", spacing)
		grid_container.add_theme_constant_override("v_separation", spacing)
	print("📱 Configuración tablet aplicada")

func setup_desktop():
	"""Configuración optimizada para desktop"""
	set_columns(3)
	spacing = 8
	margin = 12
	if grid_container:
		grid_container.add_theme_constant_override("h_separation", spacing)
		grid_container.add_theme_constant_override("v_separation", spacing)
	print("🖥️ Configuración desktop aplicada")
