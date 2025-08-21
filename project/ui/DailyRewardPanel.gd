# T026: Panel de recompensas diarias - UI para el sistema de recompensas
extends Control

@onready var daily_reward_manager: DailyRewardManager
@onready var reward_button: Button = $VBoxContainer/RewardButton
@onready var streak_label: Label = $VBoxContainer/StreakLabel
@onready var reward_amount_label: Label = $VBoxContainer/RewardAmountLabel
@onready var next_reward_label: Label = $VBoxContainer/NextRewardLabel
@onready var milestone_progress: ProgressBar = $VBoxContainer/MilestoneProgress
@onready var milestone_label: Label = $VBoxContainer/MilestoneLabel

var base_reward: int = 10
var max_streak_bonus: int = 7


func _ready():
	# Conectar con el manager principal
	if GameController.daily_reward_manager:
		daily_reward_manager = GameController.daily_reward_manager
		daily_reward_manager.reward_claimed.connect(_on_reward_claimed)
		update_display()

	if reward_button:
		reward_button.pressed.connect(_on_reward_button_pressed)


func update_display():
	if not daily_reward_manager:
		return

	var can_claim = daily_reward_manager.can_claim_daily_reward()
	var current_streak = daily_reward_manager.get_current_streak()
	var days_total = daily_reward_manager.get_total_days()

	# Actualizar botón
	if reward_button:
		reward_button.disabled = not can_claim
		if can_claim:
			reward_button.text = "💎 ¡RECLAMAR RECOMPENSA!"
			reward_button.modulate = Color.YELLOW
		else:
			reward_button.text = "✓ Ya reclamaste hoy"
			reward_button.modulate = Color.GRAY

	# Actualizar racha
	if streak_label:
		if current_streak > 0:
			streak_label.text = "🔥 Racha actual: %d días" % current_streak
		else:
			streak_label.text = "Comienza tu racha diaria"

	# Calcular cantidad de recompensa
	var reward_amount = _calculate_display_reward()
	if reward_amount_label:
		reward_amount_label.text = "Recompensa: %d 💎" % reward_amount

	# Mostrar cuándo es la próxima recompensa
	if next_reward_label:
		if can_claim:
			next_reward_label.text = "¡Disponible ahora!"
		else:
			var hours_until_next = daily_reward_manager._get_hours_until_next_reward()
			if hours_until_next > 0:
				next_reward_label.text = "Próxima en: %d horas" % hours_until_next
			else:
				next_reward_label.text = "Disponible en breve"

	# Actualizar progreso de milestone
	_update_milestone_display(days_total)


func _calculate_display_reward() -> int:
	if not daily_reward_manager:
		return base_reward

	var current_streak = daily_reward_manager.get_current_streak()
	var streak_bonus = min(current_streak, max_streak_bonus)
	var reward = base_reward + streak_bonus

	# Bonus de prestigio (estimado)
	var prestige_stars = 0
	if GameData:
		prestige_stars = GameData.get_prestige_stars()

	if prestige_stars >= 50:
		reward = int(reward * 1.5)

	return reward


func _update_milestone_display(days_total: int):
	if not milestone_progress or not milestone_label:
		return

	var next_milestone: int
	var milestone_reward: int

	# Determinar próximo milestone
	if days_total < 7:
		next_milestone = 7
		milestone_reward = 50
	elif days_total < 30:
		next_milestone = 30
		milestone_reward = 200
	elif days_total < 100:
		next_milestone = 100
		milestone_reward = 500
	else:
		# Ya alcanzó todos los milestones
		milestone_progress.value = 100
		milestone_label.text = "🏆 ¡Todos los milestones completados!"
		return

	var progress = float(days_total) / float(next_milestone) * 100.0
	milestone_progress.value = progress
	milestone_label.text = (
		"Progreso a día %d: %d/%d (Premio: %d💎)"
		% [next_milestone, days_total, next_milestone, milestone_reward]
	)


func _on_reward_button_pressed():
	if daily_reward_manager and daily_reward_manager.can_claim_daily_reward():
		var reward_amount = daily_reward_manager.claim_daily_reward()

		# Mostrar animación/feedback
		_show_reward_feedback(reward_amount)

		# Actualizar display
		update_display()


func _on_reward_claimed(amount: int, new_streak: int):
	# Callback cuando se reclama recompensa
	print("Recompensa reclamada: %d gemas, racha: %d" % [amount, new_streak])

	# Aquí se podría agregar efectos visuales, sonidos, etc.
	_show_celebration_effect(amount, new_streak)


func _show_reward_feedback(amount: int):
	# Crear label temporal para mostrar la recompensa
	var feedback_label = Label.new()
	feedback_label.text = "+%d 💎" % amount
	feedback_label.add_theme_color_override("font_color", Color.YELLOW)
	feedback_label.add_theme_font_size_override("font_size", 32)
	feedback_label.position = reward_button.global_position + Vector2(50, -30)
	get_tree().current_scene.add_child(feedback_label)

	# Animar el feedback
	var tween = create_tween()
	tween.parallel().tween_property(
		feedback_label, "position", feedback_label.position + Vector2(0, -50), 1.0
	)
	tween.parallel().tween_property(feedback_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(feedback_label.queue_free)


func _show_celebration_effect(amount: int, streak: int):
	# Efecto especial para rachas largas
	if streak >= 7:
		print("🎉 ¡Racha épica de %d días!" % streak)
	elif streak >= 3:
		print("🔥 ¡Buena racha de %d días!" % streak)


# Método para abrir/cerrar el panel
func toggle_panel():
	visible = not visible
	if visible:
		update_display()


func show_panel():
	visible = true
	update_display()


func hide_panel():
	visible = false
