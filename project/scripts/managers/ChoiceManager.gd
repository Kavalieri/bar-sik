extends RefCounted
class_name ChoiceManager

## Sistema de Decisiones Estratégicas para Bar-Sik
## Meaningful choices beyond just waiting

signal choice_presented(choice_data: Dictionary)
signal choice_made(choice_id: String, option: String)

var active_choices: Array[Dictionary] = []
var choice_history: Array[Dictionary] = []
var game_data: GameData

enum ChoiceType { ECONOMIC, STRATEGIC, RISK_REWARD, EFFICIENCY, EXPANSION }  # Business decisions  # Long-term planning  # Risk vs reward scenarios  # Optimization choices  # Growth decisions


func _init(gd: GameData):
	game_data = gd


## === MEANINGFUL CHOICE GENERATION ===


func generate_strategic_choices():
	"""Genera decisiones estratégicas basadas en el estado del juego"""
	_clear_expired_choices()

	# Solo mostrar 1-2 choices activos para no overwhelm
	if active_choices.size() >= 2:
		return

	var player_level = _calculate_player_level()
	var available_choices = _get_choices_for_level(player_level)

	# Seleccionar choice relevante
	if available_choices.size() > 0:
		var choice = available_choices.pick_random()
		_present_choice(choice)


func _calculate_player_level() -> String:
	"""Determina el nivel del jugador basado en progreso"""
	if game_data.prestige_level >= 5:
		return "veteran"
	elif game_data.prestige_level >= 2:
		return "advanced"
	elif game_data.money >= 100000:
		return "intermediate"
	else:
		return "beginner"


func _get_choices_for_level(level: String) -> Array[Dictionary]:
	"""Obtiene choices apropiados para el nivel del jugador"""
	match level:
		"beginner":
			return _get_beginner_choices()
		"intermediate":
			return _get_intermediate_choices()
		"advanced":
			return _get_advanced_choices()
		"veteran":
			return _get_veteran_choices()
		_:
			return []


## === BEGINNER CHOICES ===


func _get_beginner_choices() -> Array[Dictionary]:
	"""Choices para jugadores nuevos (meaningful early decisions)"""
	var choices: Array[Dictionary] = []

	# Choice 1: Investment Strategy
	choices.append(
		{
			"id": "early_investment",
			"type": ChoiceType.STRATEGIC,
			"title": "🏦 Investment Strategy",
			"description": "You have $1,000. How do you want to invest it?",
			"duration_minutes": 30,
			"options":
			[
				{
					"id": "safe_growth",
					"title": "🛡️ Safe Growth",
					"description": "Upgrade existing equipment (+25% production)",
					"effects": {"production_multiplier": 1.25},
					"immediate": true
				},
				{
					"id": "expansion",
					"title": "📈 Aggressive Expansion",
					"description": "Buy new brewing station (+50% capacity, -10% efficiency)",
					"effects": {"capacity_multiplier": 1.5, "efficiency_multiplier": 0.9},
					"immediate": true
				},
				{
					"id": "research",
					"title": "🔬 Research Investment",
					"description": "Invest in R&D (no immediate benefit, +tech points)",
					"effects": {"research_points": 10},
					"delayed_benefit": "unlock_premium_recipes"
				}
			]
		}
	)

	# Choice 2: Customer Focus
	choices.append(
		{
			"id": "customer_focus",
			"type": ChoiceType.ECONOMIC,
			"title": "👥 Customer Strategy",
			"description": "Your bar is getting busier. What's your approach?",
			"duration_minutes": 45,
			"options":
			[
				{
					"id": "premium_service",
					"title": "⭐ Premium Service",
					"description": "Focus on high-paying customers (+50% revenue, -25% volume)",
					"effects": {"revenue_multiplier": 1.5, "customer_rate": 0.75}
				},
				{
					"id": "volume_business",
					"title": "🏃 High Volume",
					"description": "Serve more customers (+75% volume, -10% per-customer revenue)",
					"effects": {"customer_rate": 1.75, "revenue_multiplier": 0.9}
				},
				{
					"id": "balanced_approach",
					"title": "⚖️ Balanced Approach",
					"description":
					"Moderate increases across the board (+15% revenue, +15% volume)",
					"effects": {"revenue_multiplier": 1.15, "customer_rate": 1.15}
				}
			]
		}
	)

	return choices


## === INTERMEDIATE CHOICES ===


func _get_intermediate_choices() -> Array[Dictionary]:
	"""Choices para jugadores con experiencia"""
	var choices: Array[Dictionary] = []

	# Choice 1: Automation vs Manual Control
	choices.append(
		{
			"id": "automation_decision",
			"type": ChoiceType.EFFICIENCY,
			"title": "🤖 Automation Decision",
			"description": "You can afford automation. What's your strategy?",
			"duration_minutes": 60,
			"options":
			[
				{
					"id": "full_automation",
					"title": "🔧 Full Automation",
					"description": "Automate everything (+300% idle income, -20% active income)",
					"effects": {"offline_multiplier": 4.0, "active_multiplier": 0.8},
					"cost": {"gems": 200}
				},
				{
					"id": "selective_automation",
					"title": "🎯 Selective Automation",
					"description": "Automate key processes (+150% idle, +10% active)",
					"effects": {"offline_multiplier": 2.5, "active_multiplier": 1.1},
					"cost": {"gems": 100}
				},
				{
					"id": "manual_optimization",
					"title": "👐 Manual Mastery",
					"description": "Stay hands-on (+50% active income, +click bonuses)",
					"effects": {"active_multiplier": 1.5, "click_multiplier": 2.0},
					"cost": {"money": 50000}
				}
			]
		}
	)

	# Choice 2: Market Expansion
	choices.append(
		{
			"id": "market_expansion",
			"type": ChoiceType.EXPANSION,
			"title": "🌍 Market Expansion",
			"description": "Opportunity to expand your business. Choose wisely:",
			"duration_minutes": 90,
			"options":
			[
				{
					"id": "local_domination",
					"title": "🏘️ Local Domination",
					"description": "Dominate local market (+100% local customer rate)",
					"effects": {"base_customer_rate": 2.0},
					"permanent": true
				},
				{
					"id": "franchise_model",
					"title": "🏢 Franchise Model",
					"description": "Start franchising (+passive token income)",
					"effects": {"passive_token_rate": 0.1},
					"recurring": true
				},
				{
					"id": "premium_brand",
					"title": "💎 Premium Brand",
					"description": "Position as premium (+200% revenue per customer)",
					"effects": {"customer_value_multiplier": 3.0},
					"permanent": true
				}
			]
		}
	)

	return choices


## === ADVANCED CHOICES ===


func _get_advanced_choices() -> Array[Dictionary]:
	"""Choices para jugadores avanzados con prestigio"""
	var choices: Array[Dictionary] = []

	# Choice 1: Prestige Strategy
	choices.append(
		{
			"id": "prestige_strategy",
			"type": ChoiceType.STRATEGIC,
			"title": "⭐ Prestige Strategy",
			"description": "You're ready for prestige. What's your approach?",
			"duration_minutes": 120,
			"options":
			[
				{
					"id": "early_prestige",
					"title": "🚀 Early Prestige",
					"description": "Prestige now for faster progression (+25% prestige tokens)",
					"effects": {"prestige_token_bonus": 1.25},
					"action": "trigger_prestige"
				},
				{
					"id": "max_prestige",
					"title": "💪 Push to Maximum",
					"description": "Push further before prestiging (+50% current run value)",
					"effects": {"current_run_multiplier": 1.5},
					"duration_hours": 2
				},
				{
					"id": "strategic_prestige",
					"title": "🧠 Strategic Timing",
					"description": "Wait for optimal prestige timing (+research opportunities)",
					"effects": {"research_unlock": true},
					"delayed": true
				}
			]
		}
	)

	# Choice 2: Meta-Progression Focus
	choices.append(
		{
			"id": "meta_focus",
			"type": ChoiceType.STRATEGIC,
			"title": "🎯 Meta-Progression Focus",
			"description": "Choose your long-term progression focus:",
			"duration_minutes": 180,
			"options":
			[
				{
					"id": "research_focus",
					"title": "🔬 Research Mastery",
					"description": "Focus on research tree (+100% research point gain)",
					"effects": {"research_multiplier": 2.0},
					"permanent": true
				},
				{
					"id": "achievement_hunter",
					"title": "🏆 Achievement Hunter",
					"description": "Focus on achievements (+25% achievement rewards)",
					"effects": {"achievement_bonus": 1.25},
					"permanent": true
				},
				{
					"id": "economic_empire",
					"title": "💰 Economic Empire",
					"description": "Focus on wealth generation (+50% all currency gains)",
					"effects": {"currency_multiplier": 1.5},
					"permanent": true
				}
			]
		}
	)

	return choices


## === VETERAN CHOICES ===


func _get_veteran_choices() -> Array[Dictionary]:
	"""Choices para jugadores veteranos (endgame)"""
	var choices: Array[Dictionary] = []

	# Choice 1: Legacy Decision
	choices.append(
		{
			"id": "legacy_choice",
			"type": ChoiceType.STRATEGIC,
			"title": "👑 Legacy Decision",
			"description": "You've mastered the game. What's your legacy?",
			"duration_minutes": 300,
			"options":
			[
				{
					"id": "mentor_path",
					"title": "🎓 Mentor Path",
					"description": "Help other players (+global bonuses for community)",
					"effects": {"community_bonus": 1.1},
					"social": true
				},
				{
					"id": "perfectionist",
					"title": "💯 Perfectionist",
					"description": "Achieve perfect optimization (+5% to all bonuses permanently)",
					"effects": {"global_bonus": 1.05},
					"permanent": true
				},
				{
					"id": "innovator",
					"title": "🔬 Innovator",
					"description": "Unlock experimental features (+access to beta content)",
					"effects": {"beta_access": true},
					"special": true
				}
			]
		}
	)

	return choices


## === CHOICE PRESENTATION & MANAGEMENT ===


func _present_choice(choice_data: Dictionary):
	"""Presenta una choice al jugador"""
	choice_data["presented_at"] = Time.get_unix_time_from_system()
	choice_data["expires_at"] = choice_data.presented_at + (choice_data.duration_minutes * 60)

	active_choices.append(choice_data)
	choice_presented.emit(choice_data)

	print("🎯 Strategic Choice Presented: ", choice_data.title)


func make_choice(choice_id: String, option_id: String) -> bool:
	"""Jugador hace una choice"""
	var choice_index = -1
	var choice_data: Dictionary = {}

	# Encontrar la choice
	for i in range(active_choices.size()):
		if active_choices[i].id == choice_id:
			choice_index = i
			choice_data = active_choices[i]
			break

	if choice_index == -1:
		return false

	# Encontrar la opción seleccionada
	var selected_option: Dictionary = {}
	for option in choice_data.options:
		if option.id == option_id:
			selected_option = option
			break

	if selected_option.is_empty():
		return false

	# Aplicar efectos de la choice
	_apply_choice_effects(selected_option)

	# Remover choice de activas y agregarla al historial
	active_choices.remove_at(choice_index)
	choice_history.append(
		{
			"choice_id": choice_id,
			"option_id": option_id,
			"timestamp": Time.get_unix_time_from_system(),
			"effects": selected_option.effects
		}
	)

	choice_made.emit(choice_id, option_id)

	print("✅ Choice Made: ", selected_option.title)
	return true


func _apply_choice_effects(option: Dictionary):
	"""Aplica los efectos de una choice al game state"""
	if not option.has("effects"):
		return

	var effects = option.effects

	# Aplicar efectos inmediatos
	for effect_name in effects:
		var value = effects[effect_name]
		_apply_individual_effect(effect_name, value, option)


func _apply_individual_effect(effect_name: String, value, option: Dictionary):
	"""Aplica un efecto individual"""
	match effect_name:
		"production_multiplier":
			game_data.production_rate_multiplier = value
		"revenue_multiplier":
			game_data.customer_value_multiplier = value
		"research_points":
			if game_data.has_method("add_research_points"):
				game_data.add_research_points(value)
		"prestige_token_bonus":
			game_data.prestige_token_multiplier = value
		"offline_multiplier":
			game_data.offline_multiplier = value
		"gems":
			if option.has("cost"):
				game_data.spend_gems(option.cost.gems)
		_:
			print("Unknown effect: ", effect_name)


func _clear_expired_choices():
	"""Limpia choices que han expirado"""
	var current_time = Time.get_unix_time_from_system()
	var expired_indices: Array[int] = []

	for i in range(active_choices.size()):
		if active_choices[i].expires_at <= current_time:
			expired_indices.append(i)

	# Remover de atrás hacia adelante para no alterar índices
	expired_indices.reverse()
	for index in expired_indices:
		print("⏰ Choice Expired: ", active_choices[index].title)
		active_choices.remove_at(index)


func get_active_choices() -> Array[Dictionary]:
	"""Obtiene choices actualmente disponibles"""
	_clear_expired_choices()
	return active_choices.duplicate()


func get_choice_history() -> Array[Dictionary]:
	"""Obtiene historial de choices hechas"""
	return choice_history.duplicate()


## === SAVE/LOAD SUPPORT ===


func save_choice_data() -> Dictionary:
	"""Guarda datos del choice system"""
	return {"active_choices": active_choices, "choice_history": choice_history}


func load_choice_data(data: Dictionary):
	"""Carga datos del choice system"""
	active_choices = data.get("active_choices", [])
	choice_history = data.get("choice_history", [])

	# Limpiar choices expiradas después de cargar
	_clear_expired_choices()
