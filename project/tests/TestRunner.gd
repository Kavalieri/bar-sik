extends SceneTree
class_name GutTestRunner

## Simple test runner para ejecutar tests de Bar-Sik
## Uso: godot --script TestRunner.gd

var tests_passed: int = 0
var tests_failed: int = 0
var total_assertions: int = 0

func _init():
	"""Ejecuta todos los tests"""
	print("🧪 === BAR-SIK TEST SUITE ===")
	print("Iniciando ejecución de tests...")
	print("=" * 50)

	# Lista de archivos de test a ejecutar
	var test_files = [
		"res://tests/test_economy.gd",
		"res://tests/test_gamedata.gd",
		"res://tests/test_ui_systems.gd",
		"res://tests/test_integration.gd",
		"res://tests/test_main_suite.gd"
	]

	var overall_success = true

	for test_file in test_files:
		print("\n🔧 Ejecutando: " + test_file)
		var success = _run_test_file(test_file)
		if not success:
			overall_success = false

	_print_final_results(overall_success)

	if overall_success:
		quit(0)
	else:
		quit(1)

func _run_test_file(test_file_path: String) -> bool:
	"""Ejecuta un archivo de test específico"""

	# Verificar que el archivo existe
	if not ResourceLoader.exists(test_file_path):
		print("❌ Archivo no encontrado: " + test_file_path)
		tests_failed += 1
		return false

	# Intentar cargar el script
	var test_script = load(test_file_path)
	if test_script == null:
		print("❌ No se pudo cargar el script: " + test_file_path)
		tests_failed += 1
		return false

	# Crear instancia del test
	var test_instance = test_script.new()
	if test_instance == null:
		print("❌ No se pudo crear instancia: " + test_file_path)
		tests_failed += 1
		return false

	# Ejecutar before_all si existe
	if test_instance.has_method("before_all"):
		test_instance.before_all()

	# Encontrar todos los métodos que empiecen con "test_"
	var test_methods = _find_test_methods(test_instance)

	var file_passed = true
	var methods_run = 0

	for method_name in test_methods:
		methods_run += 1
		print("  ▶️ " + method_name)

		# before_each
		if test_instance.has_method("before_each"):
			test_instance.before_each()

		# Reset test state if available
		if test_instance.has_method("reset_test_state"):
			test_instance.reset_test_state()

		# Ejecutar el test method
		var method_success = true

		# Llamar al método de test
		test_instance.call(method_name)

		# Check results if available
		if test_instance.has_method("did_pass"):
			if test_instance.did_pass():
				print("    ✅ PASSED")
				tests_passed += 1
			else:
				print("    ❌ FAILED")
				tests_failed += 1
				file_passed = false
		else:
			print("    ✅ PASSED (no assertions)")
			tests_passed += 1

		# after_each
		if test_instance.has_method("after_each"):
			test_instance.after_each()

	# Ejecutar after_all si existe
	if test_instance.has_method("after_all"):
		test_instance.after_all()

	# Limpiar instancia
	if test_instance.has_method("queue_free"):
		test_instance.queue_free()

	print("📊 Métodos ejecutados: " + str(methods_run))

	if file_passed:
		print("✅ " + test_file_path + " - TODOS PASARON")
	else:
		print("❌ " + test_file_path + " - ALGUNOS FALLARON")

	return file_passed

func _find_test_methods(test_instance) -> Array[String]:
	"""Encuentra todos los métodos que empiecen con 'test_'"""
	var methods: Array[String] = []

	# Get all methods from the instance
	var method_list = test_instance.get_method_list()

	for method_info in method_list:
		var method_name = method_info["name"]
		if method_name.begins_with("test_"):
			methods.append(method_name)

	return methods

func _print_final_results(overall_success: bool):
	"""Imprime resultados finales"""
	print("\n" + "=" * 50)
	print("🏁 === RESULTADOS FINALES ===")
	print("Tests exitosos: " + str(tests_passed))
	print("Tests fallidos: " + str(tests_failed))
	print("Total: " + str(tests_passed + tests_failed))

	if tests_passed + tests_failed > 0:
		var success_rate = float(tests_passed) / float(tests_passed + tests_failed) * 100.0
		print("Tasa de éxito: " + str(success_rate) + "%")

	if overall_success:
		print("🎉 TODOS LOS TESTS PASARON!")
		print("✅ BAR-SIK TESTING SUITE - SUCCESS")
	else:
		print("⚠️ ALGUNOS TESTS FALLARON")
		print("❌ BAR-SIK TESTING SUITE - FAILED")

	print("=" * 50)
