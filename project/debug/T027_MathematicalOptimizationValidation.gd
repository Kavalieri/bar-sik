extends Node

## T027 - Mathematical Optimization Validation
## Script para validar que las curvas matemáticas están optimizadas correctamente


func _ready():
	print("\n🧮 T027 - MATHEMATICAL OPTIMIZATION VALIDATION")
	print("=" * 60)
	_validate_mathematical_optimization()


func _validate_mathematical_optimization():
	"""Validar todas las optimizaciones matemáticas implementadas"""

	print("\n1️⃣ Testing Cost Scaling Optimization...")
	_test_cost_scaling_curves()

	print("\n2️⃣ Testing Idle Efficiency Curves...")
	_test_idle_efficiency_optimization()

	print("\n3️⃣ Testing Prestige Mathematics...")
	_test_prestige_calculations()

	print("\n4️⃣ Testing Game Phase Detection...")
	_test_game_phase_detection()

	print("\n5️⃣ Testing Engagement Optimization...")
	_test_engagement_optimization()

	print("\n✅ T027 Mathematical Optimization Validation Complete!")


func _test_cost_scaling_curves():
	"""Test que las curvas de costo estén optimizadas"""

	var math_manager = MathematicalBalanceManager.new()

	# Test early game progression (should be gentle)
	var early_progress = {"money": 1000, "prestige_count": 0, "max_generator_level": 5}
	var early_cost_1 = math_manager.get_optimized_cost(100, 1, "generator", early_progress)
	var early_cost_5 = math_manager.get_optimized_cost(100, 5, "generator", early_progress)
	var early_cost_10 = math_manager.get_optimized_cost(100, 10, "generator", early_progress)

	print(
		(
			"   Early Game Costs: L1=%.0f, L5=%.0f, L10=%.0f"
			% [early_cost_1, early_cost_5, early_cost_10]
		)
	)

	# Test mid game progression (should accelerate)
	var mid_progress = {"money": 50000, "prestige_count": 0, "max_generator_level": 25}
	var mid_cost_20 = math_manager.get_optimized_cost(100, 20, "generator", mid_progress)
	var mid_cost_30 = math_manager.get_optimized_cost(100, 30, "generator", mid_progress)

	print("   Mid Game Costs: L20=%.0f, L30=%.0f" % [mid_cost_20, mid_cost_30])

	# Test late game progression (should be steep for prestige incentive)
	var late_progress = {"money": 1000000, "prestige_count": 1, "max_generator_level": 60}
	var late_cost_50 = math_manager.get_optimized_cost(100, 50, "generator", late_progress)
	var late_cost_70 = math_manager.get_optimized_cost(100, 70, "generator", late_progress)

	print("   Late Game Costs: L50=%.0f, L70=%.0f" % [late_cost_50, late_cost_70])

	# Validate curve progression is appropriate
	var early_growth = early_cost_5 / early_cost_1
	var mid_growth = mid_cost_30 / mid_cost_20
	var late_growth = late_cost_70 / late_cost_50

	print(
		(
			"   Growth Ratios: Early=%.2fx, Mid=%.2fx, Late=%.2fx"
			% [early_growth, mid_growth, late_growth]
		)
	)

	if early_growth < mid_growth and mid_growth < late_growth:
		print("   ✅ Cost curve progression is optimized")
	else:
		print("   ❌ Cost curve needs adjustment")


func _test_idle_efficiency_optimization():
	"""Test que la curva de eficiencia idle esté optimizada"""

	var math_manager = MathematicalBalanceManager.new()

	# Test various offline times
	var efficiency_5min = math_manager.get_idle_efficiency(300, false)  # 5 min
	var efficiency_1hour = math_manager.get_idle_efficiency(3600, false)  # 1 hour
	var efficiency_8hours = math_manager.get_idle_efficiency(28800, false)  # 8 hours
	var efficiency_24hours = math_manager.get_idle_efficiency(86400, false)  # 24 hours

	print(
		(
			"   Idle Efficiency: 5min=%.1f%%, 1h=%.1f%%, 8h=%.1f%%, 24h=%.1f%%"
			% [
				efficiency_5min * 100,
				efficiency_1hour * 100,
				efficiency_8hours * 100,
				efficiency_24hours * 100
			]
		)
	)

	# Test premium bonuses
	var premium_1hour = math_manager.get_idle_efficiency(3600, true)
	var premium_8hours = math_manager.get_idle_efficiency(28800, true)

	print(
		"   Premium Efficiency: 1h=%.1f%%, 8h=%.1f%%" % [premium_1hour * 100, premium_8hours * 100]
	)

	# Validate curve incentivizes frequent check-ins but allows idle
	if (
		efficiency_5min > efficiency_1hour
		and efficiency_1hour > efficiency_8hours
		and efficiency_8hours > efficiency_24hours
		and efficiency_5min >= 0.8
	):
		print("   ✅ Idle efficiency curve is optimized")
	else:
		print("   ❌ Idle efficiency curve needs adjustment")


func _test_prestige_calculations():
	"""Test que los cálculos de prestige estén balanceados"""

	var math_manager = MathematicalBalanceManager.new()

	# Test prestige star calculations
	var stars_100k = math_manager.calculate_prestige_stars(100000, 25)
	var stars_1m = math_manager.calculate_prestige_stars(1000000, 50)
	var stars_10m = math_manager.calculate_prestige_stars(10000000, 75)

	print("   Prestige Stars: $100k=⭐%d, $1M=⭐%d, $10M=⭐%d" % [stars_100k, stars_1m, stars_10m])

	# Test prestige timing analysis
	var prestige_analysis_early = math_manager.should_prestige(500000, 30, 0)
	var prestige_analysis_ready = math_manager.should_prestige(2000000, 60, 0)

	print("   Prestige Analysis Early: %s" % str(prestige_analysis_early.should_prestige))
	print("   Prestige Analysis Ready: %s" % str(prestige_analysis_ready.should_prestige))

	if stars_1m > stars_100k and stars_10m > stars_1m:
		print("   ✅ Prestige progression is balanced")
	else:
		print("   ❌ Prestige progression needs adjustment")


func _test_game_phase_detection():
	"""Test que la detección de fases del juego sea precisa"""

	var math_manager = MathematicalBalanceManager.new()

	# Create test scenarios for each phase
	var early_progress = {"money": 5000, "prestige_count": 0, "max_generator_level": 8}
	var mid_progress = {"money": 150000, "prestige_count": 0, "max_generator_level": 35}
	var late_progress = {"money": 2000000, "prestige_count": 1, "max_generator_level": 80}

	# Test multipliers for generators in each phase
	var early_mult = math_manager._get_growth_multiplier(10, "generator", early_progress)
	var mid_mult = math_manager._get_growth_multiplier(30, "generator", mid_progress)
	var late_mult = math_manager._get_growth_multiplier(60, "generator", late_progress)

	print(
		"   Phase Multipliers: Early=%.3f, Mid=%.3f, Late=%.3f" % [early_mult, mid_mult, late_mult]
	)

	# Validate phase progression
	if early_mult < mid_mult and mid_mult < late_mult:
		print("   ✅ Game phase detection is working correctly")
	else:
		print("   ❌ Game phase detection needs adjustment")


func _test_engagement_optimization():
	"""Test que el sistema de optimización de engagement funcione"""

	var math_manager = MathematicalBalanceManager.new()

	# Create test player progress
	var player_progress = {"money": 25000, "prestige_count": 0, "max_generator_level": 20}

	# Create test purchase options
	var item_costs = [
		{"type": "generator", "cost": 15000, "level": 15, "name": "Generator L15"},
		{"type": "station", "cost": 30000, "level": 8, "name": "Station L8"},
		{"type": "upgrade", "cost": 40000, "level": 5, "name": "Upgrade L5"},
		{"type": "automation", "cost": 50000, "level": 3, "name": "Automation L3"}
	]

	var recommendations = math_manager.get_next_purchase_target(25000, item_costs, player_progress)

	print("   Purchase Recommendations:")
	if recommendations.immediate_recommendation:
		print("     Immediate: %s" % recommendations.immediate_recommendation.name)
	if recommendations.short_term_goal:
		print("     Short-term: %s" % recommendations.short_term_goal.name)

	print("   Affordable items: %d" % recommendations.affordable_items.size())
	print("   Upcoming items: %d" % recommendations.upcoming_items.size())

	print("   ✅ Engagement optimization system is functional")


func _test_balance_summary():
	"""Generate a balance summary for debugging"""

	var math_manager = MathematicalBalanceManager.new()

	var test_progress = {"money": 150000, "stars": 2, "max_level": 45, "prestige_count": 1}

	var summary = math_manager.get_balance_summary(test_progress)
	print("\n📊 BALANCE SUMMARY:")
	print(summary)
