class_name EffectsManager
extends Node

## T033 - Sistema de Efectos Visuales y Animaciones
## Controla micro-animaciones que mejoran el game feel

# Señales
signal animation_started(animation_id: String)
signal animation_completed(animation_id: String)
signal effect_created(effect_id: String, target_node: Node)

# Referencias
var game_data: GameData
var tween_pool: Array[Tween] = []

# Configuración de efectos
var effects_enabled: bool = true
var animation_speed_multiplier: float = 1.0

# Constantes de animación
const BUTTON_PRESS_SCALE = 0.98
const BUTTON_SUCCESS_SCALE = 1.05
const BUTTON_ANIMATION_TIME = 0.1
const SHAKE_AMOUNT = 2.0
const FADE_TIME = 0.3
const FLOAT_DISTANCE = 30.0


func _ready():
	print("✨ EffectsManager inicializado (T033)")


## === BUTTON EFFECTS ===


func animate_button_press(button: Node, callback: Callable = Callable()):
	"""Animación de presión de botón"""
	if not effects_enabled or not button:
		if callback.is_valid():
			callback.call()
		return

	var tween = create_tween()
	tween_pool.append(tween)

	# Escala hacia abajo
	tween.tween_property(
		button,
		"scale",
		Vector2(BUTTON_PRESS_SCALE, BUTTON_PRESS_SCALE),
		BUTTON_ANIMATION_TIME * animation_speed_multiplier
	)

	# Escala de vuelta
	tween.tween_property(
		button, "scale", Vector2.ONE, BUTTON_ANIMATION_TIME * animation_speed_multiplier
	)

	if callback.is_valid():
		tween.tween_callback(callback)

	animation_started.emit("button_press")
	tween.finished.connect(func(): _on_animation_finished("button_press", tween))


func animate_button_success(button: Node, success_color: Color = Color.GREEN):
	"""Animación de éxito de botón con color y escala"""
	if not effects_enabled or not button:
		return

	var tween = create_tween()
	tween_pool.append(tween)

	var original_modulate = button.modulate
	var original_scale = button.scale

	# Paralelo: escala y color
	tween.parallel().tween_property(
		button,
		"scale",
		Vector2(BUTTON_SUCCESS_SCALE, BUTTON_SUCCESS_SCALE),
		BUTTON_ANIMATION_TIME * 2 * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		button, "modulate", success_color, BUTTON_ANIMATION_TIME * animation_speed_multiplier
	)

	# Volver a normal
	tween.parallel().tween_property(
		button, "scale", original_scale, BUTTON_ANIMATION_TIME * 2 * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		button,
		"modulate",
		original_modulate,
		BUTTON_ANIMATION_TIME * 3 * animation_speed_multiplier
	)

	animation_started.emit("button_success")
	tween.finished.connect(func(): _on_animation_finished("button_success", tween))


func animate_button_error(button: Node, error_color: Color = Color.RED):
	"""Animación de error de botón con shake y color"""
	if not effects_enabled or not button:
		return

	var tween = create_tween()
	tween_pool.append(tween)

	var original_position = button.position
	var original_modulate = button.modulate

	# Cambio de color
	tween.parallel().tween_property(
		button, "modulate", error_color, BUTTON_ANIMATION_TIME * animation_speed_multiplier
	)

	# Shake effect
	for i in range(4):
		tween.tween_property(
			button,
			"position",
			(
				original_position
				+ Vector2(
					randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT),
					randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT)
				)
			),
			0.05 * animation_speed_multiplier
		)

	# Volver a posición y color original
	tween.tween_property(
		button, "position", original_position, BUTTON_ANIMATION_TIME * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		button,
		"modulate",
		original_modulate,
		BUTTON_ANIMATION_TIME * 2 * animation_speed_multiplier
	)

	animation_started.emit("button_error")
	tween.finished.connect(func(): _on_animation_finished("button_error", tween))


## === FLOATING TEXT EFFECTS ===


func create_floating_text(
	parent: Node, text: String, start_pos: Vector2, color: Color = Color.WHITE, font_size: int = 16
):
	"""Crea texto flotante que se desvanece hacia arriba"""
	if not effects_enabled or not parent:
		return

	var label = Label.new()
	label.text = text
	label.position = start_pos
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	label.z_index = 100  # Encima de todo
	parent.add_child(label)

	var tween = create_tween()
	tween_pool.append(tween)

	# Flotación hacia arriba y fade out
	var end_pos = start_pos + Vector2(0, -FLOAT_DISTANCE)
	tween.parallel().tween_property(
		label, "position", end_pos, FADE_TIME * 2 * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		label, "modulate", Color.TRANSPARENT, FADE_TIME * 2 * animation_speed_multiplier
	)

	# Limpiar al final
	tween.tween_callback(label.queue_free)

	animation_started.emit("floating_text")
	effect_created.emit("floating_text", label)
	tween.finished.connect(func(): _on_animation_finished("floating_text", tween))


func create_currency_gain_effect(
	parent: Node, amount: float, currency_type: String, start_pos: Vector2
):
	"""Efecto específico para ganar dinero/tokens/gems"""
	if not effects_enabled:
		return

	var text = ""
	var color = Color.WHITE

	match currency_type:
		"money":
			text = "+$%.0f" % amount
			color = Color.GREEN
		"tokens":
			text = "+%d 🪙" % int(amount)
			color = Color.GOLD
		"gems":
			text = "+%d 💎" % int(amount)
			color = Color.CYAN
		_:
			text = "+%s" % str(amount)
			color = Color.WHITE

	create_floating_text(parent, text, start_pos, color, 18)


## === PROGRESS BAR ANIMATIONS ===


func animate_progress_fill(
	progress_bar: ProgressBar, from_value: float, to_value: float, duration: float = 0.5
):
	"""Anima el llenado suave de una barra de progreso"""
	if not effects_enabled or not progress_bar:
		progress_bar.value = to_value
		return

	var tween = create_tween()
	tween_pool.append(tween)

	progress_bar.value = from_value
	tween.tween_property(progress_bar, "value", to_value, duration * animation_speed_multiplier)

	animation_started.emit("progress_fill")
	tween.finished.connect(func(): _on_animation_finished("progress_fill", tween))


## === PANEL ANIMATIONS ===


func animate_panel_open(panel: Control, open_scale: Vector2 = Vector2.ONE):
	"""Animación de apertura de panel desde escala pequeña"""
	if not effects_enabled or not panel:
		panel.scale = open_scale
		panel.modulate = Color.WHITE
		return

	# Estado inicial
	panel.scale = Vector2(0.9, 0.9)
	panel.modulate = Color.TRANSPARENT

	var tween = create_tween()
	tween_pool.append(tween)

	# Animación paralela de escala y fade in
	tween.parallel().tween_property(
		panel, "scale", open_scale, FADE_TIME * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		panel, "modulate", Color.WHITE, FADE_TIME * animation_speed_multiplier
	)

	animation_started.emit("panel_open")
	tween.finished.connect(func(): _on_animation_finished("panel_open", tween))


func animate_panel_close(panel: Control, callback: Callable = Callable()):
	"""Animación de cierre de panel con fade out y escala"""
	if not effects_enabled or not panel:
		if callback.is_valid():
			callback.call()
		return

	var tween = create_tween()
	tween_pool.append(tween)

	# Animación paralela de escala y fade out
	tween.parallel().tween_property(
		panel, "scale", Vector2(0.9, 0.9), FADE_TIME * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		panel, "modulate", Color.TRANSPARENT, FADE_TIME * animation_speed_multiplier
	)

	if callback.is_valid():
		tween.tween_callback(callback)

	animation_started.emit("panel_close")
	tween.finished.connect(func(): _on_animation_finished("panel_close", tween))


## === TAB ANIMATIONS ===


func animate_tab_switch(current_tab: Control, new_tab: Control, direction: String = "left"):
	"""Animación de cambio de tabs con slide"""
	if not effects_enabled or not current_tab or not new_tab:
		current_tab.visible = false
		new_tab.visible = true
		return

	var slide_distance = (
		current_tab.size.x if direction in ["left", "right"] else current_tab.size.y
	)
	var slide_vector = Vector2.ZERO

	match direction:
		"left":
			slide_vector = Vector2(-slide_distance, 0)
		"right":
			slide_vector = Vector2(slide_distance, 0)
		"up":
			slide_vector = Vector2(0, -slide_distance)
		"down":
			slide_vector = Vector2(0, slide_distance)

	# Configurar posiciones iniciales
	var current_original_pos = current_tab.position
	var new_original_pos = new_tab.position
	new_tab.position = new_original_pos - slide_vector
	new_tab.visible = true

	var tween = create_tween()
	tween_pool.append(tween)

	# Animación paralela de ambos tabs
	tween.parallel().tween_property(
		current_tab,
		"position",
		current_original_pos + slide_vector,
		0.2 * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		new_tab, "position", new_original_pos, 0.2 * animation_speed_multiplier
	)

	# Ocultar tab anterior al final
	tween.tween_callback(func(): current_tab.visible = false)
	tween.tween_callback(func(): current_tab.position = current_original_pos)

	animation_started.emit("tab_switch")
	tween.finished.connect(func(): _on_animation_finished("tab_switch", tween))


## === ACHIEVEMENT/CELEBRATION EFFECTS ===


func animate_achievement_celebration(achievement_node: Control):
	"""Animación especial para logros desbloqueados"""
	if not effects_enabled or not achievement_node:
		return

	var tween = create_tween()
	tween_pool.append(tween)

	# Efecto de "bounce" con rotación sutil
	var original_scale = achievement_node.scale
	var original_rotation = achievement_node.rotation

	# Secuencia de celebración
	tween.tween_property(
		achievement_node, "scale", Vector2(1.2, 1.2), 0.15 * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		achievement_node, "rotation", 0.1, 0.15 * animation_speed_multiplier
	)

	tween.tween_property(
		achievement_node, "scale", Vector2(0.95, 0.95), 0.1 * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		achievement_node, "rotation", -0.05, 0.1 * animation_speed_multiplier
	)

	tween.tween_property(
		achievement_node, "scale", original_scale, 0.1 * animation_speed_multiplier
	)
	tween.parallel().tween_property(
		achievement_node, "rotation", original_rotation, 0.1 * animation_speed_multiplier
	)

	# Crear texto flotante de celebración
	var parent = achievement_node.get_parent()
	if parent:
		create_floating_text(
			parent, "🏆 ¡LOGRO DESBLOQUEADO!", achievement_node.global_position, Color.GOLD, 20
		)

	animation_started.emit("achievement_celebration")
	tween.finished.connect(func(): _on_animation_finished("achievement_celebration", tween))


## === UTILITY FUNCTIONS ===


func _on_animation_finished(animation_id: String, tween: Tween):
	"""Limpia tweens completados"""
	if tween in tween_pool:
		tween_pool.erase(tween)
	animation_completed.emit(animation_id)


func clear_all_animations():
	"""Cancela todas las animaciones activas"""
	for tween in tween_pool:
		if tween.is_valid():
			tween.kill()
	tween_pool.clear()


## === CONFIGURATION ===


func set_effects_enabled(enabled: bool):
	"""Habilitar/deshabilitar efectos"""
	effects_enabled = enabled


func set_animation_speed(speed: float):
	"""Ajustar velocidad de animaciones (1.0 = normal, 2.0 = doble velocidad)"""
	animation_speed_multiplier = clamp(speed, 0.1, 3.0)


## === API PÚBLICAS PARA UI ===


func ui_button_pressed(button: Node, callback: Callable = Callable()):
	"""API pública para botones de UI"""
	animate_button_press(button, callback)


func ui_purchase_success(button: Node, amount: float, currency: String):
	"""API pública para compras exitosas"""
	animate_button_success(button)
	var parent = button.get_parent()
	if parent:
		create_currency_gain_effect(parent, amount, currency, button.global_position)


func ui_error_feedback(button: Node, error_message: String = ""):
	"""API pública para errores de UI"""
	animate_button_error(button)


func ui_panel_transition(panel: Control, opening: bool):
	"""API pública para transiciones de paneles"""
	if opening:
		animate_panel_open(panel)
	else:
		animate_panel_close(panel)


## === INTEGRATION ===


func set_game_data(data: GameData):
	"""Conectar con GameData"""
	game_data = data


## === SAVE SYSTEM ===


func to_dict() -> Dictionary:
	"""Serializar configuración de efectos"""
	return {
		"effects_enabled": effects_enabled, "animation_speed_multiplier": animation_speed_multiplier
	}


func from_dict(data: Dictionary):
	"""Deserializar configuración de efectos"""
	effects_enabled = data.get("effects_enabled", true)
	animation_speed_multiplier = data.get("animation_speed_multiplier", 1.0)
