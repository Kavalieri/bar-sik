extends RefCounted
class_name UIStyleManager
## UIStyleManager - Gestión centralizada de estilos (COMPATIBILIDAD)
## ⚠️ DEPRECADO: Usar UITheme + UIComponentsFactory para nuevos desarrollos


# Clase para colores (mantenida por compatibilidad)
class Colors:
	static var PRIMARY = UITheme.Colors.PRIMARY
	static var SECONDARY = UITheme.Colors.SECONDARY
	static var SUCCESS = UITheme.Colors.SUCCESS
	static var WARNING = UITheme.Colors.WARNING
	static var ERROR = UITheme.Colors.ERROR
	static var BACKGROUND = UITheme.Colors.BG_MAIN
	static var SURFACE = UITheme.Colors.BG_PANEL
	static var SURFACE_VARIANT = UITheme.Colors.BG_CARD
	static var OUTLINE = UITheme.Colors.SECONDARY
	static var TEXT_PRIMARY = UITheme.Colors.LIGHT
	static var TEXT_SECONDARY = Color(
		UITheme.Colors.LIGHT.r, UITheme.Colors.LIGHT.g, UITheme.Colors.LIGHT.b, 0.7
	)


# Instancia de colores accesible
static var COLORS = Colors

# Paleta de colores profesional para idle games (mantenemos compatibilidad)
static var colors = {
	"primary": Color(0.2, 0.6, 1.0),  # Azul primario
	"secondary": Color(0.7, 0.7, 0.7),  # Gris secundario
	"success": Color(0.2, 0.8, 0.2),  # Verde éxito
	"warning": Color(1.0, 0.8, 0.0),  # Amarillo advertencia
	"danger": Color(1.0, 0.3, 0.3),  # Rojo peligro
	"error": Color(1.0, 0.3, 0.3),  # Alias para danger (error)
	"background": Color(0.08, 0.08, 0.12),  # Fondo principal oscuro
	"card": Color(0.12, 0.12, 0.16),  # Fondo de tarjetas
	"surface": Color(0.16, 0.16, 0.20),  # Superficie elevada
	"surface_variant": Color(0.20, 0.20, 0.24),  # Superficie variante
	"outline": Color(0.3, 0.3, 0.3),  # Bordes y contornos
	"text_primary": Color(0.95, 0.95, 0.95),  # Texto principal
	"text_secondary": Color(0.7, 0.7, 0.7),  # Texto secundario
	"border": Color(0.3, 0.3, 0.3),  # Bordes suaves
	"accent": Color(0.8, 0.4, 1.0),  # Color de acento violeta
}

# Tamaños de fuente consistentes
static var font_sizes = {
	"title": 18,
	"subtitle": 16,
	"body": 14,
	"caption": 12,
	"small": 10,
}

# Espaciado consistente
static var spacing = {
	"xs": 4,
	"sm": 8,
	"md": 12,
	"lg": 16,
	"xl": 24,
}

# Radios de bordes
static var border_radius = {
	"small": 4,
	"medium": 8,
	"large": 12,
	"rounded": 16,
}


## Crear header de sección (MÉTODO PRINCIPAL - ACTUALIZADO)
static func create_section_header(title: String, subtitle: String = "") -> VBoxContainer:
	# Delegar al nuevo sistema UIComponentsFactory
	return UIComponentsFactory.create_section_header(title, subtitle)


## Crear panel estilizado (ACTUALIZADO)
static func create_styled_panel(style: String = "card") -> Panel:
	# Usar el nuevo sistema
	return UIComponentsFactory.create_content_panel()


## Método de compatibilidad para botones
static func create_primary_button(text: String) -> Button:
	return UIComponentsFactory.create_primary_button(text)


## Crear un botón estilizado
static func create_styled_button(text: String, style: String = "primary") -> Button:
	var button = Button.new()
	button.text = text

	var base_color: Color
	match style:
		"primary":
			base_color = colors.primary
		"success":
			base_color = colors.success
		"warning":
			base_color = colors.warning
		"danger":
			base_color = colors.danger
		"secondary":
			base_color = colors.secondary
		_:
			base_color = colors.primary

	# Estados del botón
	var style_normal = _create_button_style(base_color)
	var style_hover = _create_button_style(base_color.lightened(0.2))
	var style_pressed = _create_button_style(base_color.darkened(0.2))

	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_color_override("font_color", colors.text_primary)

	return button


## Crear un label estilizado
static func create_styled_label(text: String, style: String = "body") -> Label:
	var label = Label.new()
	label.text = text

	match style:
		"title":
			label.add_theme_font_size_override("font_size", font_sizes.title)
			label.add_theme_color_override("font_color", colors.text_primary)
		"subtitle":
			label.add_theme_font_size_override("font_size", font_sizes.subtitle)
			label.add_theme_color_override("font_color", colors.primary)
		"body":
			label.add_theme_font_size_override("font_size", font_sizes.body)
			label.add_theme_color_override("font_color", colors.text_primary)
		"caption":
			label.add_theme_font_size_override("font_size", font_sizes.caption)
			label.add_theme_color_override("font_color", colors.text_secondary)
		"small":
			label.add_theme_font_size_override("font_size", font_sizes.small)
			label.add_theme_color_override("font_color", colors.text_secondary)
		_:
			label.add_theme_color_override("font_color", colors.text_primary)

	return label


## Función privada para crear estilos de botón
static func _create_button_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = border_radius.small
	style.corner_radius_top_right = border_radius.small
	style.corner_radius_bottom_left = border_radius.small
	style.corner_radius_bottom_right = border_radius.small
	style.content_margin_left = spacing.md
	style.content_margin_right = spacing.md
	style.content_margin_top = spacing.sm
	style.content_margin_bottom = spacing.sm
	return style


## Aplicar tema oscuro profesional a un Control
static func apply_professional_theme(control: Control) -> void:
	# Aplicar colores base
	control.modulate = Color.WHITE

	# Si es un panel principal, aplicar fondo
	if control is Panel:
		var style = StyleBoxFlat.new()
		style.bg_color = colors.background
		control.add_theme_stylebox_override("panel", style)
