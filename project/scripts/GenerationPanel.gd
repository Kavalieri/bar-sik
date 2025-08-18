extends ScrollContainer
## GenerationPanel - Panel de generación de recursos
## Maneja los recursos disponibles y los generadores para comprar

@onready var resource_container: VBoxContainer = $MainContainer/ResourcesSection/ResourceContainer
@onready var generator_container: VBoxContainer = $MainContainer/GeneratorsSection/GeneratorContainer

# Variables de UI
var resource_labels: Dictionary = {}
var generator_buttons: Array[Button] = []

# Señales para comunicación con GameScene
signal generator_purchased(generator_index: int)


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

	# Crear botones para generadores
	for i in range(resource_generators.size()):
		var button = Button.new()
		button.pressed.connect(_on_generator_purchased.bind(i))
		generator_container.add_child(button)
		generator_buttons.append(button)


func update_resource_displays(game_data: Dictionary) -> void:
	for resource_name in resource_labels.keys():
		var label = resource_labels[resource_name]
		var amount = game_data["resources"].get(resource_name, 0)
		var icon = _get_resource_icon(resource_name)
		label.text = "%s %s: %d" % [icon, resource_name.capitalize(), amount]


func update_generator_buttons(
	resource_generators: Array[Dictionary], game_data: Dictionary
) -> void:
	for i in range(generator_buttons.size()):
		if i < resource_generators.size():
			var generator = resource_generators[i]
			var button = generator_buttons[i]
			var cost = _calculate_generator_cost(generator, game_data)
			var owned = game_data["generators"].get(generator.id, 0)
			var can_afford = game_data["money"] >= cost

			button.text = (
				"%s\nCosto: $%.0f\nPropiedad: %d\n%s"
				% [generator.name, cost, owned, generator.description]
			)
			button.disabled = not can_afford


func _calculate_generator_cost(generator: Dictionary, game_data: Dictionary) -> float:
	var owned = game_data["generators"].get(generator.id, 0)
	return generator.base_cost * pow(1.15, owned)


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


func _on_generator_purchased(generator_index: int) -> void:
	generator_purchased.emit(generator_index)
