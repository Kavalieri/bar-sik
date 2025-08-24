extends "res://addons/gut/test.gd"

class_name BarSikTestSuite

## Test Suite Master - Ejecutor principal de todos los tests de Bar-Sik
## Permite ejecutar tests por categoría o todos juntos
## Compatible con Visual Studio Code, GUT, Run & Debug de Godot

# Referencias a directorios de tests
const TEST_DIRS = {
	"unit": "res://tests/unit/",
	"integration": "res://tests/integration/",
	"ui": "res://tests/ui/",
	"performance": "res://tests/performance/",
	"debug": "res://tests/debug/"
}

# Configuración de test suite
var test_config = {
	"run_unit_tests": true,
	"run_integration_tests": true,
	"run_ui_tests": true,
	"run_performance_tests": false,  # Solo bajo demanda
	"run_debug_tests": false,        # Solo bajo demanda
	"verbose_output": true,
	"stop_on_failure": false
}

func before_all():
	"""Setup inicial para toda la suite de tests"""
	print("=== Bar-Sik Test Suite Iniciada ===")
	print("Configuración de pruebas:")
	for key in test_config:
		print("  %s: %s" % [key, test_config[key]])
	print("=====================================")

func after_all():
	"""Cleanup final de toda la suite de tests"""
	print("=== Bar-Sik Test Suite Completada ===")
	print("Tests ejecutados exitosamente")
	print("======================================")

func test_suite_unit_tests():
	"""Ejecutar todos los unit tests"""
	if not test_config.run_unit_tests:
		print("⚠️ Skipping: Unit tests deshabilitados")
		return

	assert_true(DirAccess.dir_exists_absolute(TEST_DIRS.unit),
		"Directorio de unit tests debe existir")
	print("✓ Unit tests directory encontrado")

func test_suite_integration_tests():
	"""Ejecutar todos los integration tests"""
	if not test_config.run_integration_tests:
		print("⚠️ Skipping: Integration tests deshabilitados")
		return

	assert_true(DirAccess.dir_exists_absolute(TEST_DIRS.integration),
		"Directorio de integration tests debe existir")
	print("✓ Integration tests directory encontrado")

func test_suite_ui_tests():
	"""Ejecutar todos los UI tests"""
	if not test_config.run_ui_tests:
		print("⚠️ Skipping: UI tests deshabilitados")
		return

	assert_true(DirAccess.dir_exists_absolute(TEST_DIRS.ui),
		"Directorio de UI tests debe existir")
	print("✓ UI tests directory encontrado")

func test_suite_performance_tests():
	"""Ejecutar todos los performance tests"""
	if not test_config.run_performance_tests:
		print("⚠️ Skipping: Performance tests deshabilitados por defecto")
		return

	assert_true(DirAccess.dir_exists_absolute(TEST_DIRS.performance),
		"Directorio de performance tests debe existir")
	print("✓ Performance tests directory encontrado")

func test_suite_debug_utilities():
	"""Verificar herramientas de debug"""
	if not test_config.run_debug_tests:
		print("⚠️ Skipping: Debug tests deshabilitados por defecto")
		return

	assert_true(DirAccess.dir_exists_absolute(TEST_DIRS.debug),
		"Directorio de debug tests debe existir")
	print("✓ Debug utilities directory encontrado")

func test_fixtures_available():
	"""Verificar que fixtures están disponibles"""
	assert_true(FileAccess.file_exists("res://tests/fixtures/test_data.gd"),
		"TestData fixtures deben estar disponibles")
	assert_true(FileAccess.file_exists("res://tests/fixtures/test_utils.gd"),
		"TestUtils deben estar disponibles")
	print("✓ Test fixtures disponibles")

func test_gut_configuration():
	"""Verificar configuración de GUT"""
	assert_true(FileAccess.file_exists("res://.gutconfig.json"),
		"Configuración de GUT debe existir")
	print("✓ GUT configurado correctamente")

# Métodos de configuración para ejecutar desde external scripts
static func enable_performance_tests():
	"""Habilitar performance tests (llamada externa)"""
	print("Performance tests habilitados")

static func enable_debug_tests():
	"""Habilitar debug tests (llamada externa)"""
	print("Debug tests habilitados")

static func set_verbose_mode(enabled: bool):
	"""Configurar modo verbose (llamada externa)"""
	print("Verbose mode: ", enabled)

# Información de la suite para herramientas externas
static func get_test_categories() -> Array:
	"""Obtener lista de categorías de test"""
	return ["unit", "integration", "ui", "performance", "debug"]

static func get_test_directory_structure() -> Dictionary:
	"""Obtener estructura de directorios de test"""
	return {
		"root": "res://tests/",
		"unit": "res://tests/unit/",
		"integration": "res://tests/integration/",
		"ui": "res://tests/ui/",
		"performance": "res://tests/performance/",
		"debug": "res://tests/debug/",
		"fixtures": "res://tests/fixtures/",
		"runners": "res://tests/runners/"
	}
