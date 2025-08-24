class_name StatisticsPanel
extends Panel

## T034 - Panel de Dashboard de Estadísticas
## UI para mostrar analytics detallados a engaged players

# Referencias
var statistics_manager: StatisticsManager
var tab_container: TabContainer
var update_timer: Timer

# Tabs principales
var production_tab: Control
var economic_tab: Control
var meta_tab: Control
var efficiency_tab: Control

# Elementos UI por tab
var production_labels: Dictionary = {}
var economic_labels: Dictionary = {}
var meta_labels: Dictionary = {}
var efficiency_labels: Dictionary = {}


func _ready():
	print("📊 StatisticsPanel inicializado (T034)")
	_create_ui_structure()
	_setup_update_timer()


func _create_ui_structure():
	"""Crea la estructura completa de la UI"""

	# Panel principal
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Contenedor con título
	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 10)

	# Título
	var title = Label.new()
	title.text = "📊 DASHBOARD DE ESTADÍSTICAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	main_vbox.add_child(title)

	# TabContainer para diferentes categorías
	tab_container = TabContainer.new()
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(tab_container)

	_create_production_tab()
	_create_economic_tab()
	_create_meta_tab()
	_create_efficiency_tab()


func _create_production_tab():
	"""Crea el tab de estadísticas de producción"""
	production_tab = ScrollContainer.new()
	production_tab.name = "🍺 Producción"
	tab_container.add_child(production_tab)

	var vbox = VBoxContainer.new()
	production_tab.add_child(vbox)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Sección: Producción General
	_add_stats_section(
		vbox,
		"📈 Producción General",
		[
			"total_beers_brewed",
			"production_streaks_current",
			"production_streaks_best",
			"waste_generated"
		],
		production_labels
	)

	# Sección: Por Tipo de Cerveza
	_add_stats_section(
		vbox,
		"🍻 Por Tipo de Cerveza",
		["top_beer_type_1", "top_beer_type_2", "top_beer_type_3"],
		production_labels
	)

	# Sección: Calidad
	_add_stats_section(
		vbox,
		"⭐ Control de Calidad",
		["quality_excellent", "quality_good", "quality_poor", "quality_ratio"],
		production_labels
	)


func _create_economic_tab():
	"""Crea el tab de estadísticas económicas"""
	economic_tab = ScrollContainer.new()
	economic_tab.name = "💰 Economía"
	tab_container.add_child(economic_tab)

	var vbox = VBoxContainer.new()
	economic_tab.add_child(vbox)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Sección: Ingresos
	_add_stats_section(
		vbox,
		"💵 Ingresos",
		[
			"money_lifetime",
			"money_session",
			"money_per_hour_avg",
			"money_per_hour_peak",
			"biggest_sale"
		],
		economic_labels
	)

	# Sección: Tokens y Gemas
	_add_stats_section(
		vbox,
		"💎 Recursos Premium",
		[
			"tokens_achievements",
			"tokens_missions",
			"tokens_prestige",
			"gems_spent_upgrades",
			"gems_spent_automation"
		],
		economic_labels
	)

	# Sección: Análisis de Ventas
	_add_stats_section(
		vbox,
		"📊 Análisis de Ventas",
		["revenue_by_beer", "customer_value", "profit_margins"],
		economic_labels
	)


func _create_meta_tab():
	"""Crea el tab de estadísticas meta"""
	meta_tab = ScrollContainer.new()
	meta_tab.name = "⏱️ Meta"
	tab_container.add_child(meta_tab)

	var vbox = VBoxContainer.new()
	meta_tab.add_child(vbox)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Sección: Tiempo de Juego
	_add_stats_section(
		vbox,
		"🕐 Tiempo de Juego",
		["total_playtime", "sessions_count", "avg_session_length", "longest_session"],
		meta_labels
	)

	# Sección: Progreso Offline
	_add_stats_section(
		vbox,
		"😴 Progreso Offline",
		["offline_time_total", "offline_gains_total", "offline_efficiency"],
		meta_labels
	)

	# Sección: Prestigio
	_add_stats_section(
		vbox,
		"🌟 Prestigio",
		["prestige_count", "prestige_fastest", "prestige_stars", "prestige_avg_time"],
		meta_labels
	)

	# Sección: Logros
	_add_stats_section(
		vbox,
		"🏆 Progreso",
		[
			"achievements_unlocked",
			"achievements_progress",
			"missions_completed",
			"features_unlocked"
		],
		meta_labels
	)


func _create_efficiency_tab():
	"""Crea el tab de estadísticas de eficiencia"""
	efficiency_tab = ScrollContainer.new()
	efficiency_tab.name = "⚡ Eficiencia"
	tab_container.add_child(efficiency_tab)

	var vbox = VBoxContainer.new()
	efficiency_tab.add_child(vbox)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Sección: Scores de Optimización
	_add_stats_section(
		vbox,
		"📈 Puntuaciones de Optimización",
		[
			"resource_management_score",
			"automation_setup_score",
			"timing_efficiency_score",
			"overall_efficiency"
		],
		efficiency_labels
	)

	# Sección: Automatización
	_add_stats_section(
		vbox,
		"🤖 Uso de Automatización",
		[
			"automation_production_hours",
			"automation_sales_hours",
			"automation_total_hours",
			"automation_vs_manual_ratio"
		],
		efficiency_labels
	)

	# Sección: Idle vs Activo
	_add_stats_section(
		vbox,
		"⚖️ Balance Idle/Activo",
		["idle_gains", "active_gains", "idle_vs_active_ratio", "optimal_balance_score"],
		efficiency_labels
	)


func _add_stats_section(parent: Control, title: String, stats: Array, labels_dict: Dictionary):
	"""Añade una sección de estadísticas con título y labels"""

	# Separador
	var separator = HSeparator.new()
	parent.add_child(separator)

	# Título de sección
	var section_title = Label.new()
	section_title.text = title
	section_title.add_theme_font_size_override("font_size", 18)
	parent.add_child(section_title)

	# Grid de stats
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 5)
	parent.add_child(grid)

	for stat_key in stats:
		# Label de nombre
		var name_label = Label.new()
		name_label.text = _get_stat_display_name(stat_key) + ":"
		grid.add_child(name_label)

		# Label de valor
		var value_label = Label.new()
		value_label.text = "0"
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grid.add_child(value_label)

		labels_dict[stat_key] = value_label


func _get_stat_display_name(stat_key: String) -> String:
	"""Convierte claves de stats a nombres legibles"""
	var display_names = {
		# Production
		"total_beers_brewed": "Cervezas Totales",
		"production_streaks_current": "Racha Actual",
		"production_streaks_best": "Mejor Racha",
		"waste_generated": "Desperdicio",
		"top_beer_type_1": "Cerveza #1",
		"top_beer_type_2": "Cerveza #2",
		"top_beer_type_3": "Cerveza #3",
		"quality_excellent": "Calidad Excelente",
		"quality_good": "Calidad Buena",
		"quality_poor": "Calidad Pobre",
		"quality_ratio": "Ratio de Calidad",
		# Economic
		"money_lifetime": "Dinero Total",
		"money_session": "Dinero Sesión",
		"money_per_hour_avg": "$/Hora Promedio",
		"money_per_hour_peak": "$/Hora Pico",
		"biggest_sale": "Mayor Venta",
		"tokens_achievements": "Tokens: Logros",
		"tokens_missions": "Tokens: Misiones",
		"tokens_prestige": "Tokens: Prestigio",
		"gems_spent_upgrades": "Gemas: Mejoras",
		"gems_spent_automation": "Gemas: Auto.",
		"revenue_by_beer": "Ingresos por Cerveza",
		"customer_value": "Valor del Cliente",
		"profit_margins": "Márgenes",
		# Meta
		"total_playtime": "Tiempo Total",
		"sessions_count": "Sesiones",
		"avg_session_length": "Duración Promedio",
		"longest_session": "Sesión Más Larga",
		"offline_time_total": "Tiempo Offline",
		"offline_gains_total": "Ganancias Offline",
		"offline_efficiency": "Eficiencia Offline",
		"prestige_count": "Prestigios",
		"prestige_fastest": "Prestigio Más Rápido",
		"prestige_stars": "Estrellas",
		"prestige_avg_time": "Tiempo Promedio",
		"achievements_unlocked": "Logros",
		"achievements_progress": "Progreso Logros",
		"missions_completed": "Misiones",
		"features_unlocked": "Características",
		# Efficiency
		"resource_management_score": "Gestión Recursos",
		"automation_setup_score": "Setup Auto.",
		"timing_efficiency_score": "Eficiencia Timing",
		"overall_efficiency": "Eficiencia General",
		"automation_production_hours": "Auto: Producción",
		"automation_sales_hours": "Auto: Ventas",
		"automation_total_hours": "Auto: Total",
		"automation_vs_manual_ratio": "Ratio Auto/Manual",
		"idle_gains": "Ganancias Idle",
		"active_gains": "Ganancias Activas",
		"idle_vs_active_ratio": "Ratio Idle/Activo",
		"optimal_balance_score": "Balance Óptimo"
	}

	return display_names.get(stat_key, stat_key.replace("_", " ").capitalize())


func _setup_update_timer():
	"""Configura timer para actualizar la UI"""
	update_timer = Timer.new()
	update_timer.wait_time = 2.0  # Actualizar cada 2 segundos
	update_timer.timeout.connect(_update_all_stats)
	update_timer.autostart = true
	add_child(update_timer)


func _update_all_stats():
	"""Actualiza todas las estadísticas mostradas"""
	if not statistics_manager:
		return

	_update_production_stats()
	_update_economic_stats()
	_update_meta_stats()
	_update_efficiency_stats()


func _update_production_stats():
	"""Actualiza stats de producción"""
	var stats = statistics_manager.get_production_summary()

	_update_label(
		"total_beers_brewed", _format_number(stats.get("total_beers_brewed", 0)), production_labels
	)
	_update_label(
		"production_streaks_current",
		str(stats.get("production_streaks", {}).get("current", 0)),
		production_labels
	)
	_update_label(
		"production_streaks_best",
		str(stats.get("production_streaks", {}).get("best", 0)),
		production_labels
	)
	_update_label("waste_generated", str(stats.get("waste_generated", 0)), production_labels)

	# Top beer types
	var top_beers = statistics_manager.get_top_beer_types(3)
	for i in range(3):
		var key = "top_beer_type_%d" % (i + 1)
		if i < top_beers.size():
			var beer_info = (
				"%s (%s)" % [top_beers[i]["type"], _format_number(top_beers[i]["quantity"])]
			)
			_update_label(key, beer_info, production_labels)
		else:
			_update_label(key, "N/A", production_labels)

	# Quality metrics
	var quality = stats.get("quality_metrics", {})
	_update_label("quality_excellent", str(quality.get("excellent", 0)), production_labels)
	_update_label("quality_good", str(quality.get("good", 0)), production_labels)
	_update_label("quality_poor", str(quality.get("poor", 0)), production_labels)

	var total_quality = (
		quality.get("excellent", 0) + quality.get("good", 0) + quality.get("poor", 0)
	)
	var ratio = (
		0.0 if total_quality == 0 else float(quality.get("excellent", 0)) / float(total_quality)
	)
	_update_label("quality_ratio", "%.1f%%" % (ratio * 100), production_labels)


func _update_economic_stats():
	"""Actualiza stats económicas"""
	var stats = statistics_manager.get_economic_summary()

	_update_label(
		"money_lifetime", _format_money(stats.get("money_earned_lifetime", 0.0)), economic_labels
	)
	_update_label(
		"money_session", _format_money(stats.get("money_earned_session", 0.0)), economic_labels
	)
	_update_label(
		"money_per_hour_avg",
		_format_money(stats.get("money_per_hour_average", 0.0)),
		economic_labels
	)
	_update_label(
		"money_per_hour_peak", _format_money(stats.get("money_per_hour_peak", 0.0)), economic_labels
	)

	var biggest = stats.get("biggest_single_sale", {})
	_update_label("biggest_sale", _format_money(biggest.get("amount", 0.0)), economic_labels)

	# Tokens
	var tokens = stats.get("tokens_earned_breakdown", {})
	_update_label("tokens_achievements", str(tokens.get("achievements", 0)), economic_labels)
	_update_label("tokens_missions", str(tokens.get("missions", 0)), economic_labels)
	_update_label("tokens_prestige", str(tokens.get("prestige", 0)), economic_labels)

	# Gemas
	var gems = stats.get("gems_spent_categories", {})
	_update_label("gems_spent_upgrades", str(gems.get("upgrades", 0)), economic_labels)
	_update_label("gems_spent_automation", str(gems.get("automation", 0)), economic_labels)


func _update_meta_stats():
	"""Actualiza stats meta"""
	if not statistics_manager.game_data:
		return

	var meta_stats = statistics_manager.meta_stats

	_update_label("total_playtime", _format_time(meta_stats.get("total_playtime", 0)), meta_labels)
	_update_label("sessions_count", str(meta_stats.get("sessions_count", 0)), meta_labels)

	var session_lengths = meta_stats.get("session_lengths", [])
	if session_lengths.size() > 0:
		var avg_length = 0
		for length in session_lengths:
			avg_length += length
		avg_length = avg_length / session_lengths.size()
		_update_label("avg_session_length", _format_time(avg_length), meta_labels)
		_update_label("longest_session", _format_time(session_lengths.max()), meta_labels)

	_update_label(
		"offline_time_total", _format_time(meta_stats.get("offline_time_total", 0)), meta_labels
	)
	_update_label(
		"offline_gains_total",
		_format_money(meta_stats.get("offline_gains_total", 0.0)),
		meta_labels
	)

	# Prestige
	var prestige = meta_stats.get("prestige_statistics", {})
	_update_label("prestige_count", str(prestige.get("count", 0)), meta_labels)
	_update_label("prestige_fastest", _format_time(prestige.get("fastest_run", 0)), meta_labels)
	_update_label("prestige_stars", str(prestige.get("total_stars_earned", 0)), meta_labels)


func _update_efficiency_stats():
	"""Actualiza stats de eficiencia"""
	var efficiency_score = statistics_manager.get_efficiency_score()
	_update_label("overall_efficiency", "%.1f%%" % (efficiency_score * 100), efficiency_labels)

	var stats = statistics_manager.efficiency_stats
	var scores = stats.get("optimization_scores", {})

	_update_label(
		"resource_management_score",
		"%.1f%%" % (scores.get("resource_management", 0.0) * 100),
		efficiency_labels
	)
	_update_label(
		"automation_setup_score",
		"%.1f%%" % (scores.get("automation_setup", 0.0) * 100),
		efficiency_labels
	)
	_update_label(
		"timing_efficiency_score",
		"%.1f%%" % (scores.get("timing_efficiency", 0.0) * 100),
		efficiency_labels
	)

	var automation = stats.get("automation_usage", {})
	_update_label(
		"automation_production_hours",
		"%.1f h" % automation.get("production", 0.0),
		efficiency_labels
	)
	_update_label(
		"automation_sales_hours", "%.1f h" % automation.get("sales", 0.0), efficiency_labels
	)
	_update_label(
		"automation_total_hours", "%.1f h" % automation.get("total_hours", 0.0), efficiency_labels
	)

	var idle_vs_active = stats.get("idle_vs_active_ratio", {})
	_update_label(
		"idle_gains", _format_money(idle_vs_active.get("idle_gains", 0.0)), efficiency_labels
	)
	_update_label(
		"active_gains", _format_money(idle_vs_active.get("active_gains", 0.0)), efficiency_labels
	)


func _update_label(key: String, value: String, labels_dict: Dictionary):
	"""Actualiza un label específico"""
	if labels_dict.has(key):
		labels_dict[key].text = value


func _format_number(value: int) -> String:
	"""Formatea números grandes"""
	if value >= 1000000:
		return "%.1fM" % (value / 1000000.0)
	elif value >= 1000:
		return "%.1fK" % (value / 1000.0)
	else:
		return str(value)


func _format_money(value: float) -> String:
	"""Formatea valores monetarios"""
	if value >= 1000000:
		return "$%.1fM" % (value / 1000000.0)
	elif value >= 1000:
		return "$%.1fK" % (value / 1000.0)
	else:
		return "$%.2f" % value


func _format_time(seconds: int) -> String:
	"""Formatea tiempo en formato legible"""
	if seconds >= 3600:
		var hours = seconds / 3600
		var mins = (seconds % 3600) / 60
		return "%dh %dm" % [hours, mins]
	elif seconds >= 60:
		return "%dm" % (seconds / 60)
	else:
		return "%ds" % seconds


## === API PÚBLICAS ===


func set_statistics_manager(manager: StatisticsManager):
	"""Conecta con el StatisticsManager"""
	statistics_manager = manager
	if statistics_manager:
		# Conectar a señales para updates en tiempo real
		statistics_manager.stat_updated.connect(_on_stat_updated)
		statistics_manager.milestone_reached.connect(_on_milestone_reached)


func _on_stat_updated(category: String, stat_name: String, value: float):
	"""Maneja actualización de estadística individual"""
	# Actualizar inmediatamente si es visible
	if visible:
		_update_all_stats()


func _on_milestone_reached(category: String, milestone_name: String, value: float):
	"""Maneja hito alcanzado"""
	print("🎯 Hito alcanzado: %s - %s: %s" % [category, milestone_name, value])
	# Aquí se podría mostrar una notificación especial
