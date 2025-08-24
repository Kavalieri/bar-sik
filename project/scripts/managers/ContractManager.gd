class_name ContractManager
extends Node

## T036 - Sistema de Contratos
## Timed challenges con rewards especiales para engaged players

# Señales
signal contract_available(contract_id: String, contract_data: Dictionary)
signal contract_accepted(contract_id: String)
signal contract_progress_updated(contract_id: String, progress: float)
signal contract_completed(contract_id: String, rewards: Dictionary)
signal contract_expired(contract_id: String)
signal contract_failed(contract_id: String)

# Referencias
var game_data: GameData
var statistics_manager: StatisticsManager

# Estado de contratos
var available_contracts: Dictionary = {}
var active_contracts: Dictionary = {}
var completed_contracts: Array = []
var contract_templates: Dictionary = {}

# Sistema de generación
var contract_generation_timer: Timer
var next_contract_time: int = 0

# Constantes
const MIN_CONTRACTS_AVAILABLE = 2
const MAX_CONTRACTS_AVAILABLE = 4
const CONTRACT_GENERATION_INTERVAL = 3600  # 1 hora
const CONTRACT_DURATION_BASE = 1800  # 30 minutos base


func _ready():
	print("📋 ContractManager inicializado (T036)")
	_initialize_contract_templates()
	_setup_contract_generation()
	_generate_initial_contracts()


func _initialize_contract_templates():
	"""Define plantillas de contratos disponibles"""

	contract_templates = {
		# === CONTRATOS DE PRODUCCIÓN ===
		"production_rush":
		{
			"type": "production",
			"name": "Fiebre de Producción",
			"description": "Produce {target} cervezas en {time} minutos",
			"icon": "🍺",
			"difficulty": "normal",
			"base_target": 100,
			"time_limit": CONTRACT_DURATION_BASE,
			"rewards": {"money": 1000, "tokens": 5, "experience": 50},
			"scaling": {"target_multiplier": 1.5, "reward_multiplier": 1.3, "time_bonus": 0.9}  # Reducir tiempo para mayor dificultad
		},
		"quality_challenge":
		{
			"type": "production",
			"name": "Maestro Cervecero",
			"description": "Produce {target} cervezas de calidad excelente",
			"icon": "⭐",
			"difficulty": "hard",
			"base_target": 25,
			"time_limit": CONTRACT_DURATION_BASE * 2,
			"rewards": {"money": 2000, "tokens": 10, "gems": 2},
			"scaling": {"target_multiplier": 1.3, "reward_multiplier": 1.5, "time_bonus": 0.95}
		},
		"speed_brewing":
		{
			"type": "production",
			"name": "Velocidad Extrema",
			"description": "Produce {target} cervezas en solo {time} minutos",
			"icon": "⚡",
			"difficulty": "hard",
			"base_target": 50,
			"time_limit": CONTRACT_DURATION_BASE * 0.5,  # Tiempo reducido
			"rewards": {"money": 1500, "tokens": 8, "research_points": 10},
			"scaling": {"target_multiplier": 1.4, "reward_multiplier": 1.6, "time_bonus": 0.85}
		},
		# === CONTRATOS ECONÓMICOS ===
		"sales_target":
		{
			"type": "economic",
			"name": "Objetivo de Ventas",
			"description": "Gana ${target} en {time} minutos",
			"icon": "💰",
			"difficulty": "normal",
			"base_target": 5000,
			"time_limit": CONTRACT_DURATION_BASE,
			"rewards": {"money": 2000, "tokens": 6, "experience": 40},
			"scaling": {"target_multiplier": 1.4, "reward_multiplier": 1.25, "time_bonus": 0.92}
		},
		"premium_customers":
		{
			"type": "economic",
			"name": "Clientela VIP",
			"description": "Atrae {target} clientes premium",
			"icon": "👑",
			"difficulty": "hard",
			"base_target": 15,
			"time_limit": CONTRACT_DURATION_BASE * 1.5,
			"rewards": {"money": 3000, "tokens": 12, "gems": 3},
			"scaling": {"target_multiplier": 1.2, "reward_multiplier": 1.4, "time_bonus": 0.9}
		},
		"profit_margin":
		{
			"type": "economic",
			"name": "Margen de Beneficio",
			"description": "Mantén un margen de beneficio del {target}% durante {time} min",
			"icon": "📈",
			"difficulty": "expert",
			"base_target": 75,  # 75% de margen
			"time_limit": CONTRACT_DURATION_BASE * 2,
			"rewards": {"money": 4000, "tokens": 15, "gems": 5, "research_points": 20},
			"scaling": {"target_multiplier": 1.1, "reward_multiplier": 1.5, "time_bonus": 1.1}  # Incremento pequeño del porcentaje  # Aumentar tiempo para mayor dificultad
		},
		# === CONTRATOS DE EFICIENCIA ===
		"zero_waste":
		{
			"type": "efficiency",
			"name": "Desperdicio Cero",
			"description": "Opera sin desperdicios durante {time} minutos",
			"icon": "♻️",
			"difficulty": "expert",
			"base_target": 0,  # 0% desperdicio
			"time_limit": CONTRACT_DURATION_BASE,
			"rewards": {"money": 2500, "tokens": 10, "gems": 4, "research_points": 15},
			"scaling": {"target_multiplier": 1.0, "reward_multiplier": 1.4, "time_bonus": 1.2}  # No cambia el objetivo  # Más tiempo para mayor dificultad
		},
		"automation_mastery":
		{
			"type": "efficiency",
			"name": "Maestría en Automatización",
			"description": "Usa automatización para producir {target} cervezas",
			"icon": "🤖",
			"difficulty": "hard",
			"base_target": 80,
			"time_limit": CONTRACT_DURATION_BASE * 1.5,
			"rewards": {"money": 3000, "tokens": 12, "research_points": 25},
			"scaling": {"target_multiplier": 1.3, "reward_multiplier": 1.35, "time_bonus": 0.9}
		},
		# === CONTRATOS ESPECIALES/EVENTOS ===
		"daily_special":
		{
			"type": "special",
			"name": "Especial del Día",
			"description": "Completa {target} tareas diversas hoy",
			"icon": "🎯",
			"difficulty": "normal",
			"base_target": 3,  # 3 tareas diferentes
			"time_limit": 86400,  # 24 horas
			"rewards": {"money": 5000, "tokens": 20, "gems": 5, "experience": 100},
			"scaling": {"target_multiplier": 1.2, "reward_multiplier": 1.6, "time_bonus": 1.0}
		},
		"prestige_prep":
		{
			"type": "special",
			"name": "Preparación para Prestigio",
			"description": "Alcanza {target} de dinero para prestigio eficiente",
			"icon": "🌟",
			"difficulty": "expert",
			"base_target": 50000,
			"time_limit": CONTRACT_DURATION_BASE * 3,
			"rewards": {"prestige_stars": 2, "tokens": 25, "research_points": 50},
			"scaling": {"target_multiplier": 2.0, "reward_multiplier": 1.8, "time_bonus": 1.1}
		}
	}


func _setup_contract_generation():
	"""Configura el sistema de generación de contratos"""
	contract_generation_timer = Timer.new()
	contract_generation_timer.wait_time = 60.0  # Revisar cada minuto
	contract_generation_timer.timeout.connect(_check_contract_generation)
	contract_generation_timer.autostart = true
	add_child(contract_generation_timer)

	# Establecer próximo tiempo de generación
	next_contract_time = Time.get_unix_time_from_system() + CONTRACT_GENERATION_INTERVAL


func _generate_initial_contracts():
	"""Genera contratos iniciales al arrancar"""
	for i in range(MIN_CONTRACTS_AVAILABLE):
		_generate_new_contract()


func _check_contract_generation():
	"""Verifica si es tiempo de generar nuevos contratos"""
	var current_time = Time.get_unix_time_from_system()

	# Generar nuevo contrato si es tiempo
	if current_time >= next_contract_time:
		_generate_new_contract()
		next_contract_time = current_time + CONTRACT_GENERATION_INTERVAL

	# Limpiar contratos expirados
	_cleanup_expired_contracts()

	# Actualizar progreso de contratos activos
	_update_active_contracts_progress()


func _generate_new_contract():
	"""Genera un nuevo contrato disponible"""
	if available_contracts.size() >= MAX_CONTRACTS_AVAILABLE:
		return

	# Seleccionar template aleatorio
	var template_keys = contract_templates.keys()
	var random_template = template_keys[randi() % template_keys.size()]
	var template = contract_templates[random_template]

	# Calcular scaling basado en progreso del jugador
	var player_level = _calculate_player_level()
	var scaling_factor = 1.0 + (player_level * 0.1)

	# Crear contrato
	var contract_id = (
		"contract_" + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000)
	)
	var contract = _create_contract_from_template(template, scaling_factor)
	contract["id"] = contract_id
	contract["generated_time"] = Time.get_unix_time_from_system()
	contract["expires_at"] = contract["generated_time"] + (contract["time_limit"] * 2)  # Doble tiempo para aceptar

	available_contracts[contract_id] = contract
	contract_available.emit(contract_id, contract)

	print("📋 Nuevo contrato disponible: %s" % contract["name"])


func _create_contract_from_template(template: Dictionary, scaling_factor: float) -> Dictionary:
	"""Crea un contrato específico basado en template"""
	var contract = template.duplicate(true)

	# Aplicar scaling
	contract["target"] = int(
		template["base_target"] * scaling_factor * template["scaling"]["target_multiplier"]
	)
	contract["time_limit"] = int(template["time_limit"] * template["scaling"]["time_bonus"])

	# Escalar recompensas
	for reward_type in contract["rewards"]:
		contract["rewards"][reward_type] = int(
			(
				contract["rewards"][reward_type]
				* scaling_factor
				* template["scaling"]["reward_multiplier"]
			)
		)

	# Formatear descripción
	var formatted_description = template["description"]
	formatted_description = formatted_description.replace("{target}", str(contract["target"]))
	formatted_description = formatted_description.replace(
		"{time}", str(contract["time_limit"] / 60)
	)
	contract["description"] = formatted_description

	return contract


func _calculate_player_level() -> int:
	"""Calcula el nivel del jugador basado en estadísticas"""
	if not game_data:
		return 1

	var level = 1

	# Nivel basado en prestige
	if game_data.prestige_level > 0:
		level += game_data.prestige_level * 2

	# Nivel basado en dinero total ganado
	var total_money = game_data.statistics.get("total_money_earned", 0.0)
	level += int(total_money / 10000)  # +1 nivel por cada 10K ganado

	# Nivel basado en logros
	level += game_data.unlocked_achievements.size()

	return min(level, 50)  # Cap en nivel 50


## === GESTIÓN DE CONTRATOS ===


func accept_contract(contract_id: String) -> bool:
	"""Acepta un contrato disponible"""
	if not available_contracts.has(contract_id):
		print("❌ Contrato no encontrado: ", contract_id)
		return false

	if active_contracts.has(contract_id):
		print("❌ Contrato ya activo: ", contract_id)
		return false

	var contract = available_contracts[contract_id]

	# Mover a activos
	available_contracts.erase(contract_id)
	active_contracts[contract_id] = contract

	# Configurar datos de seguimiento
	active_contracts[contract_id]["accepted_time"] = Time.get_unix_time_from_system()
	active_contracts[contract_id]["deadline"] = (
		active_contracts[contract_id]["accepted_time"] + contract["time_limit"]
	)
	active_contracts[contract_id]["progress"] = 0.0
	active_contracts[contract_id]["initial_stats"] = _capture_current_stats(contract["type"])

	contract_accepted.emit(contract_id)
	print("✅ Contrato aceptado: %s" % contract["name"])
	return true


func _capture_current_stats(contract_type: String) -> Dictionary:
	"""Captura estadísticas actuales para tracking de progreso"""
	var stats = {}

	if not statistics_manager:
		return stats

	match contract_type:
		"production":
			stats["beers_produced"] = statistics_manager.production_stats.get(
				"total_beers_brewed", 0
			)
			stats["quality_excellent"] = (
				statistics_manager.production_stats.get("quality_metrics", {}).get("excellent", 0)
			)
		"economic":
			stats["money_earned"] = statistics_manager.economic_stats.get(
				"money_earned_lifetime", 0.0
			)
			stats["premium_customers"] = 0  # Esto requeriría tracking específico
		"efficiency":
			stats["waste_generated"] = statistics_manager.production_stats.get("waste_generated", 0)
			stats["automation_usage"] = (
				statistics_manager
				. efficiency_stats
				. get("automation_usage", {})
				. get("total_hours", 0.0)
			)

	return stats


func _update_active_contracts_progress():
	"""Actualiza el progreso de todos los contratos activos"""
	for contract_id in active_contracts.keys():
		_update_contract_progress(contract_id)


func _update_contract_progress(contract_id: String):
	"""Actualiza el progreso de un contrato específico"""
	var contract = active_contracts[contract_id]
	var current_time = Time.get_unix_time_from_system()

	# Verificar si expiró
	if current_time > contract["deadline"]:
		_expire_contract(contract_id)
		return

	# Calcular progreso basado en tipo
	var progress = _calculate_contract_progress(contract)
	contract["progress"] = progress

	contract_progress_updated.emit(contract_id, progress)

	# Verificar si está completo
	if progress >= 1.0:
		_complete_contract(contract_id)


func _calculate_contract_progress(contract: Dictionary) -> float:
	"""Calcula el progreso actual de un contrato"""
	if not statistics_manager:
		return 0.0

	var progress = 0.0
	var initial_stats = contract.get("initial_stats", {})

	match contract["type"]:
		"production":
			if contract["name"] == "Maestro Cervecero":  # Quality challenge
				var current_excellent = (
					statistics_manager
					. production_stats
					. get("quality_metrics", {})
					. get("excellent", 0)
				)
				var initial_excellent = initial_stats.get("quality_excellent", 0)
				var produced_excellent = current_excellent - initial_excellent
				progress = float(produced_excellent) / float(contract["target"])
			else:  # Production rush o speed brewing
				var current_beers = statistics_manager.production_stats.get("total_beers_brewed", 0)
				var initial_beers = initial_stats.get("beers_produced", 0)
				var produced_beers = current_beers - initial_beers
				progress = float(produced_beers) / float(contract["target"])

		"economic":
			if contract["name"] == "Objetivo de Ventas":
				var current_money = statistics_manager.economic_stats.get(
					"money_earned_lifetime", 0.0
				)
				var initial_money = initial_stats.get("money_earned", 0.0)
				var earned_money = current_money - initial_money
				progress = earned_money / float(contract["target"])
			elif contract["name"] == "Clientela VIP":
				# Esto requeriría tracking específico de clientes premium
				progress = 0.5  # Simulado por ahora

		"efficiency":
			if contract["name"] == "Desperdicio Cero":
				var current_waste = statistics_manager.production_stats.get("waste_generated", 0)
				var initial_waste = initial_stats.get("waste_generated", 0)
				var generated_waste = current_waste - initial_waste
				progress = 1.0 if generated_waste == 0 else 0.0
			elif contract["name"] == "Maestría en Automatización":
				# Esto requeriría tracking específico de producción automatizada
				progress = 0.3  # Simulado

		"special":
			# Los contratos especiales requieren lógica customizada
			progress = 0.2  # Simulado

	return min(progress, 1.0)


func _complete_contract(contract_id: String):
	"""Completa un contrato y otorga recompensas"""
	var contract = active_contracts[contract_id]

	# Otorgar recompensas
	_grant_contract_rewards(contract["rewards"])

	# Mover a completados
	active_contracts.erase(contract_id)
	completed_contracts.append(contract_id)

	contract_completed.emit(contract_id, contract["rewards"])
	print("🎉 ¡Contrato completado! %s" % contract["name"])

	_save_contract_data()


func _expire_contract(contract_id: String):
	"""Expira un contrato por tiempo límite"""
	var contract = active_contracts[contract_id]
	active_contracts.erase(contract_id)

	contract_expired.emit(contract_id)
	print("⏰ Contrato expirado: %s" % contract["name"])


func _cleanup_expired_contracts():
	"""Limpia contratos disponibles expirados"""
	var current_time = Time.get_unix_time_from_system()
	var expired_contracts = []

	for contract_id in available_contracts.keys():
		var contract = available_contracts[contract_id]
		if current_time > contract["expires_at"]:
			expired_contracts.append(contract_id)

	for contract_id in expired_contracts:
		available_contracts.erase(contract_id)
		print("🗑️ Contrato disponible expirado: %s" % contract_id)


func _grant_contract_rewards(rewards: Dictionary):
	"""Otorga las recompensas de un contrato"""
	if not game_data:
		return

	for reward_type in rewards:
		var amount = rewards[reward_type]

		match reward_type:
			"money":
				game_data.money += amount
				print("💰 +$%d" % amount)
			"tokens":
				game_data.prestige_tokens += amount
				print("🪙 +%d tokens" % amount)
			"gems":
				game_data.gems += amount
				print("💎 +%d gemas" % amount)
			"experience":
				# Esto requeriría un sistema de experiencia
				print("⭐ +%d XP" % amount)
			"research_points":
				# Otorgar puntos al ResearchManager si existe
				var research_manager = get_parent().get_node_or_null("ResearchManager")
				if research_manager:
					research_manager.add_research_points(amount)
				print("🔬 +%d puntos de investigación" % amount)
			"prestige_stars":
				# Esto requeriría integración con PrestigeManager
				print("🌟 +%d estrellas de prestigio" % amount)


## === SAVE/LOAD ===


func _save_contract_data():
	"""Guarda datos de contratos en GameData"""
	if not game_data:
		return

	if not game_data.contract_data:
		game_data.contract_data = {}

	game_data.contract_data["available_contracts"] = available_contracts
	game_data.contract_data["active_contracts"] = active_contracts
	game_data.contract_data["completed_contracts"] = completed_contracts
	game_data.contract_data["next_contract_time"] = next_contract_time


func load_contract_data():
	"""Carga datos de contratos desde GameData"""
	if not game_data or not game_data.contract_data:
		return

	var data = game_data.contract_data

	if data.has("available_contracts"):
		available_contracts = data["available_contracts"]

	if data.has("active_contracts"):
		active_contracts = data["active_contracts"]

	if data.has("completed_contracts"):
		completed_contracts = data["completed_contracts"]

	if data.has("next_contract_time"):
		next_contract_time = data["next_contract_time"]

	print("📋 Datos de contratos cargados")


## === API PÚBLICAS ===


func get_available_contracts() -> Dictionary:
	"""Obtiene contratos disponibles para aceptar"""
	return available_contracts.duplicate(true)


func get_active_contracts() -> Dictionary:
	"""Obtiene contratos activos con su progreso"""
	return active_contracts.duplicate(true)


func get_completed_contracts_count() -> int:
	"""Obtiene número de contratos completados"""
	return completed_contracts.size()


func get_contract_info(contract_id: String) -> Dictionary:
	"""Obtiene información de un contrato específico"""
	if available_contracts.has(contract_id):
		return available_contracts[contract_id].duplicate(true)
	elif active_contracts.has(contract_id):
		return active_contracts[contract_id].duplicate(true)
	return {}


func get_contract_progress_summary() -> Dictionary:
	"""Obtiene resumen del progreso de contratos"""
	return {
		"available": available_contracts.size(),
		"active": active_contracts.size(),
		"completed": completed_contracts.size(),
		"next_generation_in": max(0, next_contract_time - Time.get_unix_time_from_system())
	}


func can_accept_contract(contract_id: String) -> bool:
	"""Verifica si se puede aceptar un contrato"""
	return available_contracts.has(contract_id) and not active_contracts.has(contract_id)


func force_generate_contract():
	"""Fuerza la generación de un nuevo contrato (debug/testing)"""
	_generate_new_contract()


## === INTEGRATION ===


func set_game_data(data: GameData):
	"""Conectar con GameData"""
	game_data = data
	load_contract_data()


func set_statistics_manager(stats_manager: StatisticsManager):
	"""Conectar con StatisticsManager para tracking de progreso"""
	statistics_manager = stats_manager
