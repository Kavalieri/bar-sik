extends Control
class_name QAPanel

## T038 - Professional QA Pass System UI
## Interfaz para ejecutar y monitorear QA Pass

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressSection/ProgressBar
@onready var progress_label: Label = $VBoxContainer/ProgressSection/ProgressLabel
@onready var results_text: RichTextLabel = $VBoxContainer/ResultsSection/ScrollContainer/ResultsText
@onready var run_qa_button: Button = $VBoxContainer/ButtonSection/RunQAButton
@onready var export_button: Button = $VBoxContainer/ButtonSection/ExportButton

var qa_validator: QAValidator
var game_data: GameData
var qa_results: Dictionary = {}


func _ready():
	_setup_ui()
	_connect_signals()
	game_data = GameData.new()


func _setup_ui():
	"""Configura la interfaz inicial"""
	progress_bar.value = 0
	progress_label.text = "Ready to run QA Pass"
	results_text.text = "[center][color=gray]Click 'Run QA Pass' to begin professional validation[/color][/center]"
	export_button.disabled = true


func _connect_signals():
	"""Conecta signals del sistema"""
	run_qa_button.pressed.connect(_on_run_qa_pressed)
	export_button.pressed.connect(_on_export_pressed)


## === QA EXECUTION ===


func _on_run_qa_pressed():
	"""Ejecuta el QA pass completo"""
	if qa_validator:
		qa_validator.queue_free()

	qa_validator = QAValidator.new()
	_connect_qa_signals()

	# Deshabilitar botón durante ejecución
	run_qa_button.disabled = true
	run_qa_button.text = "Running QA..."
	export_button.disabled = true

	# Limpiar resultados previos
	results_text.text = "[center][color=yellow]🔍 Running Professional QA Pass...[/color][/center]"
	progress_bar.value = 0

	# Ejecutar QA pass
	qa_results = await qa_validator.run_complete_qa_pass(game_data)

	# Mostrar resultados
	_display_qa_results()

	# Reactivar botón
	run_qa_button.disabled = false
	run_qa_button.text = "Run QA Pass Again"
	export_button.disabled = false


func _connect_qa_signals():
	"""Conecta signals del QA validator"""
	qa_validator.qa_progress_updated.connect(_on_qa_progress_updated)
	qa_validator.qa_issue_found.connect(_on_qa_issue_found)
	qa_validator.qa_completed.connect(_on_qa_completed)


func _on_qa_progress_updated(step: String, progress: float):
	"""Actualiza progreso del QA"""
	progress_bar.value = progress * 100
	progress_label.text = "Running: " + step + " (" + str(int(progress * 100)) + "%)"


func _on_qa_issue_found(category: String, issue: String, severity: String):
	"""Maneja issue encontrado durante QA"""
	var color = _get_severity_color(severity)
	var icon = _get_severity_icon(severity)

	var issue_text = (
		"[color="
		+ color
		+ "]"
		+ icon
		+ " ["
		+ severity
		+ "] "
		+ category
		+ ": "
		+ issue
		+ "[/color]\n"
	)
	results_text.text += issue_text


func _on_qa_completed(passed: bool, total_issues: int):
	"""Maneja finalización del QA"""
	progress_bar.value = 100
	progress_label.text = "QA Pass Completed"

	var status_color = "green" if passed else "red"
	var status_text = "✅ PASSED" if passed else "❌ FAILED"

	results_text.text += (
		"\n[center][color=" + status_color + "][b]" + status_text + "[/b][/color][/center]\n"
	)
	results_text.text += "[center]Total Issues Found: " + str(total_issues) + "[/center]"


## === RESULTS DISPLAY ===


func _display_qa_results():
	"""Muestra resultados detallados del QA"""
	if qa_results.is_empty():
		return

	var summary = qa_results.get("summary", {})
	var categories = qa_results.get("categories", {})
	var recommendations = qa_results.get("recommendations", [])

	var display_text = _build_results_header(summary)
	display_text += _build_categories_section(categories)
	display_text += _build_recommendations_section(recommendations)
	display_text += _build_footer()

	results_text.text = display_text


func _build_results_header(summary: Dictionary) -> String:
	"""Construye header de resultados"""
	var quality_score = summary.get("quality_score", 0.0)
	var release_readiness = summary.get("release_readiness", "Unknown")
	var pass_rate = summary.get("pass_rate", 0.0)

	var score_color = _get_score_color(quality_score)
	var readiness_color = _get_readiness_color(release_readiness)

	var header = "[center][size=24][b]🎯 BAR-SIK QA REPORT[/b][/size][/center]\n"
	header += "[center][size=18][color=gray]Professional Quality Assurance Pass[/color][/size][/center]\n\n"

	header += "[b]📊 QUALITY METRICS[/b]\n"
	header += (
		"• Quality Score: [color="
		+ score_color
		+ "][b]"
		+ str(int(quality_score))
		+ "/100[/b][/color]\n"
	)
	header += "• Pass Rate: [color=blue][b]" + str(int(pass_rate)) + "%[/b][/color]\n"
	header += (
		"• Release Status: [color="
		+ readiness_color
		+ "][b]"
		+ release_readiness
		+ "[/b][/color]\n\n"
	)

	return header


func _build_categories_section(categories: Dictionary) -> String:
	"""Construye sección de categorías"""
	var section = "[b]📋 DETAILED RESULTS BY CATEGORY[/b]\n\n"

	for category_key in categories:
		var category = categories[category_key]
		var category_name = category.get("category", "Unknown")
		var issues = category.get("issues", [])

		var icon = _get_category_icon(category_name)
		var status = "✅ PASSED" if issues.is_empty() else "⚠️ ISSUES FOUND"
		var status_color = "green" if issues.is_empty() else "orange"

		section += (
			icon
			+ " [b]"
			+ category_name
			+ "[/b] - [color="
			+ status_color
			+ "]"
			+ status
			+ "[/color]\n"
		)

		if not issues.is_empty():
			for issue in issues:
				var severity = issue.get("severity", "INFO")
				var description = issue.get("description", "Unknown issue")
				var severity_color = _get_severity_color(severity)
				var severity_icon = _get_severity_icon(severity)

				section += (
					"  "
					+ severity_icon
					+ " [color="
					+ severity_color
					+ "]["
					+ severity
					+ "][/color] "
					+ description
					+ "\n"
				)

		section += "\n"

	return section


func _build_recommendations_section(recommendations: Array) -> String:
	"""Construye sección de recomendaciones"""
	if recommendations.is_empty():
		return ""

	var section = "[b]💡 RECOMMENDATIONS[/b]\n\n"

	for recommendation in recommendations:
		section += "• " + str(recommendation) + "\n"

	section += "\n"

	return section


func _build_footer() -> String:
	"""Construye footer del reporte"""
	var timestamp = Time.get_datetime_string_from_system()
	var footer = (
		"[center][size=12][color=gray]Generated: " + timestamp + "[/color][/size][/center]\n"
	)
	footer += "[center][size=12][color=gray]Bar-Sik Professional QA System v1.0[/color][/size][/center]"

	return footer


## === EXPORT FUNCTIONALITY ===


func _on_export_pressed():
	"""Exporta resultados del QA"""
	if qa_results.is_empty():
		return

	var export_data = _prepare_export_data()
	var file_path = (
		"user://qa_report_" + Time.get_datetime_string_from_system().replace(":", "-") + ".json"
	)

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(export_data, "\t"))
		file.close()

		_show_export_notification("QA Report exported to: " + file_path)
	else:
		_show_export_notification("Failed to export QA Report")


func _prepare_export_data() -> Dictionary:
	"""Prepara datos para exportación"""
	return {
		"qa_report": qa_results,
		"export_timestamp": Time.get_datetime_string_from_system(),
		"game_version": "Bar-Sik v0.3.0",
		"qa_system_version": "1.0"
	}


func _show_export_notification(message: String):
	"""Muestra notificación de exportación"""
	# En implementación completa, esto sería un popup o notification
	results_text.text += "\n[center][color=cyan]📁 " + message + "[/color][/center]\n"


## === HELPER METHODS ===


func _get_severity_color(severity: String) -> String:
	"""Obtiene color para severidad"""
	match severity:
		"CRITICAL":
			return "red"
		"MAJOR":
			return "orange"
		"MINOR":
			return "yellow"
		"INFO":
			return "cyan"
		_:
			return "white"


func _get_severity_icon(severity: String) -> String:
	"""Obtiene icono para severidad"""
	match severity:
		"CRITICAL":
			return "🚨"
		"MAJOR":
			return "⚠️"
		"MINOR":
			return "💡"
		"INFO":
			return "ℹ️"
		_:
			return "•"


func _get_score_color(score: float) -> String:
	"""Obtiene color basado en score de calidad"""
	if score >= 90:
		return "green"
	elif score >= 75:
		return "yellow"
	elif score >= 50:
		return "orange"
	else:
		return "red"


func _get_readiness_color(readiness: String) -> String:
	"""Obtiene color basado en readiness"""
	if "READY FOR RELEASE" in readiness:
		return "green"
	elif "READY WITH CAVEATS" in readiness:
		return "yellow"
	elif "CAUTION" in readiness:
		return "orange"
	else:
		return "red"


func _get_category_icon(category: String) -> String:
	"""Obtiene icono para categoría"""
	match category:
		"Save/Load System":
			return "💾"
		"UI/UX Responsiveness":
			return "🖱️"
		"Performance Stability":
			return "⚡"
		"Game Balance":
			return "⚖️"
		"Audio/Visual Polish":
			return "✨"
		"System Integration":
			return "🔗"
		_:
			return "📋"


## === SCENE MANAGEMENT ===


func _input(event):
	"""Manejo de input"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F5:  # F5 para ejecutar QA rápido
			_on_run_qa_pressed()
		elif event.keycode == KEY_ESCAPE:
			_close_qa_panel()


func _close_qa_panel():
	"""Cierra el panel de QA"""
	queue_free()
