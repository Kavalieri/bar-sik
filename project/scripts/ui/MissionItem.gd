extends Control
class_name MissionItem

## Componente UI para mostrar una misión individual

# Referencias UI
@onready var icon_label: Label = $HBoxContainer/IconLabel
@onready var mission_name: Label = $HBoxContainer/InfoContainer/NameLabel
@onready var description_label: Label = $HBoxContainer/InfoContainer/DescriptionLabel
@onready var progress_bar: ProgressBar = $HBoxContainer/InfoContainer/ProgressContainer/ProgressBar
@onready var progress_label: Label = $HBoxContainer/InfoContainer/ProgressContainer/ProgressLabel
@onready var reward_label: Label = $HBoxContainer/RewardContainer/RewardLabel
@onready var completed_icon: Label = $HBoxContainer/CompletedIcon

# Datos de la misión
var mission_data: Dictionary


func setup_mission(data: Dictionary):
	"""Configurar el item con datos de misión"""
	mission_data = data
	_update_display()


func _update_display():
	"""Actualizar la visualización con los datos actuales"""
	if mission_data.is_empty():
		return

	# Icono y nombre
	icon_label.text = mission_data.get("icon", "📋")
	mission_name.text = mission_data.get("name", "Misión")

	# Descripción
	description_label.text = mission_data.get("description", "")

	# Progreso
	var progress = mission_data.get("progress", 0)
	var target = mission_data.get("target", 1)
	var completed = mission_data.get("completed", false)

	progress_bar.min_value = 0
	progress_bar.max_value = target
	progress_bar.value = progress

	if completed:
		progress_label.text = "¡Completada!"
		progress_bar.modulate = Color.GREEN
		completed_icon.text = "✅"
		completed_icon.show()
	else:
		progress_label.text = "%d/%d" % [progress, target]
		progress_bar.modulate = Color.WHITE
		completed_icon.hide()

	# Recompensa
	var reward = mission_data.get("token_reward", 0)
	reward_label.text = "🪙 %d tokens" % reward


func _ready():
	# Actualizar cada segundo por si cambia el progreso
	var timer = Timer.new()
	timer.wait_time = 2.0  # Actualizar cada 2 segundos
	timer.timeout.connect(_check_update)
	timer.autostart = true
	add_child(timer)


func _check_update():
	"""Verificar si necesita actualización (para progreso en tiempo real)"""
	if mission_data.has("id"):
		# Aquí se podría pedir datos actualizados al MissionManager
		_update_display()
