class_name ResearchManager
extends Node

## T035 - Sistema de Árbol de Investigación
## Tech upgrades para advanced players con unlocks progresivos

# Señales
signal research_completed(research_id: String, research_data: Dictionary)
signal research_unlocked(research_id: String)
signal research_progress_updated(research_id: String, progress: float)
signal tech_bonus_applied(bonus_type: String, bonus_value: float)

# Referencias
var game_data: GameData
var statistics_manager: StatisticsManager

# Estado de investigación
var research_tree: Dictionary = {}
var active_researches: Dictionary = {}
var completed_researches: Array = []
var available_researches: Array = []

# Recursos para investigación
var research_points: int = 0
var research_speed_multiplier: float = 1.0

# Timer para progreso de investigación
var research_timer: Timer

# Constantes
const BASE_RESEARCH_TIME = 300  # 5 minutos base
const RESEARCH_POINT_GENERATION_RATE = 1.0  # Por segundo cuando es elegible

func _ready():
	print("🔬 ResearchManager inicializado (T035)")
	_initialize_research_tree()
	_setup_research_timer()
	_calculate_available_researches()


func _initialize_research_tree():
	"""Define la estructura completa del árbol de investigación"""

	research_tree = {
		# === RAMA DE PRODUCCIÓN ===
		"production_efficiency_1": {
			"name": "Optimización Básica",
			"category": "production",
			"description": "Mejora la eficiencia de producción base en 15%",
			"cost": 50,
			"time": BASE_RESEARCH_TIME,
			"prerequisites": [],
			"unlocks": ["production_efficiency_2", "quality_control_1"],
			"bonus": {"type": "production_speed", "value": 0.15},
			"tier": 1
		},

		"production_efficiency_2": {
			"name": "Optimización Avanzada",
			"category": "production",
			"description": "Mejora adicional de eficiencia de producción en 25%",
			"cost": 150,
			"time": BASE_RESEARCH_TIME * 1.5,
			"prerequisites": ["production_efficiency_1"],
			"unlocks": ["production_efficiency_3", "batch_brewing"],
			"bonus": {"type": "production_speed", "value": 0.25},
			"tier": 2
		},

		"production_efficiency_3": {
			"name": "Maestría en Producción",
			"category": "production",
			"description": "Máxima optimización: +40% eficiencia de producción",
			"cost": 300,
			"time": BASE_RESEARCH_TIME * 2,
			"prerequisites": ["production_efficiency_2"],
			"unlocks": ["legendary_brewing"],
			"bonus": {"type": "production_speed", "value": 0.40},
			"tier": 3
		},

		"quality_control_1": {
			"name": "Control de Calidad Básico",
			"category": "production",
			"description": "Reduce defectos en 20% y mejora calidad promedio",
			"cost": 75,
			"time": BASE_RESEARCH_TIME * 1.2,
			"prerequisites": ["production_efficiency_1"],
			"unlocks": ["quality_control_2", "premium_ingredients"],
			"bonus": {"type": "quality_improvement", "value": 0.20},
			"tier": 2
		},

		"batch_brewing": {
			"name": "Producción en Lotes",
			"category": "production",
			"description": "Permite producir múltiples cervezas simultáneamente",
			"cost": 200,
			"time": BASE_RESEARCH_TIME * 1.8,
			"prerequisites": ["production_efficiency_2"],
			"unlocks": ["mass_production"],
			"bonus": {"type": "batch_size", "value": 2},
			"tier": 3
		},

		# === RAMA ECONÓMICA ===
		"market_analysis_1": {
			"name": "Análisis de Mercado I",
			"category": "economic",
			"description": "Incrementa precios de venta en 10%",
			"cost": 60,
			"time": BASE_RESEARCH_TIME,
			"prerequisites": [],
			"unlocks": ["market_analysis_2", "customer_psychology"],
			"bonus": {"type": "price_multiplier", "value": 0.10},
			"tier": 1
		},

		"market_analysis_2": {
			"name": "Análisis de Mercado II",
			"category": "economic",
			"description": "Incremento adicional de precios en 18%",
			"cost": 180,
			"time": BASE_RESEARCH_TIME * 1.5,
			"prerequisites": ["market_analysis_1"],
			"unlocks": ["market_domination", "brand_recognition"],
			"bonus": {"type": "price_multiplier", "value": 0.18},
			"tier": 2
		},

		"customer_psychology": {
			"name": "Psicología del Cliente",
			"category": "economic",
			"description": "Aumenta frecuencia de compra de clientes en 25%",
			"cost": 120,
			"time": BASE_RESEARCH_TIME * 1.3,
			"prerequisites": ["market_analysis_1"],
			"unlocks": ["loyalty_programs", "targeted_marketing"],
			"bonus": {"type": "customer_frequency", "value": 0.25},
			"tier": 2
		},

		"brand_recognition": {
			"name": "Reconocimiento de Marca",
			"category": "economic",
			"description": "Atrae 30% más clientes premium",
			"cost": 250,
			"time": BASE_RESEARCH_TIME * 2,
			"prerequisites": ["market_analysis_2", "customer_psychology"],
			"unlocks": ["market_monopoly"],
			"bonus": {"type": "premium_customer_rate", "value": 0.30},
			"tier": 3
		},

		# === RAMA DE AUTOMATIZACIÓN ===
		"automation_basics": {
			"name": "Fundamentos de Automatización",
			"category": "automation",
			"description": "Reduce costo de automatización en 20%",
			"cost": 80,
			"time": BASE_RESEARCH_TIME * 1.1,
			"prerequisites": [],
			"unlocks": ["smart_systems", "efficiency_protocols"],
			"bonus": {"type": "automation_cost_reduction", "value": 0.20},
			"tier": 1
		},

		"smart_systems": {
			"name": "Sistemas Inteligentes",
			"category": "automation",
			"description": "Automatización es 35% más eficiente",
			"cost": 160,
			"time": BASE_RESEARCH_TIME * 1.6,
			"prerequisites": ["automation_basics"],
			"unlocks": ["ai_optimization", "predictive_maintenance"],
			"bonus": {"type": "automation_efficiency", "value": 0.35},
			"tier": 2
		},

		"ai_optimization": {
			"name": "Optimización por IA",
			"category": "automation",
			"description": "IA gestiona automáticamente la producción óptima",
			"cost": 350,
			"time": BASE_RESEARCH_TIME * 2.5,
			"prerequisites": ["smart_systems"],
			"unlocks": ["full_automation"],
			"bonus": {"type": "ai_management", "value": 1},
			"tier": 3
		},

		# === RAMA DE RECURSOS ===
		"resource_optimization_1": {
			"name": "Optimización de Recursos I",
			"category": "resources",
			"description": "Reduce consumo de ingredientes en 15%",
			"cost": 70,
			"time": BASE_RESEARCH_TIME,
			"prerequisites": [],
			"unlocks": ["resource_optimization_2", "recycling_systems"],
			"bonus": {"type": "resource_efficiency", "value": 0.15},
			"tier": 1
		},

		"recycling_systems": {
			"name": "Sistemas de Reciclaje",
			"category": "resources",
			"description": "Recupera 25% de recursos desperdiciados",
			"cost": 130,
			"time": BASE_RESEARCH_TIME * 1.4,
			"prerequisites": ["resource_optimization_1"],
			"unlocks": ["zero_waste_production"],
			"bonus": {"type": "waste_recovery", "value": 0.25},
			"tier": 2
		},

		# === INVESTIGACIONES LEGENDARIAS (TIER 4) ===
		"legendary_brewing": {
			"name": "Arte Legendario",
			"category": "legendary",
			"description": "Desbloquea cervezas legendarias con precios 5x",
			"cost": 500,
			"time": BASE_RESEARCH_TIME * 4,
			"prerequisites": ["production_efficiency_3", "quality_control_2"],
			"unlocks": [],
			"bonus": {"type": "legendary_recipes", "value": 5.0},
			"tier": 4
		},

		"market_monopoly": {
			"name": "Monopolio del Mercado",
			"category": "legendary",
			"description": "Control total: +100% a todos los ingresos",
			"cost": 750,
			"time": BASE_RESEARCH_TIME * 5,
			"prerequisites": ["brand_recognition", "market_domination"],
			"unlocks": [],
			"bonus": {"type": "total_income_multiplier", "value": 1.0},
			"tier": 4
		},

		"full_automation": {
			"name": "Automatización Total",
			"category": "legendary",
			"description": "El negocio funciona completamente solo",
			"cost": 600,
			"time": BASE_RESEARCH_TIME * 4.5,
			"prerequisites": ["ai_optimization"],
			"unlocks": [],
			"bonus": {"type": "complete_automation", "value": 1},
			"tier": 4
		}
	}

	# Agregar investigaciones intermedias que no detallé
	_add_missing_researches()


func _add_missing_researches():
	"""Agrega las investigaciones intermedias faltantes"""
	var missing_researches = {
		"quality_control_2": {
			"name": "Control de Calidad Avanzado",
			"category": "production",
			"description": "Calidad perfecta: +35% calidad, reduce defectos 40%",
			"cost": 200,
			"time": BASE_RESEARCH_TIME * 1.8,
			"prerequisites": ["quality_control_1"],
			"unlocks": ["legendary_brewing"],
			"bonus": {"type": "quality_improvement", "value": 0.35},
			"tier": 3
		},

		"premium_ingredients": {
			"name": "Ingredientes Premium",
			"category": "production",
			"description": "Ingredientes de lujo mejoran calidad en 25%",
			"cost": 150,
			"time": BASE_RESEARCH_TIME * 1.5,
			"prerequisites": ["quality_control_1"],
			"unlocks": ["legendary_brewing"],
			"bonus": {"type": "ingredient_quality", "value": 0.25},
			"tier": 3
		},

		"market_domination": {
			"name": "Dominación de Mercado",
			"category": "economic",
			"description": "Elimina 50% de la competencia",
			"cost": 280,
			"time": BASE_RESEARCH_TIME * 2.2,
			"prerequisites": ["market_analysis_2"],
			"unlocks": ["market_monopoly"],
			"bonus": {"type": "competition_reduction", "value": 0.50},
			"tier": 3
		},

		"efficiency_protocols": {
			"name": "Protocolos de Eficiencia",
			"category": "automation",
			"description": "Sistemas automatizados son 20% más rápidos",
			"cost": 140,
			"time": BASE_RESEARCH_TIME * 1.4,
			"prerequisites": ["automation_basics"],
			"unlocks": ["predictive_maintenance"],
			"bonus": {"type": "automation_speed", "value": 0.20},
			"tier": 2
		}
	}

	for research_id in missing_researches:
		research_tree[research_id] = missing_researches[research_id]


func _setup_research_timer():
	"""Configura el timer para progreso de investigación"""
	research_timer = Timer.new()
	research_timer.wait_time = 1.0  # Tick cada segundo
	research_timer.timeout.connect(_process_research_progress)
	research_timer.autostart = true
	add_child(research_timer)


## === GESTIÓN DE INVESTIGACIÓN ===

func start_research(research_id: String) -> bool:
	"""Inicia una investigación si es posible"""

	if not research_tree.has(research_id):
		print("❌ Investigación no encontrada: ", research_id)
		return false

	if completed_researches.has(research_id):
		print("❌ Investigación ya completada: ", research_id)
		return false

	if active_researches.has(research_id):
		print("❌ Investigación ya en progreso: ", research_id)
		return false

	var research = research_tree[research_id]

	# Verificar prerequisitos
	if not _check_prerequisites(research_id):
		print("❌ Prerequisitos no cumplidos para: ", research_id)
		return false

	# Verificar costo
	if research_points < research["cost"]:
		print("❌ Puntos de investigación insuficientes: %d/%d" % [research_points, research["cost"]])
		return false

	# Iniciar investigación
	research_points -= research["cost"]
	active_researches[research_id] = {
		"progress": 0.0,
		"total_time": research["time"],
		"start_time": Time.get_unix_time_from_system()
	}

	print("🔬 Investigación iniciada: %s (Costo: %d)" % [research["name"], research["cost"]])
	research_progress_updated.emit(research_id, 0.0)
	return true


func _check_prerequisites(research_id: String) -> bool:
	"""Verifica si se cumplen los prerequisitos para una investigación"""
	var research = research_tree[research_id]

	for prereq in research["prerequisites"]:
		if not completed_researches.has(prereq):
			return false

	return true


func _process_research_progress():
	"""Procesa el progreso de las investigaciones activas"""
	for research_id in active_researches.keys():
		var active_research = active_researches[research_id]
		var research_data = research_tree[research_id]

		# Incrementar progreso
		var progress_per_second = research_speed_multiplier / research_data["time"]
		active_research["progress"] += progress_per_second

		research_progress_updated.emit(research_id, active_research["progress"])

		# Verificar si está completa
		if active_research["progress"] >= 1.0:
			_complete_research(research_id)


func _complete_research(research_id: String):
	"""Completa una investigación y aplica sus bonificaciones"""
	var research = research_tree[research_id]

	# Remover de activas y agregar a completadas
	active_researches.erase(research_id)
	completed_researches.append(research_id)

	# Aplicar bonus
	_apply_research_bonus(research_id, research["bonus"])

	# Actualizar disponibles
	_calculate_available_researches()

	print("✅ Investigación completada: %s" % research["name"])
	research_completed.emit(research_id, research)

	# Guardar progreso
	_save_research_data()


func _apply_research_bonus(research_id: String, bonus: Dictionary):
	"""Aplica las bonificaciones de una investigación completada"""
	var bonus_type = bonus["type"]
	var bonus_value = bonus["value"]

	match bonus_type:
		"production_speed":
			_apply_production_speed_bonus(bonus_value)
		"quality_improvement":
			_apply_quality_bonus(bonus_value)
		"price_multiplier":
			_apply_price_bonus(bonus_value)
		"customer_frequency":
			_apply_customer_frequency_bonus(bonus_value)
		"automation_efficiency":
			_apply_automation_efficiency_bonus(bonus_value)
		"resource_efficiency":
			_apply_resource_efficiency_bonus(bonus_value)
		# Bonus legendarios
		"legendary_recipes":
			_unlock_legendary_recipes()
		"complete_automation":
			_enable_complete_automation()
		"total_income_multiplier":
			_apply_total_income_multiplier(bonus_value)

	tech_bonus_applied.emit(bonus_type, bonus_value)


func _apply_production_speed_bonus(bonus: float):
	"""Aplica bonus de velocidad de producción"""
	if game_data and game_data.research_bonuses:
		if not game_data.research_bonuses.has("production_speed_multiplier"):
			game_data.research_bonuses["production_speed_multiplier"] = 1.0
		game_data.research_bonuses["production_speed_multiplier"] += bonus
		print("⚡ Bonus de producción aplicado: +%.0f%% (Total: %.0f%%)" %
			[bonus * 100, (game_data.research_bonuses["production_speed_multiplier"] - 1) * 100])


func _apply_quality_bonus(bonus: float):
	"""Aplica bonus de calidad"""
	if game_data and game_data.research_bonuses:
		if not game_data.research_bonuses.has("quality_multiplier"):
			game_data.research_bonuses["quality_multiplier"] = 1.0
		game_data.research_bonuses["quality_multiplier"] += bonus
		print("⭐ Bonus de calidad aplicado: +%.0f%%" % (bonus * 100))


func _apply_price_bonus(bonus: float):
	"""Aplica bonus de precio de venta"""
	if game_data and game_data.research_bonuses:
		if not game_data.research_bonuses.has("price_multiplier"):
			game_data.research_bonuses["price_multiplier"] = 1.0
		game_data.research_bonuses["price_multiplier"] += bonus
		print("💰 Bonus de precio aplicado: +%.0f%%" % (bonus * 100))


func _apply_customer_frequency_bonus(bonus: float):
	"""Aplica bonus de frecuencia de clientes"""
	if game_data and game_data.research_bonuses:
		if not game_data.research_bonuses.has("customer_frequency_multiplier"):
			game_data.research_bonuses["customer_frequency_multiplier"] = 1.0
		game_data.research_bonuses["customer_frequency_multiplier"] += bonus
		print("🚶 Bonus de frecuencia de clientes aplicado: +%.0f%%" % (bonus * 100))


func _apply_automation_efficiency_bonus(bonus: float):
	"""Aplica bonus de eficiencia de automatización"""
	if game_data and game_data.research_bonuses:
		if not game_data.research_bonuses.has("automation_efficiency_multiplier"):
			game_data.research_bonuses["automation_efficiency_multiplier"] = 1.0
		game_data.research_bonuses["automation_efficiency_multiplier"] += bonus
		print("🤖 Bonus de automatización aplicado: +%.0f%%" % (bonus * 100))


func _apply_resource_efficiency_bonus(bonus: float):
	"""Aplica bonus de eficiencia de recursos"""
	if game_data and game_data.research_bonuses:
		if not game_data.research_bonuses.has("resource_efficiency_multiplier"):
			game_data.research_bonuses["resource_efficiency_multiplier"] = 1.0
		game_data.research_bonuses["resource_efficiency_multiplier"] += bonus
		print("📦 Bonus de recursos aplicado: +%.0f%%" % (bonus * 100))


func _unlock_legendary_recipes():
	"""Desbloquea recetas legendarias"""
	if game_data and game_data.research_bonuses:
		game_data.research_bonuses["legendary_recipes_unlocked"] = true
		print("🌟 ¡RECETAS LEGENDARIAS DESBLOQUEADAS!")


func _enable_complete_automation():
	"""Habilita automatización completa"""
	if game_data and game_data.research_bonuses:
		game_data.research_bonuses["complete_automation"] = true
		print("🏭 ¡AUTOMATIZACIÓN TOTAL ACTIVADA!")


func _apply_total_income_multiplier(bonus: float):
	"""Aplica multiplicador total de ingresos"""
	if game_data and game_data.research_bonuses:
		if not game_data.research_bonuses.has("total_income_multiplier"):
			game_data.research_bonuses["total_income_multiplier"] = 1.0
		game_data.research_bonuses["total_income_multiplier"] += bonus
		print("💎 ¡MONOPOLIO ACTIVADO! +%.0f%% a TODOS los ingresos" % (bonus * 100))


## === GESTIÓN DE PUNTOS DE INVESTIGACIÓN ===

func add_research_points(amount: int):
	"""Agrega puntos de investigación"""
	research_points += amount
	print("🔬 +%d puntos de investigación (Total: %d)" % [amount, research_points])


func generate_research_points():
	"""Genera puntos de investigación basado en criterios"""
	# Puntos base por tiempo
	var base_points = 1

	# Bonus por estadísticas (si está disponible)
	if statistics_manager:
		var efficiency_score = statistics_manager.get_efficiency_score()
		base_points += int(efficiency_score * 2)  # Hasta +2 puntos por eficiencia

	# Bonus por prestige level
	if game_data and game_data.prestige_level > 0:
		base_points += game_data.prestige_level

	add_research_points(base_points)


func _calculate_available_researches():
	"""Calcula qué investigaciones están disponibles para iniciar"""
	available_researches.clear()

	for research_id in research_tree.keys():
		if completed_researches.has(research_id):
			continue

		if active_researches.has(research_id):
			continue

		if _check_prerequisites(research_id):
			available_researches.append(research_id)
			if not research_tree[research_id].get("notified", false):
				research_unlocked.emit(research_id)
				research_tree[research_id]["notified"] = true


## === SAVE/LOAD ===

func _save_research_data():
	"""Guarda datos de investigación en GameData"""
	if not game_data:
		return

	if not game_data.research_data:
		game_data.research_data = {}

	game_data.research_data["completed_researches"] = completed_researches
	game_data.research_data["active_researches"] = active_researches
	game_data.research_data["research_points"] = research_points
	game_data.research_data["research_speed_multiplier"] = research_speed_multiplier


func load_research_data():
	"""Carga datos de investigación desde GameData"""
	if not game_data or not game_data.research_data:
		return

	var data = game_data.research_data

	if data.has("completed_researches"):
		completed_researches = data["completed_researches"]
		# Reaplicar bonuses de investigaciones completadas
		for research_id in completed_researches:
			if research_tree.has(research_id):
				_apply_research_bonus(research_id, research_tree[research_id]["bonus"])

	if data.has("active_researches"):
		active_researches = data["active_researches"]

	if data.has("research_points"):
		research_points = data["research_points"]

	if data.has("research_speed_multiplier"):
		research_speed_multiplier = data["research_speed_multiplier"]

	_calculate_available_researches()
	print("🔬 Datos de investigación cargados")


## === API PÚBLICAS ===

func get_research_info(research_id: String) -> Dictionary:
	"""Obtiene información de una investigación"""
	if research_tree.has(research_id):
		return research_tree[research_id].duplicate(true)
	return {}


func get_available_researches() -> Array:
	"""Obtiene investigaciones disponibles para iniciar"""
	return available_researches.duplicate()


func get_active_researches() -> Dictionary:
	"""Obtiene investigaciones activas con su progreso"""
	return active_researches.duplicate(true)


func get_completed_researches() -> Array:
	"""Obtiene investigaciones completadas"""
	return completed_researches.duplicate()


func get_research_by_category(category: String) -> Array:
	"""Obtiene investigaciones de una categoría específica"""
	var category_researches = []
	for research_id in research_tree.keys():
		if research_tree[research_id]["category"] == category:
			category_researches.append(research_id)
	return category_researches


func get_research_tree_progress() -> Dictionary:
	"""Obtiene progreso general del árbol de investigación"""
	var total_researches = research_tree.size()
	var completed_count = completed_researches.size()
	var active_count = active_researches.size()

	return {
		"total": total_researches,
		"completed": completed_count,
		"active": active_count,
		"available": available_researches.size(),
		"completion_percentage": float(completed_count) / float(total_researches) * 100,
		"research_points": research_points
	}


func can_start_research(research_id: String) -> bool:
	"""Verifica si se puede iniciar una investigación"""
	if not research_tree.has(research_id):
		return false
	if completed_researches.has(research_id):
		return false
	if active_researches.has(research_id):
		return false
	if not _check_prerequisites(research_id):
		return false
	if research_points < research_tree[research_id]["cost"]:
		return false
	return true


## === INTEGRATION ===

func set_game_data(data: GameData):
	"""Conectar con GameData"""
	game_data = data

	# Inicializar research_bonuses si no existe
	if not game_data.research_bonuses:
		game_data.research_bonuses = {}

	load_research_data()


func set_statistics_manager(stats_manager: StatisticsManager):
	"""Conectar con StatisticsManager para generar puntos basado en stats"""
	statistics_manager = stats_manager
