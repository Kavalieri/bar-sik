extends RefCounted
class_name ObjectiveManager

## Sistema de Objetivos Claros y Dinámicos para Bar-Sik
## Clear objectives y goals en todo momento

signal objective_added(objective: Dictionary)
signal objective_completed(objective: Dictionary)
signal objective_updated(objective: Dictionary, progress: float)

var active_objectives: Array[Dictionary] = []
var completed_objectives: Array[Dictionary] = []
var game_data: GameData

enum ObjectiveType {
	IMMEDIATE,    # Short-term (1-5 minutes)
	SHORT_TERM,   # Medium-term (10-30 minutes)
	LONG_TERM,    # Long-term (1+ hours)
	MILESTONE,    # Major milestones
	CHALLENGE     # Special challenges
}

enum ObjectiveCategory {
	ECONOMIC,     # Money, revenue goals
	PRODUCTION,   # Brewing, output goals
	PROGRESSION,  # Leveling, unlocks
	EFFICIENCY,   # Optimization goals
	EXPLORATION,  # Discovering features
	MASTERY      # Advanced skill goals
}

func _init(gd: GameData):
	game_data = gd


## === DYNAMIC OBJECTIVE GENERATION ===

func update_objectives():
	"""Actualiza objetivos basado en el estado actual del juego"""
	_check_objective_completion()
	_generate_missing_objectives()
	_update_objective_progress()


func _generate_missing_objectives():
	"""Genera objetivos faltantes para mantener engagement"""
	var player_state = _analyze_player_state()

	# Mantener 2-3 immediate, 2 short-term, 1-2 long-term activos
	var immediate_count = _count_objectives_by_type(ObjectiveType.IMMEDIATE)
	var short_term_count = _count_objectives_by_type(ObjectiveType.SHORT_TERM)
	var long_term_count = _count_objectives_by_type(ObjectiveType.LONG_TERM)

	# Generar immediate objectives (always have 2-3)
	while immediate_count < 2:
		var objective = _generate_immediate_objective(player_state)
		if objective:
			_add_objective(objective)
			immediate_count += 1
		else:
			break

	# Generar short-term objectives (always have 1-2)
	while short_term_count < 2:
		var objective = _generate_short_term_objective(player_state)
		if objective:
			_add_objective(objective)
			short_term_count += 1
		else:
			break

	# Generar long-term objectives (always have 1)
	if long_term_count == 0:
		var objective = _generate_long_term_objective(player_state)
		if objective:
			_add_objective(objective)


func _analyze_player_state() -> Dictionary:
	"""Analiza el estado del jugador para generar objetivos apropiados"""
	return {
		"money": game_data.money,
		"tokens": game_data.prestige_tokens,
		"gems": game_data.gems,
		"prestige_level": game_data.prestige_level,
		"play_time": _estimate_play_time(),
		"progression_stage": _get_progression_stage(),
		"needs_guidance": _player_needs_guidance(),
		"last_major_action": _get_last_major_action(),
		"stuck_indicators": _detect_stuck_indicators()
	}


func _get_progression_stage() -> String:
	"""Determina en qué etapa de progresión está el jugador"""
	if game_data.prestige_level >= 5:
		return "endgame"
	elif game_data.prestige_level >= 2:
		return "advanced"
	elif game_data.money >= 50000:
		return "mid_game"
	elif game_data.money >= 1000:
		return "early_game"
	else:
		return "tutorial"


## === IMMEDIATE OBJECTIVES GENERATION ===

func _generate_immediate_objective(player_state: Dictionary) -> Dictionary:
	"""Genera objetivos inmediatos (1-5 minutos)"""
	var stage = player_state.progression_stage
	var immediate_objectives = []

	match stage:
		"tutorial":
			immediate_objectives = _get_tutorial_immediate_objectives(player_state)
		"early_game":
			immediate_objectives = _get_early_immediate_objectives(player_state)
		"mid_game":
			immediate_objectives = _get_mid_immediate_objectives(player_state)
		"advanced":
			immediate_objectives = _get_advanced_immediate_objectives(player_state)
		"endgame":
			immediate_objectives = _get_endgame_immediate_objectives(player_state)

	if immediate_objectives.size() > 0:
		return immediate_objectives.pick_random()
	return {}


func _get_tutorial_immediate_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos inmediatos para tutorial"""
	var objectives: Array[Dictionary] = []

	# Objective: First $100
	if player_state.money < 100:
		objectives.append({
			"id": "first_100",
			"type": ObjectiveType.IMMEDIATE,
			"category": ObjectiveCategory.ECONOMIC,
			"title": "💰 Earn Your First $100",
			"description": "Keep brewing and selling to reach $100",
			"target_value": 100,
			"current_value": player_state.money,
			"reward": {"money": 50, "guidance": "Great! Now you can afford your first upgrade."},
			"estimated_time": "2 minutes"
		})

	# Objective: First Purchase
	if player_state.money >= 100 and not _has_made_first_purchase():
		objectives.append({
			"id": "first_purchase",
			"type": ObjectiveType.IMMEDIATE,
			"category": ObjectiveCategory.PROGRESSION,
			"title": "🛒 Make Your First Purchase",
			"description": "Buy an upgrade to improve your brewery",
			"target_value": 1,
			"current_value": 0,
			"reward": {"gems": 10, "guidance": "Upgrades are key to growing your business!"},
			"estimated_time": "1 minute"
		})

	# Objective: Production Goal
	objectives.append({
		"id": "brew_10_beers",
		"type": ObjectiveType.IMMEDIATE,
		"category": ObjectiveCategory.PRODUCTION,
		"title": "🍺 Brew 10 Beers",
		"description": "Click or wait to produce 10 beers total",
		"target_value": 10,
		"current_value": _get_total_beers_brewed(),
		"reward": {"money": 25, "tokens": 1},
		"estimated_time": "3 minutes"
	})

	return objectives


func _get_early_immediate_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos inmediatos para early game"""
	var objectives: Array[Dictionary] = []

	# Money milestones
	var next_money_milestone = _get_next_money_milestone(player_state.money)
	if next_money_milestone > 0:
		objectives.append({
			"id": "money_milestone_" + str(next_money_milestone),
			"type": ObjectiveType.IMMEDIATE,
			"category": ObjectiveCategory.ECONOMIC,
			"title": "💵 Reach $" + _format_number(next_money_milestone),
			"description": "Earn money to reach the next milestone",
			"target_value": next_money_milestone,
			"current_value": player_state.money,
			"reward": _get_milestone_reward(next_money_milestone),
			"estimated_time": _estimate_time_to_money(next_money_milestone, player_state.money)
		})

	# Customer interaction
	objectives.append({
		"id": "serve_customers",
		"type": ObjectiveType.IMMEDIATE,
		"category": ObjectiveCategory.PRODUCTION,
		"title": "👥 Serve 5 Customers",
		"description": "Serve customers to earn money and tokens",
		"target_value": 5,
		"current_value": _get_customers_served_today(),
		"reward": {"money": 100, "tokens": 2},
		"estimated_time": "4 minutes"
	})

	return objectives


func _get_mid_immediate_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos inmediatos para mid game"""
	var objectives: Array[Dictionary] = []

	# Token earning objectives
	if player_state.tokens < 10:
		objectives.append({
			"id": "earn_tokens",
			"type": ObjectiveType.IMMEDIATE,
			"category": ObjectiveCategory.ECONOMIC,
			"title": "🪙 Earn 5 Tokens",
			"description": "Serve premium customers to earn tokens",
			"target_value": player_state.tokens + 5,
			"current_value": player_state.tokens,
			"reward": {"gems": 25},
			"estimated_time": "5 minutes"
		})

	# Efficiency objectives
	objectives.append({
		"id": "optimize_production",
		"type": ObjectiveType.IMMEDIATE,
		"category": ObjectiveCategory.EFFICIENCY,
		"title": "⚡ Optimize Production",
		"description": "Achieve 80% production efficiency",
		"target_value": 80,
		"current_value": _calculate_current_efficiency(),
		"reward": {"money": 500, "research_points": 1},
		"estimated_time": "3 minutes"
	})

	return objectives


func _get_advanced_immediate_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos inmediatos para jugadores avanzados"""
	var objectives: Array[Dictionary] = []

	# Prestige preparation
	if _is_prestige_beneficial() and not _recently_prestiged():
		objectives.append({
			"id": "prestige_prep",
			"type": ObjectiveType.IMMEDIATE,
			"category": ObjectiveCategory.PROGRESSION,
			"title": "⭐ Prepare for Prestige",
			"description": "Optimize your setup before prestiging",
			"target_value": 100,
			"current_value": _calculate_prestige_readiness(),
			"reward": {"prestige_tokens": 5},
			"estimated_time": "2 minutes"
		})

	# Advanced customer management
	objectives.append({
		"id": "premium_customers",
		"type": ObjectiveType.IMMEDIATE,
		"category": ObjectiveCategory.MASTERY,
		"title": "💎 Serve Premium Customers",
		"description": "Focus on high-value customer segments",
		"target_value": 3,
		"current_value": _get_premium_customers_served(),
		"reward": {"gems": 50, "tokens": 10},
		"estimated_time": "4 minutes"
	})

	return objectives


func _get_endgame_immediate_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos inmediatos para endgame players"""
	var objectives: Array[Dictionary] = []

	# Mastery challenges
	objectives.append({
		"id": "mastery_challenge",
		"type": ObjectiveType.IMMEDIATE,
		"category": ObjectiveCategory.MASTERY,
		"title": "🎯 Mastery Challenge",
		"description": "Demonstrate advanced brewery management",
		"target_value": 100,
		"current_value": _calculate_mastery_score(),
		"reward": {"research_points": 5, "gems": 100},
		"estimated_time": "5 minutes"
	})

	# Innovation objectives
	objectives.append({
		"id": "innovation_goal",
		"type": ObjectiveType.IMMEDIATE,
		"category": ObjectiveCategory.EXPLORATION,
		"title": "🔬 Innovation Goal",
		"description": "Experiment with advanced brewing techniques",
		"target_value": 1,
		"current_value": 0,
		"reward": {"special_unlock": true},
		"estimated_time": "3 minutes"
	})

	return objectives


## === SHORT-TERM OBJECTIVES ===

func _generate_short_term_objective(player_state: Dictionary) -> Dictionary:
	"""Genera objetivos a corto plazo (10-30 minutos)"""
	var stage = player_state.progression_stage
	var short_objectives = []

	match stage:
		"tutorial", "early_game":
			short_objectives = _get_early_short_term_objectives(player_state)
		"mid_game":
			short_objectives = _get_mid_short_term_objectives(player_state)
		"advanced", "endgame":
			short_objectives = _get_advanced_short_term_objectives(player_state)

	if short_objectives.size() > 0:
		return short_objectives.pick_random()
	return {}


func _get_early_short_term_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos a corto plazo para early game"""
	var objectives: Array[Dictionary] = []

	# First major milestone
	objectives.append({
		"id": "first_major_milestone",
		"type": ObjectiveType.SHORT_TERM,
		"category": ObjectiveCategory.PROGRESSION,
		"title": "🎯 Reach First Major Milestone",
		"description": "Earn $10,000 to unlock new features",
		"target_value": 10000,
		"current_value": player_state.money,
		"reward": {"gems": 50, "unlock": "advanced_brewing"},
		"estimated_time": "15 minutes"
	})

	# Customer automation
	objectives.append({
		"id": "automate_customers",
		"type": ObjectiveType.SHORT_TERM,
		"category": ObjectiveCategory.EFFICIENCY,
		"title": "🤖 Automate Customer Service",
		"description": "Unlock and configure customer automation",
		"target_value": 1,
		"current_value": _get_automation_level(),
		"reward": {"tokens": 20, "research_points": 2},
		"estimated_time": "20 minutes"
	})

	return objectives


func _get_mid_short_term_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos a corto plazo para mid game"""
	var objectives: Array[Dictionary] = []

	# Token milestone
	objectives.append({
		"id": "token_milestone",
		"type": ObjectiveType.SHORT_TERM,
		"category": ObjectiveCategory.ECONOMIC,
		"title": "🪙 Accumulate 100 Tokens",
		"description": "Build up your token reserves for major upgrades",
		"target_value": 100,
		"current_value": player_state.tokens,
		"reward": {"gems": 100, "unlock": "premium_upgrades"},
		"estimated_time": "25 minutes"
	})

	# Research progress
	objectives.append({
		"id": "research_progress",
		"type": ObjectiveType.SHORT_TERM,
		"category": ObjectiveCategory.EXPLORATION,
		"title": "🔬 Complete Research Project",
		"description": "Finish a research project to unlock new capabilities",
		"target_value": 1,
		"current_value": _get_active_research_progress(),
		"reward": {"research_points": 10, "special_unlock": true},
		"estimated_time": "30 minutes"
	})

	return objectives


func _get_advanced_short_term_objectives(player_state: Dictionary) -> Array[Dictionary]:
	"""Objetivos a corto plazo para advanced/endgame"""
	var objectives: Array[Dictionary] = []

	# Prestige optimization
	objectives.append({
		"id": "prestige_optimization",
		"type": ObjectiveType.SHORT_TERM,
		"category": ObjectiveCategory.MASTERY,
		"title": "⭐ Optimize Prestige Run",
		"description": "Achieve maximum efficiency in your current run",
		"target_value": 95,
		"current_value": _calculate_run_efficiency(),
		"reward": {"prestige_tokens": 25, "gems": 200},
		"estimated_time": "20 minutes"
	})

	return objectives


## === LONG-TERM OBJECTIVES ===

func _generate_long_term_objective(player_state: Dictionary) -> Dictionary:
	"""Genera objetivos a largo plazo (1+ horas)"""
	var stage = player_state.progression_stage
	var long_objectives = []

	match stage:
		"early_game":
			long_objectives.append({
				"id": "early_mastery",
				"type": ObjectiveType.LONG_TERM,
				"category": ObjectiveCategory.MILESTONE,
				"title": "🏆 Early Game Mastery",
				"description": "Master the fundamentals and prepare for mid-game",
				"target_value": 100000,
				"current_value": player_state.money,
				"reward": {"gems": 500, "unlock": "mid_game_features"},
				"estimated_time": "2 hours"
			})

		"mid_game":
			long_objectives.append({
				"id": "first_prestige",
				"type": ObjectiveType.LONG_TERM,
				"category": ObjectiveCategory.MILESTONE,
				"title": "⭐ First Prestige Achievement",
				"description": "Reach your first prestige to unlock the meta-game",
				"target_value": 1,
				"current_value": player_state.prestige_level,
				"reward": {"prestige_tokens": 50, "unlock": "prestige_bonuses"},
				"estimated_time": "1.5 hours"
			})

		"advanced":
			long_objectives.append({
				"id": "mastery_path",
				"type": ObjectiveType.LONG_TERM,
				"category": ObjectiveCategory.MASTERY,
				"title": "🎯 Choose Your Mastery Path",
				"description": "Specialize in a particular aspect of brewery management",
				"target_value": 5,
				"current_value": player_state.prestige_level,
				"reward": {"specialization_unlock": true, "gems": 1000},
				"estimated_time": "3 hours"
			})

		"endgame":
			long_objectives.append({
				"id": "legacy_achievement",
				"type": ObjectiveType.LONG_TERM,
				"category": ObjectiveCategory.MILESTONE,
				"title": "👑 Create Your Legacy",
				"description": "Achieve legendary status in the brewing world",
				"target_value": 10,
				"current_value": player_state.prestige_level,
				"reward": {"legacy_unlock": true, "infinite_gems": true},
				"estimated_time": "5+ hours"
			})

	if long_objectives.size() > 0:
		return long_objectives.pick_random()
	return {}


## === OBJECTIVE MANAGEMENT ===

func _add_objective(objective: Dictionary):
	"""Añade un objetivo al sistema"""
	objective["created_at"] = Time.get_unix_time_from_system()
	objective["progress"] = 0.0

	active_objectives.append(objective)
	objective_added.emit(objective)

	print("🎯 New Objective: ", objective.title)


func _check_objective_completion():
	"""Verifica si algún objetivo se ha completado"""
	var completed_indices: Array[int] = []

	for i in range(active_objectives.size()):
		var objective = active_objectives[i]
		var current_progress = _calculate_objective_progress(objective)

		if current_progress >= objective.target_value:
			_complete_objective(objective)
			completed_indices.append(i)

	# Remover objetivos completados
	completed_indices.reverse()
	for index in completed_indices:
		active_objectives.remove_at(index)


func _complete_objective(objective: Dictionary):
	"""Completa un objetivo y otorga recompensas"""
	objective["completed_at"] = Time.get_unix_time_from_system()
	completed_objectives.append(objective)

	# Otorgar recompensas
	_grant_objective_rewards(objective.reward)

	objective_completed.emit(objective)
	print("✅ Objective Completed: ", objective.title)


func _update_objective_progress():
	"""Actualiza el progreso de objetivos activos"""
	for objective in active_objectives:
		var current_value = _calculate_objective_progress(objective)
		var progress = float(current_value) / float(objective.target_value) * 100.0
		progress = min(100.0, progress)

		if abs(progress - objective.progress) > 1.0:  # Solo emit si cambio significativo
			objective.progress = progress
			objective.current_value = current_value
			objective_updated.emit(objective, progress)


func _calculate_objective_progress(objective: Dictionary) -> float:
	"""Calcula el progreso actual de un objetivo"""
	match objective.id:
		"first_100", "money_milestone_500", "money_milestone_1000":
			return game_data.money
		"earn_tokens":
			return game_data.prestige_tokens
		"brew_10_beers":
			return _get_total_beers_brewed()
		"serve_customers":
			return _get_customers_served_today()
		_:
			return objective.get("current_value", 0.0)


## === HELPER METHODS ===

func _count_objectives_by_type(type: ObjectiveType) -> int:
	"""Cuenta objetivos por tipo"""
	var count = 0
	for objective in active_objectives:
		if objective.type == type:
			count += 1
	return count


func _get_next_money_milestone(current_money: float) -> int:
	"""Obtiene el próximo milestone de dinero"""
	var milestones = [500, 1000, 2500, 5000, 10000, 25000, 50000, 100000]
	for milestone in milestones:
		if current_money < milestone:
			return milestone
	return 0


func _format_number(number: float) -> String:
	"""Formatea números para display"""
	if number >= 1000000:
		return str(snapped(number / 1000000.0, 0.1)) + "M"
	elif number >= 1000:
		return str(snapped(number / 1000.0, 0.1)) + "K"
	else:
		return str(int(number))


func get_active_objectives() -> Array[Dictionary]:
	"""Obtiene objetivos activos"""
	return active_objectives.duplicate()


func get_completed_objectives() -> Array[Dictionary]:
	"""Obtiene objetivos completados"""
	return completed_objectives.duplicate()


## === PLACEHOLDER METHODS ===
# Estos métodos necesitarían implementación real basada en GameData

func _estimate_play_time() -> float:
	return 0.0

func _player_needs_guidance() -> bool:
	return false

func _get_last_major_action() -> String:
	return ""

func _detect_stuck_indicators() -> bool:
	return false

func _has_made_first_purchase() -> bool:
	return game_data.money < 100  # Placeholder logic

func _get_total_beers_brewed() -> int:
	return 0  # Would track in GameData

func _get_customers_served_today() -> int:
	return 0  # Would track in GameData

func _estimate_time_to_money(target: float, current: float) -> String:
	var diff = target - current
	var minutes = max(1, diff / 100)  # Estimate based on income rate
	return str(int(minutes)) + " minutes"

func _get_milestone_reward(amount: int) -> Dictionary:
	return {"money": amount * 0.1, "gems": max(5, amount / 100)}

func _calculate_current_efficiency() -> float:
	return 75.0  # Placeholder

func _is_prestige_beneficial() -> bool:
	return game_data.prestige_level < 2

func _recently_prestiged() -> bool:
	return false  # Would track timestamp

func _calculate_prestige_readiness() -> float:
	return 80.0  # Placeholder

func _get_premium_customers_served() -> int:
	return 0  # Would track in GameData

func _calculate_mastery_score() -> float:
	return 85.0  # Placeholder

func _get_automation_level() -> int:
	return 0  # Would check GameData

func _get_active_research_progress() -> float:
	return 0.5  # Placeholder

func _calculate_run_efficiency() -> float:
	return 90.0  # Placeholder

func _grant_objective_rewards(rewards: Dictionary):
	"""Otorga recompensas de objetivos"""
	for reward_type in rewards:
		var amount = rewards[reward_type]
		match reward_type:
			"money":
				game_data.add_money(amount)
			"tokens":
				game_data.add_prestige_tokens(amount)
			"gems":
				game_data.add_gems(amount)
			_:
				print("Reward granted: ", reward_type, " = ", amount)
