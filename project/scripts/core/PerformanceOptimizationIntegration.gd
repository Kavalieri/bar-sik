extends Node

## T028 - Performance Optimization Integration
## Script para integrar sistemas de performance con managers existentes
## Se ejecuta automáticamente al inicializar el juego


func _ready():
	print("🚀 T028 Performance Optimization Integration")
	_initialize_performance_systems()


func _initialize_performance_systems():
	"""Initialize all performance optimization systems"""

	# Add performance managers to scene tree
	_add_performance_managers()

	# Optimize existing managers
	await get_tree().process_frame
	_optimize_existing_managers()

	# Connect performance monitoring
	_setup_performance_monitoring()

	print("✅ Performance optimization systems initialized")


func _add_performance_managers():
	"""Add performance managers to the scene"""

	# Create and add PerformanceManager
	var performance_manager = PerformanceManager.new()
	performance_manager.name = "PerformanceManager"
	get_tree().root.add_child(performance_manager)

	# Create and add ObjectPoolManager
	var object_pool_manager = ObjectPoolManager.new()
	object_pool_manager.name = "ObjectPoolManager"
	get_tree().root.add_child(object_pool_manager)

	# Create and add TickManager
	var tick_manager = TickManager.new()
	tick_manager.name = "TickManager"
	get_tree().root.add_child(tick_manager)

	print("📊 Performance managers added to scene tree")


func _optimize_existing_managers():
	"""Optimize existing managers to use performance systems"""

	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		print("⚠️ GameController not found for optimization")
		return

	# Convert managers to use tick system instead of _process
	_optimize_generator_manager(game_controller)
	_optimize_production_manager(game_controller)
	_optimize_ui_panels(game_controller)

	print("⚡ Existing managers optimized for performance")


func _optimize_generator_manager(game_controller):
	"""Optimize GeneratorManager to use tick system"""

	var generator_manager = game_controller.get("generator_manager")
	if not generator_manager:
		return

	var tick_manager = TickManager.instance
	if not tick_manager:
		return

	# Register generator updates to normal tick (30 FPS)
	var generator_tick_callback = func():
		if generator_manager.has_method("tick_update"):
			generator_manager.tick_update()
		elif generator_manager.has_method("_update_generation"):
			generator_manager._update_generation()

	tick_manager.register_normal_tick(generator_tick_callback)
	print("🔧 GeneratorManager optimized with tick system")


func _optimize_production_manager(game_controller):
	"""Optimize ProductionManager to use tick system"""

	var production_manager = game_controller.get("production_manager")
	if not production_manager:
		return

	var tick_manager = TickManager.instance
	if not tick_manager:
		return

	# Register production updates to slow tick (10 FPS) - production is less time-sensitive
	var production_tick_callback = func():
		if production_manager.has_method("tick_update"):
			production_manager.tick_update()
		elif production_manager.has_method("_process_auto_production"):
			production_manager._process_auto_production()

	tick_manager.register_slow_tick(production_tick_callback)
	print("🔧 ProductionManager optimized with tick system")


func _optimize_ui_panels(game_controller):
	"""Optimize UI panels to use object pooling"""

	var object_pool_manager = ObjectPoolManager.instance
	if not object_pool_manager:
		return

	# Create pools for common UI elements used in panels
	object_pool_manager.create_pool("StockLabel", 20)
	object_pool_manager.create_pool("ProductButton", 15)
	object_pool_manager.create_pool("GeneratorButton", 10)
	object_pool_manager.create_pool("ProgressIndicator", 10)

	print("🔧 UI panels optimized with object pooling")


func _setup_performance_monitoring():
	"""Setup performance monitoring and auto-optimization"""

	var performance_manager = PerformanceManager.instance
	if not performance_manager:
		return

	# Connect performance signals
	performance_manager.performance_warning.connect(_on_performance_warning)
	performance_manager.performance_critical.connect(_on_performance_critical)
	performance_manager.performance_recovered.connect(_on_performance_recovered)

	print("📊 Performance monitoring active")


func _on_performance_warning(fps: float, memory: int):
	"""Handle performance warning"""
	print("⚠️ Performance warning: FPS=%.1f, Memory=%s" % [fps, _format_memory(memory)])

	# Apply moderate optimizations
	var tick_manager = TickManager.instance
	if tick_manager:
		tick_manager.optimize_for_performance_mode("optimized")

	# Show performance notification to user
	_show_performance_notification("Performance optimizations enabled", false)


func _on_performance_critical(fps: float, memory: int):
	"""Handle critical performance issues"""
	print("🚨 CRITICAL performance issue: FPS=%.1f, Memory=%s" % [fps, _format_memory(memory)])

	# Apply emergency optimizations
	var tick_manager = TickManager.instance
	if tick_manager:
		tick_manager.optimize_for_performance_mode("emergency")

	var object_pool_manager = ObjectPoolManager.instance
	if object_pool_manager:
		object_pool_manager.force_cleanup_all()

	# Show critical performance notification
	_show_performance_notification("Emergency performance mode active", true)


func _on_performance_recovered():
	"""Handle performance recovery"""
	print("✅ Performance recovered - returning to normal mode")

	# Return to normal performance settings
	var tick_manager = TickManager.instance
	if tick_manager:
		tick_manager.optimize_for_performance_mode("normal")

	# Show recovery notification
	_show_performance_notification("Performance back to normal", false)


func _show_performance_notification(message: String, is_critical: bool):
	"""Show performance notification to user"""

	# Try to find notification system
	var game_controller = get_tree().get_first_node_in_group("game_controller")
	if not game_controller:
		return

	# Use achievement manager's notification system if available
	var achievement_manager = game_controller.get("achievement_manager")
	if achievement_manager and achievement_manager.has_method("show_notification"):
		var icon = "⚡" if not is_critical else "🚨"
		achievement_manager.show_notification(icon + " " + message)
		return

	# Fallback to console output
	var prefix = "⚡ PERFORMANCE: " if not is_critical else "🚨 CRITICAL: "
	print(prefix + message)


func _format_memory(bytes: int) -> String:
	"""Format memory usage in human-readable format"""
	if bytes < 1024:
		return "%d B" % bytes
	elif bytes < 1024 * 1024:
		return "%.1f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.1f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.1f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))


# ═══════════════════════════════════════════════════════════════════════════════════
# PUBLIC API FOR DEBUGGING
# ═══════════════════════════════════════════════════════════════════════════════════


func get_performance_report() -> Dictionary:
	"""Get comprehensive performance report"""

	var report = {
		"status": "Performance systems not initialized",
		"performance_manager": null,
		"object_pool_manager": null,
		"tick_manager": null
	}

	# Get PerformanceManager stats
	var performance_manager = PerformanceManager.instance
	if performance_manager:
		report.performance_manager = performance_manager.get_performance_stats()
		report.status = "Performance systems active"

	# Get ObjectPoolManager stats
	var object_pool_manager = ObjectPoolManager.instance
	if object_pool_manager:
		report.object_pool_manager = object_pool_manager.get_pool_stats()

	# Get TickManager stats
	var tick_manager = TickManager.instance
	if tick_manager:
		report.tick_manager = tick_manager.get_tick_stats()

	return report


func print_performance_report():
	"""Print detailed performance report to console"""

	print("\n🚀 T028 PERFORMANCE OPTIMIZATION REPORT")
	print("=" * 60)

	var performance_manager = PerformanceManager.instance
	if performance_manager:
		print(performance_manager.get_performance_summary())
	else:
		print("⚠️ PerformanceManager not initialized")

	print()

	var object_pool_manager = ObjectPoolManager.instance
	if object_pool_manager:
		print(object_pool_manager.get_pool_summary())
	else:
		print("⚠️ ObjectPoolManager not initialized")

	print()

	var tick_manager = TickManager.instance
	if tick_manager:
		print(tick_manager.get_tick_summary())
	else:
		print("⚠️ TickManager not initialized")

	print("=" * 60)
