extends GutTest

## Test oficial usando GUT framework
## Para verificar que todo funciona correctamente

func test_basic_assertions():
	"""Test básico de assertions de GUT"""
	assert_true(true, "True should be true")
	assert_false(false, "False should be false")
	assert_eq(1, 1, "1 should equal 1")
	assert_ne(1, 2, "1 should not equal 2")

func test_math_operations():
	"""Test operaciones matemáticas"""
	assert_eq(2 + 2, 4, "2 + 2 = 4")
	assert_eq(10 * 5, 50, "10 * 5 = 50")
	assert_almost_eq(10.0 / 3.0, 3.333, 0.01, "Division approximation")

func test_string_operations():
	"""Test operaciones con strings"""
	var greeting = "Hello"
	var world = "World"
	assert_eq(greeting + " " + world, "Hello World", "String concatenation")

func test_array_operations():
	"""Test operaciones con arrays"""
	var numbers = [1, 2, 3, 4, 5]
	assert_eq(numbers.size(), 5, "Array should have 5 elements")
	assert_has(numbers, 3, "Array should contain 3")

func test_file_operations():
	"""Test básico de operaciones de archivo"""
	var test_file = "user://gut_test_file.tmp"

	# Write test
	var file = FileAccess.open(test_file, FileAccess.WRITE)
	assert_not_null(file, "Should be able to create file")
	file.store_string("Test data")
	file.close()

	# Read test
	assert_file_exists(test_file, "File should exist after write")

	var read_file = FileAccess.open(test_file, FileAccess.READ)
	var content = read_file.get_as_text()
	read_file.close()

	assert_eq(content, "Test data", "File content should match")

	# Cleanup
	DirAccess.remove_absolute(test_file)
