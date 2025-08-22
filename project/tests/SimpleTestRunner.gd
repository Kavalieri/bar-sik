extends SceneTree

## Test runner específico para test simple

func _init():
	print("🧪 === EJECUTANDO TEST SIMPLE ===")

	var test_script = preload("res://tests/test_gut_simple.gd")
	var test_instance = test_script.new()

	print("🔧 Ejecutando test_gut_simple.gd...")

	# Ejecutar tests específicos
	var test_methods = [
		"test_gut_assertions_work",
		"test_mathematical_operations",
		"test_string_operations",
		"test_array_operations",
		"test_dictionary_operations",
		"test_node_operations",
		"test_file_system_access"
	]

	var passed = 0
	var total = test_methods.size()

	for method_name in test_methods:
		print("\n▶️ " + method_name)

		if test_instance.has_method("reset_test_state"):
			test_instance.reset_test_state()

		test_instance.call(method_name)

		if test_instance.has_method("did_pass"):
			if test_instance.did_pass():
				print("  ✅ PASSED")
				passed += 1
			else:
				print("  ❌ FAILED")
		else:
			print("  ✅ PASSED (no assertions)")
			passed += 1

	print("\n" + "=" * 40)
	print("📊 RESULTADO: " + str(passed) + "/" + str(total) + " tests pasaron")

	if passed == total:
		print("🎉 TODOS LOS TESTS PASARON!")
		quit(0)
	else:
		print("⚠️ ALGUNOS TESTS FALLARON")
		quit(1)
