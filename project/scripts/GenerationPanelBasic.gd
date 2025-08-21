extends Control
## GenerationPanelBasic - Panel simple sin herencias complejas

# Señales
signal generator_purchased(generator_id: String, quantity: int)
signal multiplier_changed(generator_id: String, new_multiplier: int)

# Estado del panel
var generator_manager_ref: Node = null
var button_states: Dictionary = {}  # Estados centralizados de botones
var update_in_progress: bool = false  # Prevenir updates recursivos

# Referencias
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var main_vbox: VBoxContainer = $ScrollContainer/MainVBox


func _ready():
	print("🎯 GenerationPanelBasic _ready() iniciado")
	setup_basic_layout()
	print("✅ GenerationPanelBasic inicializado")


func setup_basic_layout():
	"""Configurar layout básico con elementos nativos de Godot"""
	# Limpiar contenido existente
	for child in main_vbox.get_children():
		child.queue_free()

	# === TÍTULO PRINCIPAL ===
	var main_title = Label.new()
	main_title.text = "🏭 PANEL DE GENERACIÓN"
	main_title.add_theme_font_size_override("font_size", 36)  # 24→36 mucho más grande
	main_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_title.add_theme_color_override("font_color", Color.GOLD)
	main_vbox.add_child(main_title)

	# Separador
	var separator1 = HSeparator.new()
	separator1.custom_minimum_size = Vector2(0, 30)  # 20→30 más espacio
	main_vbox.add_child(separator1)

	# === SECCIÓN DE RECURSOS ===
	setup_resources_section()

	# Separador
	var separator2 = HSeparator.new()
	separator2.custom_minimum_size = Vector2(0, 30)
	main_vbox.add_child(separator2)

	# === SECCIÓN DE GENERADORES ===
	setup_generators_section()


func setup_resources_section():
	"""Crear sección de recursos con GridContainer"""
	var resources_title = Label.new()
	resources_title.text = "📦 RECURSOS DISPONIBLES"
	resources_title.add_theme_font_size_override("font_size", 24)  # 18→24 más grande
	resources_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(resources_title)

	# Crear grid para recursos (2 columnas)
	var resources_grid = GridContainer.new()
	resources_grid.columns = 2
	resources_grid.add_theme_constant_override("h_separation", 16)
	resources_grid.add_theme_constant_override("v_separation", 8)
	main_vbox.add_child(resources_grid)

	# Agregar cada recurso
	for resource_id in GameConfig.RESOURCE_DATA.keys():
		var data = GameConfig.RESOURCE_DATA[resource_id]
		var resource_panel = create_resource_panel(resource_id, data)
		resources_grid.add_child(resource_panel)


func setup_generators_section():
	"""Crear sección de generadores con VBoxContainer para mobile"""
	var generators_title = Label.new()
	generators_title.text = "🚜 GENERADORES DISPONIBLES"
	generators_title.add_theme_font_size_override("font_size", 24)  # 18→24 más grande
	generators_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_vbox.add_child(generators_title)

	# Crear VBox para generadores (layout vertical para mobile)
	var generators_vbox = VBoxContainer.new()
	generators_vbox.add_theme_constant_override("separation", 12)
	main_vbox.add_child(generators_vbox)

	# Agregar cada generador
	for generator_id in GameConfig.GENERATOR_DATA.keys():
		var data = GameConfig.GENERATOR_DATA[generator_id]
		var generator_button = create_generator_button(generator_id, data)
		generators_vbox.add_child(generator_button)


func create_resource_panel(resource_id: String, data: Dictionary) -> Panel:
	"""Crear panel individual para un recurso"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(200, 100)  # 180x80→200x100 más grande para fuentes
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Contenedor interno
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	vbox.add_theme_constant_override("margin_left", 8)
	vbox.add_theme_constant_override("margin_right", 8)
	vbox.add_theme_constant_override("margin_top", 8)
	vbox.add_theme_constant_override("margin_bottom", 8)

	# Título del recurso
	var title_label = Label.new()
	title_label.text = "%s %s" % [data.emoji, data.name]
	title_label.add_theme_font_size_override("font_size", 18)  # 14→18 más grande
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# T009: Cantidad del recurso con rate display
	var amount_label = Label.new()
	amount_label.text = "Cantidad: 0/100"
	amount_label.add_theme_font_size_override("font_size", 16)
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	amount_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	amount_label.name = "amount_label_" + resource_id

	# T009: Rate display "💧 Agua: 2.5/seg"
	var rate_label = Label.new()
	rate_label.text = "Rate: 0.0/seg"
	rate_label.add_theme_font_size_override("font_size", 14)
	rate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rate_label.name = "rate_label_" + resource_id
	rate_label.add_theme_color_override("font_color", Color.CYAN)

	vbox.add_child(title_label)
	vbox.add_child(amount_label)
	vbox.add_child(rate_label)  # T009: Nuevo rate display
	panel.add_child(vbox)

	return panel


func create_generator_button(generator_id: String, data: Dictionary) -> Control:
	"""T009: Crear panel mejorado estilo IdleBuyButton para generador"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)

	# T009: Panel principal mejorado con mejor visual
	var main_panel = Panel.new()
	main_panel.custom_minimum_size = Vector2(0, 120)  # 100→120 más alto para mejor layout
	main_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# T009: Aplicar estilo profesional al panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.25, 0.3, 1.0)  # Fondo azul oscuro
	style_box.border_color = Color(0.4, 0.6, 0.8, 1.0)  # Borde azul claro
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	main_panel.add_theme_stylebox_override("panel", style_box)

	# Layout del panel con mejor espaciado
	var panel_vbox = VBoxContainer.new()
	panel_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_vbox.add_theme_constant_override("margin_left", 12)
	panel_vbox.add_theme_constant_override("margin_right", 12)
	panel_vbox.add_theme_constant_override("margin_top", 10)
	panel_vbox.add_theme_constant_override("margin_bottom", 10)
	panel_vbox.add_theme_constant_override("separation", 6)

	# T009: Título del generador mejorado
	var title_label = Label.new()
	title_label.text = "%s %s" % [data.emoji, data.name]
	title_label.add_theme_font_size_override("font_size", 20)  # 18→20 más prominente
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color.GOLD)  # Dorado para destacar

	# T009: Info mejorada con rate display
	var info_label = Label.new()
	info_label.text = "Poseído: 0 | Costo: $%.0f" % data.base_price
	info_label.add_theme_font_size_override("font_size", 16)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.name = "info_label_" + generator_id
	info_label.add_theme_color_override("font_color", Color.WHITE)

	# T009: Rate label para cada generador
	var generator_rate_label = Label.new()
	generator_rate_label.text = "Rate: 0.0/seg"
	generator_rate_label.add_theme_font_size_override("font_size", 14)
	generator_rate_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	generator_rate_label.name = "generator_rate_label_" + generator_id
	generator_rate_label.add_theme_color_override("font_color", Color.CYAN)

	panel_vbox.add_child(title_label)
	panel_vbox.add_child(info_label)
	panel_vbox.add_child(generator_rate_label)  # T009: Rate display por generador
	main_panel.add_child(panel_vbox)

	# T009: Contenedor de botones mejorado
	var buttons_hbox = HBoxContainer.new()
	buttons_hbox.add_theme_constant_override("separation", 10)

	# T009: Botón principal mejorado estilo IdleBuyButton
	var buy_button = Button.new()
	buy_button.text = "COMPRAR"
	buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_button.custom_minimum_size = Vector2(0, 45)  # 40→45 más alto
	buy_button.add_theme_font_size_override("font_size", 18)  # 16→18 más legible
	buy_button.name = "buy_button_" + generator_id

	# T009: Estilo del botón principal
	var buy_button_style = StyleBoxFlat.new()
	buy_button_style.bg_color = Color(0.1, 0.5, 0.1, 1.0)  # Verde
	buy_button_style.corner_radius_top_left = 6
	buy_button_style.corner_radius_top_right = 6
	buy_button_style.corner_radius_bottom_left = 6
	buy_button_style.corner_radius_bottom_right = 6
	buy_button.add_theme_stylebox_override("normal", buy_button_style)

	# T009: Botón multiplicador mejorado con ciclo x1→x5→x10→x25
	var multiplier_button = Button.new()
	multiplier_button.text = "x1"
	multiplier_button.custom_minimum_size = Vector2(70, 45)  # 60x40→70x45 más grande
	multiplier_button.add_theme_font_size_override("font_size", 16)  # 14→16 más legible
	multiplier_button.name = "multiplier_button_" + generator_id

	# T009: Estilo del botón multiplicador
	var mult_button_style = StyleBoxFlat.new()
	mult_button_style.bg_color = Color(0.5, 0.3, 0.1, 1.0)  # Marrón
	mult_button_style.corner_radius_top_left = 6
	mult_button_style.corner_radius_top_right = 6
	mult_button_style.corner_radius_bottom_left = 6
	mult_button_style.corner_radius_bottom_right = 6
	multiplier_button.add_theme_stylebox_override("normal", mult_button_style)

	# Conectar señales
	buy_button.pressed.connect(_on_generator_buy_pressed.bind(generator_id))
	multiplier_button.pressed.connect(_on_multiplier_button_pressed.bind(generator_id))

	buttons_hbox.add_child(buy_button)
	buttons_hbox.add_child(multiplier_button)

	container.add_child(main_panel)
	container.add_child(buttons_hbox)

	# T009: Guardar referencia completa con rate_label incluido
	button_states[generator_id] = {
		"multiplier": 1,
		"buy_button": buy_button,
		"multiplier_button": multiplier_button,
		"info_label": info_label,
		"rate_label": generator_rate_label  # T009: Para actualizar rates de generador
	}

	return container


func _on_generator_buy_pressed(generator_id: String):
	"""Manejar compra de generador con multiplicador"""
	if not button_states.has(generator_id):
		print("❌ Estado del botón no encontrado para: %s" % generator_id)
		return

	var state = button_states[generator_id]
	var multiplier = state.multiplier
	print("🔘 Botón de generador presionado: %s x%d" % [generator_id, multiplier])
	generator_purchased.emit(generator_id, multiplier)


func _on_multiplier_button_pressed(generator_id: String):
	"""Cambiar multiplicador del generador de forma centralizada"""
	if update_in_progress:
		print("⚠️ Update en progreso, ignorando cambio de multiplicador")
		return

	if not button_states.has(generator_id):
		print("❌ Estado del botón no encontrado para: %s" % generator_id)
		return

	# Actualizar estado centralizado
	var state = button_states[generator_id]
	var current_multiplier = state.multiplier
	var next_multiplier = _get_next_multiplier(current_multiplier)

	state.multiplier = next_multiplier
	state.multiplier_button.text = "x%d" % next_multiplier

	print("🔢 Multiplicador cambiado para %s: x%d" % [generator_id, next_multiplier])

	# Emitir señal para notificar cambio
	multiplier_changed.emit(generator_id, next_multiplier)

	# Actualizar solo este generador específico INMEDIATAMENTE
	_update_single_generator_state(generator_id)
	print("✅ Botón actualizado inmediatamente después del cambio de multiplicador")


func _get_next_multiplier(current: int) -> int:
	"""Obtener siguiente multiplicador en secuencia x1→x5→x10→x25→x1"""
	match current:
		1:
			return 5
		5:
			return 10
		10:
			return 25
		25:
			return 1
		_:
			return 1


# Método para compatibilidad con GameController
func set_generator_manager(manager: Node):
	"""Establecer referencia al GeneratorManager"""
	generator_manager_ref = manager
	print("🔗 GenerationPanelBasic conectado con GeneratorManager")


## ===== MÉTODOS PÚBLICOS PARA INTERFAZ EXTERNA =====


func refresh_all_generators():
	"""Refrescar todos los generadores - método público para GameController"""
	if generator_manager_ref:
		var game_data = get_current_game_data()
		update_generator_displays(game_data)


func refresh_single_generator(generator_id: String):
	"""Refrescar un generador específico - método público"""
	if generator_manager_ref:
		_update_single_generator_state(generator_id)


func get_generator_multiplier(generator_id: String) -> int:
	"""Obtener multiplicador actual de un generador"""
	if button_states.has(generator_id):
		return button_states[generator_id].multiplier
	return 1


func set_generator_multiplier(generator_id: String, multiplier: int):
	"""Establecer multiplicador de un generador (para sincronización)"""
	if button_states.has(generator_id):
		button_states[generator_id].multiplier = multiplier
		button_states[generator_id].multiplier_button.text = "x%d" % multiplier
		_update_single_generator_state(generator_id)


# T009: Métodos para actualizar datos con rate display y visual feedback
func update_resource_displays(game_data: Dictionary):
	"""Actualizar displays de recursos con rate display y colores"""
	var resources = game_data.get("resources", {})
	var generators = game_data.get("generators", {})

	for resource_id in GameConfig.RESOURCE_DATA.keys():
		var amount_label = main_vbox.find_child("amount_label_" + resource_id, true, false)
		var rate_label = main_vbox.find_child("rate_label_" + resource_id, true, false)

		if amount_label:
			var amount = resources.get(resource_id, 0)
			var max_storage = GameConfig.RESOURCE_DATA[resource_id].max_storage
			amount_label.text = "Cantidad: %.0f/%.0f" % [amount, max_storage]

			# T009: Visual feedback - color coding
			var fill_percentage = amount / max_storage
			if fill_percentage >= 0.95:  # 95%+ = rojo (casi lleno)
				amount_label.add_theme_color_override("font_color", Color.RED)
			elif fill_percentage >= 0.75:  # 75%+ = amarillo (advertencia)
				amount_label.add_theme_color_override("font_color", Color.YELLOW)
			else:  # <75% = verde (OK)
				amount_label.add_theme_color_override("font_color", Color.GREEN)

		if rate_label:
			# T009: Calcular rate de generación
			var generation_rate = _calculate_resource_generation_rate(resource_id, generators)
			if generation_rate > 0:
				rate_label.text = "📈 %.1f/seg" % generation_rate
				rate_label.add_theme_color_override("font_color", Color.CYAN)
			else:
				rate_label.text = "⏸️ Inactivo"
				rate_label.add_theme_color_override("font_color", Color.GRAY)


## T009: Calcular rate de generación para un recurso
func _calculate_resource_generation_rate(resource_id: String, generators: Dictionary) -> float:
	"""Calcular rate de generación total para un recurso"""
	var total_rate = 0.0

	for generator_id in GameConfig.GENERATOR_DATA.keys():
		var generator_data = GameConfig.GENERATOR_DATA[generator_id]
		if generator_data.get("produces", "") == resource_id:
			var owned = generators.get(generator_id, 0)
			if owned > 0:
				var base_rate = generator_data.get("generation_rate", 1.0)
				total_rate += base_rate * owned

	return total_rate


func update_generator_displays(game_data: Dictionary):
	"""Actualizar displays de generadores usando estado centralizado"""
	if update_in_progress:
		return

	update_in_progress = true
	for generator_id in GameConfig.GENERATOR_DATA.keys():
		_update_single_generator_state(generator_id, game_data)
	update_in_progress = false


func _update_single_generator_state(generator_id: String, game_data: Dictionary = {}):
	"""Actualizar estado de un generador específico usando datos centralizados"""
	if not button_states.has(generator_id):
		print("⚠️ Estado del botón no inicializado para: %s" % generator_id)
		return

	# Obtener datos del juego si no se proporcionan
	if game_data.is_empty():
		game_data = get_current_game_data()

	var state = button_states[generator_id]
	var generators = game_data.get("generators", {})
	var money = game_data.get("money", 0)
	var data = GameConfig.GENERATOR_DATA[generator_id]
	var owned = generators.get(generator_id, 0)
	var multiplier = state.multiplier

	# Calcular costos usando el GeneratorManager
	var single_cost = get_generator_cost_from_manager(generator_id, 1)
	var total_cost = get_generator_cost_from_manager(generator_id, multiplier)
	var can_afford = money >= total_cost

	# DEBUG: Mostrar información de cálculo de costos
	print(
		(
			"🔍 DEBUG BOTÓN %s: dinero=%.1f, multiplicador=%d, costo_unitario=%.1f"
			% [generator_id, money, multiplier, single_cost]
		)
	)
	print("🔍   costo_total=%.1f, puede_costear=%s" % [total_cost, can_afford])

	# Actualizar UI elements
	state.info_label.text = (
		"Poseído: %.0f | Costo: $%.0f (x%d = $%.0f)" % [owned, single_cost, multiplier, total_cost]
	)

	# T009: Actualizar rate_label si existe
	if state.has("rate_label") and state.rate_label:
		var generation_rate = data.get("generation_rate", 1.0) * owned
		if owned > 0:
			state.rate_label.text = "⚡ %.1f/seg (x%.0f)" % [generation_rate, owned]
			state.rate_label.add_theme_color_override("font_color", Color.CYAN)
		else:
			state.rate_label.text = "⏸️ Inactivo"
			state.rate_label.add_theme_color_override("font_color", Color.GRAY)

	state.buy_button.disabled = not can_afford
	state.buy_button.modulate = Color.WHITE if can_afford else Color.GRAY

	if can_afford:
		state.buy_button.text = "COMPRAR x%d" % multiplier
	else:
		state.buy_button.text = "SIN DINERO"


func update_single_generator_display(generator_id: String, game_data: Dictionary):
	"""LEGACY: Redirigir a la nueva implementación centralizada"""
	_update_single_generator_state(generator_id, game_data)


func get_generator_cost_from_manager(generator_id: String, quantity: int) -> float:
	"""Obtener costo usando la misma lógica que GeneratorManager"""
	if generator_manager_ref and generator_manager_ref.has_method("get_generator_cost"):
		return generator_manager_ref.get_generator_cost(generator_id, quantity)

	# Fallback: usar GameUtils directamente
	var data = GameConfig.GENERATOR_DATA[generator_id]
	var game_data = get_current_game_data()
	var owned = game_data.get("generators", {}).get(generator_id, 0)

	# T024: Usar nuevo sistema de escalado para generadores
	if quantity == 1:
		return GameUtils.get_scaled_cost(data.base_price, owned + 1, "generator")
	else:
		return GameUtils.get_bulk_scaled_cost(data.base_price, owned, quantity, "generator")


func get_current_game_data() -> Dictionary:
	"""Obtener datos actuales del juego"""
	if generator_manager_ref and generator_manager_ref.has_method("get_game_data"):
		return generator_manager_ref.get_game_data()
	return {"generators": {}, "money": 0}


func calculate_generator_cost(generator_id: String, current_owned: float) -> float:
	"""DEPRECATED: Usar get_generator_cost_from_manager en su lugar"""
	var base_price = GameConfig.GENERATOR_DATA[generator_id].base_price
	var scale_factor = GameConfig.GENERATOR_SCALE_FACTOR
	return base_price * pow(scale_factor, current_owned)
