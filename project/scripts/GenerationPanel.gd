extends ScrollContainer
## GenerationPanel - Panel de generación MODULAR Y PROFESIONAL
## Genera recursos e ingredientes con UI coherente y responsive

# Referencias a contenedores
@onready var main_container: VBoxContainer = $MainContainer
@onready var resources_container: VBoxContainer = $MainContainer/ResourcesSection/ResourceContainer
@onready var generators_container: VBoxContainer = $MainContainer/GeneratorsSection/GeneratorContainer

# Estado del panel
var is_initialized: bool = false
var resource_labels: Dictionary = {}
var generator_interfaces: Array[Control] = []
var generator_definitions: Array[Dictionary] = []

# Señales
signal generator_purchased(generator_index: int, quantity: int)

func _ready() -> void:
	print("📦 GenerationPanel inicializando con sistema modular...")
	call_deferred("_initialize_panel")

func _initialize_panel() -> void:
	"""Inicialización completa del panel con tema coherente"""
	_create_sections()
	_apply_consistent_theming()
	is_initialized = true
	print("✅ GenerationPanel inicializado con tema profesional")

func _apply_consistent_theming() -> void:
	"""Aplicar tema coherente a todo el panel"""
	# Aplicar responsive design
	UIComponentsFactory.make_responsive(self)

	# Animación de entrada para el contenido
	UIComponentsFactory.animate_fade_in(main_container, 0.35)

func _create_sections() -> void:
	"""Crear secciones del panel con componentes modulares"""
	_create_resources_section()
	_add_section_separator()
	_create_generators_section()

func _add_section_separator() -> void:
	"""Añadir separador visual profesional"""
	var separator = UIComponentsFactory.create_section_separator()
	main_container.add_child(separator)

func _create_resources_section() -> void:
	"""Crear sección de recursos con componentes profesionales"""
	UIComponentsFactory.clear_container(resources_container)

	var header = UIComponentsFactory.create_section_header(
		"📦 INGREDIENTES DISPONIBLES",
		"Inventario de materias primas"
	)
	resources_container.add_child(header)

	# Panel de contenido profesional
	var content_panel = UIComponentsFactory.create_content_panel(120)
	resources_container.add_child(content_panel)

func _create_generators_section() -> void:
	"""Crear sección de generadores con componentes profesionales"""
	UIComponentsFactory.clear_container(generators_container)

	var header = UIComponentsFactory.create_section_header(
		"🌾 GENERADORES AUTOMÁTICOS",
		"Producen ingredientes de forma continua"
	)
	generators_container.add_child(header)

	# Lista scrolleable para generadores
	var generators_scroll = UIComponentsFactory.create_scrollable_list()
	generators_container.add_child(generators_scroll)


func setup_resources(game_data: Dictionary) -> void:
	"""Configura los recursos del juego"""
	if not is_initialized:
		call_deferred("setup_resources", game_data)
		return

	resource_labels.clear()

	# Crear labels para recursos
	for resource_name in game_data["resources"].keys():
		var resource_card = UIComponentsFactory.create_content_panel(50)

		var label = Label.new()
		label.text = "%s: 0.0" % resource_name.capitalize()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size",
			int(UITheme.Typography.BODY_MEDIUM * UITheme.get_font_scale()))

		resource_card.add_child(label)
		resources_container.add_child(resource_card)
		resource_labels[resource_name] = label

func setup_generators(resource_generators: Array[Dictionary]) -> void:
	"""Configura los generadores disponibles"""
	if not is_initialized:
		call_deferred("setup_generators", resource_generators)
		return

	generator_definitions = resource_generators
	_clear_generator_interfaces()

	# Crear interface para cada generador
	for i in range(resource_generators.size()):
		var generator = resource_generators[i]
		var interface = _create_generator_interface(generator, i)
		generators_container.add_child(interface)
		generator_interfaces.append(interface)

func _create_generator_interface(generator: Dictionary, index: int) -> Control:
	"""Crea la interface de un generador"""
	var card = UIComponentsFactory.create_content_panel(120)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", UITheme.Spacing.SMALL)
	card.add_child(vbox)

	# Información del generador
	var info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	info_label.add_theme_font_size_override("font_size", 13)
	info_label.text = _format_generator_info(generator, 0)
	vbox.add_child(info_label)

	# Contenedor de botones
	var button_container = HBoxContainer.new()
	button_container.set_custom_minimum_size(Vector2(0, 35))
	button_container.add_theme_constant_override("separation", 4)
	vbox.add_child(button_container)

	# Botones de compra
	var increments = [1, 5, 10, 25]
	for increment in increments:
		var button = UIComponentsFactory.create_primary_button("×%d\n$0" % increment)
		button.set_custom_minimum_size(Vector2(65, 30))
		button.add_theme_font_size_override("font_size",
			int(UITheme.Typography.BUTTON_SMALL * UITheme.get_font_scale()))
		button.set_meta("generator_index", index)
		button.set_meta("quantity", increment)
		button.pressed.connect(_on_generator_purchase.bind(index, increment))
		button_container.add_child(button)

	return card

func _format_generator_info(generator: Dictionary, owned_count: int) -> String:
	"""Formatea la información del generador"""
	var name = generator.get("name", "Generador")
	var description = generator.get("description", "")
	var base_cost = generator.get("base_cost", 10.0)
	var production_rate = generator.get("production_rate", 1.0)
	var production_per_sec = owned_count / production_rate if production_rate > 0 else 0

	return "%s (Nivel: %d)\n%s\nCosto base: $%.0f • Produce: %.1f/s" % [
		name, owned_count, description, base_cost, production_per_sec
	]


func update_resource_displays(game_data: Dictionary) -> void:
	"""Actualiza las visualizaciones de recursos"""
	if not is_initialized:
		return

	for resource_name in resource_labels.keys():
		if resource_name in game_data["resources"]:
			var amount = game_data["resources"][resource_name]
			var label = resource_labels[resource_name]
			if label:
				label.text = "%s: %s" % [
					resource_name.capitalize(),
					GameUtils.format_large_number(amount)
				]


func update_generator_displays(resource_generators: Array[Dictionary], game_data: Dictionary) -> void:
	"""Actualiza las interfaces de generadores"""
	if not is_initialized:
		return

	var generators_owned = game_data.get("generators", {})
	var money = game_data.get("money", 0.0)

	for i in range(min(generator_interfaces.size(), resource_generators.size())):
		var interface = generator_interfaces[i]
		var generator = resource_generators[i]
		var generator_id = generator.get("id", "")
		var owned_count = generators_owned.get(generator_id, 0)

		_update_generator_interface(interface, generator, owned_count, money)

func _update_generator_interface(interface: Control, generator: Dictionary, owned: int, money: float) -> void:
	"""Actualiza una interface específica de generador"""
	var vbox = interface.get_child(0) as VBoxContainer
	if not vbox or vbox.get_child_count() < 2:
		return

	# Actualizar información
	var info_label = vbox.get_child(0) as Label
	if info_label:
		info_label.text = _format_generator_info(generator, owned)

	# Actualizar botones
	var button_container = vbox.get_child(1) as HBoxContainer
	if button_container:
		_update_generator_buttons(button_container, generator, owned, money)

func _update_generator_buttons(button_container: HBoxContainer, generator: Dictionary, owned: int, money: float) -> void:
	"""Actualiza los botones de compra"""
	for button_node in button_container.get_children():
		var button = button_node as Button
		if not button:
			continue

		var quantity = button.get_meta("quantity", 1)
		var total_cost = _calculate_bulk_cost(generator, owned, quantity)
		var can_afford = money >= total_cost

		button.text = "×%d\n$%s" % [quantity, GameUtils.format_large_number(total_cost)]
		button.disabled = not can_afford
		button.modulate = Color.WHITE if can_afford else Color.GRAY

func _calculate_bulk_cost(generator: Dictionary, owned_count: int, quantity: int) -> float:
	"""Calcula el costo de comprar múltiples generadores"""
	var base_cost = generator.get("base_cost", 10.0)
	var multiplier = generator.get("cost_multiplier", 1.15)

	var total_cost = 0.0
	for i in range(quantity):
		var cost = base_cost * pow(multiplier, owned_count + i)
		total_cost += cost

	return total_cost

func _on_generator_purchase(generator_index: int, quantity: int) -> void:
	"""Maneja la compra de generador"""
	generator_purchased.emit(generator_index, quantity)

# Funciones de limpieza
func _clear_container(container: Container) -> void:
	"""Limpia un contenedor de forma segura"""
	if not container:
		return
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _clear_generator_interfaces() -> void:
	"""Limpia las interfaces de generadores"""
	for interface in generator_interfaces:
		if interface:
			interface.queue_free()
	generator_interfaces.clear()


	generator_interfaces.clear()


func update_with_game_data(game_data: Dictionary, generator_defs: Array[Dictionary]) -> void:
	"""Actualizar panel con datos del juego"""
	# TODO: Implementar actualización con datos del juego
	pass


func _clear_resource_labels() -> void:
	for label in resource_labels.values():
		if label != null:
			label.queue_free()
	resource_labels.clear()


func _clear_generator_buttons() -> void:
	for child in generators_container.get_children():
		if child != null:
			child.queue_free()
	generator_interfaces.clear()
