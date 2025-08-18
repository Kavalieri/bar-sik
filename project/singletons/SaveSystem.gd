extends Node
## SaveSystem - Sistema de guardado y carga para BAR-SIK
## Maneja la persistencia de datos del juego de forma centralizada

const SAVE_FILE_PATH = "user://barsik_save.dat"
const BACKUP_FILE_PATH = "user://barsik_save_backup.dat"

var current_save_data: Dictionary = {}


func _ready() -> void:
	print("💾 SaveSystem inicializado")

	# Conectar al evento de guardado cuando GameEvents esté disponible
	call_deferred("_connect_to_events")


func _connect_to_events() -> void:
	if has_node("/root/GameEvents"):
		GameEvents.save_data_requested.connect(_on_save_requested)


## Guardar datos del juego
func save_game_data(data: Dictionary) -> bool:
	var save_data = {
		"version": "0.2.0", "timestamp": Time.get_unix_time_from_system(), "game_data": data
	}

	# Crear backup del archivo anterior
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var backup_success = _create_backup()
		if not backup_success:
			print("⚠️ No se pudo crear backup, pero continuando...")

	# Guardar nuevo archivo
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()
		current_save_data = save_data
		print("💾 Juego guardado exitosamente")
		return true
	else:
		print("❌ Error al guardar archivo")
		return false


## Cargar datos del juego
func load_game_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("📁 No existe archivo de guardado, devolviendo datos por defecto")
		return get_default_save_data()

	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not save_file:
		print("❌ Error al abrir archivo de guardado")
		return get_default_save_data()

	var json_string = save_file.get_as_text()
	save_file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		print("⚠️ Error al parsear guardado, intentando backup...")
		return _try_load_backup()

	var save_data = json.get_data()

	# Validar estructura del archivo
	if not _validate_save_data(save_data):
		print("⚠️ Archivo de guardado corrupto, intentando backup...")
		return _try_load_backup()

	current_save_data = save_data
	print("📁 Datos cargados exitosamente")

	# GameEvents puede no estar disponible aún durante la inicialización
	if has_node("/root/GameEvents"):
		GameEvents.data_loaded.emit()

	return save_data.get("game_data", get_default_save_data())


## Obtener datos por defecto para nuevo juego
func get_default_save_data() -> Dictionary:
	return {
		"money": 50.0,
		"resources": {"barley": 0, "hops": 0, "water": 10, "yeast": 0},
		"products": {"basic_beer": 0, "premium_beer": 0, "cocktail": 0},
		"generators": {"barley_farm": 0, "hops_farm": 0},
		"stations": {"brewery": 1, "bar_station": 0},  # Comienza con 1 cervecería desbloqueada
		"statistics":
		{
			"total_money_earned": 0.0,
			"products_sold": 0,
			"customers_served": 0,
			"resources_generated": 0
		}
	}


## Crear backup del archivo actual
func _create_backup() -> bool:
	var original_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not original_file:
		return false

	var content = original_file.get_buffer(original_file.get_length())
	original_file.close()

	var backup_file = FileAccess.open(BACKUP_FILE_PATH, FileAccess.WRITE)
	if not backup_file:
		return false

	backup_file.store_buffer(content)
	backup_file.close()
	return true


## Intentar cargar backup
func _try_load_backup() -> Dictionary:
	if not FileAccess.file_exists(BACKUP_FILE_PATH):
		print("💥 No hay backup disponible, usando datos por defecto")
		return get_default_save_data()

	var backup_file = FileAccess.open(BACKUP_FILE_PATH, FileAccess.READ)
	if not backup_file:
		print("💥 Error al abrir backup, usando datos por defecto")
		return get_default_save_data()

	var json_string = backup_file.get_as_text()
	backup_file.close()

	var json = JSON.new()
	if json.parse(json_string) != OK:
		print("💥 Backup también corrupto, usando datos por defecto")
		return get_default_save_data()

	var backup_data = json.get_data()
	if not _validate_save_data(backup_data):
		print("💥 Backup inválido, usando datos por defecto")
		return get_default_save_data()

	print("🔄 Backup cargado exitosamente")
	return backup_data.get("game_data", get_default_save_data())


## Validar estructura del archivo de guardado
func _validate_save_data(data: Dictionary) -> bool:
	if not data.has("version"):
		return false
	if not data.has("game_data"):
		return false
	if not data["game_data"].has("money"):
		return false
	if not data["game_data"].has("resources"):
		return false
	if not data["game_data"].has("products"):
		return false
	return true


## Callback para evento de guardado
func _on_save_requested() -> void:
	print("💾 Guardado solicitado por evento")


## Guardar al salir del juego
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("💾 Guardando al cerrar aplicación...")
		# El GameManager debería manejar el guardado real


## GESTIÓN DE SLOTS Y RESET
## Resetear a valores por defecto
func reset_to_defaults() -> void:
	print("🗑️ Reseteando datos a valores por defecto...")
	var default_data = get_default_save_data()
	save_game_data(default_data["game_data"])
	print("✅ Datos reseteados exitosamente")


## Obtener datos por defecto para nuevo juego
func get_default_save_data() -> Dictionary:
	return {
		"version": "0.2.0",
		"timestamp": Time.get_unix_time_from_system(),
		"game_data":
		{
			"money": 50.0,
			"resources": {"water": 10, "barley": 5, "hops": 3, "basic_beer": 0, "premium_beer": 0},
			"generators": {"barley_farm": 0, "hops_farm": 0},
			"stations": {"brewery": 1, "bar_station": 0}
		}
	}


## Crear nuevo slot de guardado (funcionalidad básica)
func create_new_slot(slot_name: String = "") -> void:
	print("💾 Creando nuevo slot: ", slot_name if slot_name != "" else "Sin nombre")
	reset_to_defaults()


## Cambiar slot activo (funcionalidad básica)
func switch_to_slot(slot_id: int) -> void:
	print("🔄 Cambiando a slot: ", slot_id)
	# Por ahora solo carga los datos actuales
	load_game_data()
