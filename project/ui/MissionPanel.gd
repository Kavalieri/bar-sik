extends Control

# 📋 MISSION PANEL UI - T030 Professional Mission System
# Interface visual profesional para el sistema de misiones diarias y semanales

signal mission_panel_closed
signal mission_tab_changed(tab_type: String)

@onready var main_container: VBoxContainer = $MainContainer
@onready var header_container: HBoxContainer = $MainContainer/HeaderContainer
@onready var title_label: Label = $MainContainer/HeaderContainer/TitleLabel
@onready var close_button: Button = $MainContainer/HeaderContainer/CloseButton
@onready var stats_label: Label = $MainContainer/HeaderContainer/StatsLabel

@onready var tab_container: HBoxContainer = $MainContainer/TabContainer
@onready var daily_tab: Button = $MainContainer/TabContainer/DailyTab
@onready var weekly_tab: Button = $MainContainer/TabContainer/WeeklyTab

@onready var content_scroll: ScrollContainer = $MainContainer/ContentScroll
@onready var mission_list: VBoxContainer = $MainContainer/ContentScroll/MissionList

@onready var footer_container: HBoxContainer = $MainContainer/FooterContainer
@onready var refresh_timer_label: Label = $MainContainer/FooterContainer/RefreshTimer
@onready var streak_label: Label = $MainContainer/FooterContainer/StreakLabel

# Referencias al sistema
@onready var mission_manager = get_node_or_null("/root/MissionManager")
@onready var game_controller = get_node_or_null("/root/GameController")

# Estado del panel
var current_tab: String = "daily"
var mission_items: Array = []
var refresh_timer: Timer

# Recursos para iconos (placeholder)
var mission_icons: Dictionary = {
	"👥": "res://gfx/missions/customers_icon.png",
	"🌾": "res://gfx/missions/resources_icon.png",
	"💰": "res://gfx/missions/money_icon.png",
	"🎯": "res://gfx/missions/offers_icon.png",
	"🍺": "res://gfx/missions/beer_icon.png",
	"⚙️": "res://gfx/missions/generators_icon.png",
	"💵": "res://gfx/missions/cash_icon.png",
	"🏭": "res://gfx/missions/stations_icon.png",
	"⭐": "res://gfx/missions/prestige_icon.png",
	"🤖": "res://gfx/missions/automation_icon.png",
	"🏆": "res://gfx/missions/achievement_icon.png",
	"👑": "res://gfx/missions/premium_icon.png",
	"💎": "res://gfx/missions/diamond_icon.png"
}

func _ready():
	_setup_ui()
	_connect_signals()
	_setup_refresh_timer()
	_load_missions()

# 🎨 UI SETUP
func _setup_ui():
	title_label.text = "📋 Misiones Diarias"

	# Setup tabs
	daily_tab.text = "Diarias"
	weekly_tab.text = "Semanales"

	# Style tabs
	_update_tab_styles()

func _connect_signals():
	# UI signals
	close_button.pressed.connect(_on_close_pressed)
	daily_tab.pressed.connect(func(): _switch_tab("daily"))
	weekly_tab.pressed.connect(func(): _switch_tab("weekly"))

	# Mission manager signals
	if mission_manager:
		if mission_manager.has_signal("mission_completed"):
			mission_manager.mission_completed.connect(_on_mission_completed)
		if mission_manager.has_signal("mission_progress_updated"):
			mission_manager.mission_progress_updated.connect(_on_mission_progress_updated)
		if mission_manager.has_signal("missions_refreshed"):
			mission_manager.missions_refreshed.connect(_on_missions_refreshed)

func _setup_refresh_timer():
	refresh_timer = Timer.new()
	refresh_timer.wait_time = 60.0  # Update every minute
	refresh_timer.timeout.connect(_update_timers)
	refresh_timer.autostart = true
	add_child(refresh_timer)

	_update_timers()

# 📋 MISSION LOADING
func _load_missions():
	if not mission_manager:
		print("⚠️ MissionManager no disponible")
		return

	_clear_mission_list()

	var missions: Array
	if current_tab == "daily":
		missions = mission_manager.get_daily_missions()
		title_label.text = "📋 Misiones Diarias"
	else:
		missions = mission_manager.get_weekly_missions()
		title_label.text = "📋 Misiones Semanales"

	for mission in missions:
		_create_mission_item(mission)

	_update_stats_display()

func _clear_mission_list():
	for child in mission_list.get_children():
		child.queue_free()
	mission_items.clear()

func _create_mission_item(mission_data: Dictionary) -> Control:
	# Main mission container
	var mission_item = PanelContainer.new()
	mission_item.custom_minimum_size = Vector2(400, 80)

	var mission_style = StyleBoxFlat.new()
	mission_style.bg_color = Color(0.2, 0.2, 0.25, 0.9)
	mission_style.border_width_left = 4
	mission_style.border_color = Color.GREEN if mission_data.completed else Color.ORANGE
	mission_item.add_theme_stylebox_override("panel", mission_style)

	# Main horizontal layout
	var hbox = HBoxContainer.new()
	mission_item.add_child(hbox)
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 12)

	# Icon
	var icon_label = Label.new()
	icon_label.text = mission_data.get("icon", "📋")
	icon_label.custom_minimum_size = Vector2(40, 40)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 24)
	hbox.add_child(icon_label)

	# Mission info container
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	# Mission title
	var title_label = Label.new()
	title_label.text = mission_data.get("name", "Mission")
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	info_vbox.add_child(title_label)

	# Mission description
	var desc_label = Label.new()
	desc_label.text = mission_data.get("description", "Complete objective")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_label)

	# Progress container
	var progress_hbox = HBoxContainer.new()
	info_vbox.add_child(progress_hbox)

	# Progress bar
	var progress_bar = ProgressBar.new()
	progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progress_bar.custom_minimum_size = Vector2(200, 20)
	progress_bar.max_value = mission_data.get("target", 100)
	progress_bar.value = mission_data.get("progress", 0)
	progress_hbox.add_child(progress_bar)

	# Progress text
	var progress_label = Label.new()
	var progress_text = "%d/%d" % [mission_data.get("progress", 0), mission_data.get("target", 100)]
	if mission_data.completed:
		progress_text = "✅ COMPLETADA"
	progress_label.text = progress_text
	progress_label.custom_minimum_size = Vector2(100, 20)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress_label.add_theme_font_size_override("font_size", 12)
	progress_hbox.add_child(progress_label)

	# Reward container
	var reward_vbox = VBoxContainer.new()
	reward_vbox.custom_minimum_size = Vector2(120, 60)
	hbox.add_child(reward_vbox)

	# Reward title
	var reward_title = Label.new()
	reward_title.text = "Recompensa:"
	reward_title.add_theme_font_size_override("font_size", 10)
	reward_title.add_theme_color_override("font_color", Color.GRAY)
	reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_vbox.add_child(reward_title)

	# Token reward
	if mission_data.get("token_reward", 0) > 0:
		var token_label = Label.new()
		token_label.text = "🪙 %d" % mission_data.token_reward
		token_label.add_theme_font_size_override("font_size", 12)
		token_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_vbox.add_child(token_label)

	# Gem reward (weekly missions)
	if mission_data.get("gem_reward", 0) > 0:
		var gem_label = Label.new()
		gem_label.text = "💎 %d" % mission_data.gem_reward
		gem_label.add_theme_font_size_override("font_size", 12)
		gem_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_vbox.add_child(gem_label)

	# Store references for updates
	mission_item.set_meta("mission_id", mission_data.get("id", ""))
	mission_item.set_meta("progress_bar", progress_bar)
	mission_item.set_meta("progress_label", progress_label)
	mission_item.set_meta("mission_style", mission_style)

	mission_list.add_child(mission_item)
	mission_items.append(mission_item)

	return mission_item

# 🔄 TAB SYSTEM
func _switch_tab(tab_type: String):
	if current_tab == tab_type:
		return

	current_tab = tab_type
	_update_tab_styles()
	_load_missions()
	mission_tab_changed.emit(tab_type)

func _update_tab_styles():
	# Reset tab styles
	for tab in [daily_tab, weekly_tab]:
		tab.modulate = Color.GRAY
		tab.flat = true

	# Highlight active tab
	var active_tab = daily_tab if current_tab == "daily" else weekly_tab
	active_tab.modulate = Color.WHITE
	active_tab.flat = false

# 📊 STATS UPDATE
func _update_stats_display():
	if not mission_manager:
		return

	var stats = mission_manager.get_mission_statistics()

	if current_tab == "daily":
		var daily_stats = stats.daily
		stats_label.text = "Completadas: %d/%d (%.0f%%)" % [daily_stats.completed, daily_stats.total, daily_stats.percentage]
	else:
		var weekly_stats = stats.weekly
		stats_label.text = "Completadas: %d/%d (%.0f%%)" % [weekly_stats.completed, weekly_stats.total, weekly_stats.percentage]

func _update_timers():
	if not mission_manager:
		return

	if current_tab == "daily":
		var time_data = mission_manager.get_time_until_reset()
		refresh_timer_label.text = "Reset en: %02d:%02d" % [time_data.hours, time_data.minutes]
	else:
		var time_data = mission_manager.get_time_until_weekly_reset()
		if time_data.days > 0:
			refresh_timer_label.text = "Reset en: %dd %02d:%02d" % [time_data.days, time_data.hours, time_data.minutes]
		else:
			refresh_timer_label.text = "Reset en: %02d:%02d" % [time_data.hours, time_data.minutes]

	# Update streak display
	var stats = mission_manager.get_mission_statistics()
	if current_tab == "daily":
		streak_label.text = "Racha: %d días" % stats.streaks.daily
	else:
		streak_label.text = "Racha: %d semanas" % stats.streaks.weekly

# 📡 EVENT HANDLERS
func _on_close_pressed():
	mission_panel_closed.emit()
	queue_free()

func _on_mission_completed(mission_id: String, mission_data: Dictionary):
	# Update mission item if visible
	for item in mission_items:
		if item.get_meta("mission_id", "") == mission_id:
			var progress_bar = item.get_meta("progress_bar")
			var progress_label = item.get_meta("progress_label")
			var mission_style = item.get_meta("mission_style")

			if progress_bar:
				progress_bar.value = progress_bar.max_value
			if progress_label:
				progress_label.text = "✅ COMPLETADA"
			if mission_style:
				mission_style.border_color = Color.GREEN

			break

	_update_stats_display()
	print("🎉 Misión completada en UI: ", mission_data.get("name", "Unknown"))

func _on_mission_progress_updated(mission_id: String, progress: int, total: int):
	# Update progress bar for specific mission
	for item in mission_items:
		if item.get_meta("mission_id", "") == mission_id:
			var progress_bar = item.get_meta("progress_bar")
			var progress_label = item.get_meta("progress_label")

			if progress_bar:
				progress_bar.value = progress
			if progress_label:
				progress_label.text = "%d/%d" % [progress, total]

			break

func _on_missions_refreshed(mission_type: String):
	if mission_type == current_tab:
		_load_missions()
		print("🔄 Misiones refrescadas: ", mission_type)

# 🔧 UTILITY FUNCTIONS
func refresh_current_tab():
	"""Refrescar el tab activo manualmente"""
	_load_missions()

func switch_to_daily_tab():
	"""Cambiar al tab de misiones diarias"""
	_switch_tab("daily")

func switch_to_weekly_tab():
	"""Cambiar al tab de misiones semanales"""
	_switch_tab("weekly")

func get_current_tab() -> String:
	"""Obtener el tab activo actual"""
	return current_tab

# 🎮 INPUT HANDLING
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		accept_event()
