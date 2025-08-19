extends Node
## UIComponentsFactory - Fábrica de componentes UI modulares y profesionales (SINGLETON)
## Sistema centralizado para crear componentes consistentes en todas las pantallas

## 🏭 FÁBRICA DE COMPONENTES BASE

## Crear header de sección con estilo coherente
static func create_section_header(title: String, subtitle: String = "") -> VBoxContainer:
	var header_container = VBoxContainer.new()
	header_container.add_theme_constant_override("separation", UITheme.Spacing.SMALL)

	# Título principal
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size",
		int(UITheme.Typography.TITLE_SMALL * UITheme.get_font_scale()))
	title_label.add_theme_color_override("font_color", UITheme.Colors.ACCENT)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_container.add_child(title_label)

	# Subtítulo opcional
	if subtitle != "":
		var subtitle_label = Label.new()
		subtitle_label.text = subtitle
		subtitle_label.add_theme_font_size_override("font_size",
			int(UITheme.Typography.BODY_SMALL * UITheme.get_font_scale()))
		subtitle_label.add_theme_color_override("font_color", UITheme.Colors.LIGHT)
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.modulate.a = 0.8
		header_container.add_child(subtitle_label)

	return header_container

## Crear panel de contenido estilizado
static func create_content_panel(min_height: int = 0) -> Panel:
	var panel = Panel.new()
	var style_box = StyleBoxFlat.new()

	# Aplicar colores del tema cervecería
	style_box.bg_color = UITheme.Colors.BG_CARD
	style_box.border_color = UITheme.Colors.SECONDARY

	# Esquinas redondeadas profesionales
	var radius = 12
	style_box.corner_radius_top_left = radius
	style_box.corner_radius_top_right = radius
	style_box.corner_radius_bottom_left = radius
	style_box.corner_radius_bottom_right = radius

	# Borde sutil
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2

	# Padding interno
	style_box.content_margin_left = UITheme.Spacing.MEDIUM
	style_box.content_margin_right = UITheme.Spacing.MEDIUM
	style_box.content_margin_top = UITheme.Spacing.MEDIUM
	style_box.content_margin_bottom = UITheme.Spacing.MEDIUM

	panel.add_theme_stylebox_override("panel", style_box)

	if min_height > 0:
		panel.custom_minimum_size.y = min_height

	return panel

## Crear botón principal estilizado
static func create_primary_button(text: String, size: String = "medium") -> Button:
	var button = Button.new()
	button.text = text

	# Aplicar estilo usando UITheme
	UITheme.apply_button_style(button, size)

	# Tamaño mínimo para touch
	if UITheme.is_mobile():
		button.custom_minimum_size.y = UITheme.Spacing.TOUCH_TARGET_MIN

	return button

## Crear separador visual profesional
static func create_section_separator() -> Control:
	var separator_container = VBoxContainer.new()

	# Espaciado antes
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size.y = UITheme.Spacing.MEDIUM
	separator_container.add_child(spacer_top)

	# Línea separadora
	var line = Panel.new()
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = UITheme.Colors.SECONDARY
	style_box.content_margin_top = 0
	style_box.content_margin_bottom = 0
	line.add_theme_stylebox_override("panel", style_box)
	line.custom_minimum_size.y = 2
	line.modulate.a = 0.3
	separator_container.add_child(line)

	# Espaciado después
	var spacer_bottom = Control.new()
	spacer_bottom.custom_minimum_size.y = UITheme.Spacing.MEDIUM
	separator_container.add_child(spacer_bottom)

	return separator_container

## 📊 COMPONENTES ESPECIALIZADOS

## Crear tarjeta de estadística
static func create_stats_card(title: String, value: String, icon: String = "") -> Panel:
	var card = create_content_panel(80)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", UITheme.Spacing.MEDIUM)
	card.add_child(hbox)

	# Icono opcional
	if icon != "":
		var icon_label = Label.new()
		icon_label.text = icon
		icon_label.add_theme_font_size_override("font_size",
			int(UITheme.Typography.TITLE_MEDIUM * UITheme.get_font_scale()))
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox.add_child(icon_label)

	# Contenido
	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(content_vbox)

	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size",
		int(UITheme.Typography.BODY_SMALL * UITheme.get_font_scale()))
	title_label.add_theme_color_override("font_color", UITheme.Colors.LIGHT)
	title_label.modulate.a = 0.8
	content_vbox.add_child(title_label)

	var value_label = Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size",
		int(UITheme.Typography.TITLE_SMALL * UITheme.get_font_scale()))
	value_label.add_theme_color_override("font_color", UITheme.Colors.ACCENT)
	content_vbox.add_child(value_label)

	return card

## Crear lista de elementos scrolleable
static func create_scrollable_list() -> ScrollContainer:
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size.y = 200
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Estilo de scroll
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	var list_container = VBoxContainer.new()
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_theme_constant_override("separation", UITheme.Spacing.SMALL)
	scroll.add_child(list_container)

	return scroll

## 🔧 UTILIDADES DE LAYOUT

## Limpiar contenedor de forma segura
static func clear_container(container: Node) -> void:
	if not container:
		return
	for child in container.get_children():
		child.queue_free()

## Crear espaciador flexible
static func create_spacer(size: int = 0) -> Control:
	var spacer = Control.new()
	if size > 0:
		spacer.custom_minimum_size.y = size
	else:
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return spacer

## Aplicar tema responsive a cualquier control
static func make_responsive(control: Control) -> void:
	if UITheme.is_small_screen():
		# Ajustar tamaños para pantalla pequeña
		if control.has_method("add_theme_constant_override"):
			control.add_theme_constant_override("separation", UITheme.Spacing.SMALL)

	if UITheme.is_mobile():
		# Asegurar targets de toque adecuados
		if control is Button:
			var button = control as Button
			if button.custom_minimum_size.y < UITheme.Spacing.TOUCH_TARGET_MIN:
				button.custom_minimum_size.y = UITheme.Spacing.TOUCH_TARGET_MIN

## 🎭 ANIMACIONES SUAVES

## Animar aparición de elemento
static func animate_fade_in(control: Control, duration: float = 0.3) -> void:
	control.modulate.a = 0.0
	var tween = control.create_tween()
	tween.tween_property(control, "modulate:a", 1.0, duration)
	tween.tween_callback(func(): print("✨ Animación fade-in completada"))

## Animar hover de botón
static func setup_button_hover(button: Button) -> void:
	var original_scale = button.scale

	button.mouse_entered.connect(func():
		var tween = button.create_tween()
		tween.tween_property(button, "scale", original_scale * 1.05,
			UITheme.Animations.TRANSITION_FAST)
	)

	button.mouse_exited.connect(func():
		var tween = button.create_tween()
		tween.tween_property(button, "scale", original_scale,
			UITheme.Animations.TRANSITION_FAST)
	)
