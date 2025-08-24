extends GutTest

## Test minimalista sin dependencias del proyecto
## Solo para verificar que GUT funciona


func test_gut_framework_works():
	"""Verifica que el framework GUT está funcionando"""
	assert_true(true, "GUT framework operational")
	assert_eq(2 + 2, 4, "Basic math works")


func test_godot_environment():
	"""Verifica que el entorno Godot está disponible"""
	assert_not_null(Engine, "Engine should be available")
	assert_gte(Engine.get_version_info().major, 4, "Should be Godot 4+")


func test_simple_data_structures():
	"""Test estructuras básicas de datos"""
	var test_dict = {"name": "test", "value": 42}
	assert_eq(test_dict["name"], "test", "Dictionary access works")
	assert_eq(test_dict["value"], 42, "Dictionary values correct")


func test_basic_file_system():
	"""Test básico del sistema de archivos"""
	var test_path = "user://minimal_test.tmp"

	# Write
	var file = FileAccess.open(test_path, FileAccess.WRITE)
	if file:
		file.store_string("minimal test")
		file.close()

		# Verify
		assert_file_exists(test_path)

		# Cleanup
		DirAccess.remove_absolute(test_path)
	else:
		fail_test("Could not create test file")


func test_assertions_work():
	"""Verifica que todas las assertions básicas funcionan"""
	assert_true(true)
	assert_false(false)
	assert_eq(1, 1)
	assert_ne(1, 2)
	assert_gt(5, 3)
	assert_lt(2, 4)
	assert_gte(5, 5)
	assert_lte(3, 3)
