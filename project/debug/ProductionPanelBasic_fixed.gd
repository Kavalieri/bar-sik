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
	var product_panel = Panel.new()
	product_panel.custom_minimum_size = Vector2(240, 160)  # 200x120 → 240x160 más grande
	product_panel.add_theme_stylebox_override("panel", create_styled_panel(Color(0.2, 0.3, 0.4, 0.8)))

	var vbox = VBoxContainer.new()
	product_panel.add_child(vbox)

	# Título con emoji
	var title_label = Label.new()
	title_label.text = "%s %s" % [data.get("emoji", "📦"), data.get("name", product_id)]
	title_label.add_theme_font_size_override("font_size", 18)  # 14→18 más grande
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(title_label)

	# Separador
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(separator)

	# Precio
	var price_label = Label.new()
	price_label.text = "Precio: $%.1f" % data.get("base_price", 0.0)
	price_label.add_theme_font_size_override("font_size", 16)  # 12→16 más grande
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_color_override("font_color", Color.GREEN)
	vbox.add_child(price_label)

	# Receta (si existe)
	var recipe = data.get("recipe", {})
	if not recipe.is_empty():
		var recipe_label = Label.new()
		var recipe_parts = []
		for ingredient in recipe.keys():
			var amount = recipe[ingredient]
			var emoji = "📦"  # emoji por defecto
			if GameConfig.INGREDIENT_DATA.has(ingredient):
				emoji = GameConfig.INGREDIENT_DATA[ingredient].get("emoji", "📦")
			recipe_parts.append("%s%d" % [emoji, amount])

		recipe_label.text = "Receta: %s" % " + ".join(recipe_parts)
		recipe_label.add_theme_font_size_override("font_size", 14)  # 10→14 más grande
		recipe_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		recipe_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)
		recipe_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(recipe_label)

	# Centrar el VBox dentro del panel
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.position = Vector2(10, 10)
	vbox.size = Vector2(220, 140)  # 180x100 → 220x140

	return product_panel

func create_station_button(station_id: String, data: Dictionary) -> Control:
	"""Crear botón de estación con toda la funcionalidad necesaria"""
	# Contenedor horizontal para la estación
	var station_hbox = HBoxContainer.new()
	station_hbox.add_theme_constant_override("separation", 15)

	# === INFORMACIÓN DE LA ESTACIÓN ===
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Título de la estación
	var title_label = Label.new()
	title_label.text = "%s %s" % [data.get("emoji", "🏭"), data.get("name", station_id)]
	title_label.add_theme_font_size_override("font_size", 24)  # 18→24 más grande
	title_label.add_theme_color_override("font_color", Color.GOLD)
	info_vbox.add_child(title_label)

	# Información dinámica de la estación (recetas, cantidad poseída)
	var info_label = Label.new()
	info_label.text = "Cargando..."  # Se actualizará dinámicamente
	info_label.add_theme_font_size_override("font_size", 18)  # 14→18 más grande
	info_label.add_theme_color_override("font_color", Color.LIGHT_BLUE)
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(info_label)

	station_hbox.add_child(info_vbox)

	# === CONTROLES DE COMPRA/PRODUCCIÓN ===
	var controls_vbox = VBoxContainer.new()
	controls_vbox.custom_minimum_size = Vector2(200, 80)

	# Botón principal (comprar/producir)
	var buy_button = Button.new()
	buy_button.text = "CARGANDO..."
	buy_button.custom_minimum_size = Vector2(180, 50)  # 150x40 → 180x50 más grande
	buy_button.add_theme_font_size_override("font_size", 18)  # 14→18 más grande
	controls_vbox.add_child(buy_button)

	# Botón multiplicador
	var multiplier_button = Button.new()
	multiplier_button.text = "x1"
	multiplier_button.custom_minimum_size = Vector2(60, 30)
	multiplier_button.add_theme_font_size_override("font_size", 16)  # 12→16 más grande
	multiplier_button.add_theme_color_override("font_color", Color.YELLOW)
	controls_vbox.add_child(multiplier_button)

	station_hbox.add_child(controls_vbox)

	# Configurar señales
	buy_button.pressed.connect(_on_station_buy_pressed.bind(station_id))
	multiplier_button.pressed.connect(_on_multiplier_button_pressed.bind(station_id))

	# Guardar estado del botón
	button_states[station_id] = {
		"buy_button": buy_button,
		"multiplier_button": multiplier_button,
		"info_label": info_label,
		"title_label": title_label,
		"multiplier": 1
	}

	return station_hbox

func create_styled_panel(color: Color) -> StyleBoxFlat:
	"""Crear estilo para paneles con bordes redondeados"""
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color.WHITE
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

## ===== FUNCIONES DE CONEXIÓN =====

func set_production_manager(manager: Node):
	"""Conectar con el ProductionManager"""
	production_manager_ref = manager
	print("🔗 ProductionPanelBasic conectado con ProductionManager")

	# Configurar actualización inicial
	update_all_states()

## ===== FUNCIONES DE ACTUALIZACIÓN =====

func update_all_states(game_data: Dictionary = {}):
	"""Actualizar estado de todas las estaciones"""
	if update_in_progress:
		return

	update_in_progress = true

	# Obtener datos del juego si no se proporcionan
	if game_data.is_empty():
		game_data = get_current_game_data()

	# Actualizar cada estación
	for station_id in button_states.keys():
		_update_single_station_state(station_id, game_data)

	# Actualizar productos
	update_product_displays(game_data)

	update_in_progress = false

func update_product_displays(game_data: Dictionary):
	"""Actualizar información de productos disponibles"""
	# Esta función se puede expandir para mostrar cantidad actual de productos
	var products = game_data.get("products", {})

	# Aquí podrías actualizar los paneles de productos si necesitas mostrar cantidades actuales
	for product_id in GameConfig.PRODUCT_DATA.keys():
		# Buscar el panel correspondiente y actualizar información
		var amount_label = find_product_amount_label(product_id)
		if amount_label:
			var amount = products.get(product_id, 0)
			amount_label.text = "Cantidad: %d" % amount

func find_product_amount_label(product_id: String) -> Label:
	"""Buscar etiqueta de cantidad para un producto específico"""
	# Implementar si necesitas actualizar cantidades de productos en tiempo real
	return null

func update_station_displays(game_data: Dictionary):
	"""Actualizar displays de estaciones (alias para update_all_states)"""
	update_all_states(game_data)

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
		# Modo producción - verificar ingredientes disponibles y mostrar qué produce
		var can_produce = can_afford_production(station_id, multiplier, game_data)
		var station_data = GameConfig.STATION_DATA.get(station_id, {})
		var produces = station_data.get("produces", "")

		# Obtener emoji del producto desde PRODUCT_DATA
		var product_emoji = "📦"  # emoji por defecto
		if GameConfig.PRODUCT_DATA.has(produces):
			product_emoji = GameConfig.PRODUCT_DATA[produces].get("emoji", "📦")

		if can_produce:
			state.buy_button.text = "PRODUCIR %s%s x%d" % [product_emoji, produces.capitalize(), multiplier]
			state.buy_button.disabled = false
			state.buy_button.modulate = Color.WHITE
		else:
			var product_name = "%s%s x%d" % [product_emoji, produces.capitalize(), multiplier]
			state.buy_button.text = "SIN INGREDIENTES (%s)" % product_name
			state.buy_button.disabled = true
			state.buy_button.modulate = Color.GRAY
	else:
		# Modo desbloqueo - siempre mostrar precio y estado
		var unlock_cost = get_unlock_cost(station_id)
		var money = game_data.get("money", 0)
		var can_afford = money >= unlock_cost

		# Siempre mostrar el precio para feedback claro al jugador
		var price_text = "$%.1f" % unlock_cost
		if can_afford:
			state.buy_button.text = "DESBLOQUEAR %s" % price_text
			state.buy_button.disabled = false
			state.buy_button.modulate = Color.WHITE
		else:
			state.buy_button.text = "DESBLOQUEAR %s (Falta $%.1f)" % [price_text, unlock_cost - money]
			state.buy_button.disabled = true
			state.buy_button.modulate = Color.GRAY

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

	for ingredient in recipe.keys():
		var needed = recipe[ingredient] * quantity
		var available = resources.get(ingredient, 0)
		if available < needed:
			return false

	return true

func get_unlock_cost(station_id: String) -> float:
	"""Obtener costo de desbloqueo de una estación"""
	if production_manager_ref and production_manager_ref.has_method("get_unlock_cost"):
		return production_manager_ref.get_unlock_cost(station_id)

	# Fallback al costo base desde GameConfig
	var station_data = GameConfig.STATION_DATA.get(station_id, {})
	return station_data.get("base_price", 100.0)

func get_current_game_data() -> Dictionary:
	"""Obtener datos actuales del juego"""
	if production_manager_ref and production_manager_ref.has_method("get_game_data"):
		return production_manager_ref.get_game_data()

	# Fallback a datos básicos
	return {"money": 0, "resources": {}, "stations": {}, "products": {}}

func _format_recipe_with_availability(station_id: String) -> String:
	"""Formatear receta mostrando ingredientes necesarios vs disponibles"""
	var station_data = GameConfig.STATION_DATA.get(station_id, {})
	var recipe = station_data.get("recipe", {})

	if recipe.is_empty():
		return "Sin receta"

	var recipe_parts = []
	for ingredient_id in recipe.keys():
		var needed = recipe[ingredient_id]
		var available = get_ingredient_available_amount(ingredient_id)

		# Obtener emoji del ingrediente
		var emoji = "📦"  # emoji por defecto
		if GameConfig.INGREDIENT_DATA.has(ingredient_id):
			emoji = GameConfig.INGREDIENT_DATA[ingredient_id].get("emoji", "📦")

		recipe_parts.append("%s %d/%d" % [emoji, needed, available])

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
	"""Manejar click en botón principal de estación"""
	if update_in_progress:
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

	var state = button_states[station_id]

	# Ciclar multiplicadores: 1 → 5 → 10 → 25 → 1
	match state.multiplier:
		1: state.multiplier = 5
		5: state.multiplier = 10
		10: state.multiplier = 25
		25: state.multiplier = 1
		_: state.multiplier = 1

	# Actualizar texto del botón
	state.multiplier_button.text = "x%d" % state.multiplier

	# Actualizar estado de la estación para reflejar nuevo multiplicador
	_update_single_station_state(station_id)

	# Emitir señal de cambio
	multiplier_changed.emit(station_id, state.multiplier)
	print("🔄 Multiplicador cambiado: %s x%d" % [station_id, state.multiplier])
