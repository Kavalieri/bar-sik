class_name TestUtils
extends RefCounted

## Utilidades comunes para testing en Bar-Sik
## Funciones de ayuda y validación para tests

# Mock de tiempo para tests determinísticos
static var mock_time: float = 0.0
static var use_mock_time: bool = false

static func is_equal_approx_tolerance(a: float, b: float, tolerance: float = 0.001) -> bool:
	"""Comparar flotantes con tolerancia personalizada"""
	return abs(a - b) <= tolerance

# Validación de GameData
static func validate_gamedata_structure(data: Dictionary) -> bool:
	"""Validar que GameData tiene estructura correcta"""
	var required_keys = ["money", "tokens", "gems"]

	for key in required_keys:
		if not data.has(key):
			return false

	# Validar tipos
	if typeof(data["money"]) != TYPE_FLOAT and typeof(data["money"]) != TYPE_INT:
		return false

	return true

static func set_mock_time(time: float):
	"""Establecer tiempo mock para tests"""
	mock_time = time
	use_mock_time = true

static func get_time() -> float:
	"""Obtener tiempo (mock o real)"""
	return mock_time if use_mock_time else Time.get_ticks_msec() / 1000.0

static func reset_mock_time():
	"""Resetear tiempo mock"""
	mock_time = 0.0
	use_mock_time = false

# Creación de GameData limpio para tests
static func create_clean_gamedata() -> GameData:
	"""Crear GameData limpio para test setup"""
	var game_data = GameData.new()
	game_data.reset_to_defaults()
	return game_data

# Validación de UI Components
static func validate_ui_component(node: Node, expected_type: String) -> bool:
	"""Validar que componente UI es del tipo correcto"""
	if not is_instance_valid(node):
		return false

	return node.get_script() != null and node.get_script().get_global_name() == expected_type

# Utilidades de Currency Display
static func format_currency_test(value: float) -> String:
	"""Formatear currency para testing (función simplificada)"""
	if value < 1000:
		return str(int(value))
	if value < 1000000:
		return "%.1fK" % (value / 1000.0)
	if value < 1000000000:
		return "%.1fM" % (value / 1000000.0)
	return "%.1fB" % (value / 1000000000.0)

# Simulación de eventos de input
static func simulate_button_press(button: BaseButton):
	"""Simular presión de botón para tests"""
	if is_instance_valid(button) and not button.disabled:
		button.emit_signal("pressed")

static func simulate_mouse_click(node: Node, position: Vector2 = Vector2.ZERO):
	"""Simular click de mouse en node"""
	if not is_instance_valid(node):
		return

	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = position
	node.get_viewport().push_input(event)

	# Release
	event.pressed = false
	node.get_viewport().push_input(event)

# Validación de Performance
static func measure_execution_time(callable: Callable) -> float:
	"""Medir tiempo de ejecución de función"""
	var start_time = Time.get_ticks_usec()
	callable.call()
	var end_time = Time.get_ticks_usec()
	return (end_time - start_time) / 1000000.0  # Convertir a segundos

# Memory tracking simplificado
static func get_approximate_memory_usage() -> int:
	"""Obtener uso aproximado de memoria (simplificado)"""
	# En un test real usarías herramientas más sofisticadas
	var node_count = Engine.get_singleton("SceneTree").get_node_count_in_group("")
	return node_count * 100  # Estimación muy básica

# Limpieza de escena para tests
static func cleanup_test_scene(scene: Node):
	"""Limpiar escena de test de manera segura"""
	if is_instance_valid(scene):
		scene.queue_free()
		# Esperar un frame para que se libere
		await Engine.get_main_loop().process_frame

# Comparación de Arrays/Dictionaries profunda
static func deep_compare(a, b) -> bool:
	"""Comparación profunda de estructuras de datos"""
	if typeof(a) != typeof(b):
		return false

	if typeof(a) == TYPE_DICTIONARY:
		if a.size() != b.size():
			return false
		for key in a.keys():
			if not b.has(key) or not deep_compare(a[key], b[key]):
				return false
		return true

	if typeof(a) == TYPE_ARRAY:
		if a.size() != b.size():
			return false
		for i in range(a.size()):
			if not deep_compare(a[i], b[i]):
				return false
		return true

	return a == b

# Debugging helpers
static func print_test_debug(message: String, data = null):
	"""Print debug info solo en tests"""
	if OS.is_debug_build():
		if data != null:
			print("[TEST DEBUG] %s: %s" % [message, str(data)])
		else:
			print("[TEST DEBUG] %s" % message)

# Assertion helpers para GUT
static func assert_gamedata_valid(test_instance, game_data: GameData, message: String = ""):
	"""Helper para assert GameData válido"""
	test_instance.assert_not_null(game_data, "GameData no debería ser null" + message)
	test_instance.assert_true(game_data.money >= 0, "Money no debería ser negativo" + message)
	test_instance.assert_true(game_data.tokens >= 0, "Tokens no deberían ser negativos" + message)

static func assert_ui_component_valid(test_instance, component: Node, message: String = ""):
	"""Helper para validar componente UI"""
	test_instance.assert_not_null(component, "Componente UI no debería ser null" + message)
	test_instance.assert_true(is_instance_valid(component),
		"Componente UI debería ser válido" + message)

# Utilidades para tests de integración
static func wait_for_condition(condition: Callable, max_wait_time: float = 5.0) -> bool:
	"""Esperar hasta que una condición sea verdadera"""
	var start_time = Time.get_ticks_msec() / 1000.0

	while Time.get_ticks_msec() / 1000.0 - start_time < max_wait_time:
		if condition.call():
			return true
		await Engine.get_main_loop().process_frame

	return false
