extends Node
## Sistema de navegación entre escenas
## Maneja la transición suave entre diferentes pantallas del juego

# Referencia a la escena actual
var current_scene: Node = null

# Rutas de escenas principales
const SCENES = {
	"splash": "res://scenes/SplashScreen.tscn",
	"main_menu": "res://scenes/MainMenu.tscn",
	"game": "res://scenes/GameScene.tscn",
	"pause": "res://scenes/PauseMenu.tscn",
	"settings": "res://scenes/SettingsMenu.tscn",
	"credits": "res://scenes/Credits.tscn"
}


func _ready() -> void:
	print("🧭 Router inicializado")

	# Obtener la escena actual
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)


## Navegar a una nueva escena
func goto_scene(scene_key: String) -> void:
	if not SCENES.has(scene_key):
		push_error("❌ Escena no encontrada: " + scene_key)
		return

	var scene_path = SCENES[scene_key]
	goto_scene_path(scene_path)


## Navegar usando ruta directa
func goto_scene_path(scene_path: String) -> void:
	print("🔄 Cambiando a escena: ", scene_path)

	# Verificar que el archivo existe
	if not FileAccess.file_exists(scene_path):
		push_error("❌ Archivo de escena no encontrado: " + scene_path)
		return

	# Esta función se ejecuta en un hilo diferente para evitar bloqueos
	call_deferred("_deferred_goto_scene", scene_path)


## Función interna para cambio diferido de escena
func _deferred_goto_scene(scene_path: String) -> void:
	# Liberar la escena actual
	if current_scene:
		current_scene.queue_free()

	# Cargar la nueva escena
	var new_scene_resource = load(scene_path)
	if not new_scene_resource:
		push_error("❌ No se pudo cargar la escena: " + scene_path)
		return

	# Instanciar la nueva escena
	current_scene = new_scene_resource.instantiate()

	# Añadirla al árbol de escenas
	get_tree().root.add_child(current_scene)

	# Hacer que sea la escena actual
	get_tree().current_scene = current_scene

	print("✅ Escena cargada exitosamente")


## Recargar la escena actual
func reload_current_scene() -> void:
	if current_scene and current_scene.scene_file_path:
		goto_scene_path(current_scene.scene_file_path)
	else:
		push_error("❌ No se puede recargar: escena actual no válida")


## Verificar si una escena existe
func scene_exists(scene_key: String) -> bool:
	if not SCENES.has(scene_key):
		return false
	return FileAccess.file_exists(SCENES[scene_key])


## Obtener el nombre de la escena actual
func get_current_scene_name() -> String:
	if current_scene:
		return current_scene.name
	return ""


## Salir del juego (con confirmación en debug)
func quit_game() -> void:
	print("🚪 Saliendo del juego...")
	get_tree().quit()


## GESTIÓN DE GUARDADO
## Resetear datos de guardado
func reset_save_data() -> void:
	print("🗑️ Reseteando datos de guardado...")
	if SaveSystem:
		SaveSystem.reset_to_defaults()
		# Recargar escena actual para aplicar cambios
		reload_current_scene()


## Crear nuevo slot de guardado
func create_new_save_slot(slot_name: String = "") -> void:
	print("💾 Creando nuevo slot de guardado...")
	if SaveSystem:
		SaveSystem.create_new_slot(slot_name)


## Cambiar slot activo
func switch_save_slot(slot_id: int) -> void:
	print("🔄 Cambiando a slot de guardado: ", slot_id)
	if SaveSystem:
		SaveSystem.switch_to_slot(slot_id)
		reload_current_scene()
