class_name ContractPanel
extends Panel

## T036 - Panel de Sistema de Contratos
## UI para mostrar y gestionar timed challenges con rewards especiales

# Referencias
var contract_manager: ContractManager
var tab_container: TabContainer

# Elementos UI
var available_tab: Control
var active_tab: Control
var completed_tab: Control

# Contenedores
var available_container: VBoxContainer
var active_container: VBoxContainer
var completed_container: VBoxContainer

# Elementos de información
var summary_label: Label
var timer_label: Label

# Datos de UI
var contract_cards: Dictionary = {}
var update_timer: Timer

# Constantes UI
const DIFFICULTY_COLORS = {
	"normal": Color.GREEN,
	"hard": Color.ORANGE,
	"expert": Color.RED,
	"legendary": Color.PURPLE
}

func _ready():
	print("📋 ContractPanel inicializado (T036)")
	_create_ui_structure()
	_setup_update_timer()


func _create_ui_structure():
	"""Crea la estructura completa de la UI de contratos"""

	# Panel principal
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Contenedor principal
	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 10)

	# Header
	_create_header(main_vbox)

	# TabContainer para diferentes vistas
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(tab_container)

	# Crear tabs
	_create_available_tab()
	_create_active_tab()
	_create_completed_tab()


func _create_header(parent: Control):
	"""Crea el header con información general"""
	var header_vbox = VBoxContainer.new()
	parent.add_child(header_vbox)
	header_vbox.add_theme_constant_override("separation", 5)

	# Título
	var title = Label.new()
	title.text = "📋 SISTEMA DE CONTRATOS"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_vbox.add_child(title)

	# Información resumida
	summary_label = Label.new()
	summary_label.text = "Cargando información..."
	summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary_label.add_theme_font_size_override("font_size", 14)
	header_vbox.add_child(summary_label)

	# Timer para próximo contrato
	timer_label = Label.new()
	timer_label.text = "Próximo contrato en: --:--"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 12)
	header_vbox.add_child(timer_label)


func _create_available_tab():
	"""Crea el tab de contratos disponibles"""
	available_tab = ScrollContainer.new()
	available_tab.name = "📋 Disponibles"
	tab_container.add_child(available_tab)

	available_container = VBoxContainer.new()
	available_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	available_container.add_theme_constant_override("separation", 10)
	available_tab.add_child(available_container)

	# Mensaje inicial
	var info_label = Label.new()
	info_label.text = "Los contratos aparecerán aquí cuando estén disponibles.\n¡Completa desafíos para obtener recompensas especiales!"
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	available_container.add_child(info_label)


func _create_active_tab():
	"""Crea el tab de contratos activos"""
	active_tab = ScrollContainer.new()
	active_tab.name = "⏳ Activos"
	tab_container.add_child(active_tab)

	active_container = VBoxContainer.new()
	active_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_container.add_theme_constant_override("separation", 10)
	active_tab.add_child(active_container)


func _create_completed_tab():
	"""Crea el tab de contratos completados"""
	completed_tab = ScrollContainer.new()
	completed_tab.name = "✅ Completados"
	tab_container.add_child(completed_tab)

	completed_container = VBoxContainer.new()
	completed_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	completed_container.add_theme_constant_override("separation", 10)
	completed_tab.add_child(completed_container)


func _create_contract_card(contract_id: String, contract_data: Dictionary, is_active: bool = false) -> Control:
	"""Crea una tarjeta visual para un contrato"""

	# Panel principal de la tarjeta
	var card_panel = Panel.new()
	card_panel.custom_minimum_size = Vector2(0, 120)

	# Contenedor principal
	var card_hbox = HBoxContainer.new()
	card_panel.add_child(card_hbox)
	card_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_hbox.add_theme_constant_override("separation", 15)

	# Icono y dificultad
	var icon_vbox = VBoxContainer.new()
	icon_vbox.custom_minimum_size = Vector2(80, 0)
	card_hbox.add_child(icon_vbox)

	var icon_label = Label.new()
	icon_label.text = contract_data.get("icon", "📋")
	icon_label.add_theme_font_size_override("font_size", 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_vbox.add_child(icon_label)

	var difficulty_label = Label.new()
	var difficulty = contract_data.get("difficulty", "normal")
	difficulty_label.text = difficulty.to_upper()
	difficulty_label.add_theme_font_size_override("font_size", 10)
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty_label.modulate = DIFFICULTY_COLORS.get(difficulty, Color.WHITE)
	icon_vbox.add_child(difficulty_label)

	# Información del contrato
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_hbox.add_child(info_vbox)

	# Nombre del contrato
	var name_label = Label.new()
	name_label.text = contract_data.get("name", "Contrato")
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)

	# Descripción
	var desc_label = Label.new()
	desc_label.text = contract_data.get("description", "Sin descripción")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_label)

	# Tiempo restante (solo para activos)
	if is_active:
		var time_label = Label.new()
		var deadline = contract_data.get("deadline", 0)
		var remaining = max(0, deadline - Time.get_unix_time_from_system())
		time_label.text = "⏰ Tiempo restante: %s" % _format_time(remaining)
		time_label.add_theme_font_size_override("font_size", 11)
		time_label.modulate = Color.ORANGE
		info_vbox.add_child(time_label)

		# Barra de progreso
		var progress_bar = ProgressBar.new()
		progress_bar.max_value = 1.0
		progress_bar.value = contract_data.get("progress", 0.0)
		progress_bar.show_percentage = true
		info_vbox.add_child(progress_bar)
	else:
		# Tiempo límite para completar
		var time_limit_label = Label.new()
		time_limit_label.text = "⏱️ Duración: %s" % _format_time(contract_data.get("time_limit", 0))
		time_limit_label.add_theme_font_size_override("font_size", 11)
		info_vbox.add_child(time_limit_label)

	# Recompensas
	var rewards_hbox = HBoxContainer.new()
	info_vbox.add_child(rewards_hbox)

	var rewards_label = Label.new()
	rewards_label.text = "🎁 "
	rewards_label.add_theme_font_size_override("font_size", 11)
	rewards_hbox.add_child(rewards_label)

	var rewards = contract_data.get("rewards", {})
	var rewards_text = []
	for reward_type in rewards:
		var amount = rewards[reward_type]
		var icon = _get_reward_icon(reward_type)
		rewards_text.append("%s%s" % [icon, amount])

	var rewards_value_label = Label.new()
	rewards_value_label.text = " | ".join(rewards_text)
	rewards_value_label.add_theme_font_size_override("font_size", 11)
	rewards_hbox.add_child(rewards_value_label)

	# Botón de acción (solo para disponibles)
	if not is_active and contract_data.get("generated_time", 0) > 0:
		var action_button = Button.new()
		action_button.text = "ACEPTAR"
		action_button.custom_minimum_size = Vector2(100, 0)
		action_button.pressed.connect(_on_accept_contract.bind(contract_id))
		card_hbox.add_child(action_button)

	return card_panel


func _get_reward_icon(reward_type: String) -> String:
	"""Obtiene el icono para un tipo de recompensa"""
	match reward_type:
		"money": return "💰"
		"tokens": return "🪙"
		"gems": return "💎"
		"experience": return "⭐"
		"research_points": return "🔬"
		"prestige_stars": return "🌟"
		_: return "🎁"


func _format_time(seconds: int) -> String:
	"""Formatea tiempo en formato legible"""
	if seconds >= 3600:
		var hours = seconds / 3600
		var mins = (seconds % 3600) / 60
		return "%dh %dm" % [hours, mins]
	elif seconds >= 60:
		return "%dm %ds" % [seconds / 60, seconds % 60]
	else:
		return "%ds" % seconds


func _on_accept_contract(contract_id: String):
	"""Maneja la aceptación de un contrato"""
	if contract_manager:
		var success = contract_manager.accept_contract(contract_id)
		if success:
			_refresh_all_tabs()
			print("✅ Contrato aceptado exitosamente")
		else:
			print("❌ No se pudo aceptar el contrato")


func _refresh_all_tabs():
	"""Actualiza todas las tabs con la información actual"""
	if not contract_manager:
		return

	_refresh_available_contracts()
	_refresh_active_contracts()
	_refresh_completed_contracts()
	_update_summary_info()


func _refresh_available_contracts():
	"""Actualiza la lista de contratos disponibles"""
	# Limpiar contenido existente
	for child in available_container.get_children():
		if child != available_container.get_child(0):  # Mantener mensaje inicial
			child.queue_free()

	var available_contracts = contract_manager.get_available_contracts()

	if available_contracts.is_empty():
		available_container.get_child(0).visible = true
	else:
		available_container.get_child(0).visible = false

		for contract_id in available_contracts:
			var contract_data = available_contracts[contract_id]
			var card = _create_contract_card(contract_id, contract_data, false)
			available_container.add_child(card)
			contract_cards[contract_id] = card


func _refresh_active_contracts():
	"""Actualiza la lista de contratos activos"""
	# Limpiar contenido existente
	for child in active_container.get_children():
		child.queue_free()

	var active_contracts = contract_manager.get_active_contracts()

	if active_contracts.is_empty():
		var no_active_label = Label.new()
		no_active_label.text = "No hay contratos activos.\n¡Acepta un contrato disponible para comenzar!"
		no_active_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		no_active_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		active_container.add_child(no_active_label)
	else:
		for contract_id in active_contracts:
			var contract_data = active_contracts[contract_id]
			var card = _create_contract_card(contract_id, contract_data, true)
			active_container.add_child(card)
			contract_cards[contract_id] = card


func _refresh_completed_contracts():
	"""Actualiza la lista de contratos completados (resumen)"""
	# Limpiar contenido existente
	for child in completed_container.get_children():
		child.queue_free()

	var completed_count = contract_manager.get_completed_contracts_count()

	var completed_info = VBoxContainer.new()
	completed_container.add_child(completed_info)

	var title_label = Label.new()
	title_label.text = "📊 HISTORIAL DE CONTRATOS"
	title_label.add_theme_font_size_override("font_size", 18)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	completed_info.add_child(title_label)

	var stats_label = Label.new()
	stats_label.text = "Contratos completados: %d" % completed_count
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	completed_info.add_child(stats_label)

	# Aquí se podría agregar estadísticas más detalladas
	var achievements_label = Label.new()
	achievements_label.text = _get_contract_achievements_text(completed_count)
	achievements_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achievements_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	completed_info.add_child(achievements_label)


func _get_contract_achievements_text(completed_count: int) -> String:
	"""Genera texto de logros basado en contratos completados"""
	if completed_count == 0:
		return "🎯 ¡Completa tu primer contrato para desbloquear logros!"
	elif completed_count < 5:
		return "🥉 Contratista Novato - Completa 5 contratos para el siguiente nivel"
	elif completed_count < 15:
		return "🥈 Contratista Experimentado - Completa 15 contratos para el siguiente nivel"
	elif completed_count < 30:
		return "🥇 Contratista Experto - Completa 30 contratos para el siguiente nivel"
	else:
		return "👑 Maestro Contratista - ¡Has dominado el sistema de contratos!"


func _update_summary_info():
	"""Actualiza la información resumida en el header"""
	if not contract_manager:
		return

	var progress = contract_manager.get_contract_progress_summary()

	summary_label.text = "📊 Disponibles: %d | Activos: %d | Completados: %d" % [
		progress["available"],
		progress["active"],
		progress["completed"]
	]

	var next_in = progress["next_generation_in"]
	timer_label.text = "⏰ Próximo contrato en: %s" % _format_time(next_in)


func _setup_update_timer():
	"""Configura timer para actualizar la UI"""
	update_timer = Timer.new()
	update_timer.wait_time = 5.0  # Actualizar cada 5 segundos
	update_timer.timeout.connect(_refresh_all_tabs)
	update_timer.autostart = true
	add_child(update_timer)


## === MANEJO DE SEÑALES ===

func _on_contract_available(contract_id: String, contract_data: Dictionary):
	"""Maneja cuando un nuevo contrato está disponible"""
	print("📋 Nuevo contrato disponible: %s" % contract_data["name"])
	_refresh_available_contracts()
	_update_summary_info()

	# Mostrar notificación
	_show_contract_notification("¡Nuevo contrato disponible!", contract_data["name"])


func _on_contract_accepted(contract_id: String):
	"""Maneja cuando se acepta un contrato"""
	_refresh_all_tabs()


func _on_contract_progress_updated(contract_id: String, progress: float):
	"""Maneja actualización de progreso de contrato"""
	# Actualizar barra de progreso en tiempo real si está visible
	if contract_cards.has(contract_id):
		# Buscar y actualizar la barra de progreso en la tarjeta
		_update_contract_card_progress(contract_id, progress)


func _on_contract_completed(contract_id: String, rewards: Dictionary):
	"""Maneja cuando se completa un contrato"""
	print("🎉 ¡Contrato completado!")
	_refresh_all_tabs()

	# Mostrar notificación de recompensas
	var rewards_text = []
	for reward_type in rewards:
		var amount = rewards[reward_type]
		var icon = _get_reward_icon(reward_type)
		rewards_text.append("%s %s" % [icon, amount])

	_show_contract_notification("¡Contrato completado!", "Recompensas: " + ", ".join(rewards_text))


func _on_contract_expired(contract_id: String):
	"""Maneja cuando expira un contrato"""
	print("⏰ Contrato expirado")
	_refresh_all_tabs()


func _update_contract_card_progress(contract_id: String, progress: float):
	"""Actualiza la barra de progreso de una tarjeta específica"""
	# Esta función buscaría la barra de progreso en la tarjeta y la actualizaría
	# Por simplicidad, actualizaremos toda la tab activa
	_refresh_active_contracts()


func _show_contract_notification(title: String, message: String):
	"""Muestra una notificación de contrato"""
	print("🔔 %s: %s" % [title, message])
	# Aquí se podría implementar una notificación visual en la UI


## === API PÚBLICAS ===

func set_contract_manager(manager: ContractManager):
	"""Conecta con el ContractManager"""
	contract_manager = manager
	if contract_manager:
		# Conectar señales
		contract_manager.contract_available.connect(_on_contract_available)
		contract_manager.contract_accepted.connect(_on_contract_accepted)
		contract_manager.contract_progress_updated.connect(_on_contract_progress_updated)
		contract_manager.contract_completed.connect(_on_contract_completed)
		contract_manager.contract_expired.connect(_on_contract_expired)

		# Cargar datos iniciales
		_refresh_all_tabs()


func show_contract_details(contract_id: String):
	"""Muestra detalles completos de un contrato"""
	var contract_info = contract_manager.get_contract_info(contract_id)
	if contract_info.is_empty():
		return

	var details = """
📋 %s

📝 %s

⏱️ Duración: %s
🎯 Dificultad: %s

🎁 Recompensas:
""" % [
	contract_info["name"],
	contract_info["description"],
	_format_time(contract_info.get("time_limit", 0)),
	contract_info.get("difficulty", "normal").capitalize()
]

	var rewards = contract_info.get("rewards", {})
	for reward_type in rewards:
		var amount = rewards[reward_type]
		var icon = _get_reward_icon(reward_type)
		details += "   • %s %s %s\n" % [icon, amount, reward_type.replace("_", " ").capitalize()]

	print(details)


func force_refresh():
	"""Fuerza actualización de toda la UI (debug/testing)"""
	_refresh_all_tabs()
