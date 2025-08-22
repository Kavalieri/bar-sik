class_name ObjectPoolManager
extends Node

## T028 - Object Pool Manager
## Sistema de pooling para reutilizar objetos UI y evitar garbage collection
## Crítico para mantener 60 FPS en idle games que corren 24/7

# ═══════════════════════════════════════════════════════════════════════════════════
# OBJECT POOL CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════════

# Pool sizes for different object types
const DEFAULT_POOL_SIZE: int = 20
const UI_ELEMENT_POOL_SIZE: int = 50  # UI elements created/destroyed frequently
const POPUP_POOL_SIZE: int = 10
const PARTICLE_POOL_SIZE: int = 30

# Pool cleanup thresholds
const MAX_UNUSED_TIME: float = 30.0  # Seconds before object is eligible for cleanup
const CLEANUP_CHECK_INTERVAL: float = 10.0  # Check cleanup every 10 seconds

# Object pools dictionary - stores pools by object type
var object_pools: Dictionary = {}
var pool_stats: Dictionary = {}  # Statistics for monitoring

# Singleton reference
static var instance: ObjectPoolManager

# ═══════════════════════════════════════════════════════════════════════════════════
# INITIALIZATION
# ═══════════════════════════════════════════════════════════════════════════════════


func _ready():
	instance = self
	_initialize_default_pools()
	_setup_cleanup_timer()
	print("🏊 ObjectPoolManager initialized with %d pools" % object_pools.size())


func _initialize_default_pools():
	"""Initialize default object pools for common UI elements"""
	# Create pools for common UI elements
	create_pool("Label", UI_ELEMENT_POOL_SIZE)
	create_pool("Button", UI_ELEMENT_POOL_SIZE)
	create_pool("Panel", UI_ELEMENT_POOL_SIZE)
	create_pool("VBoxContainer", UI_ELEMENT_POOL_SIZE)
	create_pool("HBoxContainer", UI_ELEMENT_POOL_SIZE)
	create_pool("TextureRect", UI_ELEMENT_POOL_SIZE)

	# Create pools for game-specific elements
	create_pool("PopupDialog", POPUP_POOL_SIZE)
	create_pool("NotificationPopup", POPUP_POOL_SIZE)
	create_pool("ProgressBar", DEFAULT_POOL_SIZE)
	create_pool("AnimationPlayer", DEFAULT_POOL_SIZE)


func _setup_cleanup_timer():
	"""Setup automatic cleanup timer"""
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = CLEANUP_CHECK_INTERVAL
	cleanup_timer.timeout.connect(_periodic_cleanup)
	cleanup_timer.autostart = true
	add_child(cleanup_timer)


# ═══════════════════════════════════════════════════════════════════════════════════
# POOL MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════════


## Create a new object pool for a specific type
func create_pool(object_type: String, initial_size: int = DEFAULT_POOL_SIZE) -> void:
	"""Create a new object pool for the specified type"""
	if object_pools.has(object_type):
		print("⚠️ Pool for %s already exists" % object_type)
		return

	object_pools[object_type] = {
		"available": [],  # Available objects ready for use
		"in_use": [],  # Objects currently in use
		"max_size": initial_size * 2,  # Maximum pool size
		"created_count": 0,  # Total objects ever created
		"reuse_count": 0  # Total reuses
	}

	pool_stats[object_type] = {"hits": 0, "misses": 0, "cleanups": 0, "peak_usage": 0}  # Pool hits (reused object)  # Pool misses (had to create new)  # Objects cleaned up  # Peak concurrent usage

	# Pre-populate pool with initial objects
	_populate_pool(object_type, initial_size)


func _populate_pool(object_type: String, count: int) -> void:
	"""Pre-populate pool with objects"""
	var pool = object_pools.get(object_type)
	if not pool:
		return

	for i in range(count):
		var obj = _create_object_instance(object_type)
		if obj:
			_setup_pooled_object(obj)
			pool.available.append(
				{"object": obj, "last_used": Time.get_ticks_msec() / 1000.0, "use_count": 0}
			)
			pool.created_count += 1


func _create_object_instance(object_type: String) -> Node:
	"""Create a new instance of the specified object type"""
	match object_type:
		"Label":
			return Label.new()
		"Button":
			return Button.new()
		"Panel":
			return Panel.new()
		"VBoxContainer":
			return VBoxContainer.new()
		"HBoxContainer":
			return HBoxContainer.new()
		"TextureRect":
			return TextureRect.new()
		"PopupDialog":
			return AcceptDialog.new()
		"NotificationPopup":
			return AcceptDialog.new()
		"ProgressBar":
			return ProgressBar.new()
		"AnimationPlayer":
			return AnimationPlayer.new()
		_:
			print("⚠️ Unknown object type: %s" % object_type)
			return null


func _setup_pooled_object(obj: Node) -> void:
	"""Setup object for pooling (hide, disconnect signals, etc.)"""
	if obj is CanvasItem:
		obj.visible = false

	# Clear any existing connections (safety)
	if obj.get_signal_list():
		for signal_info in obj.get_signal_list():
			var signal_name = signal_info.name
			if obj.is_connected(signal_name, Callable()):
				pass  # Would need specific cleanup per object type


# ═══════════════════════════════════════════════════════════════════════════════════
# OBJECT ACQUISITION AND RELEASE
# ═══════════════════════════════════════════════════════════════════════════════════


## Get an object from the pool
func get_object(object_type: String, parent: Node = null) -> Node:
	"""Get an object from the pool, creating one if pool is empty"""
	var pool = object_pools.get(object_type)
	if not pool:
		# No pool exists, create object directly
		pool_stats[object_type] = {"hits": 0, "misses": 1, "cleanups": 0, "peak_usage": 0}
		var obj = _create_object_instance(object_type)
		if obj and parent:
			parent.add_child(obj)
		return obj

	var stats = pool_stats[object_type]
	var obj: Node = null

	# Try to get from available pool
	if pool.available.size() > 0:
		var pool_entry = pool.available.pop_back()
		obj = pool_entry.object
		pool_entry.last_used = Time.get_ticks_msec() / 1000.0
		pool_entry.use_count += 1
		pool.in_use.append(pool_entry)
		pool.reuse_count += 1
		stats.hits += 1

		# Reset object state
		_reset_object_state(obj)

	else:
		# Pool is empty, create new object
		obj = _create_object_instance(object_type)
		if obj:
			_setup_pooled_object(obj)
			var pool_entry = {
				"object": obj, "last_used": Time.get_ticks_msec() / 1000.0, "use_count": 1
			}
			pool.in_use.append(pool_entry)
			pool.created_count += 1
		stats.misses += 1

	# Update peak usage stats
	if pool.in_use.size() > stats.peak_usage:
		stats.peak_usage = pool.in_use.size()

	# Add to parent if specified
	if obj and parent:
		parent.add_child(obj)
		if obj is CanvasItem:
			obj.visible = true

	return obj


## Return an object to the pool
func return_object(obj: Node, object_type: String = "") -> void:
	"""Return an object to its pool for reuse"""
	if not is_instance_valid(obj):
		return

	# Try to determine object type if not specified
	if object_type == "":
		object_type = _determine_object_type(obj)

	var pool = object_pools.get(object_type)
	if not pool:
		# No pool exists, just free the object
		_safe_free_object(obj)
		return

	# Find object in in_use list
	var found_index = -1
	for i in range(pool.in_use.size()):
		if pool.in_use[i].object == obj:
			found_index = i
			break

	if found_index >= 0:
		var pool_entry = pool.in_use[found_index]
		pool.in_use.remove_at(found_index)

		# Reset object state and add to available pool
		_reset_object_state(obj)
		_prepare_for_pooling(obj)

		# Check pool size limits
		if pool.available.size() < pool.max_size:
			pool.available.append(pool_entry)
		else:
			# Pool is full, free the object
			_safe_free_object(obj)
			pool_stats[object_type].cleanups += 1
	else:
		# Object not found in pool, free it
		_safe_free_object(obj)


func _determine_object_type(obj: Node) -> String:
	"""Try to determine object type from the node"""
	var class_name = obj.get_class()

	# Map Godot class names to our pool names
	match class_name:
		"Label":
			return "Label"
		"Button", "CheckBox", "OptionButton":
			return "Button"
		"Panel":
			return "Panel"
		"VBoxContainer":
			return "VBoxContainer"
		"HBoxContainer":
			return "HBoxContainer"
		"TextureRect":
			return "TextureRect"
		"AcceptDialog", "ConfirmationDialog":
			return "PopupDialog"
		"ProgressBar":
			return "ProgressBar"
		"AnimationPlayer":
			return "AnimationPlayer"
		_:
			return class_name


func _reset_object_state(obj: Node) -> void:
	"""Reset object to clean state for reuse"""
	if obj is Label:
		obj.text = ""
	elif obj is Button:
		obj.text = ""
		obj.disabled = false
	elif obj is ProgressBar:
		obj.value = 0
	elif obj is AcceptDialog:
		obj.title = ""
		obj.dialog_text = ""
	elif obj is CanvasItem:
		obj.modulate = Color.WHITE
		obj.visible = false


func _prepare_for_pooling(obj: Node) -> void:
	"""Prepare object for pooling (remove from parent, etc.)"""
	if obj.get_parent():
		obj.get_parent().remove_child(obj)

	if obj is CanvasItem:
		obj.visible = false


func _safe_free_object(obj: Node) -> void:
	"""Safely free an object with proper cleanup"""
	if is_instance_valid(obj):
		if obj.get_parent():
			obj.get_parent().remove_child(obj)
		obj.queue_free()


# ═══════════════════════════════════════════════════════════════════════════════════
# POOL CLEANUP AND MAINTENANCE
# ═══════════════════════════════════════════════════════════════════════════════════


func _periodic_cleanup():
	"""Periodic cleanup of unused objects"""
	var current_time = Time.get_ticks_msec() / 1000.0
	var total_cleaned = 0

	for object_type in object_pools.keys():
		total_cleaned += _cleanup_pool(object_type, current_time)

	if total_cleaned > 0:
		print("🧹 ObjectPool cleanup: %d objects freed" % total_cleaned)


func _cleanup_pool(object_type: String, current_time: float) -> int:
	"""Cleanup unused objects from a specific pool"""
	var pool = object_pools[object_type]
	var stats = pool_stats[object_type]
	var cleaned_count = 0

	# Clean up old objects from available pool
	var i = 0
	while i < pool.available.size():
		var pool_entry = pool.available[i]
		var time_unused = current_time - pool_entry.last_used

		if time_unused > MAX_UNUSED_TIME and pool.available.size() > 5:  # Keep minimum 5
			_safe_free_object(pool_entry.object)
			pool.available.remove_at(i)
			cleaned_count += 1
			stats.cleanups += 1
		else:
			i += 1

	return cleaned_count


## Force cleanup of all unused objects
func cleanup_unused_objects() -> void:
	"""Force cleanup of all unused objects across all pools"""
	var current_time = Time.get_ticks_msec() / 1000.0
	var total_cleaned = 0

	for object_type in object_pools.keys():
		total_cleaned += _cleanup_pool(object_type, current_time)

	print("🧹 Forced ObjectPool cleanup: %d objects freed" % total_cleaned)


## Force cleanup of all objects (emergency cleanup)
func force_cleanup_all() -> void:
	"""Emergency cleanup - free all available objects"""
	var total_freed = 0

	for object_type in object_pools.keys():
		var pool = object_pools[object_type]

		# Free all available objects
		for pool_entry in pool.available:
			_safe_free_object(pool_entry.object)
			total_freed += 1

		pool.available.clear()
		pool_stats[object_type].cleanups += total_freed

	print("🚨 Emergency ObjectPool cleanup: %d objects freed" % total_freed)


# ═══════════════════════════════════════════════════════════════════════════════════
# POOL STATISTICS AND MONITORING
# ═══════════════════════════════════════════════════════════════════════════════════


## Get pool statistics for monitoring
func get_pool_stats() -> Dictionary:
	"""Get comprehensive pool statistics"""
	var total_stats = {
		"pools": pool_stats.duplicate(true),
		"summary":
		{
			"total_pools": object_pools.size(),
			"total_objects": 0,
			"total_in_use": 0,
			"total_available": 0,
			"total_hits": 0,
			"total_misses": 0,
			"hit_rate": 0.0
		}
	}

	# Calculate summary statistics
	var summary = total_stats.summary
	for object_type in object_pools.keys():
		var pool = object_pools[object_type]
		var stats = pool_stats[object_type]

		summary.total_objects += pool.created_count
		summary.total_in_use += pool.in_use.size()
		summary.total_available += pool.available.size()
		summary.total_hits += stats.hits
		summary.total_misses += stats.misses

	# Calculate hit rate
	var total_requests = summary.total_hits + summary.total_misses
	if total_requests > 0:
		summary.hit_rate = float(summary.total_hits) / float(total_requests) * 100.0

	return total_stats


## Get formatted pool summary for display
func get_pool_summary() -> String:
	"""Get formatted pool summary for UI display"""
	var stats = get_pool_stats()
	var summary = stats.summary

	return (
		"""Object Pools: %d active
Objects: %d total (%d in use, %d available)
Hit Rate: %.1f%% (%d hits, %d misses)
Memory Efficiency: %s"""
		% [
			summary.total_pools,
			summary.total_objects,
			summary.total_in_use,
			summary.total_available,
			summary.hit_rate,
			summary.total_hits,
			summary.total_misses,
			(
				"EXCELLENT"
				if summary.hit_rate > 80
				else ("GOOD" if summary.hit_rate > 60 else "NEEDS_IMPROVEMENT")
			)
		]
	)


## Print detailed pool status (debug)
func print_pool_status():
	"""Print detailed status of all pools (debug function)"""
	if not OS.is_debug_build():
		return

	print("\n🏊 OBJECT POOL STATUS:")
	print("=" * 50)

	for object_type in object_pools.keys():
		var pool = object_pools[object_type]
		var stats = pool_stats[object_type]

		var hit_rate = 0.0
		var total_requests = stats.hits + stats.misses
		if total_requests > 0:
			hit_rate = float(stats.hits) / float(total_requests) * 100.0

		print(
			(
				"%s: %d available, %d in use, %.1f%% hit rate"
				% [object_type, pool.available.size(), pool.in_use.size(), hit_rate]
			)
		)

	print("=" * 50)
