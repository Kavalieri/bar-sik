extends Control

# 🏆 ACHIEVEMENT PANEL UI
# Interface visual profesional para el sistema de achievements
# Compatible con el sistema modular de UI de Bar-Sik

signal achievement_panel_closed
signal achievement_category_changed(category: int)

@onready var main_container: VBoxContainer = $MainContainer
@onready var header_container: HBoxContainer = $MainContainer/HeaderContainer
@onready var title_label: Label = $MainContainer/HeaderContainer/TitleLabel
@onready var close_button: Button = $MainContainer/HeaderContainer/CloseButton
@onready var progress_label: Label = $MainContainer/HeaderContainer/ProgressLabel

@onready var category_tabs: HBoxContainer = $MainContainer/CategoryTabs
@onready var content_scroll: ScrollContainer = $MainContainer/ContentScroll
@onready var achievement_list: VBoxContainer = $MainContainer/ContentScroll/AchievementList

@onready var notification_container: Control = $NotificationContainer
@onready var notification_panel: PanelContainer = $NotificationContainer/NotificationPanel
@onready var notification_title: Label = $NotificationContainer/NotificationPanel/VBox/TitleLabel
@onready var notification_desc: Label = $NotificationContainer/NotificationPanel/VBox/DescLabel
@onready var notification_reward: Label = $NotificationContainer/NotificationPanel/VBox/RewardLabel

# Referencias al sistema
@onready var achievement_manager = get_node("/root/AchievementManager")

# Estado del panel
var current_category: AchievementManager.AchievementCategory = AchievementManager.AchievementCategory.PRODUCTION
var achievement_items: Array = []
var category_buttons: Array[Button] = []

# Recursos para iconos (placeholder)
var achievement_icons: Dictionary = {
	"beer_icon": "🍺",
	"factory_icon": "🏭",
	"industry_icon": "🏗️",
	"mega_icon": "⭐",
	"crown_icon": "👑",
	"money_icon": "💰",
	"shop_icon": "🏪",
	"bar_icon": "🍻",
	"diamond_icon": "💎",
	"gold_icon": "🏅",
	"planet_icon": "🌍",
	"token_icon": "🪙",
	"legend_icon": "🏆",
	"gem_icon": "💎",
	"whale_icon": "🐋",
	"star_icon": "⭐",
	"veteran_icon": "🎖️",
	"master_icon": "👑",
	"mythic_icon": "🔮",
	"constellation_icon": "✨",
	"galaxy_icon": "🌌",
	"universe_icon": "🌟",
	"speed_icon": "⚡",
	"auto_icon": "🤖",
	"robot_icon": "🦾",
	"ai_icon": "🧠",
	"efficiency_icon": "⚙️",
	"key_icon": "🔑",
	"ascend_icon": "🚀",
	"sunrise_icon": "🌅",
	"moon_icon": "🌙",
	"calendar_icon": "📅",
	"perfect_icon": "💯",
	"compass_icon": "🧭",
	"hunter_icon": "🎯",
	"complete_icon": "✅"
}

func _ready():
	name = "AchievementPanel"
	_setup_ui()
	_connect_signals()
	_create_category_tabs()
	_load_achievements()

	# Hide notification initially
	notification_container.visible = false

func _setup_ui():
	# Configure main panel
	custom_minimum_size = Vector2(800, 600)

	# Header setup
	title_label.text = "🏆 LOGROS"
	close_button.text = "✖"

	# Style the panel
	add_theme_stylebox_override("panel", _create_panel_style())

func _create_panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.GOLD
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

func _connect_signals():
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

	if achievement_manager:
		achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)
		achievement_manager.achievement_progress_updated.connect(_on_progress_updated)
		achievement_manager.achievement_notification.connect(_show_achievement_notification)

func _create_category_tabs():
	var categories = [
		{"id": AchievementManager.AchievementCategory.PRODUCTION, "name": "📊 Producción", "color": Color.CYAN},
		{"id": AchievementManager.AchievementCategory.ECONOMIC, "name": "💰 Económicos", "color": Color.GOLD},
		{"id": AchievementManager.AchievementCategory.META, "name": "⭐ Meta", "color": Color.MAGENTA},
		{"id": AchievementManager.AchievementCategory.AUTOMATION, "name": "🤖 Automation", "color": Color.GREEN},
		{"id": AchievementManager.AchievementCategory.PROGRESSION, "name": "📈 Progreso", "color": Color.ORANGE},
		{"id": AchievementManager.AchievementCategory.SPECIAL, "name": "🎁 Especiales", "color": Color.PURPLE},
		{"id": AchievementManager.AchievementCategory.COLLECTION, "name": "🎯 Colección", "color": Color.YELLOW}
	]

	for category_data in categories:
		var button = Button.new()
		button.text = category_data["name"]
		button.toggle_mode = true
		button.button_group = ButtonGroup.new() if category_buttons.is_empty() else category_buttons[0].button_group

		# Style the button
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color(0.2, 0.2, 0.2, 0.8)
		style_normal.corner_radius_top_left = 5
		style_normal.corner_radius_top_right = 5
		style_normal.corner_radius_bottom_left = 5
		style_normal.corner_radius_bottom_right = 5

		var style_pressed = StyleBoxFlat.new()
		style_pressed.bg_color = category_data["color"] * 0.7
		style_pressed.corner_radius_top_left = 5
		style_pressed.corner_radius_top_right = 5
		style_pressed.corner_radius_bottom_left = 5
		style_pressed.corner_radius_bottom_right = 5

		button.add_theme_stylebox_override("normal", style_normal)
		button.add_theme_stylebox_override("pressed", style_pressed)

		button.pressed.connect(_on_category_selected.bind(category_data["id"]))

		category_tabs.add_child(button)
		category_buttons.append(button)

	# Select first category by default
	if not category_buttons.is_empty():
		category_buttons[0].button_pressed = true

func _load_achievements():
	_refresh_achievement_display()
	_update_progress_display()

func _refresh_achievement_display():
	# Clear existing items
	for child in achievement_list.get_children():
		child.queue_free()
	achievement_items.clear()

	if not achievement_manager:
		return

	# Get achievements for current category
	var achievements = achievement_manager.get_achievements_by_category(current_category)

	# Sort achievements: unlocked first, then by progress
	achievements.sort_custom(_sort_achievements)

	# Create UI items for each achievement
	for achievement_data in achievements:
		if achievement_data.get("hidden", false) and not achievement_data.get("unlocked", false):
			continue  # Skip hidden achievements that aren't unlocked

		var item = _create_achievement_item(achievement_data)
		achievement_list.add_child(item)
		achievement_items.append(item)

func _sort_achievements(a: Dictionary, b: Dictionary) -> bool:
	# Unlocked achievements first
	if a.get("unlocked", false) != b.get("unlocked", false):
		return a.get("unlocked", false)

	# Then by progress percentage
	var progress_a = a.get("progress", 0.0) / a.get("required", 1.0)
	var progress_b = b.get("progress", 0.0) / b.get("required", 1.0)
	return progress_a > progress_b

func _create_achievement_item(achievement_data: Dictionary) -> PanelContainer:
	var item = PanelContainer.new()
	item.custom_minimum_size = Vector2(0, 80)

	# Create background style
	var is_unlocked = achievement_data.get("unlocked", false)
	var bg_color = Color.GREEN * 0.3 if is_unlocked else Color.GRAY * 0.3
	var border_color = Color.GOLD if is_unlocked else Color.WHITE

	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	item.add_theme_stylebox_override("panel", style)

	# Main container
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 80)
	item.add_child(hbox)

	# Icon
	var icon_label = Label.new()
	icon_label.text = achievement_icons.get(achievement_data.get("icon", ""), "🏆")
	icon_label.custom_minimum_size = Vector2(60, 0)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 32)
	hbox.add_child(icon_label)

	# Content area
	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(content_vbox)

	# Title
	var title_label = Label.new()
	title_label.text = achievement_data.get("title", "Achievement")
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.modulate = Color.GOLD if is_unlocked else Color.WHITE
	content_vbox.add_child(title_label)

	# Description
	var desc_label = Label.new()
	desc_label.text = achievement_data.get("description", "")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.modulate = Color.LIGHT_GRAY
	content_vbox.add_child(desc_label)

	# Progress bar and text
	if not is_unlocked:
		var progress_container = HBoxContainer.new()
		content_vbox.add_child(progress_container)

		var progress_bar = ProgressBar.new()
		progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		progress_bar.custom_minimum_size = Vector2(200, 20)

		var current = achievement_data.get("progress", 0.0)
		var required = achievement_data.get("required", 1.0)
		progress_bar.max_value = required
		progress_bar.value = current

		progress_container.add_child(progress_bar)

		var progress_text = Label.new()
		progress_text.text = "%s / %s" % [_format_number(current), _format_number(required)]
		progress_text.add_theme_font_size_override("font_size", 10)
		progress_text.custom_minimum_size = Vector2(100, 0)
		progress_container.add_child(progress_text)
	else:
		var unlocked_label = Label.new()
		unlocked_label.text = "✅ DESBLOQUEADO"
		unlocked_label.add_theme_font_size_override("font_size", 12)
		unlocked_label.modulate = Color.GREEN
		content_vbox.add_child(unlocked_label)

	# Rewards section
	var rewards_container = HBoxContainer.new()
	content_vbox.add_child(rewards_container)

	var gems = achievement_data.get("reward_gems", 0)
	var tokens = achievement_data.get("reward_tokens", 0)
	var multiplier = achievement_data.get("reward_multiplier", 1.0)

	if gems > 0:
		var gem_label = Label.new()
		gem_label.text = "💎 %d" % gems
		gem_label.add_theme_font_size_override("font_size", 10)
		gem_label.modulate = Color.CYAN
		rewards_container.add_child(gem_label)

	if tokens > 0:
		var token_label = Label.new()
		token_label.text = "🪙 %d" % tokens
		token_label.add_theme_font_size_override("font_size", 10)
		token_label.modulate = Color.YELLOW
		rewards_container.add_child(token_label)

	if multiplier > 1.0:
		var mult_label = Label.new()
		mult_label.text = "🚀 +%.0f%%" % ((multiplier - 1.0) * 100)
		mult_label.add_theme_font_size_override("font_size", 10)
		mult_label.modulate = Color.MAGENTA
		rewards_container.add_child(mult_label)

	return item

func _format_number(number: float) -> String:
	if number >= 1000000:
		return "%.1fM" % (number / 1000000.0)
	elif number >= 1000:
		return "%.1fK" % (number / 1000.0)
	else:
		return "%.0f" % number

func _update_progress_display():
	if not achievement_manager:
		return

	var progress = achievement_manager.get_total_progress()
	progress_label.text = "Progreso: %d/%d (%.1f%%)" % [
		progress["completed"],
		progress["total"],
		progress["percentage"]
	]

func _on_category_selected(category: AchievementManager.AchievementCategory):
	current_category = category
	_refresh_achievement_display()
	achievement_category_changed.emit(category)

func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary):
	_refresh_achievement_display()
	_update_progress_display()

func _on_progress_updated(achievement_id: String, current: float, required: float):
	# Update progress bars in real-time
	_refresh_achievement_display()  # Simple refresh for now

func _show_achievement_notification(achievement_data: Dictionary):
	if not notification_container:
		return

	notification_title.text = "🏆 " + achievement_data.get("title", "Achievement Unlocked!")
	notification_desc.text = achievement_data.get("description", "")

	var rewards = []
	if achievement_data.get("reward_gems", 0) > 0:
		rewards.append("💎 %d Gemas" % achievement_data["reward_gems"])
	if achievement_data.get("reward_tokens", 0) > 0:
		rewards.append("🪙 %d Tokens" % achievement_data["reward_tokens"])
	if achievement_data.get("reward_multiplier", 1.0) > 1.0:
		rewards.append("🚀 +%.0f%% Multiplicador" % ((achievement_data["reward_multiplier"] - 1.0) * 100))

	notification_reward.text = "Recompensas: " + ", ".join(rewards) if rewards.size() > 0 else ""

	# Show notification with animation
	notification_container.visible = true
	notification_container.modulate = Color.TRANSPARENT

	var tween = create_tween()
	tween.tween_property(notification_container, "modulate", Color.WHITE, 0.3)
	tween.tween_delay(3.0)
	tween.tween_property(notification_container, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(func(): notification_container.visible = false)

func _on_close_button_pressed():
	achievement_panel_closed.emit()
	visible = false

# API pública
func show_panel():
	visible = true
	_refresh_achievement_display()
	_update_progress_display()

func hide_panel():
	visible = false

func set_category(category: AchievementManager.AchievementCategory):
	current_category = category
	_refresh_achievement_display()

	# Update button state
	if category < category_buttons.size():
		category_buttons[category].button_pressed = true
