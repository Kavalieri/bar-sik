extends Node
class_name DevToolsManager
## Herramientas de desarrollo y debugging
## Contiene funciones para facilitar desarrollo y testing

# Constantes de desarrollo
const DEV_MODE_UNLOCK_ALL = true
const DEBUG_ENABLED = true

var game_data_ref: GameData

func _ready():
	print("🛠️ DevToolsManager inicializado")
	if DEV_MODE_UNLOCK_ALL:
		print("🚀 MODO DESARROLLO ACTIVADO")

func initialize(game_data: GameData):
	"""Inicializar con referencia a game_data"""
	game_data_ref = game_data
	if DEV_MODE_UNLOCK_ALL:
		call_deferred("apply_dev_mode_unlocks")

func apply_dev_mode_unlocks():
	"""Aplicar desbloqueos de modo desarrollo"""
	if not game_data_ref:
		push_error("❌ GameData no disponible para dev unlocks")
		return
		
	print("🚀 MODO DESARROLLO - Desbloqueando características...")
	
	# Desbloquear sistemas
	game_data_ref.customer_system_unlocked = true
	game_data_ref.automation_system_unlocked = true
	game_data_ref.prestige_system_unlocked = true
	game_data_ref.research_system_unlocked = true
	game_data_ref.contracts_system_unlocked = true
	
	# Recursos para testing
	game_data_ref.money = 100000.0
	game_data_ref.prestige_tokens = 50
	game_data_ref.gems = 25
	game_data_ref.research_points = 100
	
	# Generadores/estaciones básicos
	if game_data_ref.generators.is_empty():
		game_data_ref.generators["basic_brewery"] = {
			"level": 3,
			"production_rate": 2.0,
			"active": true
		}
	
	if game_data_ref.stations.is_empty():
		game_data_ref.stations["lager_station"] = {
			"level": 2,
			"production_rate": 1.5,
			"active": true
		}
	
	print("✅ Dev unlocks aplicados")

func debug_game_info(location: String):
	"""Información de debugging sin breakpoints"""
	if not DEBUG_ENABLED:
		return
		
	print("🐛 [DEBUG] %s - GameData válido: %s" % [location, game_data_ref != null])

func debug_game_state():
	"""Debug del estado general del juego"""
	if not DEBUG_ENABLED or not game_data_ref:
		return
		
	print("📊 === DEBUG GAME STATE ===")
	print("💰 Money: %s" % game_data_ref.money)
	print("🏭 Generators: %d" % game_data_ref.generators.size())
	print("🏪 Stations: %d" % game_data_ref.stations.size())
	print("========================")

func reload_game_data():
	"""Recargar datos del juego para testing"""
	if game_data_ref:
		game_data_ref = GameData.new()
		apply_dev_mode_unlocks()
		print("🔄 GameData recargado con dev unlocks")

func take_screenshot():
	"""Tomar screenshot para debugging"""
	var image = get_viewport().get_texture().get_image()
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "screenshot_%s.png" % timestamp
	image.save_png("user://screenshots/" + filename)
	print("📸 Screenshot guardado: %s" % filename)

func is_dev_mode_active() -> bool:
	"""Verificar si el modo desarrollo está activo"""
	return DEV_MODE_UNLOCK_ALL
