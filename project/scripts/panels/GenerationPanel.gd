extends "res://scripts/ui/BasePanel.gd"
class_name GenerationPanel
## GenerationPanel - Panel de generación de recursos con arquitectura limpia

# Referencias específicas del panel
@onready var resources_container: VBoxContainer
@onready var generators_container: VBoxContainer

# Datos del panel
var resource_data: Dictionary = {}
var generator_definitions: Array[Dictionary] = []
var generator_interfaces: Array[Control] = []

# Señales
signal generator_purchased(generator_index: int, quantity: int)

func _ready() -> void:
	# Configurar referencias específicas antes de la inicialización base
	main_container = $MainContainer
	resources_container = $MainContainer/ResourcesSection/ResourceContainer
	generators_container = $MainContainer/GeneratorsSection/GeneratorContainer

	# Llamar a la inicialización base
	super._ready()

func _create_sections() -> void:
	"""Crea las secciones del panel de generación"""
	_create_resources_section()
	_create_generators_section()

func _create_resources_section() -> void:
	"""Crea la sección de recursos disponibles"""
	clear_container(resources_container)

	var header = create_section_header("📦 INGREDIENTES DISPONIBLES")
	resources_container.add_child(header)

func _create_generators_section() -> void:
	"""Crea la sección de generadores"""
	clear_container(generators_container)

	var header = create_section_header(
		"🌾 GENERADORES",
		"Compra generadores para producir ingredientes automáticamente"
	)
	generators_container.add_child(header)

func _setup_data_internal(data: Dictionary) -> void:
	"""Configura los datos iniciales del panel"""
	if data.has("resources"):
		resource_data = data["resources"]
		_setup_resource_displays()

	if data.has("generators"):
		generator_definitions = data["generators"]
		_setup_generator_interfaces()

func _update_displays_internal(data: Dictionary) -> void:
	"""Actualiza todas las visualizaciones del panel"""
	if data.has("resources"):
		resource_data = data["resources"]
		_update_resource_displays()

	if data.has("game_data"):
		_update_generator_displays(data["game_data"])

func _setup_resource_displays() -> void:
	"""Configura las visualizaciones de recursos"""
	# Encontrar el primer contenedor después del header
	var display_container = _get_display_container(resources_container)
	if not display_container:
		display_container = VBoxContainer.new()
		resources_container.add_child(display_container)

	clear_container(display_container)

	# Crear labels para cada recurso
	for resource_name in resource_data.keys():
		var resource_card = create_styled_card()
		resource_card.set_custom_minimum_size(Vector2(0, 60))

		var label = Label.new()
		label.text = "%s: %s" % [resource_name.capitalize(), "0.0"]
		label.add_theme_font_size_override("font_size", 16)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		resource_card.add_child(label)
		display_container.add_child(resource_card)

func _setup_generator_interfaces() -> void:
	"""Configura las interfaces de generadores"""
	var display_container = _get_display_container(generators_container)
	if not display_container:
		display_container = VBoxContainer.new()
		generators_container.add_child(display_container)

	clear_container(display_container)
	generator_interfaces.clear()

	# Crear interface para cada generador
	for i in range(generator_definitions.size()):
		var generator = generator_definitions[i]
		var interface = _create_generator_interface(generator, i)
		display_container.add_child(interface)
		generator_interfaces.append(interface)

func _create_generator_interface(generator: Dictionary, index: int) -> Control:
	"""Crea la interface para un generador específico"""
	var card = create_styled_card()
	card.set_custom_minimum_size(Vector2(0, 140))

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)

	# Información del generador
	var info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	info_label.add_theme_font_size_override("font_size", 14)
	info_label.text = _format_generator_info(generator, 0)
	vbox.add_child(info_label)

	# Separador
	add_separator_to_container(vbox, 4)

	# Contenedor de botones
	var button_container = HBoxContainer.new()
	button_container.set_custom_minimum_size(Vector2(0, 40))
	button_container.add_theme_constant_override("separation", 4)
	vbox.add_child(button_container)

	# Crear botones de compra
	var increments = [1, 5, 10, 25]
	for increment in increments:
		var button = UIStyleManager.create_styled_button("")
		button.set_custom_minimum_size(Vector2(70, 35))
		button.add_theme_font_size_override("font_size", 12)
		button.text = "×%d\n$0" % increment
		button.set_meta("generator_index", index)
		button.set_meta("quantity", increment)
		button.pressed.connect(_on_generator_purchase_requested.bind(index, increment))
		button_container.add_child(button)

	return card

func _format_generator_info(generator: Dictionary, owned_count: int) -> String:
	"""Formatea la información de un generador"""
	var name = generator.get("name", "Generador")
	var description = generator.get("description", "")
	var base_cost = generator.get("base_cost", 10.0)
	var production_rate = generator.get("production_rate", 1.0)
	var production_per_second = owned_count / production_rate if production_rate > 0 else 0

	return "%s (Nivel: %d)\n%s\nCosto base: $%.0f | Producción: %.1f/s" % [
		name, owned_count, description, base_cost, production_per_second
	]

func _update_resource_displays() -> void:
	"""Actualiza las visualizaciones de recursos"""
	var display_container = _get_display_container(resources_container)
	if not display_container:
		return

	var cards = display_container.get_children()
	var resource_names = resource_data.keys()

	for i in range(min(cards.size(), resource_names.size())):
		var card = cards[i]
		var resource_name = resource_names[i]
		var amount = resource_data.get(resource_name, 0.0)

		var label = card.get_child(0) as Label
		if label:
			label.text = "%s: %s" % [
				resource_name.capitalize(),
				GameUtils.format_large_number(amount)
			]

func _update_generator_displays(game_data: Dictionary) -> void:
	"""Actualiza las interfaces de generadores"""
	var generators_owned = game_data.get("generators", {})
	var money = game_data.get("money", 0.0)

	for i in range(min(generator_interfaces.size(), generator_definitions.size())):
		var interface = generator_interfaces[i]
		var generator = generator_definitions[i]
		var generator_id = generator.get("id", "")
		var owned_count = generators_owned.get(generator_id, 0)

		# Actualizar información del generador
		var vbox = interface.get_child(0) as VBoxContainer
		if vbox and vbox.get_child_count() >= 3:
			var info_label = vbox.get_child(0) as Label
			if info_label:
				info_label.text = _format_generator_info(generator, owned_count)

			# Actualizar botones
			var button_container = vbox.get_child(2) as HBoxContainer
			if button_container:
				_update_generator_buttons(button_container, generator, owned_count, money)

func _update_generator_buttons(button_container: HBoxContainer, generator: Dictionary, owned_count: int, money: float) -> void:
	"""Actualiza los botones de compra de un generador"""
	var buttons = button_container.get_children()

	for button_node in buttons:
		var button = button_node as Button
		if not button:
			continue

		var quantity = button.get_meta("quantity", 1)
		var total_cost = _calculate_bulk_cost(generator, owned_count, quantity)
		var can_afford = money >= total_cost

		button.text = "×%d\n$%s" % [quantity, GameUtils.format_large_number(total_cost)]
		button.disabled = not can_afford

		# Cambiar color según disponibilidad
		if can_afford:
			button.modulate = Color.WHITE
		else:
			button.modulate = Color.GRAY

func _calculate_bulk_cost(generator: Dictionary, owned_count: int, quantity: int) -> float:
	"""Calcula el costo total de comprar múltiples generadores"""
	var base_cost = generator.get("base_cost", 10.0)
	var multiplier = generator.get("cost_multiplier", 1.15)

	var total_cost = 0.0
	for i in range(quantity):
		var cost = base_cost * pow(multiplier, owned_count + i)
		total_cost += cost

	return total_cost

func _get_display_container(parent: Container) -> Container:
	"""Obtiene el contenedor de display (después del header)"""
	if parent.get_child_count() >= 2:
		return parent.get_child(1) as Container
	return null

func _on_generator_purchase_requested(generator_index: int, quantity: int) -> void:
	"""Maneja la solicitud de compra de generador"""
	generator_purchased.emit(generator_index, quantity)

# Métodos públicos específicos del panel
func setup_generators(definitions: Array[Dictionary]) -> void:
	"""Configura las definiciones de generadores"""
	generator_definitions = definitions
	if is_initialized:
		_setup_generator_interfaces()

func update_with_game_data(game_data: Dictionary, generator_defs: Array[Dictionary]) -> void:
	"""Actualiza el panel con datos del juego"""
	if generator_defs.size() > 0:
		generator_definitions = generator_defs

	var panel_data = {
		"resources": game_data.get("resources", {}),
		"game_data": game_data
	}
	update_displays(panel_data)
