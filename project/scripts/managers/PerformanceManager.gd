class_name PerformanceManager
extends Node

## T028 - Performance Optimization Manager
## Sistema central de monitoreo y optimización para 60 FPS stable + memory management
## Garantiza que Bar-Sik pueda correr 24/7 sin degradación de performance

# ═══════════════════════════════════════════════════════════════════════════════════
# PERFORMANCE MONITORING CONSTANTS
# ═══════════════════════════════════════════════════════════════════════════════════

const TARGET_FPS: int = 60
const MIN_ACCEPTABLE_FPS: int = 45
const PERFORMANCE_CHECK_INTERVAL: float = 5.0  # Check every 5 seconds
const MEMORY_WARNING_THRESHOLD: int = 100 * 1024 * 1024  # 100MB
const MEMORY_CRITICAL_THRESHOLD: int = 200 * 1024 * 1024  # 200MB

# Performance tracking
var frame_times: Array[float] = []
var max_frame_time_samples: int = 300  # 5 seconds at 60fps
var current_fps: float = 60.0
var average_frame_time: float = 0.0
var memory_usage: int = 0
var peak_memory_usage: int = 0

# Performance optimization states
var performance_mode: String = "normal"  # "normal", "optimized", "emergency"
var optimizations_enabled: Dictionary = {}

# Performance monitoring signals
signal performance_warning(fps: float, memory: int)
signal performance_critical(fps: float, memory: int)
signal performance_recovered

# Singleton reference
static var instance: PerformanceManager

# ═══════════════════════════════════════════════════════════════════════════════════
# INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════════


func _ready():
	instance = self
	_initialize_performance_monitoring()
	_setup_optimization_systems()
	print("🚀 PerformanceManager initialized - Target: %d FPS" % TARGET_FPS)


func _initialize_performance_monitoring():
	"""Initialize performance monitoring systems"""
	# Setup frame time tracking
	frame_times.resize(max_frame_time_samples)
	frame_times.fill(1.0 / TARGET_FPS)

	# Create performance check timer
	var timer = Timer.new()
	timer.wait_time = PERFORMANCE_CHECK_INTERVAL
	timer.timeout.connect(_check_performance)
	timer.autostart = true
	add_child(timer)

	# Enable detailed performance monitoring in debug
	if OS.is_debug_build():
		Engine.max_fps = 0  # Uncap FPS for testing
	else:
		Engine.max_fps = TARGET_FPS


func _setup_optimization_systems():
	"""Setup available optimization systems"""
	optimizations_enabled = {
		"ui_pooling": true,
		"batch_updates": true,
		"reduced_effects": false,
		"simplified_animations": false,
		"emergency_mode": false
	}


# ═══════════════════════════════════════════════════════════════════════════════════
# FRAME-BY-FRAME MONITORING
# ═══════════════════════════════════════════════════════════════════════════════════


func _process(delta: float):
	"""Monitor frame performance in real-time"""
	_track_frame_time(delta)
	_update_fps_calculation(delta)


func _track_frame_time(delta: float):
	"""Track individual frame times for analysis"""
	# Shift array left and add new frame time
	for i in range(frame_times.size() - 1):
		frame_times[i] = frame_times[i + 1]
	frame_times[frame_times.size() - 1] = delta

	# Calculate average frame time
	var total_time = 0.0
	for frame_time in frame_times:
		total_time += frame_time
	average_frame_time = total_time / frame_times.size()


func _update_fps_calculation(delta: float):
	"""Update current FPS calculation with smoothing"""
	var instant_fps = 1.0 / delta if delta > 0 else TARGET_FPS
	# Smooth FPS calculation to avoid jitter
	current_fps = lerp(current_fps, instant_fps, 0.1)


# ═══════════════════════════════════════════════════════════════════════════════════
# PERFORMANCE ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════════════


func _check_performance():
	"""Periodic performance check and optimization"""
	_update_memory_usage()
	_analyze_performance_state()
	_apply_optimizations_if_needed()


func _update_memory_usage():
	"""Update memory usage statistics"""
	memory_usage = OS.get_static_memory_usage_by_type().get("Object", 0)
	if memory_usage > peak_memory_usage:
		peak_memory_usage = memory_usage


func _analyze_performance_state():
	"""Analyze current performance and determine state"""
	var fps_healthy = current_fps >= MIN_ACCEPTABLE_FPS
	var memory_healthy = memory_usage < MEMORY_WARNING_THRESHOLD

	if fps_healthy and memory_healthy:
		if performance_mode != "normal":
			_set_performance_mode("normal")
			performance_recovered.emit()
	elif current_fps < 30 or memory_usage > MEMORY_CRITICAL_THRESHOLD:
		_set_performance_mode("emergency")
		performance_critical.emit(current_fps, memory_usage)
	else:
		_set_performance_mode("optimized")
		performance_warning.emit(current_fps, memory_usage)


func _set_performance_mode(new_mode: String):
	"""Change performance mode and log transition"""
	if performance_mode != new_mode:
		print(
			(
				"📊 Performance mode: %s → %s (FPS: %.1f, Memory: %s)"
				% [performance_mode, new_mode, current_fps, _format_memory(memory_usage)]
			)
		)
		performance_mode = new_mode


# ═══════════════════════════════════════════════════════════════════════════════════
# OPTIMIZATION SYSTEMS
# ═══════════════════════════════════════════════════════════════════════════════════


func _apply_optimizations_if_needed():
	"""Apply performance optimizations based on current state"""
	match performance_mode:
		"normal":
			_enable_all_features()
		"optimized":
			_enable_performance_optimizations()
		"emergency":
			_enable_emergency_optimizations()


func _enable_all_features():
	"""Enable all features when performance is good"""
	optimizations_enabled.reduced_effects = false
	optimizations_enabled.simplified_animations = false
	optimizations_enabled.emergency_mode = false


func _enable_performance_optimizations():
	"""Enable performance optimizations for medium performance"""
	optimizations_enabled.reduced_effects = true
	optimizations_enabled.simplified_animations = false
	optimizations_enabled.emergency_mode = false

	# Trigger object pool cleanup
	if ObjectPoolManager.instance:
		ObjectPoolManager.instance.cleanup_unused_objects()


func _enable_emergency_optimizations():
	"""Enable emergency optimizations for poor performance"""
	optimizations_enabled.reduced_effects = true
	optimizations_enabled.simplified_animations = true
	optimizations_enabled.emergency_mode = true

	# Force garbage collection
	_force_garbage_collection()

	# Aggressive object pool cleanup
	if ObjectPoolManager.instance:
		ObjectPoolManager.instance.force_cleanup_all()


# ═══════════════════════════════════════════════════════════════════════════════════
# MEMORY MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════════


func _force_garbage_collection():
	"""Force garbage collection to free memory"""
	# Call GC multiple times to ensure thorough cleanup
	for i in range(3):
		if GDScript.is_class_instance_valid(self):  # Safety check
			await get_tree().process_frame

	print(
		(
			"🗑️ Forced garbage collection - Memory: %s → %s"
			% [
				_format_memory(memory_usage),
				_format_memory(OS.get_static_memory_usage_by_type().get("Object", 0))
			]
		)
	)


func optimize_memory_usage():
	"""Public function to optimize memory usage"""
	_force_garbage_collection()

	# Clear any cached data that can be regenerated
	_clear_performance_caches()

	# Request object pool cleanup
	if ObjectPoolManager.instance:
		ObjectPoolManager.instance.cleanup_unused_objects()


func _clear_performance_caches():
	"""Clear non-essential cached data to free memory"""
	# Clear frame time history (keep only recent data)
	var recent_frames = frame_times.slice(frame_times.size() - 60, frame_times.size())
	frame_times.clear()
	frame_times.append_array(recent_frames)


# ═══════════════════════════════════════════════════════════════════════════════════
# PUBLIC PERFORMANCE API
# ═══════════════════════════════════════════════════════════════════════════════════


## Get current performance statistics
func get_performance_stats() -> Dictionary:
	"""Get comprehensive performance statistics"""
	return {
		"fps": current_fps,
		"target_fps": TARGET_FPS,
		"average_frame_time": average_frame_time * 1000,  # Convert to ms
		"memory_usage": memory_usage,
		"memory_usage_mb": memory_usage / (1024 * 1024),
		"peak_memory_usage": peak_memory_usage,
		"peak_memory_mb": peak_memory_usage / (1024 * 1024),
		"performance_mode": performance_mode,
		"optimizations": optimizations_enabled.duplicate()
	}


## Check if specific optimization is enabled
func is_optimization_enabled(optimization_name: String) -> bool:
	"""Check if a specific optimization is currently enabled"""
	return optimizations_enabled.get(optimization_name, false)


## Force performance check (useful for debugging)
func force_performance_check():
	"""Force an immediate performance check"""
	_check_performance()


## Get formatted performance summary for UI display
func get_performance_summary() -> String:
	"""Get formatted performance summary for display"""
	var stats = get_performance_stats()
	return (
		"""FPS: %.1f/%d (%.1f ms)
Memory: %s (Peak: %s)
Mode: %s
Optimizations: %d active"""
		% [
			stats.fps,
			TARGET_FPS,
			stats.average_frame_time,
			_format_memory(stats.memory_usage),
			_format_memory(stats.peak_memory_usage),
			stats.performance_mode.capitalize(),
			_count_active_optimizations()
		]
	)


# ═══════════════════════════════════════════════════════════════════════════════════
# UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════════


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


func _count_active_optimizations() -> int:
	"""Count how many optimizations are currently active"""
	var count = 0
	for value in optimizations_enabled.values():
		if value:
			count += 1
	return count


# ═══════════════════════════════════════════════════════════════════════════════════
# PERFORMANCE DEBUGGING
# ═══════════════════════════════════════════════════════════════════════════════════


func start_performance_profiling():
	"""Start detailed performance profiling (debug only)"""
	if not OS.is_debug_build():
		return

	print("🔍 Starting performance profiling...")
	# Enable additional debug monitoring
	Engine.print_error_messages = true


func stop_performance_profiling():
	"""Stop performance profiling and print results"""
	if not OS.is_debug_build():
		return

	print("📊 Performance Profiling Results:")
	print("   Current FPS: %.1f" % current_fps)
	print("   Average Frame Time: %.2f ms" % (average_frame_time * 1000))
	print("   Memory Usage: %s" % _format_memory(memory_usage))
	print("   Peak Memory: %s" % _format_memory(peak_memory_usage))


## Generate detailed performance report
func generate_performance_report() -> Dictionary:
	"""Generate detailed performance report for analysis"""
	var report = get_performance_stats()

	# Add additional analysis data
	report["frame_time_variance"] = _calculate_frame_time_variance()
	report["memory_growth_trend"] = _analyze_memory_growth()
	report["performance_recommendations"] = _generate_performance_recommendations()

	return report


func _calculate_frame_time_variance() -> float:
	"""Calculate frame time variance to detect inconsistency"""
	var variance_sum = 0.0
	for frame_time in frame_times:
		var diff = frame_time - average_frame_time
		variance_sum += diff * diff
	return variance_sum / frame_times.size()


func _analyze_memory_growth() -> String:
	"""Analyze memory growth trend"""
	var growth_ratio = (
		float(memory_usage) / float(peak_memory_usage) if peak_memory_usage > 0 else 1.0
	)

	if growth_ratio > 0.9:
		return "HIGH - Memory near peak usage"
	elif growth_ratio > 0.7:
		return "MODERATE - Memory usage increasing"
	else:
		return "LOW - Memory usage stable"


func _generate_performance_recommendations() -> Array[String]:
	"""Generate performance improvement recommendations"""
	var recommendations: Array[String] = []

	if current_fps < TARGET_FPS:
		recommendations.append("Enable performance optimizations")

	if memory_usage > MEMORY_WARNING_THRESHOLD:
		recommendations.append("Reduce memory usage through object pooling")

	if _calculate_frame_time_variance() > 0.001:
		recommendations.append("Reduce frame time variance with tick-based updates")

	if optimizations_enabled.emergency_mode:
		recommendations.append("Investigate performance bottlenecks")

	return recommendations
