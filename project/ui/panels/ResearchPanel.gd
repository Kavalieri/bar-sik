class_name ResearchPanel
extends Panel

## T035 - Panel del Árbol de Investigación
## UI para mostrar y gestionar tech upgrades para advanced players

# Referencias
var research_manager: ResearchManager
var tab_container: TabContainer

# Elementos UI
var research_points_label: Label
var progress_bars: Dictionary = {}
var research_buttons: Dictionary = {}
var research_info_labels: Dictionary = {}

# Categorías UI
var categories_tabs: Dictionary = {}
var category_scrolls: Dictionary = {}

# Constantes de UI
const BUTTON_COLOR_AVAILABLE = Color.GREEN
const BUTTON_COLOR_LOCKED = Color.GRAY
const BUTTON_COLOR_ACTIVE = Color.YELLOW
const BUTTON_COLOR_COMPLETED = Color.BLUE

func _ready():
	print("🔬 ResearchPanel inicializado (T035)")
	_create_ui_structure()
	_setup_update_timer()


func _create_ui_structure():
	"""Crea la estructura completa de la UI del árbol de investigación"""

	# Panel principal
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Contenedor principal
	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 15)

	# Header con título y puntos
	_create_header(main_vbox)

	# TabContainer para categorías
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(tab_container)

	# Crear tabs por categoría
	_create_category_tabs()


func _create_header(parent: Control):
	"""Crea el header con título y puntos de investigación"""
	var header_hbox = HBoxContainer.new()
	parent.add_child(header_hbox)

	# Título
	var title = Label.new()
	title.text = "🔬 ÁRBOL DE INVESTIGACIÓN"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title)

	# Puntos de investigación
	research_points_label = Label.new()
	research_points_label.text = "Puntos: 0"
	research_points_label.add_theme_font_size_override("font_size", 18)
	research_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header_hbox.add_child(research_points_label)


func _create_category_tabs():
	"""Crea los tabs para cada categoría de investigación"""
	var categories = ["production", "economic", "automation", "resources", "legendary"]
	var category_names = {
		"production": "🍺 Producción",
		"economic": "💰 Economía",
		"automation": "🤖 Automatización",
		"resources": "📦 Recursos",
		"legendary": "🌟 Legendario"
	}

	for category in categories:
		var scroll = ScrollContainer.new()
		scroll.name = category_names.get(category, category.capitalize())
		tab_container.add_child(scroll)

		var grid = GridContainer.new()
		grid.columns = 3  # 3 investigaciones por fila
		grid.add_theme_constant_override("h_separation", 10)
		grid.add_theme_constant_override("v_separation", 10)
		scroll.add_child(grid)

		categories_tabs[category] = grid
		category_scrolls[category] = scroll


func _populate_research_tree():
	"""Puebla el árbol de investigación con botones"""
	if not research_manager:
		return

	# Limpiar contenido existente
	for category in categories_tabs:
		for child in categories_tabs[category].get_children():
			child.queue_free()

	research_buttons.clear()
	research_info_labels.clear()
	progress_bars.clear()

	# Obtener investigaciones por categoría
	for category in categories_tabs:
		var researches = research_manager.get_research_by_category(category)
		var grid = categories_tabs[category]

		# Ordenar por tier
		researches.sort_custom(func(a, b):
			var tier_a = research_manager.research_tree[a].get("tier", 1)
			var tier_b = research_manager.research_tree[b].get("tier", 1)
			return tier_a < tier_b
		)

		for research_id in researches:
			_create_research_node(grid, research_id)


func _create_research_node(parent: GridContainer, research_id: String):
	"""Crea un nodo de investigación en la UI"""
	var research_info = research_manager.get_research_info(research_id)

	# Container principal del nodo
	var research_container = VBoxContainer.new()
	research_container.custom_minimum_size = Vector2(200, 150)
	parent.add_child(research_container)

	# Panel de fondo
	var background_panel = Panel.new()
	research_container.add_child(background_panel)
	background_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# VBox para contenido
	var content_vbox = VBoxContainer.new()
	research_container.add_child(content_vbox)
	content_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_vbox.add_theme_constant_override("separation", 5)

	# Título de la investigación
	var title_label = Label.new()
	title_label.text = research_info["name"]
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(title_label)

	# Descripción
	var desc_label = Label.new()
	desc_label.text = research_info["description"]
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_vbox.add_child(desc_label)

	# Información de costo y tiempo
	var info_label = Label.new()
	info_label.text = "Costo: %d | Tiempo: %ds" % [research_info["cost"], research_info["time"]]
	info_label.add_theme_font_size_override("font_size", 9)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_vbox.add_child(info_label)
	research_info_labels[research_id] = info_label

	# Barra de progreso (solo visible si está activa)
	var progress_bar = ProgressBar.new()
	progress_bar.max_value = 1.0
	progress_bar.value = 0.0
	progress_bar.visible = false
	content_vbox.add_child(progress_bar)
	progress_bars[research_id] = progress_bar

	# Botón de investigación
	var research_button = Button.new()
	research_button.text = "INVESTIGAR"
	research_button.pressed.connect(_on_research_button_pressed.bind(research_id))
	content_vbox.add_child(research_button)
	research_buttons[research_id] = research_button

	# Mostrar prerequisitos si los hay
	if research_info["prerequisites"].size() > 0:
		var prereq_label = Label.new()
		prereq_label.text = "Requiere: " + ", ".join(research_info["prerequisites"])
		prereq_label.add_theme_font_size_override("font_size", 8)
		prereq_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prereq_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_vbox.add_child(prereq_label)


func _on_research_button_pressed(research_id: String):
	"""Maneja el clic en un botón de investigación"""
	if not research_manager:
		return

	if research_manager.can_start_research(research_id):
		var success = research_manager.start_research(research_id)
		if success:
			_update_research_display()
			# Efecto de sonido o visual aquí
			print("🔬 Investigación iniciada: %s" % research_id)
	else:
		var research_info = research_manager.get_research_info(research_id)
		var message = "No se puede iniciar: "
		if research_manager.research_points < research_info["cost"]:
			message += "Puntos insuficientes (%d/%d)" % [research_manager.research_points, research_info["cost"]]
		else:
			message += "Prerequisitos no cumplidos"
		print("❌ " + message)


func _update_research_display():
	"""Actualiza la visualización de todas las investigaciones"""
	if not research_manager:
		return

	# Actualizar puntos
	var progress = research_manager.get_research_tree_progress()
	research_points_label.text = "Puntos: %d | Progreso: %.1f%%" % [
		progress["research_points"],
		progress["completion_percentage"]
	]

	# Actualizar estado de cada investigación
	for research_id in research_buttons.keys():
		_update_research_node_state(research_id)


func _update_research_node_state(research_id: String):
	"""Actualiza el estado visual de un nodo de investigación"""
	var button = research_buttons.get(research_id)
	var progress_bar = progress_bars.get(research_id)
	var info_label = research_info_labels.get(research_id)

	if not button or not progress_bar or not info_label:
		return

	var research_info = research_manager.get_research_info(research_id)
	var completed = research_manager.completed_researches.has(research_id)
	var active_researches = research_manager.get_active_researches()
	var is_active = active_researches.has(research_id)
	var can_start = research_manager.can_start_research(research_id)

	# Estado completado
	if completed:
		button.text = "COMPLETADO"
		button.disabled = true
		button.modulate = BUTTON_COLOR_COMPLETED
		progress_bar.visible = false
		info_label.text = "✅ INVESTIGACIÓN COMPLETADA"

	# Estado activo
	elif is_active:
		button.text = "EN PROGRESO"
		button.disabled = true
		button.modulate = BUTTON_COLOR_ACTIVE
		progress_bar.visible = true

		var active_data = active_researches[research_id]
		progress_bar.value = active_data["progress"]

		var remaining_time = (1.0 - active_data["progress"]) * research_info["time"]
		info_label.text = "Tiempo restante: %ds" % int(remaining_time)

	# Estado disponible
	elif can_start:
		button.text = "INVESTIGAR"
		button.disabled = false
		button.modulate = BUTTON_COLOR_AVAILABLE
		progress_bar.visible = false
		info_label.text = "Costo: %d | Tiempo: %ds" % [research_info["cost"], research_info["time"]]

	# Estado bloqueado
	else:
		button.text = "BLOQUEADO"
		button.disabled = true
		button.modulate = BUTTON_COLOR_LOCKED
		progress_bar.visible = false

		if research_manager.research_points < research_info["cost"]:
			info_label.text = "Puntos insuficientes: %d/%d" % [research_manager.research_points, research_info["cost"]]
		else:
			info_label.text = "Prerequisitos requeridos"


func _setup_update_timer():
	"""Configura timer para actualizar la UI"""
	var update_timer = Timer.new()
	update_timer.wait_time = 1.0  # Actualizar cada segundo
	update_timer.timeout.connect(_update_research_display)
	update_timer.autostart = true
	add_child(update_timer)


func _on_research_completed(research_id: String, research_data: Dictionary):
	"""Maneja cuando se completa una investigación"""
	print("🎉 ¡Investigación completada!: %s" % research_data["name"])
	_update_research_display()

	# Mostrar notificación de investigación completada
	_show_research_completed_notification(research_data)


func _on_research_unlocked(research_id: String):
	"""Maneja cuando se desbloquea una nueva investigación"""
	var research_info = research_manager.get_research_info(research_id)
	print("🔓 Nueva investigación disponible: %s" % research_info["name"])
	_update_research_display()


func _show_research_completed_notification(research_data: Dictionary):
	"""Muestra notificación de investigación completada"""
	# Aquí se podría implementar una notificación popup
	var notification_text = "🎉 INVESTIGACIÓN COMPLETADA:\n%s\n\n%s" % [
		research_data["name"],
		research_data["description"]
	]
	print(notification_text)


func _show_research_tree_overview():
	"""Muestra información general del progreso del árbol"""
	if not research_manager:
		return

	var progress = research_manager.get_research_tree_progress()
	var overview_text = """
🔬 RESUMEN DEL ÁRBOL DE INVESTIGACIÓN:

📊 Progreso General:
   • Total: %d investigaciones
   • Completadas: %d (%.1f%%)
   • Activas: %d
   • Disponibles: %d
   • Puntos: %d

🏆 Por Categoría:
""" % [
	progress["total"],
	progress["completed"],
	progress["completion_percentage"],
	progress["active"],
	progress["available"],
	progress["research_points"]
]

	# Agregar progreso por categoría
	var categories = ["production", "economic", "automation", "resources", "legendary"]
	for category in categories:
		var category_researches = research_manager.get_research_by_category(category)
		var completed_in_category = 0
		for research_id in category_researches:
			if research_manager.completed_researches.has(research_id):
				completed_in_category += 1

		var category_progress = float(completed_in_category) / float(category_researches.size()) * 100
		overview_text += "   • %s: %d/%d (%.1f%%)\n" % [
			category.capitalize(),
			completed_in_category,
			category_researches.size(),
			category_progress
		]

	print(overview_text)


## === API PÚBLICAS ===

func set_research_manager(manager: ResearchManager):
	"""Conecta con el ResearchManager"""
	research_manager = manager
	if research_manager:
		# Conectar señales
		research_manager.research_completed.connect(_on_research_completed)
		research_manager.research_unlocked.connect(_on_research_unlocked)
		research_manager.research_progress_updated.connect(_on_research_progress_updated)
		research_manager.tech_bonus_applied.connect(_on_tech_bonus_applied)

		# Poblar UI inicial
		_populate_research_tree()
		_update_research_display()


func _on_research_progress_updated(research_id: String, progress: float):
	"""Maneja actualización de progreso de investigación"""
	if progress_bars.has(research_id):
		progress_bars[research_id].value = progress


func _on_tech_bonus_applied(bonus_type: String, bonus_value: float):
	"""Maneja cuando se aplica un bonus tecnológico"""
	print("⚡ Bonus aplicado: %s (+%.1f%%)" % [bonus_type, bonus_value * 100])


func show_research_details(research_id: String):
	"""Muestra detalles completos de una investigación"""
	var research_info = research_manager.get_research_info(research_id)
	if research_info.is_empty():
		return

	var details = """
🔬 %s

📝 Descripción: %s

💰 Costo: %d puntos de investigación
⏱️ Tiempo: %d segundos
🏷️ Categoría: %s
🎯 Tier: %d

🔗 Prerequisitos:
""" % [
	research_info["name"],
	research_info["description"],
	research_info["cost"],
	research_info["time"],
	research_info["category"],
	research_info["tier"]
]

	if research_info["prerequisites"].size() > 0:
		for prereq in research_info["prerequisites"]:
			var prereq_info = research_manager.get_research_info(prereq)
			details += "   • %s\n" % prereq_info.get("name", prereq)
	else:
		details += "   • Ninguno\n"

	details += "\n🔓 Desbloquea:\n"
	if research_info["unlocks"].size() > 0:
		for unlock in research_info["unlocks"]:
			var unlock_info = research_manager.get_research_info(unlock)
			details += "   • %s\n" % unlock_info.get("name", unlock)
	else:
		details += "   • Ninguna investigación adicional\n"

	details += "\n⚡ Bonus:\n   • %s: +%.1f%%\n" % [
		research_info["bonus"]["type"].replace("_", " ").capitalize(),
		research_info["bonus"]["value"] * 100
	]

	print(details)
