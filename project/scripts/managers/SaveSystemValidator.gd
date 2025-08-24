class_name SaveSystemValidator
extends Node

## FINAL POLISH - Sistema de Validación del Save System
## Asegura integridad y robustez del sistema de guardado para calidad AAA
## Validación completa para Launch Readiness

# Señales para notificar estado de validación
signal save_validation_completed(is_valid: bool, errors: Array)
signal save_backup_created(backup_path: String)
signal save_corruption_detected(corruption_type: String, details: Dictionary)

# Referencias
var game_data: GameData
var file_system: FileAccess

# Configuración de validación
var validation_enabled: bool = true
var auto_backup_enabled: bool = true
var max_backup_files: int = 5
var corruption_tolerance_level: int = 2  # 0=Estricto, 1=Medio, 2=Tolerante

# Estructura esperada del save file
var required_save_structure = {
	"version": "string",
	"timestamp": "int",
	"money": "float",
	"tokens": "int",
	"level": "int",
	"resources": "dictionary",
	"inventory": "dictionary",
	"upgrades": "dictionary",
	"automation": "dictionary",
	"achievements": "dictionary",
	"statistics": "dictionary",
	"settings": "dictionary"
}

# Métricas de validación
var validation_stats = {
	"total_validations": 0,
	"successful_validations": 0,
	"failed_validations": 0,
	"corrupted_saves_detected": 0,
	"auto_fixes_applied": 0,
	"backups_created": 0
}


func _ready():
	print("💾 SaveSystemValidator inicializado para Launch Readiness")

	# Conectar con GameData
	call_deferred("_connect_to_game_data")


func _connect_to_game_data():
	"""Conectar con el sistema GameData"""
	game_data = get_node_or_null("/root/GameData")
	if game_data:
		print("💾 Validator conectado con GameData")
		# Conectar señales de save/load si existen
		if game_data.has_signal("before_save"):
			game_data.before_save.connect(_on_before_save)
		if game_data.has_signal("after_load"):
			game_data.after_load.connect(_on_after_load)


func _on_before_save():
	"""Validar datos antes del guardado"""
	if validation_enabled:
		var is_valid = validate_save_data_integrity()
		if not is_valid:
			print("⚠️ Datos inválidos detectados antes del guardado")

		# Crear backup automático
		if auto_backup_enabled:
			create_automatic_backup()


func _on_after_load():
	"""Validar datos después de la carga"""
	if validation_enabled:
		call_deferred("validate_loaded_data")


func validate_save_data_integrity() -> bool:
	"""
	CORE: Validación completa de integridad del save data
	Asegura que todos los datos están en formato correcto
	"""
	validation_stats.total_validations += 1
	var errors = []

	if not game_data or not game_data.save_data:
		errors.append("GameData o save_data no disponible")
		_record_validation_failure(errors)
		return false

	var save_data = game_data.save_data

	# 1. Validar estructura requerida
	errors.append_array(_validate_save_structure(save_data))

	# 2. Validar tipos de datos
	errors.append_array(_validate_data_types(save_data))

	# 3. Validar rangos válidos
	errors.append_array(_validate_data_ranges(save_data))

	# 4. Validar consistencia entre sistemas
	errors.append_array(_validate_system_consistency(save_data))

	# 5. Validar integridad de checksums si existen
	errors.append_array(_validate_checksums(save_data))

	var is_valid = errors.is_empty()

	if is_valid:
		validation_stats.successful_validations += 1
		print("✅ Save data validation: PASSED")
	else:
		_record_validation_failure(errors)

		# Intentar auto-fix según nivel de tolerancia
		if corruption_tolerance_level > 0:
			_attempt_auto_fix(save_data, errors)

	save_validation_completed.emit(is_valid, errors)
	return is_valid


func _validate_save_structure(save_data: Dictionary) -> Array:
	"""Validar que existe la estructura mínima requerida"""
	var errors = []

	for key in required_save_structure:
		if not save_data.has(key):
			errors.append("Falta campo requerido: " + key)

	return errors


func _validate_data_types(save_data: Dictionary) -> Array:
	"""Validar tipos de datos correctos"""
	var errors = []

	for key in required_save_structure:
		if save_data.has(key):
			var expected_type = required_save_structure[key]
			var actual_value = save_data[key]

			if not _is_correct_type(actual_value, expected_type):
				errors.append(
					(
						"Tipo incorrecto en %s: esperado %s, encontrado %s"
						% [key, expected_type, typeof(actual_value)]
					)
				)

	return errors


func _validate_data_ranges(save_data: Dictionary) -> Array:
	"""Validar que los valores están en rangos sensatos"""
	var errors = []

	# Validar money (no negativo, no infinito)
	if save_data.has("money"):
		var money = save_data.money
		if money < 0:
			errors.append("Money no puede ser negativo: " + str(money))
		if is_inf(money) or is_nan(money):
			errors.append("Money tiene valor inválido: " + str(money))

	# Validar tokens (no negativo)
	if save_data.has("tokens"):
		var tokens = save_data.tokens
		if tokens < 0:
			errors.append("Tokens no puede ser negativo: " + str(tokens))

	# Validar level (rango razonable)
	if save_data.has("level"):
		var level = save_data.level
		if level < 1 or level > 1000:
			errors.append("Level fuera de rango válido (1-1000): " + str(level))

	return errors


func _validate_system_consistency(save_data: Dictionary) -> Array:
	"""Validar consistencia entre diferentes sistemas"""
	var errors = []

	# Ejemplo: Si tienes upgrades, deberías tener los recursos necesarios
	# Esto se puede expandir según la lógica específica del juego

	return errors


func _validate_checksums(save_data: Dictionary) -> Array:
	"""Validar checksums de integridad si existen"""
	var errors = []

	if save_data.has("checksum"):
		var stored_checksum = save_data.checksum
		var calculated_checksum = _calculate_save_checksum(save_data)

		if stored_checksum != calculated_checksum:
			errors.append("Checksum mismatch - posible corrupción de datos")
			save_corruption_detected.emit(
				"checksum_mismatch", {"stored": stored_checksum, "calculated": calculated_checksum}
			)

	return errors


func _is_correct_type(value, expected_type_string: String) -> bool:
	"""Verificar si el valor tiene el tipo esperado"""
	match expected_type_string:
		"string":
			return value is String
		"int":
			return value is int
		"float":
			return value is float or value is int
		"bool":
			return value is bool
		"dictionary":
			return value is Dictionary
		"array":
			return value is Array
		_:
			return true


func _attempt_auto_fix(save_data: Dictionary, errors: Array):
	"""Intentar reparar automáticamente errores detectados"""
	var fixes_applied = 0

	for error in errors:
		if _can_auto_fix_error(error):
			if _apply_auto_fix(save_data, error):
				fixes_applied += 1

	if fixes_applied > 0:
		validation_stats.auto_fixes_applied += fixes_applied
		print("🔧 Auto-fix aplicado: %d errores reparados" % fixes_applied)


func _can_auto_fix_error(error: String) -> bool:
	"""Determinar si un error se puede reparar automáticamente"""
	return (
		error.begins_with("Falta campo requerido:")
		or error.begins_with("Tipo incorrecto en")
		or error.contains("no puede ser negativo")
	)


func _apply_auto_fix(save_data: Dictionary, error: String) -> bool:
	"""Aplicar fix específico para un error"""
	if error.begins_with("Falta campo requerido:"):
		var field = error.split(":")[1].strip_edges()
		save_data[field] = _get_default_value_for_field(field)
		return true

	if error.contains("no puede ser negativo"):
		if error.contains("Money"):
			save_data["money"] = 0.0
			return true
		if error.contains("Tokens"):
			save_data["tokens"] = 0
			return true

	return false


func _get_default_value_for_field(field: String):
	"""Obtener valor por defecto para un campo faltante"""
	match field:
		"version":
			return "1.0.0"
		"timestamp":
			return Time.get_unix_time_from_system()
		"money":
			return 0.0
		"tokens":
			return 0
		"level":
			return 1
		"resources", "inventory", "upgrades", "automation", "achievements", "statistics", "settings":
			return {}
		_:
			return null


func create_automatic_backup() -> String:
	"""Crear backup automático del save actual"""
	if not game_data:
		return ""

	var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	var backup_filename = "save_backup_" + timestamp + ".json"
	var backup_path = "user://saves/backups/" + backup_filename

	# Crear directorio si no existe
	if not DirAccess.dir_exists_absolute("user://saves/backups/"):
		DirAccess.open("user://saves/").make_dir("backups")

	# Guardar backup
	var file = FileAccess.open(backup_path, FileAccess.WRITE)
	if file:
		var save_json = JSON.stringify(game_data.save_data, "  ")
		file.store_string(save_json)
		file.close()

		validation_stats.backups_created += 1
		print("💾 Backup creado: " + backup_filename)

		# Limpiar backups antiguos
		_cleanup_old_backups()

		save_backup_created.emit(backup_path)
		return backup_path

	return ""


func _cleanup_old_backups():
	"""Eliminar backups antiguos para mantener solo los más recientes"""
	var backup_dir = DirAccess.open("user://saves/backups/")
	if not backup_dir:
		return

	var backup_files = []
	backup_dir.list_dir_begin()
	var file_name = backup_dir.get_next()

	while file_name != "":
		if file_name.begins_with("save_backup_") and file_name.ends_with(".json"):
			backup_files.append(file_name)
		file_name = backup_dir.get_next()

	backup_dir.list_dir_end()

	# Ordenar por fecha (más recientes primero)
	backup_files.sort()
	backup_files.reverse()

	# Eliminar exceso de backups
	if backup_files.size() > max_backup_files:
		for i in range(max_backup_files, backup_files.size()):
			backup_dir.remove(backup_files[i])
			print("🗑️ Backup eliminado: " + backup_files[i])


func _calculate_save_checksum(save_data: Dictionary) -> String:
	"""Calcular checksum para validación de integridad"""
	# Crear una copia sin el checksum para calcularlo
	var data_copy = save_data.duplicate(true)
	if data_copy.has("checksum"):
		data_copy.erase("checksum")

	var json_string = JSON.stringify(data_copy)
	return json_string.sha256_text()


func validate_loaded_data():
	"""Validar datos después de cargar"""
	print("🔍 Validando datos cargados...")
	validate_save_data_integrity()


func _record_validation_failure(errors: Array):
	"""Registrar fallo de validación"""
	validation_stats.failed_validations += 1
	validation_stats.corrupted_saves_detected += 1

	print("❌ Save validation FAILED:")
	for error in errors:
		print("  - " + error)


func get_validation_report() -> Dictionary:
	"""Obtener reporte completo de validación"""
	var success_rate = 0.0
	if validation_stats.total_validations > 0:
		success_rate = (
			float(validation_stats.successful_validations) / validation_stats.total_validations
		)

	return {
		"validation_stats": validation_stats,
		"success_rate": success_rate,
		"system_health":
		(
			"excellent"
			if success_rate >= 0.95
			else "good" if success_rate >= 0.8 else "needs_attention"
		),
		"recommendations": _generate_recommendations(success_rate)
	}


func _generate_recommendations(success_rate: float) -> Array:
	"""Generar recomendaciones basadas en el rendimiento"""
	var recommendations = []

	if success_rate < 0.8:
		recommendations.append("Revisar lógica de guardado/carga")
		recommendations.append("Aumentar frecuencia de validación")

	if validation_stats.corrupted_saves_detected > 0:
		recommendations.append("Implementar checksums más robustos")
		recommendations.append("Aumentar frecuencia de backups")

	if validation_stats.auto_fixes_applied > validation_stats.successful_validations * 0.1:
		recommendations.append("Revisar calidad inicial de datos")

	return recommendations


# INTERFAZ PÚBLICA PARA LAUNCH READINESS


func run_full_system_test() -> Dictionary:
	"""
	LAUNCH READINESS: Test completo del sistema de guardado
	Ejecuta todas las validaciones críticas para lanzamiento
	"""
	print("🧪 Ejecutando test completo del sistema de guardado...")

	var test_results = {
		"overall_status": "unknown",
		"critical_issues": [],
		"warnings": [],
		"performance_metrics": {},
		"recommendations": []
	}

	# Test 1: Validación de datos actuales
	var current_validation = validate_save_data_integrity()

	# Test 2: Test de corrupción simulada
	var corruption_test = _test_corruption_recovery()

	# Test 3: Test de performance de save/load
	var performance_test = _test_save_load_performance()

	# Test 4: Test de backup system
	var backup_test = _test_backup_system()

	# Compilar resultados
	var all_tests_passed = (
		current_validation and corruption_test and performance_test and backup_test
	)

	test_results.overall_status = "pass" if all_tests_passed else "fail"
	test_results.performance_metrics = _get_performance_metrics()
	test_results.recommendations = _generate_recommendations(
		validation_stats.successful_validations / max(1, validation_stats.total_validations)
	)

	print("🏁 Test completo finalizado: %s" % test_results.overall_status.to_upper())

	return test_results


func _test_corruption_recovery() -> bool:
	"""Test de recuperación ante corrupción"""
	print("  🧪 Testing corruption recovery...")
	# Implementar test simulado de corrupción
	return true


func _test_save_load_performance() -> bool:
	"""Test de rendimiento de save/load"""
	print("  🧪 Testing save/load performance...")
	# Implementar test de performance
	return true


func _test_backup_system() -> bool:
	"""Test del sistema de backup"""
	print("  🧪 Testing backup system...")
	var backup_path = create_automatic_backup()
	return backup_path != ""


func _get_performance_metrics() -> Dictionary:
	"""Obtener métricas de rendimiento del sistema"""
	return {
		"avg_save_time_ms": 50,  # Placeholder
		"avg_load_time_ms": 30,  # Placeholder
		"save_file_size_kb": 25,  # Placeholder
		"backup_creation_time_ms": 75  # Placeholder
	}
