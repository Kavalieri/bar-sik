extends Control
class_name OffersScene
## OffersScene - Sistema de ofertas especiales y promociones temporales
## Ofertas diarias, semanales y eventos especiales

@onready var back_button: Button = $MainContainer/Header/BackButton
@onready var timer_label: Label = $MainContainer/Header/TimerLabel
@onready var daily_offers_list: GridContainer = $MainContainer/OffersContainer/DailyOffers/DailyOffersList
@onready var weekly_offers_list: GridContainer = $MainContainer/OffersContainer/WeeklyOffers/WeeklyOffersList
@onready var special_offers_list: VBoxContainer = $MainContainer/OffersContainer/SpecialOffers/SpecialOffersList

# Datos del juego
var game_data: GameData

# Sistema de ofertas
var daily_offers: Array = []
var weekly_offers: Array = []
var special_offers: Array = []

# Timer para ofertas
var offer_timer: Timer

# Señales
signal offers_closed
signal offer_claimed(offer_type: String, offer_id: String, reward: Dictionary)

func _ready() -> void:
	print_rich("[color=yellow]🎁 OffersScene._ready() iniciado[/color]")

	# Aplicar temas
	_apply_theme_styling()

	# Configurar timer
	_setup_offer_timer()

	# Conectar señales
	back_button.pressed.connect(_on_back_pressed)

	# Generar ofertas
	_generate_daily_offers()
	_generate_weekly_offers()
	_generate_special_offers()

	print_rich("[color=green]✅ OffersScene listo[/color]")

func _apply_theme_styling() -> void:
	# Aplicar estilos coherentes
	UITheme.apply_button_style(back_button, "medium")
	UITheme.apply_label_style($MainContainer/Header/TitleLabel, "title_medium")
	UITheme.apply_label_style(timer_label, "body_large")

func _setup_offer_timer() -> void:
	offer_timer = Timer.new()
	offer_timer.wait_time = 1.0  # Actualizar cada segundo
	offer_timer.autostart = true
	offer_timer.timeout.connect(_update_timer_display)
	add_child(offer_timer)

func _update_timer_display() -> void:
	# Calcular tiempo hasta medianoche para ofertas diarias
	var time = Time.get_datetime_dict_from_system()
	var seconds_until_midnight = (24 - time.hour) * 3600 + (60 - time.minute) * 60 + (60 - time.second)

	var hours = seconds_until_midnight / 3600
	var minutes = (seconds_until_midnight % 3600) / 60
	var seconds = seconds_until_midnight % 60

	timer_label.text = "⏰ %02d:%02d:%02d" % [hours, minutes, seconds]

func _generate_daily_offers() -> void:
	# Ofertas que cambian cada día
	daily_offers = [
		{
			"title": "💰 Dinero Extra",
			"description": "Bonus de $500 gratis",
			"reward": {"money": 500},
			"type": "daily_money"
		},
		{
			"title": "⚡ Boost Temporal",
			"description": "x2 velocidad por 30min",
			"reward": {"speed_multiplier": 2.0, "duration": 1800},
			"type": "daily_boost"
		}
	]

	_populate_offers_list(daily_offers_list, daily_offers, "daily")

func _generate_weekly_offers() -> void:
	# Ofertas que cambian cada semana
	weekly_offers = [
		{
			"title": "🎁 Pack Iniciación",
			"description": "3 generadores básicos",
			"reward": {"generators": {"water_collector": 1, "barley_farm": 1, "hops_farm": 1}},
			"type": "weekly_starter"
		}
	]

	_populate_offers_list(weekly_offers_list, weekly_offers, "weekly")

func _generate_special_offers() -> void:
	# Ofertas especiales por eventos
	special_offers = [
		{
			"title": "⭐ Oferta Lanzamiento",
			"description": "50% descuento en todo",
			"reward": {"discount": 0.5},
			"type": "launch_special"
		}
	]

	_populate_offers_list(special_offers_list, special_offers, "special")

func _populate_offers_list(container: Control, offers: Array, offer_type: String) -> void:
	for offer in offers:
		_create_offer_card(container, offer, offer_type)

func _create_offer_card(parent: Control, offer: Dictionary, offer_type: String) -> void:
	# Crear card de oferta
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)

	var card_content = HBoxContainer.new()
	card.add_child(card_content)

	# Info de la oferta
	var info_container = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_content.add_child(info_container)

	var title_label = Label.new()
	title_label.text = offer.title
	UITheme.apply_label_style(title_label, "body_large")
	info_container.add_child(title_label)

	var desc_label = Label.new()
	desc_label.text = offer.description
	UITheme.apply_label_style(desc_label, "body_small")
	info_container.add_child(desc_label)

	# Botón reclamar
	var claim_button = Button.new()
	claim_button.text = "🎁 RECLAMAR"
	claim_button.custom_minimum_size = Vector2(120, 60)
	UITheme.apply_button_style(claim_button, "medium")
	claim_button.pressed.connect(_on_offer_claim.bind(offer_type, offer.type, offer.reward))
	card_content.add_child(claim_button)

	parent.add_child(card)

func _on_offer_claim(offer_type: String, offer_id: String, reward: Dictionary) -> void:
	offer_claimed.emit(offer_type, offer_id, reward)
	print_rich("[color=green]🎁 Oferta reclamada: %s[/color]" % offer_id)

func _on_back_pressed() -> void:
	offers_closed.emit()
	print_rich("[color=cyan]🔙 Saliendo de ofertas[/color]")
