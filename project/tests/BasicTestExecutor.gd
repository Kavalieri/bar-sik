extends SceneTree

## Script ejecutor de tests básicos
## Uso: godot --script BasicTestExecutor.gd

func _init():
	"""Ejecuta tests básicos al inicializar"""
	print("🚀 Iniciando verificación de tests básicos...")

	# Cargar el test runner
	var test_runner_script = preload("res://tests/BasicTestRunner.gd")

	# Ejecutar tests
	var success = test_runner_script.run_basic_tests()

	if success:
		print("✅ VERIFICACIÓN COMPLETADA - SISTEMA READY")
		quit(0)  # Exit con código 0 (éxito)
	else:
		print("❌ VERIFICACIÓN FALLÓ - REVISAR SETUP")
		quit(1)  # Exit con código 1 (error)

func _ready():
	"""No usado en este contexto, pero requerido"""
	pass
