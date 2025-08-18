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
			button.text = str(increment)
			button.pressed.connect(_on_generator_purchased.bind(i, increment))
			button_container.add_child(button)
		
		# Agregar separador
		var separator = HSeparator.new()
		generator_container_h.add_child(separator)


func update_resource_displays(game_data: Dictionary) -> void:
	for resource_name in resource_labels.keys():
		var label = resource_labels[resource_name]
		var amount = game_data["resources"].get(resource_name, 0)
		var icon = _get_resource_icon(resource_name)
		label.text = "%s %s: %d" % [icon, resource_name.capitalize(), amount]


func update_generator_displays(
	resource_generators: Array[Dictionary], game_data: Dictionary
) -> void:
	# Actualizar cada interfaz de generador
	var generator_interfaces = generator_container.get_children()
	
	for i in range(min(generator_interfaces.size(), resource_generators.size())):
		var generator = resource_generators[i]
		var interface_container = generator_interfaces[i]
		
		# Actualizar info label (primer hijo)
		var info_label = interface_container.get_child(0) as Label
		var owned = game_data["generators"].get(generator.id, 0)
		var base_cost = generator.base_cost
		
		info_label.text = "%s (Propiedad: %d)\n%s\nCosto base: $%.0f" % [
			generator.name, owned, generator.description, base_cost
		]
		
		# Actualizar botones de compra (segundo hijo es el HBoxContainer)
		var button_container = interface_container.get_child(1) as HBoxContainer
		var buttons = button_container.get_children()
		
		for j in range(buttons.size()):
			var button = buttons[j] as Button
			var increment = int(button.text)
			var total_cost = _calculate_bulk_cost(generator, game_data, increment)
			var can_afford = game_data["money"] >= total_cost
			
			button.text = "%d\n$%.0f" % [increment, total_cost]
			button.disabled = not can_afford


func _calculate_bulk_cost(generator: Dictionary, game_data: Dictionary, quantity: int) -> float:
	var owned = game_data["generators"].get(generator.id, 0)
	var total_cost = 0.0
	
	# Calcular costo acumulativo para compras múltiples
	for i in range(quantity):
		var cost = generator.base_cost * pow(1.15, owned + i)
		total_cost += cost
	
	return total_cost


func _get_resource_icon(resource_name: String) -> String:
	match resource_name:
		"barley":
			return "🌾"
		"hops":
			return "🌿"
		"water":
			return "💧"
		"yeast":
			return "🦠"
		_:
			return "📦"


func _clear_resource_labels() -> void:
	for child in resource_container.get_children():
		child.queue_free()
	resource_labels.clear()


func _clear_generator_buttons() -> void:
	for child in generator_container.get_children():
		child.queue_free()
	generator_buttons.clear()


func _on_generator_purchased(generator_index: int, quantity: int) -> void:
	generator_purchased.emit(generator_index, quantity)
