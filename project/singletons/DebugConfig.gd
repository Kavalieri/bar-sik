extends Node
## DebugConfig - Configuración centralizada de debug
## Controla si el código debug debe ejecutarse o no

# Flag global de debug - CAMBIAR A false EN PRODUCCIÓN
const DEBUG_ENABLED: bool = true

# Flags específicos por sistema
const DEBUG_PRINTS: bool = DEBUG_ENABLED
const DEBUG_TESTS: bool = DEBUG_ENABLED and false  # Tests deshabilitados por defecto
const DEBUG_GENERATION: bool = DEBUG_ENABLED
const DEBUG_PERSISTENCE: bool = DEBUG_ENABLED

# Función helper para debug condicional
static func debug_print(message: String, system: String = "GENERAL") -> void:
	if DEBUG_PRINTS:
		print("[DEBUG-%s] %s" % [system.to_upper(), message])

# Función para verificar si los tests deben ejecutarse
static func should_run_tests() -> bool:
	return DEBUG_TESTS

# Función para verificar si el debug de sistema específico está activo
static func is_system_debug_enabled(system: String) -> bool:
	match system.to_lower():
		"generation":
			return DEBUG_GENERATION
		"persistence":
			return DEBUG_PERSISTENCE
		"prints":
			return DEBUG_PRINTS
		"tests":
			return DEBUG_TESTS
		_:
			return DEBUG_ENABLED
