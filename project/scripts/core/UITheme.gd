extends Node
## UITheme - Sistema centralizado de temas para coherencia visual (SINGLETON)
## Define todos los estilos, colores y medidas del juego

## 🎨 PALETA DE COLORES CERVECERÍA PROFESIONAL
class Colors:
	# Colores principales
	const PRIMARY = Color(0.545, 0.271, 0.075)      # #8B4513 Saddle Brown (Madera bar)
	const SECONDARY = Color(0.824, 0.412, 0.118)    # #D2691E Chocolate (Cobre/Latón)
	const ACCENT = Color(1.0, 0.843, 0.0)           # #FFD700 Gold (Cerveza/Oro)

	# Colores base
	const DARK = Color(0.184, 0.106, 0.078)         # #2F1B14 Dark Brown (Sombras)
	const LIGHT = Color(0.961, 0.871, 0.702)       # #F5DEB3 Wheat (Backgrounds claros)

	# Estados
	const SUCCESS = Color(0.133, 0.545, 0.133)      # #228B22 Forest Green
	const ERROR = Color(0.863, 0.078, 0.235)       # #DC143C Crimson
	const WARNING = Color(1.0, 0.647, 0.0)         # #FFA500 Orange

	# UI Estados
	const BUTTON_NORMAL = PRIMARY
	const BUTTON_HOVER = SECONDARY
	const BUTTON_PRESSED = DARK
	const BUTTON_DISABLED = Color(0.5, 0.5, 0.5, 0.5)

	# Backgrounds
	const BG_MAIN = DARK
	const BG_PANEL = Color(LIGHT.r, LIGHT.g, LIGHT.b, 0.1)
	const BG_CARD = Color(LIGHT.r, LIGHT.g, LIGHT.b, 0.05)

## 📝 TIPOGRAFÍA RESPONSIVE
class Typography:
	# Headers principales
	const TITLE_LARGE = 56      # Títulos principales (+8)
	const TITLE_MEDIUM = 40     # Subtítulos (+8)
	const TITLE_SMALL = 32      # Headers de sección (+8)

	# Contenido
	const BODY_LARGE = 24       # Texto importante (+6)
	const BODY_MEDIUM = 20      # Texto normal (+4)
	const BODY_SMALL = 18       # Texto secundario (+4)

	# UI Elements
	const BUTTON_LARGE = 24     # Botones principales (+6)
	const BUTTON_MEDIUM = 20    # Botones normales (+4)
	const BUTTON_SMALL = 18     # Botones pequeños (+4)

	# Incremento móvil
	const MOBILE_SCALE = 1.4    # +40% en móvil (era 1.2)

## 📏 MEDIDAS Y ESPACIADO
class Spacing:
	# Espaciado básico
	const TINY = 6
	const SMALL = 12
	const MEDIUM = 20
	const LARGE = 32
	const EXTRA_LARGE = 40

	# Tamaños de botones para móvil
	const BUTTON_HEIGHT_SMALL = 55    # +15
	const BUTTON_HEIGHT_MEDIUM = 70   # +20
	const BUTTON_HEIGHT_LARGE = 85    # +25

	# Mínimos para touch (aumentado)
	const TOUCH_TARGET_MIN = 60       # +16

	# Margins y paddings (aumentado)
	const MARGIN_SCREEN = 24          # +4
	const PADDING_PANEL = 20          # +4
	const PADDING_BUTTON = 16         # +4

## 🎭 ANIMACIONES Y TRANSICIONES
class Animations:
	const TRANSITION_FAST = 0.15
	const TRANSITION_NORMAL = 0.25
	const TRANSITION_SLOW = 0.4

	const EASE_IN_OUT = Tween.EASE_IN_OUT
	const EASE_OUT = Tween.EASE_OUT

## 📱 DETECCIÓN DE PLATAFORMA
static func is_mobile() -> bool:
	return OS.get_name() == "Android" or OS.get_name() == "iOS"

static func is_small_screen() -> bool:
	# Usar el tamaño de la ventana principal
	var window_size = DisplayServer.window_get_size()
	return window_size.x < 768

static func get_font_scale() -> float:
	return Typography.MOBILE_SCALE if is_mobile() else 1.0

## 🎨 FUNCIONES DE UTILIDAD PARA APLICAR TEMAS

static func apply_button_style(button: Button, size: String = "medium"):
	var font_size = Typography.BUTTON_MEDIUM
	var height = Spacing.BUTTON_HEIGHT_MEDIUM

	match size:
		"small":
			font_size = Typography.BUTTON_SMALL
			height = Spacing.BUTTON_HEIGHT_SMALL
		"large":
			font_size = Typography.BUTTON_LARGE
			height = Spacing.BUTTON_HEIGHT_LARGE

	# Aplicar escala móvil
	font_size = int(font_size * get_font_scale())

	button.custom_minimum_size.y = height

	# Crear StyleBox para estados
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Colors.BUTTON_NORMAL
	style_normal.corner_radius_top_left = 8
	style_normal.corner_radius_top_right = 8
	style_normal.corner_radius_bottom_left = 8
	style_normal.corner_radius_bottom_right = 8

	var style_hover = style_normal.duplicate()
	style_hover.bg_color = Colors.BUTTON_HOVER

	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = Colors.BUTTON_PRESSED

	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_font_size_override("font_size", font_size)

static func apply_label_style(label: Label, type: String = "body"):
	var font_size = Typography.BODY_MEDIUM

	match type:
		"title_large":
			font_size = Typography.TITLE_LARGE
		"title_medium":
			font_size = Typography.TITLE_MEDIUM
		"title_small":
			font_size = Typography.TITLE_SMALL
		"body_large":
			font_size = Typography.BODY_LARGE
		"body_small":
			font_size = Typography.BODY_SMALL

	# Aplicar escala móvil
	font_size = int(font_size * get_font_scale())
	label.add_theme_font_size_override("font_size", font_size)

static func apply_panel_background(control: Control):
	var style = StyleBoxFlat.new()
	style.bg_color = Colors.BG_PANEL
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12

	# Aplicar a diferentes tipos de control
	if control is Panel:
		control.add_theme_stylebox_override("panel", style)
	elif control is ColorRect:
		control.color = Colors.BG_PANEL
