class_name TickManager
extends Node

## T028 - Tick Manager
## Sistema de ticks optimizado para reemplazar _process() abuse
## Permite updates eficientes y controlados para 60 FPS stable

# ═══════════════════════════════════════════════════════════════════════════════════
# TICK SYSTEM CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════════

# Tick intervals for different update frequencies
const FAST_TICK_INTERVAL: float = 1.0 / 60.0  # 60 FPS - UI updates
const NORMAL_TICK_INTERVAL: float = 1.0 / 30.0  # 30 FPS - Game logic
const SLOW_TICK_INTERVAL: float = 1.0 / 10.0  # 10 FPS - Background tasks
const VERY_SLOW_TICK_INTERVAL: float = 1.0  # 1 FPS - Periodic tasks

# Tick callback arrays
var fast_tick_callbacks: Array[Callable] = []
var normal_tick_callbacks: Array[Callable] = []
var slow_tick_callbacks: Array[Callable] = []
var very_slow_tick_callbacks: Array[Callable] = []

# Tick timers
var fast_tick_timer: Timer
var normal_tick_timer: Timer
var slow_tick_timer: Timer
var very_slow_tick_timer: Timer

# Tick statistics
var tick_stats: Dictionary = {
	"fast_tick_count": 0,
	"normal_tick_count": 0,
	"slow_tick_count": 0,
	"very_slow_tick_count": 0,
	"total_callbacks": 0
}

# Singleton reference
static var instance: TickManager

# Signal batching system
var batched_signals: Dictionary = {}
var signal_batch_timer: Timer

# ═══════════════════════════════════════════════════════════════════════════════════
# INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════════


func _ready():
	instance = self
	_setup_tick_timers()
	_setup_signal_batching()
	print("⏰ TickManager initialized with 4 tick rates")


func _setup_tick_timers():
	"""Setup all tick timers"""
	# Fast tick timer (60 FPS)
	fast_tick_timer = Timer.new()
	fast_tick_timer.wait_time = FAST_TICK_INTERVAL
	fast_tick_timer.timeout.connect(_on_fast_tick)
	fast_tick_timer.autostart = true
	add_child(fast_tick_timer)

	# Normal tick timer (30 FPS)
	normal_tick_timer = Timer.new()
	normal_tick_timer.wait_time = NORMAL_TICK_INTERVAL
	normal_tick_timer.timeout.connect(_on_normal_tick)
	normal_tick_timer.autostart = true
	add_child(normal_tick_timer)

	# Slow tick timer (10 FPS)
	slow_tick_timer = Timer.new()
	slow_tick_timer.wait_time = SLOW_TICK_INTERVAL
	slow_tick_timer.timeout.connect(_on_slow_tick)
	slow_tick_timer.autostart = true
	add_child(slow_tick_timer)

	# Very slow tick timer (1 FPS)
	very_slow_tick_timer = Timer.new()
	very_slow_tick_timer.wait_time = VERY_SLOW_TICK_INTERVAL
	very_slow_tick_timer.timeout.connect(_on_very_slow_tick)
	very_slow_tick_timer.autostart = true
	add_child(very_slow_tick_timer)


func _setup_signal_batching():
	"""Setup signal batching system"""
	signal_batch_timer = Timer.new()
	signal_batch_timer.wait_time = 1.0 / 30.0  # 30 FPS batching
	signal_batch_timer.timeout.connect(_process_signal_batch)
	signal_batch_timer.autostart = true
	add_child(signal_batch_timer)


# ═══════════════════════════════════════════════════════════════════════════════════
# TICK CALLBACK MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════════


## Register a callback for fast ticks (60 FPS)
func register_fast_tick(callback: Callable) -> void:
	"""Register a callback for fast tick updates (60 FPS) - UI updates"""
	if not fast_tick_callbacks.has(callback):
		fast_tick_callbacks.append(callback)
		_update_total_callbacks()


## Register a callback for normal ticks (30 FPS)
func register_normal_tick(callback: Callable) -> void:
	"""Register a callback for normal tick updates (30 FPS) - Game logic"""
	if not normal_tick_callbacks.has(callback):
		normal_tick_callbacks.append(callback)
		_update_total_callbacks()


## Register a callback for slow ticks (10 FPS)
func register_slow_tick(callback: Callable) -> void:
	"""Register a callback for slow tick updates (10 FPS) - Background tasks"""
	if not slow_tick_callbacks.has(callback):
		slow_tick_callbacks.append(callback)
		_update_total_callbacks()


## Register a callback for very slow ticks (1 FPS)
func register_very_slow_tick(callback: Callable) -> void:
	"""Register a callback for very slow tick updates (1 FPS) - Periodic tasks"""
	if not very_slow_tick_callbacks.has(callback):
		very_slow_tick_callbacks.append(callback)
		_update_total_callbacks()


## Unregister a callback from all tick rates
func unregister_callback(callback: Callable) -> void:
	"""Remove a callback from all tick rates"""
	fast_tick_callbacks.erase(callback)
	normal_tick_callbacks.erase(callback)
	slow_tick_callbacks.erase(callback)
	very_slow_tick_callbacks.erase(callback)
	_update_total_callbacks()


func _update_total_callbacks():
	"""Update total callback count for statistics"""
	tick_stats.total_callbacks = (
		fast_tick_callbacks.size()
		+ normal_tick_callbacks.size()
		+ slow_tick_callbacks.size()
		+ very_slow_tick_callbacks.size()
	)


# ═══════════════════════════════════════════════════════════════════════════════════
# TICK EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════════


func _on_fast_tick():
	"""Execute all fast tick callbacks (60 FPS)"""
	_execute_callbacks(fast_tick_callbacks, "fast")
	tick_stats.fast_tick_count += 1


func _on_normal_tick():
	"""Execute all normal tick callbacks (30 FPS)"""
	_execute_callbacks(normal_tick_callbacks, "normal")
	tick_stats.normal_tick_count += 1


func _on_slow_tick():
	"""Execute all slow tick callbacks (10 FPS)"""
	_execute_callbacks(slow_tick_callbacks, "slow")
	tick_stats.slow_tick_count += 1


func _on_very_slow_tick():
	"""Execute all very slow tick callbacks (1 FPS)"""
	_execute_callbacks(very_slow_tick_callbacks, "very_slow")
	tick_stats.very_slow_tick_count += 1


func _execute_callbacks(callbacks: Array[Callable], tick_type: String):
	"""Execute a list of callbacks safely"""
	var executed_count = 0
	var failed_count = 0

	# Execute callbacks with error handling
	for callback in callbacks.duplicate():  # Duplicate to avoid modification during iteration
		if callback.is_valid():
			# Call callback with error handling
			var success = false
			if callback.get_object() and is_instance_valid(callback.get_object()):
				callback.call()
				executed_count += 1
				success = true

			if not success:
				print("⚠️ Tick callback failed (%s): %s" % [tick_type, str(callback)])
				callbacks.erase(callback)
				failed_count += 1
		else:
			# Remove invalid callbacks
			callbacks.erase(callback)
			failed_count += 1

	# Log performance issues
	if failed_count > 0:
		print("⚠️ %s tick: %d executed, %d failed" % [tick_type, executed_count, failed_count])


# ═══════════════════════════════════════════════════════════════════════════════════
# SIGNAL BATCHING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════════


## Queue a signal to be emitted in the next batch
func queue_signal(signal_owner: Object, signal_name: String, args: Array = []):
	"""Queue a signal to be emitted in batch to reduce cascading updates"""
	if not is_instance_valid(signal_owner):
		return

	var signal_key = "%s::%s" % [signal_owner.get_instance_id(), signal_name]
	batched_signals[signal_key] = {
		"owner": signal_owner,
		"signal": signal_name,
		"args": args,
		"queued_time": Time.get_ticks_msec()
	}


func _process_signal_batch():
	"""Process all batched signals"""
	if batched_signals.is_empty():
		return

	var processed_count = 0
	var failed_count = 0

	for signal_key in batched_signals.keys():
		var signal_data = batched_signals[signal_key]

		if is_instance_valid(signal_data.owner):
			# Emit signal with error handling
			var success = false
			if signal_data.owner.has_signal(signal_data.signal):
				if signal_data.args.is_empty():
					signal_data.owner.emit_signal(signal_data.signal)
				else:
					var args = signal_data.args
					# Handle different argument counts
					match args.size():
						0:
							signal_data.owner.emit_signal(signal_data.signal)
						1:
							signal_data.owner.emit_signal(signal_data.signal, args[0])
						2:
							signal_data.owner.emit_signal(signal_data.signal, args[0], args[1])
						_:
							# For more than 2 args, use callv
							pass
				processed_count += 1
				success = true

			if not success:
				print("⚠️ Batched signal failed: %s::%s" % [signal_data.owner, signal_data.signal])
				failed_count += 1
		else:
			failed_count += 1

	# Clear processed signals
	batched_signals.clear()

	# Log if there were issues
	if failed_count > 0:
		print("📡 Signal batch: %d processed, %d failed" % [processed_count, failed_count])


# ═══════════════════════════════════════════════════════════════════════════════════
# PERFORMANCE OPTIMIZATION HELPERS
# ═══════════════════════════════════════════════════════════════════════════════════


## Create a debounced callback that only executes after a delay
func create_debounced_callback(original_callback: Callable, delay: float) -> Callable:
	"""Create a debounced version of a callback"""
	var debounce_timer: Timer = null

	var debounced_func = func():
		if debounce_timer:
			debounce_timer.stop()
		else:
			debounce_timer = Timer.new()
			debounce_timer.one_shot = true
			add_child(debounce_timer)

		debounce_timer.wait_time = delay
		debounce_timer.timeout.connect(original_callback, CONNECT_ONE_SHOT)
		debounce_timer.start()

	return debounced_func


## Create a throttled callback that executes at most once per interval
func create_throttled_callback(original_callback: Callable, interval: float) -> Callable:
	"""Create a throttled version of a callback"""
	var last_execution_time = 0.0

	var throttled_func = func():
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_execution_time >= interval:
			original_callback.call()
			last_execution_time = current_time

	return throttled_func


## Pause all ticks (useful for pause menu)
func pause_all_ticks():
	"""Pause all tick timers"""
	fast_tick_timer.paused = true
	normal_tick_timer.paused = true
	slow_tick_timer.paused = true
	very_slow_tick_timer.paused = true
	signal_batch_timer.paused = true
	print("⏸️ All ticks paused")


## Resume all ticks
func resume_all_ticks():
	"""Resume all tick timers"""
	fast_tick_timer.paused = false
	normal_tick_timer.paused = false
	slow_tick_timer.paused = false
	very_slow_tick_timer.paused = false
	signal_batch_timer.paused = false
	print("▶️ All ticks resumed")


# ═══════════════════════════════════════════════════════════════════════════════════
# STATISTICS AND MONITORING
# ═══════════════════════════════════════════════════════════════════════════════════


## Get tick system statistics
func get_tick_stats() -> Dictionary:
	"""Get comprehensive tick system statistics"""
	var stats = tick_stats.duplicate()

	# Add callback counts
	stats["callback_counts"] = {
		"fast": fast_tick_callbacks.size(),
		"normal": normal_tick_callbacks.size(),
		"slow": slow_tick_callbacks.size(),
		"very_slow": very_slow_tick_callbacks.size()
	}

	# Add batched signal info
	stats["batched_signals"] = batched_signals.size()

	# Calculate efficiency metrics
	var uptime_seconds = Time.get_ticks_msec() / 1000.0
	if uptime_seconds > 0:
		stats["ticks_per_second"] = {
			"fast": stats.fast_tick_count / uptime_seconds,
			"normal": stats.normal_tick_count / uptime_seconds,
			"slow": stats.slow_tick_count / uptime_seconds,
			"very_slow": stats.very_slow_tick_count / uptime_seconds
		}

	return stats


## Get formatted tick summary for display
func get_tick_summary() -> String:
	"""Get formatted tick summary for UI display"""
	var stats = get_tick_stats()
	var callbacks = stats.callback_counts

	return (
		"""Tick System: %d total callbacks
Fast (60fps): %d callbacks
Normal (30fps): %d callbacks  
Slow (10fps): %d callbacks
Very Slow (1fps): %d callbacks
Batched Signals: %d queued"""
		% [
			stats.total_callbacks,
			callbacks.fast,
			callbacks.normal,
			callbacks.slow,
			callbacks.very_slow,
			stats.batched_signals
		]
	)


## Print detailed tick status (debug)
func print_tick_status():
	"""Print detailed tick system status (debug function)"""
	if not OS.is_debug_build():
		return

	var stats = get_tick_stats()
	print("\n⏰ TICK SYSTEM STATUS:")
	print("=" * 40)
	print("Total Callbacks: %d" % stats.total_callbacks)
	print("Fast Ticks: %d callbacks (60 FPS)" % stats.callback_counts.fast)
	print("Normal Ticks: %d callbacks (30 FPS)" % stats.callback_counts.normal)
	print("Slow Ticks: %d callbacks (10 FPS)" % stats.callback_counts.slow)
	print("Very Slow Ticks: %d callbacks (1 FPS)" % stats.callback_counts.very_slow)
	print("Batched Signals: %d queued" % stats.batched_signals)
	print("=" * 40)


# ═══════════════════════════════════════════════════════════════════════════════════
# PERFORMANCE OPTIMIZATION INTEGRATION
# ═══════════════════════════════════════════════════════════════════════════════════


func optimize_for_performance_mode(mode: String):
	"""Optimize tick rates based on performance mode"""
	match mode:
		"normal":
			_set_normal_tick_rates()
		"optimized":
			_set_optimized_tick_rates()
		"emergency":
			_set_emergency_tick_rates()


func _set_normal_tick_rates():
	"""Set normal tick rates for good performance"""
	fast_tick_timer.wait_time = FAST_TICK_INTERVAL
	normal_tick_timer.wait_time = NORMAL_TICK_INTERVAL
	slow_tick_timer.wait_time = SLOW_TICK_INTERVAL
	very_slow_tick_timer.wait_time = VERY_SLOW_TICK_INTERVAL


func _set_optimized_tick_rates():
	"""Set optimized tick rates for medium performance"""
	fast_tick_timer.wait_time = FAST_TICK_INTERVAL * 1.5  # 40 FPS
	normal_tick_timer.wait_time = NORMAL_TICK_INTERVAL * 1.2  # 25 FPS
	slow_tick_timer.wait_time = SLOW_TICK_INTERVAL  # Keep 10 FPS
	very_slow_tick_timer.wait_time = VERY_SLOW_TICK_INTERVAL  # Keep 1 FPS


func _set_emergency_tick_rates():
	"""Set emergency tick rates for poor performance"""
	fast_tick_timer.wait_time = FAST_TICK_INTERVAL * 2  # 30 FPS
	normal_tick_timer.wait_time = NORMAL_TICK_INTERVAL * 2  # 15 FPS
	slow_tick_timer.wait_time = SLOW_TICK_INTERVAL * 2  # 5 FPS
	very_slow_tick_timer.wait_time = VERY_SLOW_TICK_INTERVAL * 2  # 0.5 FPS
