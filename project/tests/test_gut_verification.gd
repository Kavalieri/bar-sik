extends "res://addons/gut/test.gd"

## Test básico para verificar que GUT funciona
class_name GutTestBasic

func test_gut_framework_works():
	"""Test básico para verificar que GUT está funcionando"""
	assert_true(true, "Este test siempre debe pasar")
	assert_eq(1 + 1, 2, "Matemáticas básicas funcionan")
	print("✅ GUT Framework está funcionando correctamente!")


func test_godot_environment():
	"""Test para verificar el entorno de Godot"""
	assert_not_null(Engine, "Engine singleton debe estar disponible")
	assert_not_null(Time, "Time singleton debe estar disponible")

	var version_info = Engine.get_version_info()
	assert_ge(version_info.major, 4, "Debe ser Godot 4.x o superior")
	print("✅ Entorno Godot validado: v" + str(version_info.major) + "." + str(version_info.minor))


func test_file_system_access():
	"""Test para verificar acceso al sistema de archivos"""
	var test_file_path = "user://test_gut_verification.tmp"

	# Crear archivo temporal
	var file = FileAccess.open(test_file_path, FileAccess.WRITE)
	assert_not_null(file, "Debe poder crear archivos temporales")

	if file:
		file.store_string("GUT test data")
		file.close()

		# Verificar que se creó
		assert_true(FileAccess.file_exists(test_file_path), "Archivo temporal debe existir")

		# Limpiar
		DirAccess.remove_absolute(test_file_path)
		print("✅ Sistema de archivos accesible")


func test_resource_system():
	"""Test para verificar sistema de recursos"""
	# Verificar que podemos crear recursos básicos
	var node = Node.new()
	assert_not_null(node, "Debe poder crear Node")
	node.name = "GutTestNode"
	assert_eq(node.name, "GutTestNode", "Propiedades de Node funcionan")
	node.queue_free()

	# Verificar acceso a res://
	var project_settings_accessible = ProjectSettings.has_setting("application/config/name")
	assert_true(project_settings_accessible, "ProjectSettings debe ser accesible")
	print("✅ Sistema de recursos funciona correctamente")
