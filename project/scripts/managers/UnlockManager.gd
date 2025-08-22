class_name UnlockManager
extends Node

## T031 - Sistema de Desbloqueos Progresivos Profesional
## Controla cuando se desbloquean features para mantener engagement

# Señales para notificar desbloqueos
signal feature_unlocked(feature_id: String, feature_data: Dictionary)
signal unlock_notification(unlock_data: Dictionary)
signal unlock_conditions_met(feature_id: String, conditions: Dictionary)
signal progress_towards_unlock(feature_id: String, progress: Dictionary)

# Referencia a GameData
var game_data: GameData

# Estado de desbloqueos
var unlocked_features: Dictionary = {}
var unlock_definitions: Dictionary = {}
var unlock_conditions: Dictionary = {}

# Tracking de progreso
var feature_progress: Dictionary = {}

# Constantes para fases del juego
enum GamePhase {
	EARLY,      # 0-30 minutos
	MID,        # 30-120 minutos
	LATE,       # 2+ horas
	ENDGAME     # Post-prestige avanzado
}

var current_phase: GamePhase = GamePhase.EARLY

func _ready():
	print("🔓 UnlockManager inicializado (T031 - Progressive Unlocks)")
	_init_unlock_definitions()
	_init_default_unlocks()

	# Timer para verificar condiciones de desbloqueo
	var check_timer = Timer.new()
	check_timer.wait_time = 5.0  # Verificar cada 5 segundos
	check_timer.timeout.connect(_check_unlock_conditions)
	check_timer.autostart = true
	add_child(check_timer)


func _init_unlock_definitions():
	"""Define todas las condiciones de desbloqueo del juego"""

	# === EARLY GAME (0-30 min) ===
	unlock_definitions["customers"] = {
		"id": "customers",
		"name": "Sistema de Clientes",
		"description": "Desbloquea clientes automáticos que compran tu cerveza",
		"phase": GamePhase.EARLY,
		"icon": "👥",
		"conditions": {
			"total_money_earned": 100.0,
			"beers_produced": 50
		},
		"unlocks": ["CustomerPanel", "customer_upgrades"],
		"notification": "¡Clientes desbloqueados! Ahora generarás dinero automáticamente."
	}

	unlock_definitions["basic_automation"] = {
		"id": "basic_automation",
		"name": "Automatización Básica",
		"description": "Desbloquea el panel de automatización básico",
		"phase": GamePhase.EARLY,
		"icon": "🤖",
		"conditions": {
			"total_money_earned": 500.0,
			"customers_unlocked": true
		},
		"unlocks": ["AutomationPanel", "auto_production"],
		"notification": "¡Automatización disponible! Tus generadores trabajarán solos."
	}

	unlock_definitions["upgrades"] = {
		"id": "upgrades",
		"name": "Sistema de Mejoras",
		"description": "Desbloquea mejoras permanentes para optimizar producción",
		"phase": GamePhase.EARLY,
		"icon": "⬆️",
		"conditions": {
			"total_money_earned": 1000.0,
			"basic_automation_unlocked": true
		},
		"unlocks": ["UpgradePanel", "permanent_bonuses"],
		"notification": "¡Mejoras desbloqueadas! Optimiza tu producción permanentemente."
	}

	# === MID GAME (30-120 min) ===
	unlock_definitions["advanced_automation"] = {
		"id": "advanced_automation",
		"name": "Automatización Avanzada",
		"description": "Desbloquea sistemas de automatización complejos",
		"phase": GamePhase.MID,
		"icon": "🔧",
		"conditions": {
			"total_money_earned": 10000.0,
			"upgrades_purchased": 5,
			"playtime_minutes": 30
		},
		"unlocks": ["AdvancedAutomation", "auto_sell", "bulk_operations"],
		"notification": "¡Automatización avanzada! Tu negocio casi se maneja solo."
	}

	unlock_definitions["prestige"] = {
		"id": "prestige",
		"name": "Sistema de Prestigio",
		"description": "Reinicia el progreso por bonos permanentes masivos",
		"phase": GamePhase.MID,
		"icon": "⭐",
		"conditions": {
			"total_money_earned": 100000.0,
			"advanced_automation_unlocked": true,
			"playtime_minutes": 60
		},
		"unlocks": ["PrestigeSystem", "star_bonuses", "meta_progression"],
		"notification": "¡PRESTIGIO DISPONIBLE! Reinicia por bonos permanentes enormes."
	}

	unlock_definitions["tokens"] = {
		"id": "tokens",
		"name": "Sistema de Tokens",
		"description": "Desbloquea la segunda moneda para upgrades premium",
		"phase": GamePhase.MID,
		"icon": "🪙",
		"conditions": {
			"prestige_completed": 1,
			"prestige_stars": 10
		},
		"unlocks": ["TokenEconomy", "premium_upgrades", "token_generators"],
		"notification": "¡Tokens desbloqueados! Nueva moneda para mejoras premium."
	}

	unlock_definitions["achievements"] = {
		"id": "achievements",
		"name": "Sistema de Logros",
		"description": "Desbloquea logros y metas para progresar",
		"phase": GamePhase.MID,
		"icon": "🏆",
		"conditions": {
			"prestige_completed": 1,
			"tokens_earned": 100
		},
		"unlocks": ["AchievementPanel", "achievement_rewards", "progression_tracking"],
		"notification": "¡Logros desbloqueados! Completa objetivos por recompensas."
	}

	unlock_definitions["missions"] = {
		"id": "missions",
		"name": "Sistema de Misiones",
		"description": "Desbloquea misiones diarias y semanales",
		"phase": GamePhase.MID,
		"icon": "📋",
		"conditions": {
			"achievements_unlocked": true,
			"achievements_completed": 3,
			"playtime_minutes": 90
		},
		"unlocks": ["MissionPanel", "daily_missions", "weekly_missions"],
		"notification": "¡Misiones desbloqueadas! Objetivos diarios y semanales disponibles."
	}

	# === LATE GAME (2+ horas) ===
	unlock_definitions["gems"] = {
		"id": "gems",
		"name": "Sistema de Gemas",
		"description": "Desbloquea la moneda premium para upgrades élite",
		"phase": GamePhase.LATE,
		"icon": "💎",
		"conditions": {
			"prestige_completed": 3,
			"prestige_stars": 100,
			"missions_unlocked": true
		},
		"unlocks": ["GemEconomy", "premium_features", "elite_upgrades"],
		"notification": "¡GEMAS DESBLOQUEADAS! Moneda premium para características élite."
	}

	unlock_definitions["advanced_prestige"] = {
		"id": "advanced_prestige",
		"name": "Prestigio Avanzado",
		"description": "Desbloquea bonos de prestigio más poderosos",
		"phase": GamePhase.LATE,
		"icon": "⭐⭐",
		"conditions": {
			"prestige_completed": 5,
			"prestige_stars": 250,
			"gems_earned": 100
		},
		"unlocks": ["AdvancedPrestigeBonuses", "star_multipliers", "prestige_automation"],
		"notification": "¡Prestigio Avanzado! Bonos de prestigio mucho más poderosos."
	}

	unlock_definitions["research"] = {
		"id": "research",
		"name": "Árbol de Investigación",
		"description": "Desbloquea investigaciones permanentes especializadas",
		"phase": GamePhase.LATE,
		"icon": "🧬",
		"conditions": {
			"advanced_prestige_unlocked": true,
			"gems_spent": 500,
			"playtime_minutes": 180
		},
		"unlocks": ["ResearchTree", "specialized_bonuses", "research_automation"],
		"notification": "¡Investigación desbloqueada! Especializa tu estrategia."
	}

	# === ENDGAME (Post-prestige avanzado) ===
	unlock_definitions["contracts"] = {
		"id": "contracts",
		"name": "Sistema de Contratos",
		"description": "Desbloquea contratos temporales por recompensas masivas",
		"phase": GamePhase.ENDGAME,
		"icon": "📝",
		"conditions": {
			"research_unlocked": true,
			"prestige_completed": 10,
			"prestige_stars": 500
		},
		"unlocks": ["ContractSystem", "timed_challenges", "massive_rewards"],
		"notification": "¡CONTRATOS DISPONIBLES! Desafíos temporales por recompensas masivas."
	}

	unlock_definitions["events"] = {
		"id": "events",
		"name": "Sistema de Eventos",
		"description": "Desbloquea eventos limitados con bonos especiales",
		"phase": GamePhase.ENDGAME,
		"icon": "🎉",
		"conditions": {
			"contracts_unlocked": true,
			"contracts_completed": 3,
			"total_playtime_hours": 10
		},
		"unlocks": ["EventSystem", "limited_bonuses", "seasonal_content"],
		"notification": "¡EVENTOS DESBLOQUEADOS! Contenido temporal con bonos únicos."
	}


func _init_default_unlocks():
	"""Inicializa features que están desbloqueadas desde el inicio"""
	unlocked_features["generators"] = true
	unlocked_features["basic_ui"] = true
	unlocked_features["save_system"] = true
	unlocked_features["settings"] = true


func _check_unlock_conditions():
	"""Verifica continuamente las condiciones de desbloqueo"""
	if not game_data:
		return

	for feature_id in unlock_definitions.keys():
		if not is_unlocked(feature_id):
			var definition = unlock_definitions[feature_id]
			var conditions = definition["conditions"]
			var progress = _evaluate_conditions(conditions)

			# Actualizar progreso
			feature_progress[feature_id] = progress

			# Verificar si se cumplieron todas las condiciones
			if _all_conditions_met(progress):
				_unlock_feature(feature_id)
			else:
				# Emitir progreso hacia desbloqueo
				progress_towards_unlock.emit(feature_id, progress)

	# Actualizar fase del juego
	_update_game_phase()


func _evaluate_conditions(conditions: Dictionary) -> Dictionary:
	"""Evalúa el progreso hacia cumplir las condiciones"""
	var progress = {}

	for condition_key in conditions.keys():
		var required_value = conditions[condition_key]
		var current_value = _get_condition_value(condition_key)

		progress[condition_key] = {
			"current": current_value,
			"required": required_value,
			"met": _condition_met(current_value, required_value),
			"progress_ratio": _calculate_progress_ratio(current_value, required_value)
		}

	return progress


func _get_condition_value(condition_key: String):
	"""Obtiene el valor actual de una condición específica"""
	match condition_key:
		"total_money_earned":
			return game_data.statistics.get("total_money_earned", 0.0)
		"beers_produced":
			return game_data.statistics.get("total_beers_produced", 0)
		"customers_unlocked":
			return is_unlocked("customers")
		"basic_automation_unlocked":
			return is_unlocked("basic_automation")
		"upgrades_purchased":
			return game_data.statistics.get("upgrades_purchased", 0)
		"playtime_minutes":
			return game_data.statistics.get("total_playtime", 0) / 60.0
		"prestige_completed":
			return game_data.statistics.get("prestige_count", 0)
		"prestige_stars":
			return game_data.prestige_stars
		"tokens_earned":
			return game_data.statistics.get("total_tokens_earned", 0)
		"achievements_unlocked":
			return is_unlocked("achievements")
		"achievements_completed":
			return game_data.statistics.get("achievements_completed", 0)
		"missions_unlocked":
			return is_unlocked("missions")
		"gems_earned":
			return game_data.statistics.get("total_gems_earned", 0)
		"gems_spent":
			return game_data.statistics.get("total_gems_spent", 0)
		"advanced_prestige_unlocked":
			return is_unlocked("advanced_prestige")
		"research_unlocked":
			return is_unlocked("research")
		"contracts_unlocked":
			return is_unlocked("contracts")
		"contracts_completed":
			return game_data.statistics.get("contracts_completed", 0)
		"total_playtime_hours":
			return game_data.statistics.get("total_playtime", 0) / 3600.0
		_:
			print("⚠️ Condición desconocida: ", condition_key)
			return 0


func _condition_met(current, required) -> bool:
	"""Verifica si una condición individual está cumplida"""
	if typeof(required) == TYPE_BOOL:
		return current == required
	else:
		return current >= required


func _calculate_progress_ratio(current, required) -> float:
	"""Calcula el ratio de progreso (0.0 - 1.0)"""
	if typeof(required) == TYPE_BOOL:
		return 1.0 if current == required else 0.0
	else:
		if required <= 0:
			return 1.0
		return min(float(current) / float(required), 1.0)


func _all_conditions_met(progress: Dictionary) -> bool:
	"""Verifica si todas las condiciones están cumplidas"""
	for condition in progress.values():
		if not condition["met"]:
			return false
	return true


func _unlock_feature(feature_id: String):
	"""Desbloquea una característica y emite notificaciones"""
	if is_unlocked(feature_id):
		return  # Ya desbloqueada

	unlocked_features[feature_id] = true
	var definition = unlock_definitions[feature_id]

	print("🔓 FEATURE DESBLOQUEADA: ", definition["name"])

	# Emitir señales
	feature_unlocked.emit(feature_id, definition)
	unlock_notification.emit({
		"title": "¡Nuevo Desbloqueo!",
		"message": definition["notification"],
		"icon": definition["icon"],
		"feature_id": feature_id
	})

	# Actualizar estadísticas
	if not game_data.statistics.has("features_unlocked"):
		game_data.statistics["features_unlocked"] = 0
	game_data.statistics["features_unlocked"] += 1


func _update_game_phase():
	"""Actualiza la fase actual del juego basada en progreso"""
	var old_phase = current_phase

	var playtime_minutes = game_data.statistics.get("total_playtime", 0) / 60.0
	var prestige_count = game_data.statistics.get("prestige_count", 0)

	if prestige_count >= 10:
		current_phase = GamePhase.ENDGAME
	elif playtime_minutes >= 120 or prestige_count >= 3:
		current_phase = GamePhase.LATE
	elif playtime_minutes >= 30 or prestige_count >= 1:
		current_phase = GamePhase.MID
	else:
		current_phase = GamePhase.EARLY

	if old_phase != current_phase:
		print("📈 Fase del juego actualizada: ", GamePhase.keys()[current_phase])


## === API PÚBLICAS ===

func is_unlocked(feature_id: String) -> bool:
	"""Verifica si una característica está desbloqueada"""
	return unlocked_features.get(feature_id, false)


func get_unlock_progress(feature_id: String) -> Dictionary:
	"""Obtiene el progreso hacia desbloquear una característica"""
	return feature_progress.get(feature_id, {})


func get_available_unlocks() -> Array:
	"""Obtiene lista de desbloqueos disponibles próximamente"""
	var available = []

	for feature_id in unlock_definitions.keys():
		if not is_unlocked(feature_id):
			var progress = get_unlock_progress(feature_id)
			var total_progress = 0.0
			var conditions_count = 0

			for condition in progress.values():
				total_progress += condition["progress_ratio"]
				conditions_count += 1

			if conditions_count > 0:
				var avg_progress = total_progress / conditions_count
				if avg_progress > 0.1:  # Al menos 10% de progreso
					available.append({
						"feature_id": feature_id,
						"definition": unlock_definitions[feature_id],
						"progress": avg_progress,
						"conditions_progress": progress
					})

	# Ordenar por progreso descendente
	available.sort_custom(func(a, b): return a["progress"] > b["progress"])
	return available


func get_unlocked_features() -> Array:
	"""Obtiene lista de todas las características desbloqueadas"""
	var unlocked = []
	for feature_id in unlocked_features.keys():
		if unlocked_features[feature_id]:
			unlocked.append(feature_id)
	return unlocked


func get_current_phase() -> GamePhase:
	"""Obtiene la fase actual del juego"""
	return current_phase


func force_unlock(feature_id: String) -> bool:
	"""Fuerza el desbloqueo de una característica (para debug/testing)"""
	if unlock_definitions.has(feature_id):
		_unlock_feature(feature_id)
		return true
	return false


## === INTEGRACIÓN CON SAVE SYSTEM ===

func to_dict() -> Dictionary:
	"""Serializa el estado para guardado"""
	return {
		"unlocked_features": unlocked_features.duplicate(true),
		"feature_progress": feature_progress.duplicate(true),
		"current_phase": current_phase
	}


func from_dict(data: Dictionary) -> void:
	"""Deserializa el estado desde guardado"""
	unlocked_features = data.get("unlocked_features", {})
	feature_progress = data.get("feature_progress", {})
	current_phase = data.get("current_phase", GamePhase.EARLY)

	# Asegurar desbloqueos por defecto
	_init_default_unlocks()


## === UTILIDADES DE DEBUG ===

func print_unlock_status():
	"""Imprime el estado actual de desbloqueos (debug)"""
	print("🔓 === ESTADO DE DESBLOQUEOS ===")
	print("Fase actual: ", GamePhase.keys()[current_phase])
	print("Features desbloqueadas: ", get_unlocked_features().size(), "/", unlock_definitions.size())

	for feature_id in unlock_definitions.keys():
		var status = "✅" if is_unlocked(feature_id) else "❌"
		var name = unlock_definitions[feature_id]["name"]
		print("  ", status, " ", feature_id, " (", name, ")")
