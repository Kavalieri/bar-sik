class_name UnlockPanel
extends Control

## T031 - Panel de Desbloqueos Progresivos
## Muestra el progreso hacia desbloqueos y próximas características

# Referencias UI
@onready var header_label: Label = $Header/Title
@onready var close_button: Button = $Header/CloseButton
@onready var phase_label: Label = $Header/PhaseIndicator

@onready var tab_container: TabContainer = $TabContainer
@onready var available_tab: VBoxContainer = $TabContainer/Disponibles
@onready var unlocked_tab: VBoxContainer = $TabContainer/Desbloqueadas

@onready var available_scroll: ScrollContainer = $TabContainer/Disponibles/AvailableScroll
@onready
var available_content: VBoxContainer = $TabContainer/Disponibles/AvailableScroll/AvailableContent

@onready var unlocked_scroll: ScrollContainer = $TabContainer/Desbloqueadas/UnlockedScroll
@onready
var unlocked_content: VBoxContainer = $TabContainer/Desbloqueadas/UnlockedScroll/UnlockedContent

# Referencias a managers
var unlock_manager: UnlockManager
var game_data: GameData

# UI State
var is_visible_panel: bool = false

# Constantes visuales
const PROGRESS_BAR_HEIGHT = 8
const ITEM_SPACING = 10
const PHASE_COLORS = {
	UnlockManager.GamePhase.EARLY: Color.GREEN,
	UnlockManager.GamePhase.MID: Color.ORANGE,
	UnlockManager.GamePhase.LATE: Color.PURPLE,
	UnlockManager.GamePhase.ENDGAME: Color.RED
}


func _ready():
	print("🔓 UnlockPanel inicializado")

	# Conectar señales UI
	close_button.pressed.connect(_on_close_pressed)

	# Referencias
	unlock_manager = get_node("/root/UnlockManager")
	var gd_node = get_node("/root/GameData")
	game_data = gd_node as GameData

	if unlock_manager:
		# Conectar señales del UnlockManager
		unlock_manager.feature_unlocked.connect(_on_feature_unlocked)
		unlock_manager.progress_towards_unlock.connect(_on_progress_updated)
		unlock_manager.unlock_notification.connect(_on_unlock_notification)

	# Configurar UI inicial
	_setup_ui()
	_refresh_content()

	# Timer para actualizar progreso
	var update_timer = Timer.new()
	update_timer.wait_time = 2.0
	update_timer.timeout.connect(_refresh_content)
	update_timer.autostart = true
	add_child(update_timer)


func _setup_ui():
	"""Configura la interfaz inicial"""
	header_label.text = "🔓 Desbloqueos Progresivos"

	# Configurar tabs
	tab_container.set_tab_title(0, "Disponibles")
	tab_container.set_tab_title(1, "Desbloqueadas")

	# Actualizar indicador de fase
	_update_phase_indicator()


func _update_phase_indicator():
	"""Actualiza el indicador de fase del juego"""
	if not unlock_manager:
		return

	var current_phase = unlock_manager.get_current_phase()
	var phase_name = UnlockManager.GamePhase.keys()[current_phase]
	var phase_color = PHASE_COLORS.get(current_phase, Color.WHITE)

	var phase_text = ""
	match current_phase:
		UnlockManager.GamePhase.EARLY:
			phase_text = "🌱 Fase Inicial (0-30 min)"
		UnlockManager.GamePhase.MID:
			phase_text = "🚀 Fase Media (30-120 min)"
		UnlockManager.GamePhase.LATE:
			phase_text = "⭐ Fase Tardía (2+ horas)"
		UnlockManager.GamePhase.ENDGAME:
			phase_text = "👑 Endgame (Post-Prestigio)"

	phase_label.text = phase_text
	phase_label.modulate = phase_color


func _refresh_content():
	"""Actualiza el contenido de ambas tabs"""
	_refresh_available_unlocks()
	_refresh_unlocked_features()
	_update_phase_indicator()


func _refresh_available_unlocks():
	"""Actualiza la lista de desbloqueos disponibles"""
	_clear_container(available_content)

	var available_unlocks = unlock_manager.get_available_unlocks()

	if available_unlocks.is_empty():
		var no_unlocks_label = Label.new()
		no_unlocks_label.text = "🎉 ¡Todas las características disponibles están desbloqueadas!\n\nContinúa jugando para acceder a más contenido."
		no_unlocks_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_unlocks_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		no_unlocks_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		available_content.add_child(no_unlocks_label)
		return

	for unlock_data in available_unlocks:
		var item = _create_available_unlock_item(unlock_data)
		available_content.add_child(item)


func _refresh_unlocked_features():
	"""Actualiza la lista de características desbloqueadas"""
	_clear_container(unlocked_content)

	var unlocked_features = unlock_manager.get_unlocked_features()
	var unlock_definitions = unlock_manager.unlock_definitions

	if unlocked_features.is_empty():
		var no_unlocked_label = Label.new()
		no_unlocked_label.text = "🔒 Aún no has desbloqueado características adicionales.\n\nContinúa jugando para desbloquear nuevo contenido."
		no_unlocked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_unlocked_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		no_unlocked_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		unlocked_content.add_child(no_unlocked_label)
		return

	# Ordenar por orden de desbloqueo (los que tienen definición primero)
	var sorted_features = []
	for feature_id in unlocked_features:
		if unlock_definitions.has(feature_id):
			sorted_features.append(feature_id)

	for feature_id in unlocked_features:
		if not unlock_definitions.has(feature_id):
			sorted_features.append(feature_id)

	for feature_id in sorted_features:
		var item = _create_unlocked_feature_item(feature_id)
		unlocked_content.add_child(item)


func _create_available_unlock_item(unlock_data: Dictionary) -> Control:
	"""Crea un item visual para un desbloqueo disponible"""
	var item_container = PanelContainer.new()
	item_container.custom_minimum_size = Vector2(0, 120)

	# Panel con estilo
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	style_box.border_width_left = 4
	style_box.border_width_right = 4
	style_box.border_width_top = 4
	style_box.border_width_bottom = 4
	style_box.border_color = Color(0.4, 0.6, 1.0, 0.6)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	item_container.add_theme_stylebox_override("panel", style_box)

	var main_vbox = VBoxContainer.new()
	main_vbox.custom_minimum_size = Vector2(0, 100)
	item_container.add_child(main_vbox)

	# Header con icon y título
	var header_hbox = HBoxContainer.new()
	main_vbox.add_child(header_hbox)

	var definition = unlock_data["definition"]

	var icon_label = Label.new()
	icon_label.text = definition["icon"]
	icon_label.add_theme_font_size_override("font_size", 24)
	header_hbox.add_child(icon_label)

	var title_label = Label.new()
	title_label.text = definition["name"]
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(title_label)

	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(spacer)

	# Progreso porcentual
	var progress_percentage = unlock_data["progress"] * 100
	var progress_label = Label.new()
	progress_label.text = "%d%%" % progress_percentage
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.add_theme_color_override("font_color", Color.CYAN)
	header_hbox.add_child(progress_label)

	# Descripción
	var description_label = Label.new()
	description_label.text = definition["description"]
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 12)
	description_label.add_theme_color_override("font_color", Color.GRAY)
	main_vbox.add_child(description_label)

	# Spacer
	main_vbox.add_child(Control.new())

	# Condiciones de desbloqueo
	var conditions_label = Label.new()
	conditions_label.text = "Condiciones:"
	conditions_label.add_theme_font_size_override("font_size", 12)
	conditions_label.add_theme_color_override("font_color", Color.YELLOW)
	main_vbox.add_child(conditions_label)

	var conditions_progress = unlock_data["conditions_progress"]
	for condition_key in conditions_progress.keys():
		var condition = conditions_progress[condition_key]
		var condition_container = _create_condition_item(condition_key, condition)
		main_vbox.add_child(condition_container)

	return item_container


func _create_condition_item(condition_key: String, condition: Dictionary) -> Control:
	"""Crea un item visual para una condición de desbloqueo"""
	var condition_hbox = HBoxContainer.new()
	condition_hbox.custom_minimum_size = Vector2(0, 20)

	# Icono de estado
	var status_icon = Label.new()
	status_icon.text = "✅" if condition["met"] else "⏳"
	condition_hbox.add_child(status_icon)

	# Nombre de condición formateado
	var condition_name = _format_condition_name(condition_key)
	var name_label = Label.new()
	name_label.text = condition_name
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	condition_hbox.add_child(name_label)

	# Progreso numérico
	var progress_text = _format_condition_progress(condition_key, condition)
	var progress_label = Label.new()
	progress_label.text = progress_text
	progress_label.add_theme_font_size_override("font_size", 11)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	if condition["met"]:
		progress_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		progress_label.add_theme_color_override("font_color", Color.ORANGE)

	condition_hbox.add_child(progress_label)

	return condition_hbox


func _format_condition_name(condition_key: String) -> String:
	"""Formatea el nombre de una condición para mostrar"""
	match condition_key:
		"total_money_earned":
			return "Dinero total ganado"
		"beers_produced":
			return "Cervezas producidas"
		"customers_unlocked":
			return "Clientes desbloqueados"
		"basic_automation_unlocked":
			return "Automatización básica"
		"upgrades_purchased":
			return "Mejoras compradas"
		"playtime_minutes":
			return "Tiempo jugado"
		"prestige_completed":
			return "Prestigios completados"
		"prestige_stars":
			return "Estrellas de prestigio"
		"tokens_earned":
			return "Tokens ganados"
		"achievements_unlocked":
			return "Logros desbloqueados"
		"achievements_completed":
			return "Logros completados"
		"missions_unlocked":
			return "Misiones desbloqueadas"
		"gems_earned":
			return "Gemas ganadas"
		"gems_spent":
			return "Gemas gastadas"
		_:
			return condition_key.replace("_", " ").capitalize()


func _format_condition_progress(condition_key: String, condition: Dictionary) -> String:
	"""Formatea el progreso de una condición"""
	var current = condition["current"]
	var required = condition["required"]

	if typeof(required) == TYPE_BOOL:
		return "Requerido" if required else "No requerido"

	# Formatear números grandes
	match condition_key:
		"total_money_earned":
			return "$%s / $%s" % [_format_currency(current), _format_currency(required)]
		"playtime_minutes":
			return "%s / %s min" % [int(current), int(required)]
		"total_playtime_hours":
			return "%.1f / %.1f hrs" % [current, required]
		_:
			return "%s / %s" % [int(current), int(required)]


func _format_currency(amount: float) -> String:
	"""Formatea montos de dinero"""
	if amount >= 1000000000:
		return "%.1fB" % (amount / 1000000000.0)
	elif amount >= 1000000:
		return "%.1fM" % (amount / 1000000.0)
	elif amount >= 1000:
		return "%.1fK" % (amount / 1000.0)
	else:
		return "%.0f" % amount


func _create_unlocked_feature_item(feature_id: String) -> Control:
	"""Crea un item visual para una característica desbloqueada"""
	var item_container = PanelContainer.new()
	item_container.custom_minimum_size = Vector2(0, 60)

	# Panel con estilo desbloqueado
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.3, 0.1, 0.8)
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.border_color = Color.GREEN
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	item_container.add_theme_stylebox_override("panel", style_box)

	var main_hbox = HBoxContainer.new()
	item_container.add_child(main_hbox)

	# Obtener datos de definición si existe
	var definition = unlock_manager.unlock_definitions.get(
		feature_id,
		{
			"name": feature_id.replace("_", " ").capitalize(),
			"description": "Característica desbloqueada",
			"icon": "✅"
		}
	)

	# Icono
	var icon_label = Label.new()
	icon_label.text = definition["icon"]
	icon_label.add_theme_font_size_override("font_size", 20)
	main_hbox.add_child(icon_label)

	# Contenido vertical
	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_hbox.add_child(content_vbox)

	# Título
	var title_label = Label.new()
	title_label.text = definition["name"]
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	content_vbox.add_child(title_label)

	# Descripción
	var description_label = Label.new()
	description_label.text = definition["description"]
	description_label.add_theme_font_size_override("font_size", 11)
	description_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content_vbox.add_child(description_label)

	# Estado desbloqueado
	var status_label = Label.new()
	status_label.text = "🔓 DESBLOQUEADO"
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", Color.GREEN)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main_hbox.add_child(status_label)

	return item_container


func _clear_container(container: Node):
	"""Limpia todos los hijos de un container"""
	for child in container.get_children():
		child.queue_free()


## === EVENT HANDLERS ===


func _on_close_pressed():
	"""Cierra el panel"""
	hide_panel()


func _on_feature_unlocked(feature_id: String, feature_data: Dictionary):
	"""Maneja cuando se desbloquea una nueva característica"""
	print("🎉 Feature desbloqueada en panel: ", feature_data["name"])
	_refresh_content()

	# Mostrar notificación visual (opcional)
	_show_unlock_celebration(feature_data)


func _on_progress_updated(feature_id: String, progress: Dictionary):
	"""Maneja actualizaciones de progreso hacia desbloqueos"""
	# Solo refrescar si el panel está visible para optimizar
	if is_visible_panel:
		_refresh_available_unlocks()


func _on_unlock_notification(unlock_data: Dictionary):
	"""Maneja notificaciones de desbloqueo"""
	print("🔔 Notificación de desbloqueo: ", unlock_data["message"])


func _show_unlock_celebration(feature_data: Dictionary):
	"""Muestra una celebración visual para un nuevo desbloqueo"""
	# TODO: Implementar animación de celebración
	# Por ahora solo un print
	print("🎊 CELEBRANDO: ", feature_data["name"], " - ", feature_data["notification"])


## === API PÚBLICAS ===


func show_panel():
	"""Muestra el panel de desbloqueos"""
	is_visible_panel = true
	visible = true
	_refresh_content()
	print("🔓 Panel de desbloqueos mostrado")


func hide_panel():
	"""Oculta el panel de desbloqueos"""
	is_visible_panel = false
	visible = false
	print("🔓 Panel de desbloqueos ocultado")


func toggle_panel():
	"""Alterna la visibilidad del panel"""
	if is_visible_panel:
		hide_panel()
	else:
		show_panel()
