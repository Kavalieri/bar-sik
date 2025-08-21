# =============================================================================
# T015 - PRESTIGE UI PANEL
# =============================================================================
# Interface de usuario para el sistema de prestigio
# Permite ver requisitos, calcular stars, comprar bonos y ejecutar prestigio
# Fecha: 22 Agosto 2025
# Estado: 🔄 EN DESARROLLO

extends Control
class_name PrestigePanel

# =============================================================================
# SIGNALS
# =============================================================================

signal prestige_requested
signal bonus_purchase_requested(bonus_id: String)
signal panel_closed

# =============================================================================
# REFERENCES
# =============================================================================

@onready var main_container: VBoxContainer = $MainContainer
@onready var close_button: Button = $MainContainer/HeaderContainer/CloseButton

# Header section
@onready var title_label: Label = $MainContainer/HeaderContainer/TitleLabel
@onready var stars_display: Label = $MainContainer/HeaderContainer/StarsDisplay

# Requirements section
@onready
var requirements_container: VBoxContainer = $MainContainer/RequirementsSection/RequirementsContainer
@onready var requirements_title: Label = $MainContainer/RequirementsSection/RequirementsTitleLabel

# Stats section
@onready var stats_container: VBoxContainer = $MainContainer/StatsSection/StatsContainer
@onready var current_cash_label: Label = $MainContainer/StatsSection/StatsContainer/CurrentCashLabel
@onready var total_cash_label: Label = $MainContainer/StatsSection/StatsContainer/TotalCashLabel
@onready var stars_to_gain_label: Label = $MainContainer/StatsSection/StatsContainer/StarsToGainLabel
@onready
var next_star_progress: ProgressBar = $MainContainer/StatsSection/StatsContainer/NextStarProgress

# Bonuses section
@onready var bonuses_scroll: ScrollContainer = $MainContainer/BonusesSection/BonusesScroll
@onready
var bonuses_container: VBoxContainer = $MainContainer/BonusesSection/BonusesScroll/BonusesContainer

# Warning section
@onready var warning_container: VBoxContainer = $MainContainer/WarningSection/WarningContainer
@onready
var warning_label: RichTextLabel = $MainContainer/WarningSection/WarningContainer/WarningLabel

# Action section
@onready var action_container: HBoxContainer = $MainContainer/ActionSection/ActionContainer
@onready var cancel_button: Button = $MainContainer/ActionSection/ActionContainer/CancelButton
@onready var prestige_button: Button = $MainContainer/ActionSection/ActionContainer/PrestigeButton

# =============================================================================
# VARIABLES
# =============================================================================

var prestige_manager: PrestigeManager
var game_data: GameData
var is_initialized: bool = false

# Cached data for updates
var cached_requirements: Dictionary = {}
var cached_bonuses: Array[Dictionary] = []

# =============================================================================
# INITIALIZATION
# =============================================================================


func _ready():
	"""Inicialización del panel"""
	print("🎮 PrestigePanel: Inicializando...")

	# Conectar señales básicas
	_connect_ui_signals()

	# Configurar estilo inicial
	_setup_initial_styling()

	print("✅ PrestigePanel inicializado")


func _connect_ui_signals():
	"""Conectar señales de la UI"""
	close_button.pressed.connect(_on_close_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	prestige_button.pressed.connect(_on_prestige_button_pressed)


func _setup_initial_styling():
	"""Configurar estilo inicial del panel"""
	# Configurar el panel como modal
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modulate = Color(1, 1, 1, 0)  # Empezar transparente para fade in

	# Estilo del título
	if title_label:
		title_label.text = "🌟 SISTEMA DE PRESTIGIO"
		title_label.add_theme_font_size_override("font_size", 24)

	# Configurar botón de prestigio
	if prestige_button:
		prestige_button.text = "⭐ REALIZAR PRESTIGIO"
		prestige_button.custom_minimum_size = Vector2(200, 50)


func setup_with_managers(prestige_mgr: PrestigeManager, game_data_ref: GameData):
	"""Configurar panel con referencias a managers"""
	prestige_manager = prestige_mgr
	game_data = game_data_ref
	is_initialized = true

	print("🔗 PrestigePanel configurado con managers")

	# Actualizar datos iniciales
	_update_all_displays()


# =============================================================================
# UPDATE METHODS
# =============================================================================


func _update_all_displays():
	"""Actualizar todos los displays del panel"""
	if not is_initialized:
		return

	_update_header_display()
	_update_requirements_display()
	_update_stats_display()
	_update_bonuses_display()
	_update_warning_display()
	_update_action_buttons()


func _update_header_display():
	"""Actualizar header con stars actuales"""
	if not prestige_manager:
		return

	var current_stars = prestige_manager.prestige_stars
	var prestige_count = prestige_manager.prestige_count

	if stars_display:
		stars_display.text = "⭐ %d stars | Prestigios: %d" % [current_stars, prestige_count]
		stars_display.add_theme_font_size_override("font_size", 18)


func _update_requirements_display():
	"""Actualizar display de requisitos de prestigio"""
	if not prestige_manager:
		return

	var requirements = prestige_manager.get_prestige_requirements()
	cached_requirements = requirements

	# Limpiar contenedor anterior
	_clear_container(requirements_container)

	# Título de requisitos
	if requirements_title:
		requirements_title.text = "📋 REQUISITOS PARA PRESTIGIO"
		requirements_title.add_theme_font_size_override("font_size", 16)

	# Mostrar cada requisito
	_add_requirement_item(
		"💰 Cash Total Histórico",
		requirements.cash.current,
		requirements.cash.required,
		requirements.cash.met
	)

	_add_requirement_item(
		"🏆 Logros Completados",
		requirements.achievements.current,
		requirements.achievements.required,
		requirements.achievements.met
	)

	_add_requirement_item(
		"👥 Sistema de Clientes",
		"Desbloqueado" if requirements.customer_system.current else "Bloqueado",
		"Requerido",
		requirements.customer_system.met
	)


func _add_requirement_item(name: String, current: Variant, required: Variant, met: bool):
	"""Agregar un item de requisito al contenedor"""
	var item_container = HBoxContainer.new()

	# Icono de estado
	var status_label = Label.new()
	status_label.text = "✅" if met else "❌"
	status_label.custom_minimum_size = Vector2(30, 0)
	item_container.add_child(status_label)

	# Nombre del requisito
	var name_label = Label.new()
	name_label.text = name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_container.add_child(name_label)

	# Valor actual/requerido
	var value_label = Label.new()
	if current is float:
		value_label.text = "%s / %s" % [_format_number(current), _format_number(required)]
	elif current is int:
		value_label.text = "%d / %d" % [current, required]
	else:
		value_label.text = "%s" % str(current)

	value_label.custom_minimum_size = Vector2(150, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	item_container.add_child(value_label)

	requirements_container.add_child(item_container)


func _update_stats_display():
	"""Actualizar display de estadísticas"""
	if not game_data or not prestige_manager:
		return

	# Cash actual
	if current_cash_label:
		current_cash_label.text = "💰 Cash Actual: %s" % _format_number(game_data.money)

	# Cash total histórico
	var total_cash = game_data.get("total_cash_earned", 0.0)
	if total_cash_label:
		total_cash_label.text = "📈 Cash Total: %s" % _format_number(total_cash)

	# Stars a ganar
	var stars_to_gain = prestige_manager.calculate_prestige_stars()
	if stars_to_gain_label:
		stars_to_gain_label.text = "⭐ Ganarás: %d stars" % stars_to_gain

		# Color según si vale la pena el prestigio
		if stars_to_gain > 0:
			stars_to_gain_label.modulate = Color.GREEN
		else:
			stars_to_gain_label.modulate = Color.RED

	# Progress hacia siguiente star
	if next_star_progress:
		var next_star_info = prestige_manager.get_next_star_progress()
		next_star_progress.value = next_star_info.get("progress_percentage", 0.0)
		next_star_progress.custom_minimum_size = Vector2(300, 25)


func _update_bonuses_display():
	"""Actualizar display de bonificaciones disponibles"""
	if not prestige_manager:
		return

	# Limpiar contenedor anterior
	_clear_container(bonuses_container)

	# Título de bonificaciones
	var bonuses_title = Label.new()
	bonuses_title.text = "🎁 BONIFICACIONES DISPONIBLES"
	bonuses_title.add_theme_font_size_override("font_size", 16)
	bonuses_container.add_child(bonuses_title)

	# Obtener todas las bonificaciones
	var all_bonuses = prestige_manager.get_all_star_bonuses_definitions()
	cached_bonuses = all_bonuses

	# Crear card para cada bonificación
	for bonus in all_bonuses:
		_create_bonus_card(bonus)


func _create_bonus_card(bonus: Dictionary):
	"""Crear una card para una bonificación"""
	var card_container = PanelContainer.new()
	card_container.custom_minimum_size = Vector2(0, 80)

	# Estilo de la card
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2

	# Determinar estado de la bonificación
	var is_owned = prestige_manager.has_star_bonus(bonus.id)
	var can_purchase = prestige_manager.can_purchase_star_bonus(bonus.id)

	if is_owned:
		card_style.bg_color = Color.GREEN.lightened(0.7)
		card_style.border_color = Color.GREEN
	elif can_purchase:
		card_style.bg_color = Color.BLUE.lightened(0.8)
		card_style.border_color = Color.BLUE
	else:
		card_style.bg_color = Color.GRAY.lightened(0.6)
		card_style.border_color = Color.GRAY

	card_container.add_theme_stylebox_override("panel", card_style)

	# Contenido de la card
	var content_container = HBoxContainer.new()
	content_container.custom_minimum_size = Vector2(0, 60)
	card_container.add_child(content_container)

	# Icon y título
	var left_section = VBoxContainer.new()
	left_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var title_label = Label.new()
	title_label.text = "%s %s" % [bonus.get("icon", "⭐"), bonus.get("name", "Bonus")]
	title_label.add_theme_font_size_override("font_size", 16)
	left_section.add_child(title_label)

	var desc_label = Label.new()
	desc_label.text = bonus.get("description", "Sin descripción")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.modulate = Color.GRAY
	left_section.add_child(desc_label)

	content_container.add_child(left_section)

	# Sección derecha con costo/estado
	var right_section = VBoxContainer.new()
	right_section.custom_minimum_size = Vector2(120, 0)

	var cost_label = Label.new()
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var status_button = Button.new()
	status_button.custom_minimum_size = Vector2(100, 30)

	if is_owned:
		cost_label.text = "✅ ACTIVO"
		cost_label.modulate = Color.GREEN
		status_button.text = "Comprado"
		status_button.disabled = true
	elif can_purchase:
		cost_label.text = "⭐ %d stars" % bonus.get("cost", 0)
		cost_label.modulate = Color.BLUE
		status_button.text = "Comprar"
		status_button.disabled = false
		# Conectar señal de compra
		status_button.pressed.connect(_on_bonus_purchase_requested.bind(bonus.id))
	else:
		cost_label.text = "⭐ %d stars" % bonus.get("cost", 0)
		cost_label.modulate = Color.GRAY
		status_button.text = "Sin Stars"
		status_button.disabled = true

	right_section.add_child(cost_label)
	right_section.add_child(status_button)
	content_container.add_child(right_section)

	bonuses_container.add_child(card_container)


func _update_warning_display():
	"""Actualizar display de advertencia de reset"""
	if not warning_label:
		return

	var warning_text = """
[color=orange]⚠️ ADVERTENCIA DE RESET ⚠️[/color]

Al realizar prestigio se REINICIARÁ lo siguiente:
• 💰 Cash actual (no el histórico)
• 🏭 Niveles de generadores y estaciones
• 📦 Todos los inventarios de recursos y productos
• ⚙️ Upgrades temporales (no permanentes)

[color=green]✅ SE PRESERVARÁ:[/color]
• 🪙 Tokens y 💎 Gemas actuales
• ⭐ Stars de prestigio y bonificaciones
• 🏆 Logros completados
• 👥 Sistema de clientes desbloqueado
• 📚 Recetas y estaciones desbloqueadas
	"""

	warning_label.text = warning_text
	warning_label.fit_content = true


func _update_action_buttons():
	"""Actualizar estado de los botones de acción"""
	if not prestige_manager or not prestige_button:
		return

	var can_prestige = prestige_manager.can_prestige()
	var stars_to_gain = prestige_manager.calculate_prestige_stars()

	prestige_button.disabled = not can_prestige or stars_to_gain <= 0

	if can_prestige and stars_to_gain > 0:
		prestige_button.text = "⭐ PRESTIGIO (+%d stars)" % stars_to_gain
		prestige_button.modulate = Color.GREEN
	elif not can_prestige:
		prestige_button.text = "❌ REQUISITOS NO CUMPLIDOS"
		prestige_button.modulate = Color.RED
	else:
		prestige_button.text = "⚠️ SIN STARS PARA GANAR"
		prestige_button.modulate = Color.ORANGE


# =============================================================================
# EVENT HANDLERS
# =============================================================================


func _on_close_button_pressed():
	"""Manejar botón de cerrar"""
	hide_panel()


func _on_cancel_button_pressed():
	"""Manejar botón de cancelar"""
	hide_panel()


func _on_prestige_button_pressed():
	"""Manejar botón de prestigio"""
	if not prestige_manager:
		return

	# Mostrar confirmación adicional
	_show_prestige_confirmation()


func _on_bonus_purchase_requested(bonus_id: String):
	"""Manejar solicitud de compra de bonificación"""
	if not prestige_manager:
		return

	print("🛒 Solicitando compra de bonus: %s" % bonus_id)

	var success = prestige_manager.purchase_star_bonus(bonus_id)
	if success:
		print("✅ Bonus comprado exitosamente: %s" % bonus_id)
		# Actualizar displays después de compra
		_update_all_displays()
		# Emitir señal para que GameController guarde
		bonus_purchase_requested.emit(bonus_id)
	else:
		print("❌ No se pudo comprar bonus: %s" % bonus_id)


func _show_prestige_confirmation():
	"""Mostrar confirmación final antes de prestigio"""
	var stars_to_gain = prestige_manager.calculate_prestige_stars() if prestige_manager else 0

	# Crear dialog de confirmación
	var confirmation_dialog = AcceptDialog.new()
	confirmation_dialog.dialog_text = (
		"¿Estás seguro de que quieres realizar prestigio?\n\nGanarás %d stars y se reseteará tu progreso actual.\n\n¡Esta acción no se puede deshacer!"
		% stars_to_gain
	)
	confirmation_dialog.title = "Confirmar Prestigio"

	# Agregar botón personalizado
	confirmation_dialog.add_cancel_button("Cancelar")

	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()

	# Conectar confirmación
	confirmation_dialog.confirmed.connect(_execute_prestige)
	confirmation_dialog.tree_exited.connect(confirmation_dialog.queue_free)


func _execute_prestige():
	"""Ejecutar prestigio confirmado"""
	print("⭐ Ejecutando prestigio...")
	prestige_requested.emit()
	hide_panel()


# =============================================================================
# SHOW/HIDE METHODS
# =============================================================================


func show_panel():
	"""Mostrar panel con animación"""
	visible = true

	# Fade in animation
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

	# Actualizar datos al mostrar
	_update_all_displays()

	print("🎮 PrestigePanel mostrado")


func hide_panel():
	"""Ocultar panel con animación"""
	# Fade out animation
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	tween.tween_callback(func(): visible = false)

	panel_closed.emit()
	print("🎮 PrestigePanel ocultado")


# =============================================================================
# UTILITY METHODS
# =============================================================================


func _clear_container(container: Container):
	"""Limpiar todos los hijos de un contenedor"""
	if not container:
		return

	for child in container.get_children():
		child.queue_free()


func _format_number(num: float) -> String:
	"""Formatear números para display"""
	if num >= 1000000000:  # Billions
		return "%.2fB" % (num / 1000000000.0)
	elif num >= 1000000:  # Millions
		return "%.2fM" % (num / 1000000.0)
	elif num >= 1000:  # Thousands
		return "%.2fK" % (num / 1000.0)
	else:
		return "%.0f" % num


func get_panel_name() -> String:
	"""Nombre del panel para identificación"""
	return "PrestigePanel"


# =============================================================================
# DEBUG METHODS
# =============================================================================


func debug_print_panel_state():
	"""Debug del estado del panel"""
	print("=== DEBUG PRESTIGE PANEL ===")
	print("Initialized: ", is_initialized)
	print("PrestigeManager: ", prestige_manager != null)
	print("GameData: ", game_data != null)
	print("Cached Requirements: ", cached_requirements.size())
	print("Cached Bonuses: ", cached_bonuses.size())

# EOF - PrestigePanel.gd
