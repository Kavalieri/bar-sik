extends "res://addons/gut/test.gd"

## Test simple para verificar que nuestro sistema GUT funciona


func test_gut_assertions_work():
	"""Test básico de assertions GUT"""
	print("🧪 Probando assertions básicas...")

	assert_true(true, "True debería ser true")
	assert_false(false, "False debería ser false")
	assert_eq(1, 1, "1 debería igual a 1")
	assert_ne(1, 2, "1 no debería ser igual a 2")
	assert_gt(5, 3, "5 debería ser mayor que 3")
	assert_lt(2, 4, "2 debería ser menor que 4")

	print("✅ Todas las assertions básicas funcionan")


func test_mathematical_operations():
	"""Test operaciones matemáticas básicas"""
	print("🧮 Probando operaciones matemáticas...")

	var result = 10 + 5
	assert_eq(result, 15, "10 + 5 = 15")

	var division = 20.0 / 4.0
	assert_eq(division, 5.0, "20 / 4 = 5")

	var power = pow(2, 3)
	assert_eq(power, 8, "2^3 = 8")

	print("✅ Operaciones matemáticas correctas")


func test_string_operations():
	"""Test operaciones con strings"""
	print("📝 Probando operaciones de strings...")

	var greeting = "Hello"
	var target = "World"
	var combined = greeting + " " + target

	assert_eq(combined, "Hello World", "Concatenación de strings")
	assert_true(combined.contains("Hello"), "String contiene 'Hello'")
	assert_true(combined.contains("World"), "String contiene 'World'")

	print("✅ Operaciones de strings correctas")


func test_array_operations():
	"""Test operaciones con arrays"""
	print("📋 Probando operaciones de arrays...")

	var numbers = [1, 2, 3, 4, 5]

	assert_eq(numbers.size(), 5, "Array tiene 5 elementos")
	assert_true(numbers.has(3), "Array contiene 3")
	assert_false(numbers.has(10), "Array no contiene 10")
	assert_eq(numbers[0], 1, "Primer elemento es 1")
	assert_eq(numbers[-1], 5, "Último elemento es 5")

	print("✅ Operaciones de arrays correctas")


func test_dictionary_operations():
	"""Test operaciones con diccionarios"""
	print("📚 Probando operaciones de diccionarios...")

	var player_data = {"name": "TestPlayer", "level": 1, "money": 100.0, "active": true}

	assert_eq(player_data["name"], "TestPlayer", "Nombre del jugador correcto")
	assert_eq(player_data["level"], 1, "Nivel del jugador correcto")
	assert_eq(player_data["money"], 100.0, "Dinero del jugador correcto")
	assert_true(player_data["active"], "Jugador está activo")

	assert_true(player_data.has("name"), "Diccionario tiene clave 'name'")
	assert_false(player_data.has("invalid_key"), "Diccionario no tiene clave inválida")

	print("✅ Operaciones de diccionarios correctas")


func test_node_operations():
	"""Test operaciones básicas con nodos"""
	print("🌳 Probando operaciones de nodos...")

	var test_node = Node.new()

	assert_not_null(test_node, "Nodo creado correctamente")

	test_node.name = "TestNode"
	assert_eq(test_node.name, "TestNode", "Nombre del nodo asignado correctamente")

	var child_node = Node.new()
	child_node.name = "ChildNode"
	test_node.add_child(child_node)

	assert_eq(test_node.get_child_count(), 1, "Nodo padre tiene 1 hijo")
	assert_eq(test_node.get_child(0).name, "ChildNode", "Hijo tiene nombre correcto")

	# Cleanup
	test_node.queue_free()

	print("✅ Operaciones de nodos correctas")


func test_file_system_access():
	"""Test acceso al sistema de archivos"""
	print("💾 Probando acceso al sistema de archivos...")

	var test_file_path = "user://test_gut_verification.dat"
	var test_data = "GUT test data verification"

	# Crear archivo
	var file = FileAccess.open(test_file_path, FileAccess.WRITE)
	assert_not_null(file, "Archivo creado correctamente")

	if file:
		file.store_string(test_data)
		file.close()

		# Verificar que existe
		assert_true(FileAccess.file_exists(test_file_path), "Archivo existe tras escritura")

		# Leer archivo
		var read_file = FileAccess.open(test_file_path, FileAccess.READ)
		assert_not_null(read_file, "Archivo abierto para lectura")

		if read_file:
			var read_data = read_file.get_as_text()
			read_file.close()

			assert_eq(read_data, test_data, "Datos leídos coinciden con escritos")

		# Limpiar
		DirAccess.remove_absolute(test_file_path)
		assert_false(FileAccess.file_exists(test_file_path), "Archivo eliminado correctamente")

	print("✅ Sistema de archivos funcional")
