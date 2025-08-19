extends ScrollContainer
## GenerationPanel - Panel de generación de recursos
## Maneja los recursos disponibles y los generadores para comprar

@onready var resource_container: VBoxContainer = $MainContainer/ResourcesSection/ResourceContainer
@onready var generator_container: VBoxContainer = $MainContainer/GeneratorsSection/GeneratorContainer

# Variables de UI
var resource_labels: Dictionary = {}
var generator_buttons: Array[Button] = []

# Señales para comunicación con GameScene
signal generator_purchased(generator_index: int, quantity: int)


func _ready() -> void:
	print("📦 GenerationPanel inicializado")

	# Crear headers de sección
	_setup_section_headers()

func _setup_section_headers() -> void:
	"""Crea headers para todas las secciones principales"""
	# Header para recursos
	var resources_header = UIStyleManager.create_section_header("📦 INGREDIENTES DISPONIBLES")
	resource_container.add_child(resources_header)
	resource_container.move_child(resources_header, 0)

	# Header para generadores
	var generators_header = UIStyleManager.create_section_header("🌾 GENERADORES (Comprar para producir ingredientes)")
	generator_container.add_child(generators_header)
	generator_container.move_child(generators_header, 0)


func setup_resources(game_data: Dictionary) -> void:
	# Limpiar contenido existente
	_clear_resource_labels()

	# Crear labels para recursos
	for resource_name in game_data["resources"].keys():
		var label = Label.new()
		resource_labels[resource_name] = label
		resource_container.add_child(label)


func setup_generators(resource_generators: Array[Dictionary]) -> void:
	# Limpiar botones existentes
	_clear_generator_buttons()

	# Crear interfaces de compra para generadores
	for i in range(resource_generators.size()):
		var generator = resource_generators[i]
		var generator_container_h = VBoxContainer.new()
		generator_container.add_child(generator_container_h)

		# Label con información del generador
		var info_label = Label.new()
		info_label.text = "%s\n%s" % [generator.name, generator.description]
		generator_container_h.add_child(info_label)

		# Contenedor horizontal para botones de compra
		var button_container = HBoxContainer.new()
		generator_container_h.add_child(button_container)

		# Botones de compra por incrementos
		var increments = [1, 5, 10, 25]
		for increment in increments:
			var button = Button.new()
			button.text = "Comprar %d\n$0" % increment
			button.pressed.connect(_on_generator_purchase.bind(i, increment))
			button_container.add_child(button)
			generator_buttons.append(button)


func update_resource_displays(game_data: Dictionary) -> void:
	for resource_name in resource_labels.keys():
		if resource_name in game_data["resources"]:
			var amount = game_data["resources"][resource_name]
			var label = resource_labels[resource_name]
			if label != null:
				label.text = "%s: %.1f" % [resource_name.capitalize(), amount]


func update_generator_displays(
	resource_generators: Array[Dictionary], game_data: Dictionary
) -> void:
	# Actualizar cada interfaz de generador
	var generator_interfaces = generator_container.get_children()

	for i in range(min(generator_interfaces.size(), resource_generators.size())):
		var generator = resource_generators[i]
		var interface_container = generator_interfaces[i]

		# Verificar que el contenedor existe y tiene hijos
		if interface_container == null:
			print("⚠️ Interface container %d is null" % i)
			continue

		if interface_container.get_child_count() < 2:
			print("⚠️ Interface container %d has insufficient children (%d)" % [i, interface_container.get_child_count()])
			continue

		# Actualizar info label (primer hijo)
		var info_label = interface_container.get_child(0) as Label
		if info_label == null:
			print("⚠️ Info label for generator %d is null" % i)
			continue

		var owned = game_data["generators"].get(generator.id, 0)
		var base_cost = generator.base_cost
		var production_rate = generator.production_rate
		var total_production_per_sec = owned * (1.0 / production_rate)

		info_label.text = "%s (Nivel: %d)\n%s\nCosto base: $%.0f\nProducción total: %.1f/s" % [
			generator.name, owned, generator.description, base_cost, total_production_per_sec
		]

		# Actualizar botones de compra (segundo hijo es el HBoxContainer)
		var button_container = interface_container.get_child(1) as HBoxContainer
		if button_container == null:
			print("⚠️ Button container for generator %d is null" % i)
			continue

		var buttons = button_container.get_children()

		for j in range(buttons.size()):
			var button = buttons[j] as Button
			if button == null:
				continue

			# Usar metadata en lugar de parsear el texto formateado
			var increment = button.get_meta("increment", 1)  # default 1 si no existe
			var total_cost = _calculate_bulk_cost(generator, game_data, increment)
			var can_afford = game_data["money"] >= total_cost

			button.text = "%d\n$%s" % [increment, GameUtils.format_large_number(total_cost)]
			button.disabled = not can_afford


func _on_generator_purchase(generator_index: int, quantity: int) -> void:
	generator_purchased.emit(generator_index, quantity)


func _calculate_bulk_cost(generator: Dictionary, game_data: Dictionary, quantity: int) -> float:
	var base_cost = generator.base_cost
	var cost_multiplier = generator.cost_multiplier
	var owned = game_data["generators"].get(generator.id, 0)

	var total_cost = 0.0
	for i in range(quantity):
		var level_cost = base_cost * pow(cost_multiplier, owned + i)
		total_cost += level_cost

	return total_cost


func _clear_resource_labels() -> void:
	for label in resource_labels.values():
		if label != null:
			label.queue_free()
	resource_labels.clear()


func _clear_generator_buttons() -> void:
	for child in generator_container.get_children():
		if child != null:
			child.queue_free()
	generator_buttons.clear()
