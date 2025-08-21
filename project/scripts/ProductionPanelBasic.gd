extends Control
## ProductionPanelBasic - Panel de producción simple sin herencias complejas
## Arquitectura idéntica a GenerationPanelBasic para consistencia

# Señales
signal station_purchased(station_id: String, quantity: int)
signal production_requested(station_id: String, quantity: int)
signal multiplier_changed(station_id: String, new_multiplier: int)

# Estado del panel
var production_manager_ref: Node = null
var button_states: Dictionary = {}  # Estados centralizados de botones
var update_in_progress: bool = false  # Prevenir updates recursivos

# Referencias
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var main_vbox: VBoxContainer = $ScrollContainer/MainVBox


func _ready():
	print("🏭 ProductionPanelBasic _ready() iniciado")
	setup_basic_layout()
	print("✅ ProductionPanelBasic inicializado")


func setup_basic_layout():
	"""Configurar layout básico con elementos nativos de Godot"""
	# Limpiar contenido existente
	for child in main_vbox.get_children():
		child.queue_free()

	# === TÍTULO PRINCIPAL ===
	var main_title = Label.new()
	main_title.text = "🏭 PANEL DE PRODUCCIÓN"
	main_title.add_theme_font_size_override("font_size", 36)  # 24→36 mucho más grande
	main_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_title.add_theme_color_override("font_color", Color.GOLD)
	main_vbox.add_child(main_title)

	# Separador
	var separator1 = HSeparator.new()
	separator1.custom_minimum_size = Vector2(0, 30)  # 20→30 más espacio
	main_vbox.add_child(separator1)

	# === SECCIÓN DE PRODUCTOS ===
	setup_products_section()

	# Separador
	var separator2 = HSeparator.new()
	separator2.custom_minimum_size = Vector2(0, 30)
	main_vbox.add_child(separator2)

	# === SECCIÓN DE ESTACIONES DE PRODUCCIÓN ===
	setup_stations_section()


func setup_products_section():
	"""Configurar sección de productos disponibles"""
	# Título de sección
	var section_title = Label.new()
	section_title.text = "🍺 PRODUCTOS DISPONIBLES"
	section_title.add_theme_font_size_override("font_size", 24)  # 18→24 más grande
	section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	section_title.add_theme_color_override("font_color", Color.CYAN)
	main_vbox.add_child(section_title)

	# Contenedor horizontal para productos
	var products_hbox = HBoxContainer.new()
	products_hbox.add_theme_constant_override("separation", 10)
	products_hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	# Crear paneles de productos desde GameConfig
	for product_id in GameConfig.PRODUCT_DATA.keys():
		var data = GameConfig.PRODUCT_DATA[product_id]
		var product_panel = create_product_display_panel(product_id, data)
		products_hbox.add_child(product_panel)

	main_vbox.add_child(products_hbox)


func setup_stations_section():
	"""Configurar sección de estaciones de producción con VBoxContainer"""
	# Título de sección
	var section_title = Label.new()
	section_title.text = "🏭 ESTACIONES DE PRODUCCIÓN"
	section_title.add_theme_font_size_override("font_size", 24)  # 18→24 más grande
	section_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	section_title.add_theme_color_override("font_color", Color.ORANGE)
	main_vbox.add_child(section_title)

	# Crear VBox para estaciones (layout vertical)
	var stations_vbox = VBoxContainer.new()
	stations_vbox.add_theme_constant_override("separation", 12)
	main_vbox.add_child(stations_vbox)

	# Crear estaciones desde GameConfig.STATION_DATA
	for station_id in GameConfig.STATION_DATA.keys():
		var data = GameConfig.STATION_DATA[station_id]
		var station_button = create_station_button(station_id, data)
		stations_vbox.add_child(station_button)


func create_product_display_panel(product_id: String, data: Dictionary) -> Panel:
	"""Crear panel individual para mostrar un producto (solo información)"""
	# Panel compacto para producto
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

	# Título del producto
	var title_label = Label.new()
	title_label.text = "%s %s" % [data.emoji, data.name]
	title_label.add_theme_font_size_override("font_size", 18)  # 14→18 más grande
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Cantidad del producto
	var amount_label = Label.new()
	amount_label.text = "Cantidad: 0"
	amount_label.add_theme_font_size_override("font_size", 16)  # Agregar tamaño
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	amount_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	amount_label.name = "amount_label_" + product_id

	vbox.add_child(title_label)
	vbox.add_child(amount_label)
	panel.add_child(vbox)

	return panel


func create_station_button(station_id: String, data: Dictionary) -> VBoxContainer:
	"""Crear botón individual para una estación de producción"""
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 8)

	# Panel principal de la estación
	var main_panel = Panel.new()
	main_panel.custom_minimum_size = Vector2(0, 100)  # 80→100 más alto para fuentes grandes
	main_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Layout del panel
	var panel_vbox = VBoxContainer.new()
	panel_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_vbox.add_theme_constant_override("margin_left", 8)
	panel_vbox.add_theme_constant_override("margin_right", 8)
	panel_vbox.add_theme_constant_override("margin_top", 8)
	panel_vbox.add_theme_constant_override("margin_bottom", 8)
	panel_vbox.add_theme_constant_override("separation", 4)

	# Título de la estación
	var title_label = Label.new()
	title_label.text = "%s %s" % [data.emoji, data.name]
	title_label.add_theme_font_size_override("font_size", 18)  # 14→18 más grande
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Info de la estación con ingredientes en formato cantidad/total
	var info_label = Label.new()
	var recipe_text = _format_recipe_with_availability(station_id)
	info_label.text = "Poseído: 0 | %s" % recipe_text
	info_label.add_theme_font_size_override("font_size", 14)  # Agregar tamaño
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.name = "info_label_" + station_id

	panel_vbox.add_child(title_label)
	panel_vbox.add_child(info_label)
	main_panel.add_child(panel_vbox)

	# Contenedor de botones (horizontal)
	var buttons_hbox = HBoxContainer.new()
	buttons_hbox.add_theme_constant_override("separation", 8)

	# Botón principal de compra
	var buy_button = Button.new()
	buy_button.text = "COMPRAR"
	buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_button.custom_minimum_size = Vector2(0, 40)
	buy_button.add_theme_font_size_override("font_size", 16)  # Botones más legibles
	buy_button.name = "buy_button_" + station_id

	# Botón multiplicador
	var multiplier_button = Button.new()
	multiplier_button.text = "x1"
	multiplier_button.custom_minimum_size = Vector2(60, 40)
	multiplier_button.add_theme_font_size_override("font_size", 14)  # Botón multiplicador legible
	multiplier_button.name = "multiplier_button_" + station_id

	# Conectar señales
	buy_button.pressed.connect(_on_station_buy_pressed.bind(station_id))
	multiplier_button.pressed.connect(_on_multiplier_button_pressed.bind(station_id))

	buttons_hbox.add_child(buy_button)
	buttons_hbox.add_child(multiplier_button)

	# Guardar estado del botón
	button_states[station_id] = {
		"buy_button": buy_button,
		"multiplier_button": multiplier_button,
		"info_label": info_label,
		"multiplier": 1,
		"station_id": station_id
	}

	container.add_child(main_panel)
	container.add_child(buttons_hbox)

	return container


func _format_recipe_with_availability(station_id: String) -> String:
	"""Formatear receta mostrando ingredientes en formato cantidad_a_usar/total_disponible"""
	var station_data = GameConfig.STATION_DATA.get(station_id, {})
	var recipe = station_data.get("recipe", {})

	if recipe.is_empty():
		return "Sin receta"

	var recipe_parts = []
	for ingredient_id in recipe.keys():
		var needed_amount = recipe[ingredient_id]
		var available_amount = get_ingredient_available_amount(ingredient_id)
		var ingredient_data = GameConfig.RESOURCE_DATA.get(
			ingredient_id, {"emoji": "❓", "name": ingredient_id}
		)

		# Formato: emoji cantidad_necesaria/disponible nombre
		recipe_parts.append(
			(
				"%s %d/%d %s"
				% [ingredient_data.emoji, needed_amount, available_amount, ingredient_data.name]
			)
		)

	return " + ".join(recipe_parts)


func get_ingredient_available_amount(ingredient_id: String) -> int:
	"""Obtener cantidad disponible de un ingrediente"""
	if production_manager_ref and production_manager_ref.has_method("get_game_data"):
		var game_data = production_manager_ref.get_game_data()
		var resources = game_data.get("resources", {})
		return int(resources.get(ingredient_id, 0))

	# Fallback usando singleton GameManager
	if GameManager and GameManager.has_method("get_game_data"):
		var game_data = GameManager.get_game_data()
		return int(game_data.resources.get(ingredient_id, 0))

	return 0


## ===== MANEJADORES DE EVENTOS =====


func _on_station_buy_pressed(station_id: String):
	"""Manejar click en botón de compra/producción de estación"""
	if update_in_progress:
		print("⚠️ Update en progreso, ignorando click")
		return

	if not button_states.has(station_id):
		print("❌ Estado del botón no encontrado para: %s" % station_id)
		return

	var state = button_states[station_id]
	var multiplier = state.multiplier

	print("🏭 Botón de estación presionado: %s (x%d)" % [station_id, multiplier])

	# Emitir señales apropiadas según el estado de la estación
	if is_station_unlocked_from_manager(station_id):
		production_requested.emit(station_id, multiplier)
		print("⚙️ Señal production_requested emitida: %s x%d" % [station_id, multiplier])
	else:
		station_purchased.emit(station_id, multiplier)
		print("🛒 Señal station_purchased emitida: %s x%d" % [station_id, multiplier])


func _on_multiplier_button_pressed(station_id: String):
	"""Manejar click en botón multiplicador"""
	if update_in_progress:
		return

	if not button_states.has(station_id):
		print("❌ Estado del botón no encontrado para: %s" % station_id)
		return

	# Actualizar estado centralizado
	var state = button_states[station_id]
	var current_multiplier = state.multiplier
	var next_multiplier = _get_next_multiplier(current_multiplier)

	state.multiplier = next_multiplier
	state.multiplier_button.text = "x%d" % next_multiplier

	print("🔢 Multiplicador cambiado para %s: x%d" % [station_id, next_multiplier])

	# Emitir señal para notificar cambio
	multiplier_changed.emit(station_id, next_multiplier)

	# Actualizar solo esta estación específica INMEDIATAMENTE
	_update_single_station_state(station_id)
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


## ===== MÉTODOS PÚBLICOS PARA INTERFAZ EXTERNA =====


# Método para compatibilidad con GameController
func set_production_manager(manager: Node):
	"""Establecer referencia al ProductionManager"""
	production_manager_ref = manager
	print("🔗 ProductionPanelBasic conectado con ProductionManager")


func refresh_station_displays():
	"""Refrescar displays de todas las estaciones - método público para GameController"""
	if production_manager_ref:
		var game_data = get_current_game_data()
		update_station_displays(game_data)


func refresh_product_displays():
	"""Refrescar displays de productos - método público para GameController"""
	if production_manager_ref:
		var game_data = get_current_game_data()
		update_product_displays(game_data)


func update_station_displays(game_data: Dictionary):
	"""Actualizar todos los displays de estaciones"""
	if update_in_progress:
		return

	update_in_progress = true

	for station_id in button_states.keys():
		_update_single_station_state(station_id, game_data)

	update_in_progress = false


func update_product_displays(game_data: Dictionary):
	"""Actualizar displays de productos disponibles"""
	# Obtener datos del juego si no se proporcionan
	if game_data.is_empty():
		game_data = get_current_game_data()

	var products = game_data.get("products", {})

	# Actualizar cada producto
	for product_id in GameConfig.PRODUCT_DATA.keys():
		var amount_label = main_vbox.find_child("amount_label_" + product_id, true, false)
		if amount_label:
			var amount = products.get(product_id, 0)
			amount_label.text = "Cantidad: %d" % amount


func _update_single_station_state(station_id: String, game_data: Dictionary = {}):
	"""Actualizar estado de una estación específica"""
	if not button_states.has(station_id):
		print("❌ Estado no encontrado para estación: %s" % station_id)
		return

	# Obtener datos del juego si no se proporcionan
	if game_data.is_empty():
		game_data = get_current_game_data()

	var state = button_states[station_id]
	var multiplier = state.multiplier

	# Obtener información actualizada
	var stations_owned = game_data.get("stations", {})
	var owned_count = stations_owned.get(station_id, 0)

	# Actualizar información con ingredientes disponibles
	var recipe_text = _format_recipe_with_availability(station_id)
	state.info_label.text = "Poseído: %d | %s" % [owned_count, recipe_text]

	# Determinar estado de la estación
	var is_unlocked = is_station_unlocked_from_manager(station_id)

	if is_unlocked:
		# Modo producción - mostrar producto resultante
		var can_produce = can_afford_production(station_id, multiplier, game_data)
		state.buy_button.disabled = not can_produce
		state.buy_button.modulate = Color.WHITE if can_produce else Color.GRAY

		# Obtener información del producto generado
		var station_data = GameConfig.STATION_DATA.get(station_id, {})
		var product_id = station_data.get("product", "")
		var product_data = GameConfig.PRODUCT_DATA.get(
			product_id, {"emoji": "⭐", "name": product_id}
		)
		var product_emoji = product_data.emoji
		var product_name = product_data.name

		if can_produce:
			state.buy_button.text = "PRODUCIR %s %s x%d" % [product_emoji, product_name, multiplier]
		else:
			state.buy_button.text = "SIN INGREDIENTES"
	else:
		# Modo desbloqueo - mostrar precio y feedback completo
		var unlock_cost = get_unlock_cost(station_id)
		var money = game_data.get("money", 0)
		var can_afford = money >= unlock_cost

		state.buy_button.disabled = not can_afford
		state.buy_button.modulate = Color.WHITE if can_afford else Color.GRAY

		if can_afford:
			state.buy_button.text = "DESBLOQUEAR $%.1f" % unlock_cost
		else:
			var faltante = unlock_cost - money
			state.buy_button.text = "DESBLOQUEAR $%.1f (Falta $%.1f)" % [unlock_cost, faltante]


func is_station_unlocked_from_manager(station_id: String) -> bool:
	"""Verificar si una estación está desbloqueada usando el manager"""
	if production_manager_ref and production_manager_ref.has_method("is_station_unlocked"):
		return production_manager_ref.is_station_unlocked(station_id)
	return false


func can_afford_production(station_id: String, quantity: int, game_data: Dictionary) -> bool:
	"""Verificar si se puede costear la producción con ingredientes"""
	var station_data = GameConfig.STATION_DATA.get(station_id, {})
	var recipe = station_data.get("recipe", {})
	var resources = game_data.get("resources", {})

	for ingredient_id in recipe.keys():
		var needed = recipe[ingredient_id] * quantity
		var available = resources.get(ingredient_id, 0)
		if available < needed:
			return false

	return true


func get_unlock_cost(station_id: String) -> float:
	"""Obtener costo de desbloqueo de una estación"""
	if production_manager_ref and production_manager_ref.has_method("get_unlock_cost"):
		return production_manager_ref.get_unlock_cost(station_id)

	# Fallback al costo base
	var station_data = GameConfig.STATION_DATA.get(station_id, {})
	return station_data.get("unlock_cost", 100.0)


func get_current_game_data() -> Dictionary:
	"""Obtener datos actuales del juego"""
	if production_manager_ref and production_manager_ref.has_method("get_game_data"):
		return production_manager_ref.get_game_data()

	# Fallback usando singleton GameManager
	if GameManager and GameManager.has_method("get_game_data"):
		var game_data = GameManager.get_game_data()
		return {
			"money": game_data.money,
			"resources": game_data.resources.duplicate(),
			"products": game_data.products.duplicate(),
			"stations": game_data.stations.duplicate()
		}

	return {"money": 0, "resources": {}, "products": {}, "stations": {}}
