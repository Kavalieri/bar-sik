extends Node
class_name DailyRewardManager

## ═══════════════════════════════════════════════════════════════════════════════════
## T026 - DAILY REWARD MANAGER - DIAMOND ECONOMY REBALANCE
## ═══════════════════════════════════════════════════════════════════════════════════
## Descripción: Sistema de recompensas diarias para economia de diamantes balanceada
## Versión: 1.0
## Fecha: 2024-12-19
## ═══════════════════════════════════════════════════════════════════════════════════

signal daily_reward_claimed(gems_earned: int, day_streak: int)
signal streak_broken
signal milestone_reached(streak_day: int, bonus_gems: int)

## Referencias
var game_data: GameData

## Daily reward configuration
var base_daily_gems: int = 10
var streak_bonus_multiplier: float = 0.2  # 20% extra por día de streak
var max_streak_bonus: int = 7  # Máximo 7 días de streak = 140% bonus
var milestone_bonuses: Dictionary = {7: 50, 30: 200, 100: 500}  # Semana completa: 50 gems extra  # Mes completo: 200 gems extra  # 100 días: 500 gems extra (rare achievement)


func _ready():
	print("💎 DailyRewardManager inicializado")
	# Conectar con sistema de logros para recompensas de gemas
	_connect_achievement_system()


## Asignar GameData
func set_game_data(data: GameData) -> void:
	game_data = data


## Verificar si hay recompensa diaria disponible
func is_daily_reward_available() -> bool:
	if not game_data:
		return false

	var last_claim = game_data.gameplay_data.get("last_daily_reward_claim", 0)
	var current_time = Time.get_unix_time_from_system()
	var hours_since_claim = (current_time - last_claim) / 3600.0

	# Disponible si han pasado más de 20 horas (permite cierta flexibilidad)
	return hours_since_claim >= 20.0


## Calcular streak actual
func get_current_streak() -> int:
	if not game_data:
		return 0

	return game_data.gameplay_data.get("daily_reward_streak", 0)


## Calcular gems de recompensa diaria
func calculate_daily_gems() -> int:
	var streak = get_current_streak()
	var streak_days = min(streak, max_streak_bonus)  # Cap en 7 días
	var streak_multiplier = 1.0 + (streak_days * streak_bonus_multiplier)

	var gems = int(base_daily_gems * streak_multiplier)

	# T026: Bonus de prestige si tiene stars altas
	if game_data and game_data.prestige_stars >= 50:
		gems = int(gems * 1.5)  # 50% extra con 50+ stars

	return gems


## Reclamar recompensa diaria
func claim_daily_reward() -> Dictionary:
	if not game_data or not is_daily_reward_available():
		return {"success": false, "message": "No disponible aún"}

	var current_time = Time.get_unix_time_from_system()
	var last_claim = game_data.gameplay_data.get("last_daily_reward_claim", 0)
	var hours_since_claim = (current_time - last_claim) / 3600.0

	# Determinar si se mantiene o rompe el streak
	var current_streak = get_current_streak()
	var new_streak = current_streak

	if hours_since_claim <= 48.0:  # 48 horas de gracia para mantener streak
		new_streak = current_streak + 1
	else:
		new_streak = 1  # Reset streak si pasan más de 48h
		if current_streak > 0:
			emit_signal("streak_broken")
			print("💔 Streak roto tras %d días" % current_streak)

	# Calcular gems basado en el nuevo streak
	game_data.gameplay_data["daily_reward_streak"] = new_streak
	var gems_earned = calculate_daily_gems()

	# Bonus por milestone
	var milestone_bonus = milestone_bonuses.get(new_streak, 0)
	if milestone_bonus > 0:
		gems_earned += milestone_bonus
		emit_signal("milestone_reached", new_streak, milestone_bonus)
		print("🏆 Milestone %d días: +%d gems bonus!" % [new_streak, milestone_bonus])

	# Otorgar gems
	game_data.add_gems(gems_earned)
	game_data.gameplay_data["last_daily_reward_claim"] = current_time

	# Actualizar estadísticas
	var total_daily_gems = game_data.gameplay_data.get("total_daily_gems_earned", 0)
	game_data.gameplay_data["total_daily_gems_earned"] = total_daily_gems + gems_earned

	emit_signal("daily_reward_claimed", gems_earned, new_streak)

	print("💎 Daily reward claimed: %d gems (streak: %d días)" % [gems_earned, new_streak])

	return {
		"success": true,
		"gems_earned": gems_earned,
		"new_streak": new_streak,
		"milestone_bonus": milestone_bonus,
		"next_reward_hours": 24
	}


# ═════════════════════════════════════════════════════════════════════════════════════
# T026: INTEGRACIÓN CON SISTEMA DE LOGROS - ACHIEVEMENT GEM REWARDS
# ═════════════════════════════════════════════════════════════════════════════════════


## Conectar con sistema de logros para recompensas automáticas
func _connect_achievement_system():
	# Buscar AchievementManager en la escena
	var achievement_manager = _find_achievement_manager()
	if achievement_manager:
		# Conectar señal de recompensas de logros
		if not achievement_manager.reward_granted.is_connected(_on_achievement_reward):
			achievement_manager.reward_granted.connect(_on_achievement_reward)
		print("💎 Conectado con AchievementManager para recompensas de gemas")
	else:
		# Intentar conectar más tarde cuando esté disponible
		call_deferred("_try_connect_later")


## Buscar AchievementManager en el árbol de nodos
func _find_achievement_manager() -> Node:
	# Buscar en GameController primero
	if GameController and GameController.has_method("get_achievement_manager"):
		return GameController.get_achievement_manager()

	# Buscar en el árbol de la escena actual
	var scene_tree = get_tree()
	if scene_tree:
		var nodes = scene_tree.get_nodes_in_group("achievement_manager")
		if nodes.size() > 0:
			return nodes[0]

	return null


## Reintentar conexión más tarde
func _try_connect_later():
	await get_tree().create_timer(1.0).timeout
	_connect_achievement_system()


## Callback cuando se otorga recompensa de logro
func _on_achievement_reward(reward_type: String, amount: int):
	if reward_type == "gems" and game_data:
		print("💎 Gemas de logro procesadas: +%d (manejado por AchievementManager)" % amount)
		# Las gemas ya fueron añadidas por AchievementManager,
		# solo registramos el evento para estadísticas futuras
		_track_achievement_gems(amount)


## Registrar gemas obtenidas por logros (para estadísticas)
func _track_achievement_gems(amount: int):
	if game_data:
		var total_achievement_gems = game_data.gameplay_data.get("total_achievement_gems", 0)
		game_data.gameplay_data["total_achievement_gems"] = total_achievement_gems + amount


## Obtener información de la próxima recompensa
func get_next_reward_info() -> Dictionary:
	if not game_data:
		return {}

	var last_claim = game_data.gameplay_data.get("last_daily_reward_claim", 0)
	var current_time = Time.get_unix_time_from_system()
	var hours_since_claim = (current_time - last_claim) / 3600.0
	var hours_until_next = max(0.0, 24.0 - hours_since_claim)

	var current_streak = get_current_streak()
	var next_gems = calculate_daily_gems()

	# Información sobre próximo milestone
	var next_milestone = 0
	var next_milestone_bonus = 0
	for milestone in milestone_bonuses.keys():
		if milestone > current_streak:
			next_milestone = milestone
			next_milestone_bonus = milestone_bonuses[milestone]
			break

	return {
		"available_now": is_daily_reward_available(),
		"hours_until_next": hours_until_next,
		"current_streak": current_streak,
		"next_gems": next_gems,
		"next_milestone": next_milestone,
		"next_milestone_bonus": next_milestone_bonus,
		"days_to_milestone": next_milestone - current_streak if next_milestone > 0 else 0
	}


## T026: Bonus gems por achievements
func award_achievement_gems(achievement_id: String) -> int:
	"""Otorgar gems por completar achievements"""
	if not game_data:
		return 0

	var gem_rewards = {
		# Production achievements
		"first_beer": 5,
		"mass_production": 10,
		"industrial_scale": 25,
		# Economic achievements
		"first_thousand": 5,
		"millionaire": 15,
		"mega_rich": 50,
		# Customer achievements
		"first_customer": 10,
		"customer_master": 25,
		"vip_service": 40,
		# Prestige achievements
		"first_prestige": 50,
		"prestige_master": 100,
		"star_collector": 200,
		# Meta achievements
		"dedicated_player": 25,
		"completionist": 100
	}

	var gems = gem_rewards.get(achievement_id, 0)
	if gems > 0:
		game_data.add_gems(gems)
		print("🏆 Achievement gems: %d por '%s'" % [gems, achievement_id])

	return gems


## Obtener estadísticas de gems totales
func get_gems_stats() -> Dictionary:
	if not game_data:
		return {}

	return {
		"current_gems": game_data.gems,
		"total_daily_earned": game_data.gameplay_data.get("total_daily_gems_earned", 0),
		"current_streak": get_current_streak(),
		"longest_streak": game_data.gameplay_data.get("longest_daily_streak", 0),
		"prestige_gems_rate": game_data.get("prestige_gems_per_hour", 0.0)
	}
