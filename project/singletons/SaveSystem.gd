extends Node
## SaveSystem - Sistema de guardado y carga para BAR-SIK
## Maneja la persistencia de datos del juego de forma centralizada

const SAVE_FILE_PATH = "user://barsik_save.dat"
const BACKUP_FILE_PATH = "user://barsik_save_backup.dat"
const BACKUP_FILE_PATH_2 = "user://barsik_save_backup_2.dat"
const BACKUP_FILE_PATH_3 = "user://barsik_save_backup_3.dat"

var current_save_data: Dictionary = {}


func _ready() -> void:
	print("💾 SaveSystem inicializado")

	# Conectar al evento de guardado cuando GameEvents esté disponible
	call_deferred("_connect_to_events")


func _connect_to_events() -> void:
	if has_node("/root/GameEvents"):
		GameEvents.save_data_requested.connect(_on_save_requested)


## Guardar datos del juego inmediatamente (para eventos críticos)
func save_game_data_immediate() -> bool:
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if game_controller and game_controller.game_data:
		return save_game_data_with_encryption(game_controller.game_data.to_dict())
	return false

## Guardar datos del juego con encriptación básica
func save_game_data_with_encryption(data: Dictionary) -> bool:
	var save_data = {
		"version": "0.2.1",
		"timestamp": Time.get_unix_time_from_system(),
		"checksum": _calculate_checksum(data),
		"game_data": data
	}

	# Rotar backups antes de guardar
	_rotate_backups()

	# Encriptar datos
	var json_string = JSON.stringify(save_data)
	var encrypted_data = _encrypt_data(json_string)

	# Guardar archivo principal
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_string(encrypted_data)
		save_file.close()
		current_save_data = save_data
		print("💾 Juego guardado con encriptación - checksum: %s" % save_data.checksum)
		return true

	print("❌ Error al guardar archivo")
	return false

## Guardar datos del juego (método original, ahora usa encriptación)
func save_game_data(data: Dictionary) -> bool:
	return save_game_data_with_encryption(data)


## Cargar datos del juego con soporte para encriptación
func load_game_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("📁 No existe archivo de guardado, devolviendo datos por defecto")
		return get_default_save_data()

	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not save_file:
		print("❌ Error al abrir archivo de guardado")
		return get_default_save_data()

	var file_content = save_file.get_as_text()
	save_file.close()

	# Intentar cargar como archivo encriptado primero
	var save_data = _try_load_encrypted(file_content)
	if save_data.is_empty():
		# Si falla, intentar como JSON plano (compatibilidad)
		save_data = _try_load_plain_json(file_content)

	if save_data.is_empty():
		print("⚠️ Error al cargar guardado, intentando backups...")
		return _try_load_backup()

	# Validar integridad con checksum si existe
	if save_data.has("checksum"):
		var calculated_checksum = _calculate_checksum(save_data.get("game_data", {}))
		if save_data.checksum != calculated_checksum:
			print("⚠️ Checksum no coincide, archivo modificado, intentando backup...")
			return _try_load_backup()

	current_save_data = save_data
	print("📁 Datos cargados exitosamente - checksum válido")

	# GameEvents puede no estar disponible aún durante la inicialización
	if has_node("/root/GameEvents"):
		GameEvents.data_loaded.emit()

	return save_data.get("game_data", _get_default_game_data())


## Obtener solo los datos de juego por defecto (sin metadatos)
func _get_default_game_data() -> Dictionary:
	return {
		"money": 50.0,
		"resources": {"barley": 0, "hops": 0, "water": 10, "yeast": 0},
		"resource_limits": {"barley": 100, "hops": 100, "water": 50, "yeast": 25},
		"products": {"basic_beer": 0, "premium_beer": 0, "cocktail": 0},
		"generators": {"barley_farm": 0, "hops_farm": 0, "water_collector": 0},
		"stations": {"brewery": 1, "bar_station": 0},
		"offers": {},
		"upgrades": {},
		"statistics": {
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


## Intentar cargar backup con múltiples opciones
func _try_load_backup() -> Dictionary:
	print("🔄 Intentando cargar backups...")

	# Intentar backup 1, 2, 3 en orden
	var backup_paths = [BACKUP_FILE_PATH, BACKUP_FILE_PATH_2, BACKUP_FILE_PATH_3]

	for i in range(backup_paths.size()):
		var backup_path = backup_paths[i]
		print("🔄 Intentando backup %d: %s" % [i + 1, backup_path])

		if not FileAccess.file_exists(backup_path):
			continue

		var backup_file = FileAccess.open(backup_path, FileAccess.READ)
		if not backup_file:
			continue

		var file_content = backup_file.get_as_text()
		backup_file.close()

		# Intentar cargar como encriptado primero
		var save_data = _try_load_encrypted(file_content)
		if save_data.is_empty():
			# Si falla, intentar como JSON plano
			save_data = _try_load_plain_json(file_content)

		if not save_data.is_empty() and _validate_save_data(save_data):
			print("✅ Backup %d cargado exitosamente" % [i + 1])
			return save_data.get("game_data", _get_default_game_data())

	print("� Todos los backups fallaron, usando datos por defecto")
	return get_default_save_data()


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
	save_game_data_immediate()

## Funciones de encriptación y seguridad
func _encrypt_data(data: String) -> String:
	# Encriptación muy simple: solo Base64 con prefijo para identificar archivos encriptados
	var prefixed_data = "BARSIK_ENC:" + data
	return Marshalls.utf8_to_base64(prefixed_data)

func _decrypt_data(encrypted_data: String) -> String:
	# Decodificar base64
	var decoded = Marshalls.base64_to_utf8(encrypted_data)
	if decoded == "":
		return ""  # Error en base64

	# Verificar prefijo
	if decoded.begins_with("BARSIK_ENC:"):
		return decoded.substr(11)  # Quitar prefijo "BARSIK_ENC:"

	return ""  # No es un archivo encriptado válido

func _calculate_checksum(data: Dictionary) -> String:
	var json_string = JSON.stringify(data)
	return str(json_string.hash())

func _try_load_encrypted(content: String) -> Dictionary:
	var decrypted = _decrypt_data(content)
	if decrypted != "":
		var json = JSON.new()
		var parse_result = json.parse(decrypted)
		if parse_result == OK:
			var data = json.get_data()
			if _validate_save_data(data):
				return data
	return {}

func _try_load_plain_json(content: String) -> Dictionary:
	var json = JSON.new()
	var parse_result = json.parse(content)
	if parse_result == OK:
		var data = json.get_data()
		if _validate_save_data(data):
			return data
	return {}

func _rotate_backups() -> void:
	# Rotar: 2→3, 1→2, principal→1
	if FileAccess.file_exists(BACKUP_FILE_PATH_2):
		DirAccess.copy_absolute(BACKUP_FILE_PATH_2, BACKUP_FILE_PATH_3)
	if FileAccess.file_exists(BACKUP_FILE_PATH):
		DirAccess.copy_absolute(BACKUP_FILE_PATH, BACKUP_FILE_PATH_2)
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.copy_absolute(SAVE_FILE_PATH, BACKUP_FILE_PATH)


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
	save_game_data_with_encryption(default_data["game_data"])  # MEJORA: Usar sistema encriptado
	print("✅ Datos reseteados exitosamente con encriptación")


## Obtener datos por defecto para nuevo juego
func get_default_save_data() -> Dictionary:
	return {
		"version": "0.3.0",
		"timestamp": Time.get_unix_time_from_system(),
		"game_data": _get_default_game_data()
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
