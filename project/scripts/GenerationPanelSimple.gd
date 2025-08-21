extends BasePanel
## GenerationPanelSimple - Versión simple y robusta del panel de generación
## Usa SimpleGridLayout en lugar de componentes experimentales

const SimpleGridLayout = preload("res://scripts/ui/SimpleGridLayout.gd")

# Señales para compatibilidad con GameController
signal generator_purchased(generator_id: String, quantity: int)

# Estado del panel
var generator_manager_ref: Node = null
var resource_grid: SimpleGridLayout
var generator_grid: SimpleGridLayout

# Contenedores de la escena
@onready var main_scroll: ScrollContainer = $ScrollContainer
@onready var main_vbox: VBoxContainer = $ScrollContainer/MainVBox


func _initialize_panel_specific() -> void:
	"""Inicialización específica del panel simple"""
	setup_simple_layout()
	print("✅ GenerationPanel (Simple) inicializado")


func _connect_panel_signals() -> void:
	"""Conectar señales específicas"""
	pass  # Las señales se conectan directamente en setup


func _update_panel_data(game_data: Dictionary) -> void:
	"""Actualizar datos del panel"""
	update_resource_displays(game_data)
	update_generator_displays(game_data)


func setup_simple_layout():
	"""Configurar layout simple con cuadrículas"""
	# Limpiar contenido existente
	for child in main_vbox.get_children():
		child.queue_free()

	# === SECCIÓN DE RECURSOS ===
	var resources_title = Label.new()
	resources_title.text = "📦 Recursos Disponibles"
	resources_title.add_theme_font_size_override("font_size", 20)
	resources_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(resources_title)

	# Cuadrícula de recursos
	resource_grid = SimpleGridLayout.new()
	resource_grid.custom_minimum_size = Vector2(0, 200)
	resource_grid.setup_mobile()  # Usar configuración mobile por defecto
	main_vbox.add_child(resource_grid)

	# Llenar cuadrícula de recursos
	setup_resources_grid()

	# Separador
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(separator)

	# === SECCIÓN DE GENERADORES ===
	var generators_title = Label.new()
	generators_title.text = "🚜 Generadores"
	generators_title.add_theme_font_size_override("font_size", 20)
	generators_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(generators_title)

	# Cuadrícula de generadores
	generator_grid = SimpleGridLayout.new()
	generator_grid.custom_minimum_size = Vector2(0, 300)
	generator_grid.setup_mobile()  # Usar configuración mobile por defecto
	main_vbox.add_child(generator_grid)

	# Llenar cuadrícula de generadores
	setup_generators_grid()


func setup_resources_grid():
	"""Configurar cuadrícula de recursos usando datos reales"""
	for resource_id in GameConfig.RESOURCE_DATA.keys():
		var data = GameConfig.RESOURCE_DATA[resource_id]
		var content = "Cantidad: 0"  # Se actualizará con datos reales

		var panel = resource_grid.add_info_panel(data.name, content, data.emoji)
		panel.name = "resource_" + resource_id

		print("📦 Recurso agregado: %s %s" % [data.emoji, data.name])


func setup_generators_grid():
	"""Configurar cuadrícula de generadores usando datos reales"""
	for generator_id in GameConfig.GENERATOR_DATA.keys():
		var data = GameConfig.GENERATOR_DATA[generator_id]
		var button_text = "%s\n$%.0f" % [data.name, data.base_price]

		var button = generator_grid.add_simple_button(button_text, data.emoji)
		button.name = "generator_" + generator_id

		# Conectar señal de compra
		button.pressed.connect(_on_generator_buy_pressed.bind(generator_id))

		print("🚜 Generador agregado: %s %s" % [data.emoji, data.name])


func update_resource_displays(game_data: Dictionary):
	"""Actualizar displays de recursos con datos reales"""
	if not resource_grid:
		return

	var resources = game_data.get("resources", {})

	for resource_id in GameConfig.RESOURCE_DATA.keys():
		var panel_node = resource_grid.grid_container.get_node_or_null("resource_" + resource_id)
		if panel_node:
			var vbox = panel_node.get_child(0)  # VBoxContainer interno
			var content_label = vbox.get_child(1)  # Segundo label (contenido)
			var amount = resources.get(resource_id, 0)
			var max_storage = GameConfig.RESOURCE_DATA[resource_id].max_storage
			content_label.text = "Cantidad: %.0f/%.0f" % [amount, max_storage]


func update_generator_displays(game_data: Dictionary):
	"""Actualizar displays de generadores con datos reales"""
	if not generator_grid:
		return

	var generators = game_data.get("generators", {})
	var money = game_data.get("money", 0)

	for generator_id in GameConfig.GENERATOR_DATA.keys():
		var button_node = generator_grid.grid_container.get_node_or_null(
			"generator_" + generator_id
		)
		if button_node:
			var data = GameConfig.GENERATOR_DATA[generator_id]
			var owned = generators.get(generator_id, 0)
			var current_cost = calculate_generator_cost(generator_id, owned)
			var can_afford = money >= current_cost

			# Actualizar texto del botón
			button_node.text = (
				"%s %s\nPoseído: %.0f\nCosto: $%.0f" % [data.emoji, data.name, owned, current_cost]
			)

			# Actualizar estado del botón
			button_node.disabled = not can_afford
			button_node.modulate = Color.WHITE if can_afford else Color.GRAY


func calculate_generator_cost(generator_id: String, current_owned: float) -> float:
	"""Calcular costo actual del generador"""
	var base_price = GameConfig.GENERATOR_DATA[generator_id].base_price
	var scale_factor = GameConfig.GENERATOR_SCALE_FACTOR
	return base_price * pow(scale_factor, current_owned)


func _on_generator_buy_pressed(generator_id: String):
	"""Manejar compra de generador"""
	if generator_manager_ref and generator_manager_ref.has_method("purchase_generator"):
		var success = generator_manager_ref.purchase_generator(generator_id, 1)
		if success:
			print("✅ Generador comprado: %s" % generator_id)
			# Emitir señal para compatibilidad con GameController
			generator_purchased.emit(generator_id, 1)
		else:
			print("❌ No se pudo comprar generador: %s" % generator_id)
	else:
		# Fallback: emitir señal directamente si no hay manager
		print("📤 Emitiendo señal de compra de generador: %s" % generator_id)
		generator_purchased.emit(generator_id, 1)


func set_generator_manager(manager: Node):
	"""Establecer referencia al GeneratorManager"""
	generator_manager_ref = manager
	print("🔗 GenerationPanel (Simple) conectado con GeneratorManager")
