extends Control
class_name MissionsPanel

## T019 - Missions & Achievements UI Panel
## Panel combinado para mostrar misiones diarias y logros del jugador

# Referencias a nodos UI
@onready var tab_container: TabContainer = $VBoxContainer/TabContainer
@onready var missions_tab: Control = $VBoxContainer/TabContainer/Misiones
@onready var achievements_tab: Control = $VBoxContainer/TabContainer/Logros

# Misiones
@onready
var missions_list: VBoxContainer = $VBoxContainer/TabContainer/Misiones/ScrollContainer/MissionsList
@onready
var mission_timer_label: Label = $VBoxContainer/TabContainer/Misiones/MissionTimerContainer/TimerLabel
@onready var missions_completed_label: Label = $VBoxContainer/TabContainer/Misiones/CompletedLabel

# Logros
@onready
var achievements_list: VBoxContainer = $VBoxContainer/TabContainer/Logros/ScrollContainer/AchievementsList
@onready
var achievements_filter: OptionButton = $VBoxContainer/TabContainer/Logros/FilterContainer/FilterOption
@onready var achievements_progress: Label = $VBoxContainer/TabContainer/Logros/ProgressLabel

# Control del panel
@onready var close_button: Button = $VBoxContainer/TopBar/CloseButton

# Managers
var mission_manager: MissionManager
var achievement_manager: AchievementManager

# Señales
signal panel_closed

# Scene templates para instanciar
const MISSION_ITEM_SCENE = preload("res://ui/components/MissionItem.tscn")
const ACHIEVEMENT_ITEM_SCENE = preload("res://ui/components/AchievementItem.tscn")

# Estado
var current_missions: Dictionary = {}
var current_achievements: Dictionary = {}
var filter_mode: String = "all"  # all, completed, pending


func _ready():
	print("🎮 MissionsPanel inicializado")

	# Conectar botón de cerrar
	close_button.pressed.connect(_on_close_pressed)

	# Configurar filtro de logros
	achievements_filter.add_item("Todos los logros", 0)
	achievements_filter.add_item("Completados", 1)
	achievements_filter.add_item("Pendientes", 2)
	achievements_filter.item_selected.connect(_on_filter_changed)

	# Timer para actualizar UI cada segundo
	var update_timer = Timer.new()
	update_timer.wait_time = 1.0
	update_timer.timeout.connect(_update_mission_timer)
	update_timer.autostart = true
	add_child(update_timer)


func setup_managers(mission_mgr: MissionManager, achievement_mgr: AchievementManager):
	"""Configurar referencias a los managers"""
	mission_manager = mission_mgr
	achievement_manager = achievement_mgr

	# Conectar señales de los managers
	if mission_manager:
		mission_manager.mission_completed.connect(_on_mission_completed)
		mission_manager.mission_progress_updated.connect(_on_mission_progress_updated)
		mission_manager.daily_missions_reset.connect(_on_missions_reset)

	if achievement_manager:
		achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)

	# Cargar datos iniciales
	_refresh_all_data()


func _refresh_all_data():
	"""Actualizar todos los datos de misiones y logros"""
	_refresh_missions()
	_refresh_achievements()


func _refresh_missions():
	"""Actualizar la lista de misiones"""
	if not mission_manager:
		return

	# Obtener misiones activas
	current_missions = mission_manager.get_active_missions()

	# Limpiar lista anterior
	_clear_missions_list()

	# Crear items para cada misión
	for mission_id in current_missions:
		var mission_data = current_missions[mission_id]
		_create_mission_item(mission_data)

	# Actualizar estadísticas
	var completed_count = mission_manager.get_completed_missions_today()
	var total_count = current_missions.size()
	missions_completed_label.text = "Completadas hoy: %d/%d" % [completed_count, total_count]


func _clear_missions_list():
	"""Limpiar la lista de misiones"""
	for child in missions_list.get_children():
		child.queue_free()


func _create_mission_item(mission_data: Dictionary):
	"""Crear un item de misión en la UI"""
	var mission_item = MISSION_ITEM_SCENE.instantiate()
	missions_list.add_child(mission_item)

	# Configurar el item
	mission_item.setup_mission(mission_data)


func _refresh_achievements():
	"""Actualizar la lista de logros"""
	if not achievement_manager:
		return

	# Obtener logros según filtro
	current_achievements = achievement_manager.get_filtered_achievements(filter_mode)

	# Limpiar lista anterior
	_clear_achievements_list()

	# Crear items para cada logro
	for achievement_id in current_achievements:
		var achievement_data = current_achievements[achievement_id]
		_create_achievement_item(achievement_data)

	# Actualizar estadísticas de progreso
	var total_achievements = achievement_manager.get_total_achievements()
	var unlocked_count = achievement_manager.get_unlocked_count()
	var progress_percent = (float(unlocked_count) / float(total_achievements)) * 100.0

	achievements_progress.text = (
		"Progreso: %d/%d logros (%.1f%%)" % [unlocked_count, total_achievements, progress_percent]
	)


func _clear_achievements_list():
	"""Limpiar la lista de logros"""
	for child in achievements_list.get_children():
		child.queue_free()


func _create_achievement_item(achievement_data: Dictionary):
	"""Crear un item de logro en la UI"""
	var achievement_item = ACHIEVEMENT_ITEM_SCENE.instantiate()
	achievements_list.add_child(achievement_item)

	# Configurar el item
	achievement_item.setup_achievement(achievement_data)


func _update_mission_timer():
	"""Actualizar el timer de reset de misiones"""
	if not mission_manager:
		return

	var time_info = mission_manager.get_time_until_reset()
	var hours = time_info.hours
	var minutes = time_info.minutes

	if hours > 0:
		mission_timer_label.text = "Nuevas misiones en: %dh %dm" % [hours, minutes]
	else:
		mission_timer_label.text = "Nuevas misiones en: %dm" % minutes


# Signal handlers
func _on_close_pressed():
	"""Cerrar el panel"""
	hide()
	panel_closed.emit()


func _on_filter_changed(index: int):
	"""Cambiar filtro de logros"""
	match index:
		0:
			filter_mode = "all"
		1:
			filter_mode = "completed"
		2:
			filter_mode = "pending"

	_refresh_achievements()


func _on_mission_completed(_mission_id: String, _mission_data: Dictionary):
	"""Actualizar UI cuando se completa una misión"""
	_refresh_missions()


func _on_mission_progress_updated(_mission_id: String, _progress: int, _total: int):
	"""Actualizar UI cuando cambia progreso de misión"""
	# Las barras de progreso se actualizan automáticamente vía sus items
	pass


func _on_missions_reset():
	"""Actualizar UI cuando se resetean las misiones"""
	_refresh_missions()


func _on_achievement_unlocked(_achievement_id: String, _achievement_data: Dictionary):
	"""Actualizar UI cuando se desbloquea un logro"""
	_refresh_achievements()


# Funciones públicas para controlar el panel
func show_panel():
	"""Mostrar el panel y actualizar datos"""
	show()
	_refresh_all_data()


func hide_panel():
	"""Ocultar el panel"""
	hide()


func show_missions_tab():
	"""Mostrar directamente el tab de misiones"""
	tab_container.current_tab = 0
	show_panel()


func show_achievements_tab():
	"""Mostrar directamente el tab de logros"""
	tab_container.current_tab = 1
	show_panel()


# Funciones de utilidad para debugging
func _print_debug_info():
	"""Imprimir información de debug"""
	print("🎮 MissionsPanel Debug Info:")
	print("  - Misiones activas: %d" % current_missions.size())
	print("  - Logros mostrados: %d" % current_achievements.size())
	print("  - Filtro actual: %s" % filter_mode)
