extends Control
class_name AchievementItem

## Componente UI para mostrar un logro individual

# Referencias UI
@onready var icon_label: Label = $HBoxContainer/IconLabel
@onready var achievement_name: Label = $HBoxContainer/InfoContainer/NameLabel
@onready var description_label: Label = $HBoxContainer/InfoContainer/DescriptionLabel
@onready var progress_bar: ProgressBar = $HBoxContainer/InfoContainer/ProgressContainer/ProgressBar
@onready var progress_label: Label = $HBoxContainer/InfoContainer/ProgressContainer/ProgressLabel
@onready var reward_container: VBoxContainer = $HBoxContainer/RewardContainer
@onready var completed_icon: Label = $HBoxContainer/CompletedIcon
@onready var category_label: Label = $HBoxContainer/InfoContainer/CategoryLabel

# Datos del logro
var achievement_data: Dictionary


func setup_achievement(data: Dictionary):
	"""Configurar el item con datos de logro"""
	achievement_data = data
	_update_display()


func _update_display():
	"""Actualizar la visualización con los datos actuales"""
	if achievement_data.is_empty():
		return

	# Icono y nombre
	icon_label.text = achievement_data.get("icon", "🏆")
	achievement_name.text = achievement_data.get("name", "Logro")

	# Descripción
	description_label.text = achievement_data.get("description", "")

	# Categoría
	var category = achievement_data.get("category", "basic")
	var category_names = {
		"basic": "Básico", "progression": "Progresión", "advanced": "Avanzado", "secret": "Secreto"
	}
	category_label.text = "[" + category_names.get(category, "Básico") + "]"

	# Estado de completado
	var unlocked = achievement_data.get("unlocked", false)
	var progress = achievement_data.get("progress", 0.0)

	if unlocked:
		progress_bar.value = 100
		progress_label.text = "¡Desbloqueado!"
		progress_bar.modulate = Color.GOLD
		completed_icon.text = "🏆"
		completed_icon.show()
		modulate = Color.WHITE
	else:
		progress_bar.value = progress
		progress_label.text = "%.1f%%" % progress
		progress_bar.modulate = Color.GRAY
		completed_icon.hide()
		modulate = Color(0.8, 0.8, 0.8)  # Más opaco si no está desbloqueado

	# Recompensas
	_update_rewards()


func _update_rewards():
	"""Actualizar la visualización de recompensas"""
	# Limpiar recompensas anteriores
	for child in reward_container.get_children():
		child.queue_free()

	# Tokens
	var token_reward = achievement_data.get("token_reward", 0)
	if token_reward > 0:
		var token_label = Label.new()
		token_label.text = "🪙 %d" % token_reward
		reward_container.add_child(token_label)

	# Gemas
	var gem_reward = achievement_data.get("gem_reward", 0)
	if gem_reward > 0:
		var gem_label = Label.new()
		gem_label.text = "💎 %d" % gem_reward
		reward_container.add_child(gem_label)


func _ready():
	progress_bar.min_value = 0
	progress_bar.max_value = 100
