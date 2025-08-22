extends "res://addons/gut/test.gd"

## T037 - Tests de UI Systems
## Validación de componentes UI modulares y interacciones

# Referencias para testing
var game_data: GameData
var main_ui: Control
var test_scene: Node

func before_each():
	"""Configuración antes de cada test"""
	game_data = GameData.new()
	game_data._initialize_default_values()

	# Crear nodo contenedor para tests UI
	test_scene = Node.new()
	add_child(test_scene)

	# Crear UI básico para tests
	main_ui = Control.new()
	main_ui.name = "MainUI"
	test_scene.add_child(main_ui)


func after_each():
	"""Limpieza después de cada test"""
	if game_data:
		game_data.queue_free()

	if test_scene:
		test_scene.queue_free()


## === TESTS DE UI COMPONENTS ===

func test_button_creation():
	"""Test: Creación y configuración básica de botones"""
	var button = Button.new()
	button.name = "TestButton"
	button.text = "Test Action"
	button.disabled = false

	main_ui.add_child(button)

	assert_not_null(button, "Botón no se creó")
	assert_eq(button.name, "TestButton", "Nombre de botón incorrecto")
	assert_eq(button.text, "Test Action", "Texto de botón incorrecto")
	assert_false(button.disabled, "Botón no debería estar deshabilitado")

	# Verificar que está en la escena
	var found_button = main_ui.get_node("TestButton")
	assert_not_null(found_button, "Botón no encontrado en UI")


func test_label_updates():
	"""Test: Actualización dinámica de labels"""
	var label = Label.new()
	label.name = "MoneyLabel"
	label.text = "$0"

	main_ui.add_child(label)

	# Simular actualización de dinero
	var money_value = 1234.56
	label.text = "$" + str(money_value)

	assert_eq(label.text, "$1234.56", "Label de dinero no se actualizó correctamente")

	# Test con formato numérico
	var formatted_money = _format_number(money_value)
	label.text = "$" + formatted_money

	assert_true(label.text.begins_with("$"), "Label debería comenzar con símbolo de dinero")


func test_progress_bar_functionality():
	"""Test: Funcionalidad de barras de progreso"""
	var progress_bar = ProgressBar.new()
	progress_bar.name = "ProductionProgress"
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0

	main_ui.add_child(progress_bar)

	# Simular progreso
	progress_bar.value = 25.0
	assert_eq(progress_bar.value, 25.0, "Valor de barra de progreso incorrecto")

	# Verificar que no excede límites
	progress_bar.value = 150.0  # Intentar exceder máximo
	assert_le(progress_bar.value, progress_bar.max_value,
		"Barra de progreso no respeta valor máximo")

	# Verificar porcentaje
	var percentage = (progress_bar.value / progress_bar.max_value) * 100
	assert_ge(percentage, 0.0, "Porcentaje no puede ser negativo")
	assert_le(percentage, 100.0, "Porcentaje no puede exceder 100%")


func test_container_management():
	"""Test: Manejo de contenedores y organización"""
	var vbox = VBoxContainer.new()
	vbox.name = "MainContainer"
	main_ui.add_child(vbox)

	# Agregar elementos hijos
	for i in range(3):
		var button = Button.new()
		button.name = "Button" + str(i)
		button.text = "Action " + str(i)
		vbox.add_child(button)

	assert_eq(vbox.get_child_count(), 3, "Contenedor no tiene el número correcto de hijos")

	# Verificar orden de elementos
	var first_button = vbox.get_child(0) as Button
	assert_eq(first_button.text, "Action 0", "Primer botón no está en orden correcto")

	var last_button = vbox.get_child(2) as Button
	assert_eq(last_button.text, "Action 2", "Último botón no está en orden correcto")


## === TESTS DE UI INTERACTIONS ===

func test_button_click_simulation():
	"""Test: Simulación de clicks en botones"""
	var button = Button.new()
	button.name = "ClickTestButton"
	button.text = "Click Me"
	main_ui.add_child(button)

	var click_received = false

	# Conectar señal
	button.pressed.connect(func(): click_received = true)

	# Simular click
	button.emit_signal("pressed")

	assert_true(click_received, "Señal de click no se recibió")


func test_input_field_validation():
	"""Test: Validación de campos de entrada"""
	var line_edit = LineEdit.new()
	line_edit.name = "NumberInput"
	line_edit.placeholder_text = "Enter amount"
	main_ui.add_child(line_edit)

	# Test con entrada válida
	line_edit.text = "123.45"
	var is_valid_number = line_edit.text.is_valid_float()
	assert_true(is_valid_number, "Número válido no fue reconocido")

	# Test con entrada inválida
	line_edit.text = "not_a_number"
	var is_invalid_number = line_edit.text.is_valid_float()
	assert_false(is_invalid_number, "Entrada inválida fue aceptada como número")

	# Test con entrada vacía
	line_edit.text = ""
	var is_empty = line_edit.text.is_empty()
	assert_true(is_empty, "Campo vacío no fue detectado correctamente")


func test_tab_container_switching():
	"""Test: Cambio entre pestañas en TabContainer"""
	var tab_container = TabContainer.new()
	tab_container.name = "MainTabs"
	main_ui.add_child(tab_container)

	# Crear pestañas
	var tab_names = ["Production", "Upgrades", "Statistics"]
	for tab_name in tab_names:
		var tab_content = Control.new()
		tab_content.name = tab_name
		tab_container.add_child(tab_content)
		tab_container.set_tab_title(tab_container.get_child_count() - 1, tab_name)

	assert_eq(tab_container.get_child_count(), 3, "Número de pestañas incorrecto")

	# Test cambio de pestaña
	tab_container.current_tab = 1
	assert_eq(tab_container.current_tab, 1, "Cambio de pestaña no funcionó")

	# Verificar título de pestaña activa
	var active_title = tab_container.get_tab_title(tab_container.current_tab)
	assert_eq(active_title, "Upgrades", "Título de pestaña activa incorrecto")


## === TESTS DE UI DATA BINDING ===

func test_money_display_binding():
	"""Test: Vinculación de display de dinero con GameData"""
	var money_label = Label.new()
	money_label.name = "MoneyDisplay"
	main_ui.add_child(money_label)

	# Simular actualización de dinero
	game_data.money = 2500.75
	_update_money_display(money_label, game_data.money)

	assert_true(money_label.text.contains("2500"),
		"Display de dinero no refleja valor correcto")
	assert_true(money_label.text.contains("$") or money_label.text.contains("Money"),
		"Display de dinero sin formato apropiado")


func test_production_info_binding():
	"""Test: Vinculación de información de producción"""
	var production_label = Label.new()
	production_label.name = "ProductionInfo"
	main_ui.add_child(production_label)

	# Simular datos de producción
	var production_rate = 5.5
	var active_stations = 3

	_update_production_display(production_label, production_rate, active_stations)

	assert_true(production_label.text.contains(str(production_rate)) or
		production_label.text.contains("5.5"),
		"Display de producción no muestra tasa correcta")
	assert_true(production_label.text.contains(str(active_stations)) or
		production_label.text.contains("3"),
		"Display de producción no muestra estaciones correctas")


func test_button_state_binding():
	"""Test: Vinculación de estados de botones con datos"""
	var upgrade_button = Button.new()
	upgrade_button.name = "UpgradeButton"
	upgrade_button.text = "Buy Upgrade ($500)"
	main_ui.add_child(upgrade_button)

	# Test con dinero insuficiente
	game_data.money = 200.0
	var upgrade_cost = 500.0

	var can_afford = game_data.money >= upgrade_cost
	_update_button_affordability(upgrade_button, can_afford, upgrade_cost)

	assert_true(upgrade_button.disabled, "Botón debería estar deshabilitado sin dinero suficiente")

	# Test con dinero suficiente
	game_data.money = 600.0
	can_afford = game_data.money >= upgrade_cost
	_update_button_affordability(upgrade_button, can_afford, upgrade_cost)

	assert_false(upgrade_button.disabled, "Botón debería estar habilitado con dinero suficiente")


## === TESTS DE UI PERFORMANCE ===

func test_ui_update_frequency():
	"""Test: Frecuencia de actualización de UI no excesiva"""
	var label = Label.new()
	label.name = "HighFrequencyLabel"
	main_ui.add_child(label)

	var update_count = 0
	var start_time = Time.get_time_dict_from_system()

	# Simular múltiples actualizaciones rápidas
	for i in range(100):
		_update_money_display(label, float(i))
		update_count += 1

	var end_time = Time.get_time_dict_from_system()

	# Verificar que las actualizaciones no tomen demasiado tiempo
	assert_eq(update_count, 100, "No todas las actualizaciones se procesaron")

	# En un entorno de test, esto debería ser casi instantáneo
	var total_seconds = _calculate_time_diff(start_time, end_time)
	assert_lt(total_seconds, 1.0, "Actualizaciones UI toman demasiado tiempo")


func test_large_ui_hierarchy():
	"""Test: Manejo de jerarquías UI grandes"""
	var main_container = VBoxContainer.new()
	main_container.name = "LargeHierarchy"
	main_ui.add_child(main_container)

	# Crear estructura anidada
	var total_nodes = 0

	for i in range(5):  # 5 categorías principales
		var category = VBoxContainer.new()
		category.name = "Category" + str(i)
		main_container.add_child(category)
		total_nodes += 1

		for j in range(10):  # 10 items por categoría
			var item = Button.new()
			item.name = "Item_" + str(i) + "_" + str(j)
			item.text = "Item " + str(j)
			category.add_child(item)
			total_nodes += 1

	assert_eq(total_nodes, 55, "Número total de nodos incorrecto")  # 5 + (5*10)
	assert_eq(main_container.get_child_count(), 5, "Número de categorías principales incorrecto")

	# Verificar acceso a elementos anidados
	var first_category = main_container.get_child(0) as VBoxContainer
	assert_eq(first_category.get_child_count(), 10, "Primera categoría no tiene 10 items")


## === HELPER FUNCTIONS ===

func _format_number(value: float) -> String:
	"""Formatea números para display"""
	if value >= 1000000:
		return str(value / 1000000).pad_decimals(1) + "M"
	elif value >= 1000:
		return str(value / 1000).pad_decimals(1) + "K"
	else:
		return str(value).pad_decimals(2)


func _update_money_display(label: Label, money: float):
	"""Actualiza display de dinero"""
	label.text = "$" + _format_number(money)


func _update_production_display(label: Label, rate: float, stations: int):
	"""Actualiza display de producción"""
	label.text = "Rate: " + str(rate) + "/s (" + str(stations) + " stations)"


func _update_button_affordability(button: Button, can_afford: bool, cost: float):
	"""Actualiza estado de botón basado en affordability"""
	button.disabled = not can_afford

	if can_afford:
		button.modulate = Color.WHITE
	else:
		button.modulate = Color.GRAY


func _calculate_time_diff(start_time: Dictionary, end_time: Dictionary) -> float:
	"""Calcula diferencia de tiempo en segundos"""
	var start_total = start_time.hour * 3600 + start_time.minute * 60 + start_time.second
	var end_total = end_time.hour * 3600 + end_time.minute * 60 + end_time.second

	var diff = end_total - start_total
	if diff < 0:  # Cambio de día
		diff += 86400  # 24 horas en segundos

	return float(diff)
