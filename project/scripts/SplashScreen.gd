extends Control
## SplashScreen - Pantalla de carga inicial del juego BAR-SIK
## Muestra el logo, barra de progreso y transiciona al menú principal

@onready var progress_bar: ProgressBar = $LoadingContainer/ProgressBar
@onready var loading_label: Label = $LoadingContainer/LoadingLabel

const SPLASH_DURATION = 3.0  # Duración mínima en segundos
var start_time: float

func _ready() -> void:
	print("🎬 SplashScreen iniciado")
	start_time = Time.get_ticks_msec() / 1000.0

	# Configurar barra de progreso
	if progress_bar:
		progress_bar.value = 0
		progress_bar.max_value = 100

	# Configurar etiqueta de carga
	if loading_label:
		loading_label.text = "Cargando..."

	# Iniciar simulación de carga
	_start_loading()

func _start_loading() -> void:
	# Crear timer para simular progreso de carga
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_update_loading)
	timer.wait_time = 0.1  # Actualizar cada 100ms
	timer.start()

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

# Función para debug - permitir saltar splash con clic
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("🔄 Saltando splash (debug)")
		Router.goto_scene("main_menu")
