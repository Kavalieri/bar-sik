class_name AudioManager
extends Node

## T032 - Sistema de Audio Profesional
## Controla SFX, música y feedback auditivo

# Señales
signal sfx_played(sfx_id: String)
signal music_started(track_id: String)
signal music_stopped(track_id: String)
signal audio_error(error_msg: String)

# Diccionarios de assets
var sfx_assets: Dictionary = {}
var music_tracks: Dictionary = {}

# Estado
var current_music: String = ""
var music_enabled: bool = true
var sfx_enabled: bool = true
var master_volume: float = 0.8
var sfx_volume: float = 0.7
var music_volume: float = 0.5

# Referencias
var game_data: GameData

# Audio players persistentes
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer


func _ready():
	print("🔊 AudioManager inicializado (T032)")
	_setup_audio_buses()
	_setup_audio_players()
	_load_synthetic_assets()
	_connect_game_events()


func _load_assets():
	# Cargar assets de SFX y música
	# Ejemplo: sfx_assets["button_click"] = preload("res://audio/sfx/button_click.wav")
	# music_tracks["ambient"] = preload("res://audio/music/ambient_brewery.ogg")
	pass


func _setup_audio_buses():
	"""Configurar buses de audio para mejor control"""
	# Los buses se configuran en el AudioBusLayout del proyecto
	# Master -> SFX, Music, UI
	pass


func _setup_audio_players():
	"""Configurar audio players persistentes"""
	# Music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

	# SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)


func _load_synthetic_assets():
	"""Crear assets de audio sintéticos para prototipo"""
	# Por ahora usamos AudioStreamGenerator para crear sonidos sintéticos
	_create_synthetic_sfx()


func _create_synthetic_sfx():
	"""Crear efectos de sonido sintéticos usando AudioStreamGenerator"""
	# SFX UI - Click de botón
	var button_click = AudioStreamGenerator.new()
	button_click.mix_rate = 22050
	sfx_assets["button_click"] = button_click

	# SFX Game - Purchase success
	var purchase_success = AudioStreamGenerator.new()
	purchase_success.mix_rate = 22050
	sfx_assets["purchase_success"] = purchase_success

	# SFX Game - Production complete
	var production_complete = AudioStreamGenerator.new()
	production_complete.mix_rate = 22050
	sfx_assets["production_complete"] = production_complete

	# SFX Game - Customer purchase
	var customer_purchase = AudioStreamGenerator.new()
	customer_purchase.mix_rate = 22050
	sfx_assets["customer_purchase"] = customer_purchase

	# SFX Game - Error
	var error_sound = AudioStreamGenerator.new()
	error_sound.mix_rate = 22050
	sfx_assets["error"] = error_sound

	# SFX Game - Achievement unlocked
	var achievement_unlock = AudioStreamGenerator.new()
	achievement_unlock.mix_rate = 22050
	sfx_assets["achievement_unlock"] = achievement_unlock

	# SFX Game - Prestige
	var prestige_sound = AudioStreamGenerator.new()
	prestige_sound.mix_rate = 22050
	sfx_assets["prestige"] = prestige_sound

	print("🎵 Assets de audio sintéticos creados: ", sfx_assets.keys().size())


func _connect_game_events():
	"""Conectar eventos del juego con audio feedback"""
	# Se conectarán automáticamente cuando los managers estén disponibles
	call_deferred("_delayed_connect_events")


func _delayed_connect_events():
	"""Conexión diferida de eventos cuando todos los managers están listos"""
	var game_controller = get_node_or_null("/root/GameController")
	if not game_controller:
		return

	# Conectar con managers si existen
	var achievement_manager = game_controller.get("achievement_manager")
	if achievement_manager and achievement_manager.has_signal("achievement_unlocked"):
		achievement_manager.achievement_unlocked.connect(_on_achievement_unlocked)
		print("🔗 AudioManager conectado con AchievementManager")

	var mission_manager = game_controller.get("mission_manager")
	if mission_manager and mission_manager.has_signal("mission_completed"):
		mission_manager.mission_completed.connect(_on_mission_completed)
		print("🔗 AudioManager conectado con MissionManager")

	var prestige_manager = game_controller.get("prestige_manager")
	if prestige_manager and prestige_manager.has_signal("prestige_completed"):
		prestige_manager.prestige_completed.connect(_on_prestige_completed)
		print("🔗 AudioManager conectado con PrestigeManager")


## === SFX ===
func play_sfx(sfx_id: String, volume_db: float = -6.0):
	if not sfx_enabled:
		return
	if not sfx_assets.has(sfx_id):
		audio_error.emit("SFX no encontrado: %s" % sfx_id)
		return

	var sfx_stream = sfx_assets[sfx_id]
	sfx_player.stream = sfx_stream
	sfx_player.volume_db = volume_db * sfx_volume
	sfx_player.play()
	sfx_played.emit(sfx_id)


## === MÚSICA ===
func play_music(track_id: String, volume_db: float = -12.0, loop: bool = true):
	if not music_enabled:
		return
	if not music_tracks.has(track_id):
		audio_error.emit("Música no encontrada: %s" % track_id)
		return

	_stop_current_music()
	var music_stream = music_tracks[track_id]
	music_player.stream = music_stream
	music_player.volume_db = volume_db * music_volume
	music_player.play()
	current_music = track_id
	music_started.emit(track_id)


func _stop_current_music():
	if music_player.playing:
		music_player.stop()
		music_stopped.emit(current_music)
	current_music = ""


func stop_music():
	_stop_current_music()


## === EVENT HANDLERS ===


func _on_achievement_unlocked(achievement_id: String, achievement_data: Dictionary):
	"""Reproduce sonido cuando se desbloquea un logro"""
	play_sfx("achievement_unlock", -3.0)  # Más alto para celebración
	print("🎵 SFX: Achievement unlocked - ", achievement_data.get("name", achievement_id))


func _on_mission_completed(mission_id: String, mission_data: Dictionary):
	"""Reproduce sonido cuando se completa una misión"""
	play_sfx("purchase_success", -6.0)
	print("🎵 SFX: Mission completed - ", mission_data.get("title", mission_id))


func _on_prestige_completed(prestige_data: Dictionary):
	"""Reproduce sonido especial para prestigio"""
	play_sfx("prestige", -3.0)  # Sonido triumphante
	print("🎵 SFX: Prestige completed!")


func _on_button_click():
	"""Reproduce click de botón - llamar desde UI"""
	play_sfx("button_click", -8.0)


func _on_purchase_made(amount: float):
	"""Reproduce sonido de compra exitosa"""
	play_sfx("purchase_success", -6.0)
	print("🎵 SFX: Purchase made: $", amount)


func _on_production_complete(beer_type: String, amount: int):
	"""Reproduce sonido de producción completada"""
	play_sfx("production_complete", -6.0)
	print("🎵 SFX: Production complete: ", amount, " ", beer_type)


func _on_customer_purchase(customer_type: String, amount: float):
	"""Reproduce sonido de cliente comprando"""
	play_sfx("customer_purchase", -4.0)  # Satisfactorio
	print("🎵 SFX: Customer purchase: ", customer_type, " - $", amount)


func _on_error_occurred(error_msg: String):
	"""Reproduce sonido de error"""
	play_sfx("error", -6.0)
	print("🎵 SFX: Error - ", error_msg)


## === CONFIGURACIÓN ===
func set_music_enabled(enabled: bool):
	music_enabled = enabled
	if not enabled:
		stop_music()


func set_sfx_enabled(enabled: bool):
	sfx_enabled = enabled


func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()


func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()


func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()


func _update_volumes():
	"""Actualizar volúmenes de todos los audio players"""
	if music_player:
		music_player.volume_db = linear_to_db(music_volume * master_volume)
	if sfx_player:
		sfx_player.volume_db = linear_to_db(sfx_volume * master_volume)


## === API PÚBLICAS PARA MANAGERS ===


func play_ui_click():
	"""Sonido para clicks de UI"""
	_on_button_click()


func play_purchase_sound(amount: float):
	"""Sonido para compras exitosas"""
	_on_purchase_made(amount)


func play_production_sound(beer_type: String, amount: int):
	"""Sonido para producción completada"""
	_on_production_complete(beer_type, amount)


func play_customer_sound(customer_type: String, amount: float):
	"""Sonido para cliente comprando"""
	_on_customer_purchase(customer_type, amount)


func play_error_sound(error_msg: String):
	"""Sonido para errores"""
	_on_error_occurred(error_msg)


func play_achievement_sound(achievement_name: String):
	"""Sonido para logros desbloqueados"""
	_on_achievement_unlocked("", {"name": achievement_name})


func play_prestige_sound():
	"""Sonido para prestigio completado"""
	_on_prestige_completed({})


## === UTILIDADES ===
func preload_sfx_asset(sfx_id: String, asset_stream: AudioStream):
	"""Agregar un asset de SFX desde código"""
	sfx_assets[sfx_id] = asset_stream


func preload_music_asset(track_id: String, asset_stream: AudioStream):
	"""Agregar un asset de música desde código"""
	music_tracks[track_id] = asset_stream


## === INTEGRATION CON SAVE SYSTEM ===
func to_dict() -> Dictionary:
	"""Serializar configuración de audio"""
	return {
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled,
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume
	}


func from_dict(data: Dictionary):
	"""Deserializar configuración de audio"""
	music_enabled = data.get("music_enabled", true)
	sfx_enabled = data.get("sfx_enabled", true)
	master_volume = data.get("master_volume", 0.8)
	sfx_volume = data.get("sfx_volume", 0.7)
	music_volume = data.get("music_volume", 0.5)
	_update_volumes()


## === GAME DATA INTEGRATION ===
func set_game_data(data: GameData):
	"""Conectar con GameData para estadísticas"""
	game_data = data
