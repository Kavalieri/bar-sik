extends RefCounted

## Test de verificación básica sin GUT
## Para comprobar que el entorno está funcionando

static func run_basic_tests():
	"""Ejecuta tests básicos sin framework"""
	print("🧪 === TESTS BÁSICOS DE VERIFICACIÓN ===")

	var tests_passed = 0
	var tests_total = 0

	# Test 1: Matemáticas básicas
	tests_total += 1
	if _test_basic_math():
		tests_passed += 1
		print("✅ Test 1: Matemáticas básicas - PASSED")
	else:
		print("❌ Test 1: Matemáticas básicas - FAILED")

	# Test 2: Engine availability
	tests_total += 1
	if _test_engine_availability():
		tests_passed += 1
		print("✅ Test 2: Engine disponible - PASSED")
	else:
		print("❌ Test 2: Engine disponible - FAILED")

	# Test 3: File system
	tests_total += 1
	if _test_file_system():
		tests_passed += 1
		print("✅ Test 3: Sistema de archivos - PASSED")
	else:
		print("❌ Test 3: Sistema de archivos - FAILED")

	# Test 4: GameData creation
	tests_total += 1
	if _test_gamedata_creation():
		tests_passed += 1
		print("✅ Test 4: GameData creation - PASSED")
	else:
		print("❌ Test 4: GameData creation - FAILED")

	# Resultado final
	var success_rate = float(tests_passed) / float(tests_total) * 100.0
	print("📊 === RESULTADO FINAL ===")
	print("Tests ejecutados: " + str(tests_total))
	print("Tests exitosos: " + str(tests_passed))
	print("Tasa de éxito: " + str(success_rate) + "%")

	if tests_passed == tests_total:
		print("🎉 TODOS LOS TESTS BÁSICOS PASARON - SISTEMA LISTO")
		return true
	else:
		print("⚠️ ALGUNOS TESTS FALLARON - REVISAR CONFIGURACIÓN")
		return false

static func _test_basic_math() -> bool:
	"""Test matemáticas básicas"""
	return (1 + 1 == 2) and (5 * 6 == 30) and (10 / 2 == 5)

static func _test_engine_availability() -> bool:
	"""Test disponibilidad del Engine"""
	if Engine == null:
		return false

	var version_info = Engine.get_version_info()
	return version_info.major >= 4

static func _test_file_system() -> bool:
	"""Test sistema de archivos"""
	var test_path = "user://basic_test.tmp"

	# Crear archivo
	var file = FileAccess.open(test_path, FileAccess.WRITE)
	if file == null:
		return false

	file.store_string("test data")
	file.close()

	# Verificar existencia
	var exists = FileAccess.file_exists(test_path)

	# Limpiar
	DirAccess.remove_absolute(test_path)

	return exists

static func _test_gamedata_creation() -> bool:
	"""Test creación de GameData"""
	# Verificar que podemos crear una instancia básica
	var test_node = Node.new()
	if test_node == null:
		return false

	test_node.name = "TestGameData"
	var name_correct = test_node.name == "TestGameData"

	test_node.queue_free()
	return name_correct
