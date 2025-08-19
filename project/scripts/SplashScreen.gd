extends Control
## SplashScreen - Pantalla de carga inicial del juego BAR-SIK
## Versión responsive con sistema de temas coherente

@onready var logo_label: Label = $MainContainer/LogoContainer/LogoLabel
@onready var subtitle_label: Label = $MainContainer/LogoContainer/SubtitleLabel
@onready var version_label: Label = $MainContainer/LogoContainer/VersionLabel
@onready var progress_bar: ProgressBar = $MainContainer/LoadingContainer/ProgressBar
@onready var loading_label: Label = $MainContainer/LoadingContainer/LoadingLabel
@onready var loading_tip: Label = $MainContainer/LoadingContainer/LoadingTip

const SPLASH_DURATION = 3.0  # Duración mínima en segundos
var start_time: float
var loading_tips: Array = [
	"💡 Prepara tu bar para los clientes...",
	"🍺 La cerveza perfecta requiere paciencia...",
	"⚙️ Automatiza la producción para mejores resultados...",
	"💰 Gestiona bien tus recursos para crecer...",
	"👥 Cada cliente tiene preferencias únicas..."
]

func _ready() -> void:
	print_rich("[color=yellow]🎬 SplashScreen iniciado - Versión responsive[/color]")
	start_time = Time.get_ticks_msec() / 1000.0

	# Aplicar sistema de temas
	_apply_responsive_styling()

	# Configurar elementos
	_setup_loading_elements()

	# Iniciar simulación de carga
	_start_loading()

func _apply_responsive_styling() -> void:
	"""Aplicar estilos del sistema de temas coherente"""
	var font_scale = UITheme.get_font_scale()

	if logo_label:
		logo_label.add_theme_font_size_override("font_size",
			int(UITheme.Typography.TITLE_LARGE * font_scale))
		logo_label.add_theme_color_override("font_color", UITheme.Colors.ACCENT)

	if subtitle_label:
		subtitle_label.add_theme_font_size_override("font_size",
			int(UITheme.Typography.TITLE_SMALL * font_scale))
		subtitle_label.add_theme_color_override("font_color", UITheme.Colors.LIGHT)

	if version_label:
		version_label.add_theme_font_size_override("font_size",
			int(UITheme.Typography.BODY_SMALL * font_scale))
		version_label.add_theme_color_override("font_color", UITheme.Colors.SECONDARY)

	if loading_label:
		loading_label.add_theme_font_size_override("font_size",
			int(UITheme.Typography.BODY_MEDIUM * font_scale))
		loading_label.add_theme_color_override("font_color", UITheme.Colors.LIGHT)

	if loading_tip:
		loading_tip.add_theme_font_size_override("font_size",
			int(UITheme.Typography.BODY_SMALL * font_scale))
		loading_tip.add_theme_color_override("font_color", UITheme.Colors.SECONDARY)

func _setup_loading_elements() -> void:
	"""Configurar elementos de carga"""
	# Configurar barra de progreso inicial
	if progress_bar:
		progress_bar.value = 0.0
		progress_bar.max_value = 100.0

	# Mostrar tip de carga aleatorio
	if loading_tip and loading_tips.size() > 0:
		loading_tip.text = loading_tips[randi() % loading_tips.size()]

func _start_loading() -> void:
	"""Iniciar proceso de carga con timer"""
	# Registrar tiempo de inicio
	start_time = Time.get_ticks_msec() / 1000.0

	# Crear timer para simular progreso de carga
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_update_loading)
	timer.wait_time = 0.1  # Actualizar cada 100ms
	timer.start()

	print("⏳ SplashScreen: Iniciando carga...")


func _update_loading() -> void:
	if progress_bar:
		progress_bar.value += 2.0  # Incrementar 2% cada update

		# Si llegamos al 100%, terminar carga
		if progress_bar.value >= 100:
			_finish_loading()


func _finish_loading() -> void:
	print("✅ Carga completada - Transicionando al menú principal")

	# Calcular tiempo transcurrido
	var elapsed = (Time.get_ticks_msec() / 1000.0) - start_time

	# Si no hemos alcanzado el tiempo mínimo, esperar
	if elapsed < SPLASH_DURATION:
		if loading_label:
			loading_label.text = "¡Listo!"
		await get_tree().create_timer(SPLASH_DURATION - elapsed).timeout

	# Cambiar al menú principal
	Router.goto_scene("main_menu")


# Función para debug - permitir saltar splash con clic (DESACTIVADA)
# func _input(event: InputEvent) -> void:
#	if event is InputEventMouseButton and event.pressed:
#		print("🔄 Saltando splash (debug)")
#		Router.goto_scene("main_menu")
