extends VBoxContainer
class_name IdleBuyButton
## IdleBuyButton - Botón de compra estándar para juegos idle
## Un botón principal + botón de multiplicador que rota

signal purchase_requested(item_id: String, quantity: int)

var item_id: String = ""
var item_display_name: String = ""
var base_cost: float = 0.0
var current_multiplier: int = 1
var multipliers: Array[int] = [1, 5, 10, 25]
var multiplier_index: int = 0

# Referencias UI
var main_button: Button
var multiplier_button: Button
var cost_calculator_func: Callable


func setup(id: String, display_name: String, cost: float, calculator: Callable) -> void:
	"""Configurar el botón con datos del item"""
	item_id = id
	item_display_name = display_name
	base_cost = cost
	cost_calculator_func = calculator
	current_multiplier = multipliers[0]

	_create_ui()
	_update_display()


func _create_ui() -> void:
	"""Crear la interfaz del botón"""
	# Limpiar contenido previo
	for child in get_children():
		child.queue_free()

	# Usar VBoxContainer para layout vertical
	set_v_size_flags(Control.SIZE_EXPAND_FILL)
	set_h_size_flags(Control.SIZE_EXPAND_FILL)

	# Botón de multiplicador en la parte superior (más fácil de acceder)
	multiplier_button = Button.new()
	multiplier_button.text = ""
	multiplier_button.set_custom_minimum_size(Vector2(280, 55))  # Tamaño móvil
	multiplier_button.add_theme_font_size_override("font_size", 18)  # Fuente móvil
	multiplier_button.add_theme_color_override("font_color", Color.WHITE)
	multiplier_button.add_theme_color_override("font_color_hover", Color.YELLOW)
	multiplier_button.pressed.connect(_on_multiplier_button_pressed)
	add_child(multiplier_button)

	# Botón principal más grande para móvil
	main_button = Button.new()
	main_button.text = ""
	main_button.set_custom_minimum_size(Vector2(280, 85))  # Tamaño móvil
	main_button.add_theme_font_size_override("font_size", 20)  # Fuente móvil
	main_button.pressed.connect(_on_main_button_pressed)
	add_child(main_button)


func _update_display() -> void:
	"""Actualizar el display del botón"""
	if not main_button or not multiplier_button:
		return

	# Calcular costo total para la cantidad actual
	var total_cost = 0.0
	if cost_calculator_func.is_valid():
		total_cost = cost_calculator_func.call(item_id, current_multiplier)
	else:
		total_cost = base_cost * current_multiplier

	# Botón principal: iconos + precio con formato claro
	var icon = _get_item_icon(item_id)
	main_button.text = (
		"%s %s\n💰 $%s" % [icon, item_display_name, GameUtils.format_large_number(total_cost)]
	)

	# Botón multiplicador: cantidad con icono claro
	multiplier_button.text = "� x%d" % current_multiplier


func set_affordability(can_afford: bool) -> void:
	"""Establecer si se puede permitir la compra"""
	if main_button:
		main_button.disabled = not can_afford
		main_button.modulate = Color.WHITE if can_afford else Color.GRAY


func _on_main_button_pressed() -> void:
	"""Manejar clic en botón principal"""
	print("🔘 IdleBuyButton presionado: %s x%d" % [item_id, current_multiplier])
	purchase_requested.emit(item_id, current_multiplier)


func _on_multiplier_button_pressed() -> void:
	"""Rotar multiplicador"""
	multiplier_index = (multiplier_index + 1) % multipliers.size()
	current_multiplier = multipliers[multiplier_index]
	_update_display()


func update_cost_display() -> void:
	"""Actualizar solo el costo sin cambiar el multiplicador"""
	_update_display()


func get_current_cost() -> float:
	"""Obtener el costo actual"""
	if cost_calculator_func.is_valid():
		return cost_calculator_func.call(item_id, current_multiplier)
	return base_cost * current_multiplier


func _get_item_icon(item_id: String) -> String:
	"""Obtener icono apropiado para cada item"""
	match item_id:
		"barley_farm":
			return "🌾"
		"hops_farm":
			return "🌿"
		"water_collector":
			return "💧"
		"brewery":
			return "🍺"
		"bar_station":
			return "🍹"
		_:
			return "🏭"
