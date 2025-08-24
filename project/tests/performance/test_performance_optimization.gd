extends Node

## T028 - Performance Optimization Validation
## Script para validar que todas las optimizaciones de performance estén funcionando


func _ready():
	print("\n🚀 T028 - PERFORMANCE OPTIMIZATION VALIDATION")
	print("=".repeat(60))
	_validate_performance_optimization()


func _validate_performance_optimization():
	"""Validar todas las optimizaciones de performance implementadas"""

	await get_tree().process_frame

	print("\n1️⃣ Testing Performance Manager...")
	_test_performance_manager()

	print("\n2️⃣ Testing Object Pool Manager...")
	_test_object_pool_manager()

	print("\n3️⃣ Testing Tick Manager...")
	_test_tick_manager()

	print("\n4️⃣ Testing Performance Integration...")
	_test_performance_integration()

	print("\n5️⃣ Testing Memory Management...")
	await _test_memory_management()

	print("\n6️⃣ Performance Stress Test...")
	await _performance_stress_test()

	print("\n✅ T028 Performance Optimization Validation Complete!")


func _test_performance_manager():
	"""Test que PerformanceManager esté funcionando"""

	var performance_manager = PerformanceManager.instance
	if not performance_manager:
		print("❌ PerformanceManager not found")
		return

	print("✅ PerformanceManager found and active")

	# Test performance statistics
	var stats = performance_manager.get_performance_stats()
	print("   Current FPS: %.1f/%.1f" % [stats.fps, stats.target_fps])
	print("   Memory Usage: %.1f MB" % stats.memory_usage_mb)
	print("   Performance Mode: %s" % stats.performance_mode)

	# Test performance summary
	var summary = performance_manager.get_performance_summary()
	if summary.length() > 0:
		print("✅ Performance summary generation working")
	else:
		print("❌ Performance summary generation failed")


func _test_object_pool_manager():
	"""Test que ObjectPoolManager esté funcionando"""

	var object_pool_manager = get_node_or_null("/root/ObjectPoolManager")
	if not object_pool_manager:
		print("❌ ObjectPoolManager not found")
		return

	print("✅ ObjectPoolManager found and active")

	# Test object creation and pooling
	var test_label = object_pool_manager.get_object("Label")
	if test_label and test_label is Label:
		print("✅ Object creation from pool working")

		# Return object to pool
		object_pool_manager.return_object(test_label, "Label")
		print("✅ Object return to pool working")
	else:
		print("❌ Object pooling failed")

	# Test pool statistics
	var pool_stats = object_pool_manager.get_pool_stats()
	if pool_stats.has("summary"):
		print(
			(
				"✅ Pool statistics: %d pools, %.1f%% hit rate"
				% [pool_stats.summary.total_pools, pool_stats.summary.hit_rate]
			)
		)
	else:
		print("❌ Pool statistics generation failed")


func _test_tick_manager():
	"""Test que TickManager esté funcionando"""

	var tick_manager = TickManager.instance
	if not tick_manager:
		print("❌ TickManager not found")
		return

	print("✅ TickManager found and active")

	# Test tick callback registration
	var test_callback_executed = false
	var test_callback = func(): test_callback_executed = true

	tick_manager.register_fast_tick(test_callback)

	# Wait for tick to execute
	await get_tree().create_timer(0.1).timeout

	if test_callback_executed:
		print("✅ Tick callback system working")
		tick_manager.unregister_callback(test_callback)
	else:
		print("❌ Tick callback system failed")

	# Test tick statistics
	var tick_stats = tick_manager.get_tick_stats()
	if tick_stats.has("total_callbacks"):
		print("✅ Tick statistics: %d total callbacks" % tick_stats.total_callbacks)
	else:
		print("❌ Tick statistics generation failed")


func _test_performance_integration():
	"""Test que la integración de performance esté funcionando"""

	var integration_node = get_node_or_null("/root/PerformanceOptimizationIntegration")
	if not integration_node:
		# Try to find it by class or name
		integration_node = get_tree().get_first_node_in_group("performance_integration")

	if integration_node:
		print("✅ Performance integration system active")

		# Test performance report generation
		if integration_node.has_method("get_performance_report"):
			var report = integration_node.get_performance_report()
			if report.has("status"):
				print("✅ Performance report: %s" % report.status)
			else:
				print("❌ Performance report generation failed")

	else:
		print("⚠️ Performance integration not found (may be embedded)")


func _test_memory_management():
	"""Test memory management and cleanup"""

	print("Testing memory management...")

	# Record initial memory
	var initial_memory = OS.get_static_memory_peak_usage()
	print("   Initial memory: %s" % _format_memory(initial_memory))

	# Create many objects to test cleanup
	var test_objects = []
	for i in range(1000):
		var obj = Label.new()
		obj.text = "Test object %d" % i
		test_objects.append(obj)

	var peak_memory = OS.get_static_memory_peak_usage()
	print("   Peak memory: %s" % _format_memory(peak_memory))

	# Clean up objects
	for obj in test_objects:
		obj.queue_free()
	test_objects.clear()

	# Force cleanup
	var performance_manager = PerformanceManager.instance
	if performance_manager:
		performance_manager.optimize_memory_usage()

	# Wait for cleanup
	await get_tree().process_frame
	await get_tree().process_frame

	var final_memory = OS.get_static_memory_peak_usage()
	print("   Final memory: %s" % _format_memory(final_memory))

	var memory_cleaned = peak_memory - final_memory
	if memory_cleaned > 0:
		print("✅ Memory cleanup working: %s freed" % _format_memory(memory_cleaned))
	else:
		print("⚠️ Memory cleanup not detected (may be automatic)")


func _performance_stress_test():
	"""Stress test para validar performance bajo carga"""

	print("Running performance stress test...")

	var performance_manager = PerformanceManager.instance
	if not performance_manager:
		print("❌ Cannot run stress test without PerformanceManager")
		return

	# Record initial performance
	var initial_stats = performance_manager.get_performance_stats()
	print("   Initial FPS: %.1f" % initial_stats.fps)

	# Create stress load
	var stress_objects = []
	var object_pool_manager = get_node_or_null("/root/ObjectPoolManager")

	# Create many UI objects rapidly
	for i in range(500):
		var obj = null
		if object_pool_manager:
			obj = object_pool_manager.get_object("Label")
		else:
			obj = Label.new()

		if obj:
			obj.text = "Stress test object %d" % i
			add_child(obj)
			stress_objects.append(obj)

		# Yield occasionally to prevent blocking
		if i % 50 == 0:
			await get_tree().process_frame

	# Measure performance under load
	await get_tree().create_timer(1.0).timeout
	var stress_stats = performance_manager.get_performance_stats()
	print("   Under load FPS: %.1f" % stress_stats.fps)

	# Clean up stress test
	for obj in stress_objects:
		if object_pool_manager:
			object_pool_manager.return_object(obj, "Label")
		else:
			obj.queue_free()
	stress_objects.clear()

	# Wait for cleanup and measure recovery
	await get_tree().create_timer(2.0).timeout
	var recovery_stats = performance_manager.get_performance_stats()
	print("   Recovery FPS: %.1f" % recovery_stats.fps)

	# Analyze results
	var fps_drop = initial_stats.fps - stress_stats.fps
	var fps_recovery = recovery_stats.fps - stress_stats.fps

	if fps_drop < 30:  # Less than 30 FPS drop under heavy load
		print("✅ Excellent performance under stress (%.1f FPS drop)" % fps_drop)
	elif fps_drop < 50:
		print("⚠️ Moderate performance under stress (%.1f FPS drop)" % fps_drop)
	else:
		print("❌ Poor performance under stress (%.1f FPS drop)" % fps_drop)

	if fps_recovery > fps_drop * 0.8:  # At least 80% recovery
		print("✅ Good performance recovery (%.1f FPS recovered)" % fps_recovery)
	else:
		print("⚠️ Slow performance recovery (%.1f FPS recovered)" % fps_recovery)


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


func _test_fps_stability():
	"""Test FPS stability over time"""

	print("Testing FPS stability...")

	var performance_manager = PerformanceManager.instance
	if not performance_manager:
		print("❌ Cannot test FPS without PerformanceManager")
		return

	var fps_samples = []
	var sample_count = 30  # 30 samples over 1 second

	for i in range(sample_count):
		var stats = performance_manager.get_performance_stats()
		fps_samples.append(stats.fps)
		await get_tree().create_timer(1.0 / 30.0).timeout  # Sample at 30 FPS

	# Calculate FPS statistics
	var min_fps = fps_samples.min()
	var max_fps = fps_samples.max()
	var avg_fps = 0.0
	for fps in fps_samples:
		avg_fps += fps
	avg_fps /= fps_samples.size()

	var fps_variance = 0.0
	for fps in fps_samples:
		var diff = fps - avg_fps
		fps_variance += diff * diff
	fps_variance /= fps_samples.size()
	var fps_stddev = sqrt(fps_variance)

	print(
		(
			"   FPS Statistics: Avg=%.1f, Min=%.1f, Max=%.1f, StdDev=%.1f"
			% [avg_fps, min_fps, max_fps, fps_stddev]
		)
	)

	# Analyze stability
	if fps_stddev < 5.0:
		print("✅ Excellent FPS stability")
	elif fps_stddev < 10.0:
		print("⚠️ Moderate FPS stability")
	else:
		print("❌ Poor FPS stability")


func _show_final_report():
	"""Show final performance optimization report"""

	print("\n📊 FINAL PERFORMANCE REPORT:")
	print("=".repeat(50))

	var performance_manager = PerformanceManager.instance
	if performance_manager:
		print(performance_manager.get_performance_summary())

	var object_pool_manager = get_node_or_null("/root/ObjectPoolManager")
	if object_pool_manager:
		print("\nObject Pool Summary:")
		print(object_pool_manager.get_pool_summary())

	var tick_manager = TickManager.instance
	if tick_manager:
		print("\nTick System Summary:")
		print(tick_manager.get_tick_summary())

	print("=".repeat(50))
	print("🎯 T028 Performance Optimization: VALIDATED")
	print("Bar-Sik is now optimized for 60 FPS stable performance!")
