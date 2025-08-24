extends Node
## Script de prueba para verificar componentes refactorizados

func _ready():
	print("🧪 === PRUEBA DE COMPONENTES REFACTORIZADOS ===")

	_test_input_controller()
	_test_ui_coordinator()
	_test_event_bridge()
	_test_dev_tools_manager()
	_test_game_coordinator()

	print("✅ === TODAS LAS PRUEBAS COMPLETADAS ===")

func _test_input_controller():
	print("🎮 Probando InputController...")
	var input_ctrl = preload("res://scripts/core/refactored/InputController.gd").new()
	print("   ✅ InputController se puede instanciar")

func _test_ui_coordinator():
	print("🎨 Probando UICoordinator...")
	# No podemos instanciar Control directamente sin escena, pero podemos verificar que se carga
	var ui_coord_script = preload("res://scripts/core/refactored/UICoordinator.gd")
	print("   ✅ UICoordinator script carga correctamente")

func _test_event_bridge():
	print("🌉 Probando EventBridge...")
	var event_bridge = preload("res://scripts/core/refactored/EventBridge.gd").new()
	print("   ✅ EventBridge se puede instanciar")

func _test_dev_tools_manager():
	print("🛠️ Probando DevToolsManager...")
	var dev_tools = preload("res://scripts/core/refactored/DevToolsManager.gd").new()
	print("   ✅ DevToolsManager se puede instanciar")

func _test_game_coordinator():
	print("🎮 Probando GameCoordinator...")
	# No podemos instanciar Control directamente sin escena, pero podemos verificar que se carga
	var gc_script = preload("res://scripts/core/refactored/GameCoordinator.gd")
	print("   ✅ GameCoordinator script carga correctamente")
