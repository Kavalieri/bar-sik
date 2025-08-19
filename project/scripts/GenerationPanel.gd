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
var current_game_data: Dictionary = {}  # Cache local de datos del juego
var generator_manager_ref: Node = null  # Referencia al GeneratorManager

# Señales
signal generator_purchased(generator_index: int, quantity: int)

## Establecer referencia al GeneratorManager para cálculos precisos
func set_generator_manager(manager: Node) -> void:
	generator_manager_ref = manager
	print("🔗 GenerationPanel conectado con GeneratorManager")

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
	"""Configura recursos y actualiza datos locales"""
	current_game_data = game_data.duplicate()  # Cache local
	if not is_initialized:
		call_deferred("setup_resources", game_data)
		return

	_clear_container(resources_container)

	# CRÍTICO: Limpiar referencias de labels antiguos
	resource_labels.clear()
	print("🧹 GenerationPanel: resource_labels limpiado")

	# Crear header de recursos
	var header = UIComponentsFactory.create_section_header(
		"📦 RECURSOS DISPONIBLES",
		"Materia prima para la producción"
	)
	resources_container.add_child(header)

	# Crear displays de recursos
	var resources = game_data.get("resources", {})
	for resource_name in resources.keys():
		var label = Label.new()
		label.text = "%s: %s" % [
			resource_name.capitalize(),
			GameUtils.format_large_number(resources[resource_name])
		]
		label.add_theme_font_size_override("font_size", 14)
		resources_container.add_child(label)
		resource_labels[resource_name] = label

	print("✅ GenerationPanel: %d resource labels creados" % resource_labels.size())

func setup_generators(resource_generators: Array[Dictionary]) -> void:
	"""Configura los generadores disponibles"""
	if not is_initialized:
		call_deferred("setup_generators", resource_generators)
		return

	generator_definitions = resource_generators
	_clear_generator_interfaces()

	# Crear interface para cada generador CON ESTADO INICIAL CORRECTO
	for i in range(resource_generators.size()):
		var generator = resource_generators[i]
		var interface = _create_generator_interface(generator, i, current_game_data)
		generators_container.add_child(interface)
		generator_interfaces.append(interface)

func _create_generator_interface(generator: Dictionary, index: int, initial_game_data: Dictionary = {}) -> Control:
	"""Crea la interface de un generador CON ESTADO INICIAL CORRECTO"""
	var card = UIComponentsFactory.create_content_panel(120)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", UITheme.Spacing.SMALL)
	card.add_child(vbox)

	# Obtener estado inicial
	var generators_owned = initial_game_data.get("generators", {})
	var money = initial_game_data.get("money", 0.0)
	var generator_id = generator.get("id", "")
	var owned_count = generators_owned.get(generator_id, 0)

	# Información del generador CON ESTADO INICIAL
	var info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	info_label.add_theme_font_size_override("font_size", 13)
	info_label.text = _format_generator_info(generator, owned_count)
	vbox.add_child(info_label)

	# Contenedor de botones - NUEVO SISTEMA IDLE
	var button_container = HBoxContainer.new()
	button_container.set_custom_minimum_size(Vector2(0, 80))
	button_container.add_theme_constant_override("separation", 8)
	vbox.add_child(button_container)

	# Crear botón idle estándar
	var idle_button = preload("res://scripts/ui/IdleBuyButton.gd").new()

	# Configurar calculadora de costo
	var cost_calculator = func(gen_id: String, quantity: int) -> float:
		if generator_manager_ref and generator_manager_ref.has_method("get_generator_cost"):
			return generator_manager_ref.get_generator_cost(gen_id, quantity)
		return _calculate_bulk_cost(generator, owned_count, quantity)

	idle_button.setup(generator.id, generator.name, generator.base_cost, cost_calculator)
	idle_button.purchase_requested.connect(_on_idle_button_purchase_wrapper.bind(index))

	# Establecer affordability inicial
	var initial_cost = cost_calculator.call(generator.id, 1)
	idle_button.set_affordability(money >= initial_cost)

	button_container.add_child(idle_button)

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
	"""Calcula el costo de comprar múltiples generadores usando GeneratorManager si está disponible"""

	# Usar GeneratorManager si está disponible para consistencia
	if generator_manager_ref and generator_manager_ref.has_method("get_generator_cost"):
		# Temporalmente ajustar el owned para el cálculo
		var generator_id = generator.get("id", "")
		if generator_id != "":
			return generator_manager_ref.get_generator_cost(generator_id, quantity)

	# Fallback al cálculo manual (para compatibilidad)
	var base_cost = generator.get("base_cost", 10.0)
	var multiplier = generator.get("cost_multiplier", 1.15)

	var total_cost = 0.0
	for i in range(quantity):
		var cost = base_cost * pow(multiplier, owned_count + i)
		total_cost += cost

	return total_cost

func _on_generator_purchase(generator_index: int, quantity: int) -> void:
	"""Maneja la compra de generador (sistema anterior)"""
	generator_purchased.emit(generator_index, quantity)

func _on_idle_button_purchase_wrapper(item_id: String, quantity: int, generator_index: int) -> void:
	"""Wrapper para manejar la conexión de señal correctamente"""
	print("🛒 Compra solicitada: generador %d (%s) x%d" % [generator_index, item_id, quantity])
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
	"""Actualiza el panel con nuevos datos del juego"""
	current_game_data = game_data.duplicate()

	# Actualizar solo las partes que han cambiado para eficiencia
	update_resource_displays(game_data)
	update_generator_displays(generator_defs, game_data)

func update_button_affordability(money: float) -> void:
	"""Actualiza solo la capacidad de compra de botones (optimizado)"""
	if not is_initialized or generator_interfaces.is_empty():
		return

	var generators_owned = current_game_data.get("generators", {})

	for i in range(min(generator_interfaces.size(), generator_definitions.size())):
		var interface = generator_interfaces[i]
		var generator = generator_definitions[i]
		var generator_id = generator.get("id", "")
		var owned_count = generators_owned.get(generator_id, 0)

		_update_buttons_affordability_only(interface, generator, owned_count, money)

func _update_buttons_affordability_only(interface: Control, generator: Dictionary, owned: int, money: float) -> void:
	"""Actualiza solo el estado de affordability de los botones"""
	var vbox = interface.get_child(0) as VBoxContainer
	if not vbox or vbox.get_child_count() < 2:
		return

	var button_container = vbox.get_child(1) as HBoxContainer
	if not button_container:
		return

	# Buscar IdleBuyButton en el contenedor
	for child in button_container.get_children():
		if child.get_script() and child.get_script().get_global_name() == "IdleBuyButton":
			var idle_button = child
			idle_button.update_cost_display()  # Actualizar precio
			var current_cost = idle_button.get_current_cost()
			idle_button.set_affordability(money >= current_cost)
		else:
			# Compatibilidad con botones antiguos
			var button = child as Button
			if button and button.has_meta("quantity"):
				var quantity = button.get_meta("quantity", 1)
				var total_cost = _calculate_bulk_cost(generator, owned, quantity)
				var can_afford = money >= total_cost
				button.disabled = not can_afford
				button.modulate = Color.WHITE if can_afford else Color.GRAY


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
