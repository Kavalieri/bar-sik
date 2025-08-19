extends Control
class_name ShopScene
## ShopScene - Tienda del juego para comprar generadores, mejoras y equipamiento
## Diseño responsive y coherente con el sistema de temas

@onready var back_button: Button = $MainContainer/Header/BackButton
@onready var money_label: Label = $MainContainer/Header/MoneyLabel
@onready var tab_container: TabContainer = $MainContainer/TabContainer

# Referencias a las listas de elementos
@onready var generators_list: VBoxContainer = $MainContainer/TabContainer/Generadores/GeneratorsList
@onready var upgrades_list: VBoxContainer = $MainContainer/TabContainer/Mejoras/UpgradesList
@onready var equipment_list: VBoxContainer = $MainContainer/TabContainer/Equipamiento/EquipmentList
@onready var recipes_list: VBoxContainer = $MainContainer/TabContainer/Recetas/RecipesList

# Datos del juego
var game_data: GameData

# Señales
signal shop_closed
signal item_purchased(item_type: String, item_id: String, cost: float)

func _ready() -> void:
	print_rich("[color=yellow]🛒 ShopScene._ready() iniciado[/color]")

	# Aplicar temas
	_apply_theme_styling()

	# Conectar señales
	back_button.pressed.connect(_on_back_pressed)

	# Cargar contenido de la tienda
	_setup_shop_content()

	print_rich("[color=green]✅ ShopScene listo[/color]")

func _apply_theme_styling() -> void:
	# Aplicar estilos del sistema de temas
	UITheme.apply_button_style(back_button, "medium")
	UITheme.apply_label_style($MainContainer/Header/TitleLabel, "title_medium")
	UITheme.apply_label_style(money_label, "body_large")

func set_game_data(data: GameData) -> void:
	game_data = data
	_update_money_display()

func _update_money_display() -> void:
	if game_data and money_label:
		money_label.text = "💰 $%.0f" % game_data.money

func _setup_shop_content() -> void:
	# Configurar contenido de cada tab
	_setup_generators_tab()
	_setup_upgrades_tab()
	_setup_equipment_tab()
	_setup_recipes_tab()

func _setup_generators_tab() -> void:
	# Crear botones para generadores disponibles
	_create_shop_item(generators_list, "🚰 Recolector de Agua", "Genera agua automáticamente", 100, "generator", "water_collector")
	_create_shop_item(generators_list, "🌾 Granja de Cebada", "Produce cebada constantemente", 250, "generator", "barley_farm")
	_create_shop_item(generators_list, "🌿 Cultivo de Lúpulo", "Cultiva lúpulo premium", 500, "generator", "hops_farm")

func _setup_upgrades_tab() -> void:
	# Crear mejoras disponibles
	_create_shop_item(upgrades_list, "⚡ Velocidad +25%", "Aumenta velocidad de generación", 200, "upgrade", "speed_boost_1")
	_create_shop_item(upgrades_list, "💧 Eficiencia +50%", "Reduce consumo de recursos", 400, "upgrade", "efficiency_1")
	_create_shop_item(upgrades_list, "🎯 Calidad Premium", "Mejora calidad de productos", 800, "upgrade", "quality_boost")

func _setup_equipment_tab() -> void:
	# Crear equipamiento disponible
	_create_shop_item(equipment_list, "🍺 Barril Grande", "Aumenta capacidad +100", 300, "equipment", "large_barrel")
	_create_shop_item(equipment_list, "⚗️ Destiladora Pro", "Permite cócteles premium", 600, "equipment", "pro_distiller")
	_create_shop_item(equipment_list, "❄️ Sistema de Frío", "Mantiene calidad perfecta", 1000, "equipment", "cooling_system")

func _setup_recipes_tab() -> void:
	# Crear recetas disponibles
	_create_shop_item(recipes_list, "🍺 Cerveza Premium", "Receta de cerveza artesanal", 150, "recipe", "premium_beer")
	_create_shop_item(recipes_list, "🍸 Cóctel Especial", "Bebida mixta premium", 300, "recipe", "special_cocktail")
	_create_shop_item(recipes_list, "🥃 Whisky de Casa", "Destilado exclusivo", 750, "recipe", "house_whisky")

func _create_shop_item(parent: VBoxContainer, title: String, description: String, cost: float, item_type: String, item_id: String) -> void:
	# Crear contenedor del item
	var item_container = HBoxContainer.new()
	parent.add_child(item_container)

	# Info del item
	var info_container = VBoxContainer.new()
	info_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_container.add_child(info_container)

	var title_label = Label.new()
	title_label.text = title
	UITheme.apply_label_style(title_label, "body_large")
	info_container.add_child(title_label)

	var desc_label = Label.new()
	desc_label.text = description
	UITheme.apply_label_style(desc_label, "body_small")
	info_container.add_child(desc_label)

	# Botón de compra
	var buy_button = Button.new()
	buy_button.text = "💰 $%.0f" % cost
	buy_button.custom_minimum_size = Vector2(120, 50)
	UITheme.apply_button_style(buy_button, "medium")
	buy_button.pressed.connect(_on_item_purchase.bind(item_type, item_id, cost))
	item_container.add_child(buy_button)

	# Separador
	var separator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 10)
	parent.add_child(separator)

func _on_item_purchase(item_type: String, item_id: String, cost: float) -> void:
	if game_data and game_data.money >= cost:
		item_purchased.emit(item_type, item_id, cost)
		print_rich("[color=green]💰 Comprado: %s por $%.0f[/color]" % [item_id, cost])
	else:
		print_rich("[color=red]❌ Dinero insuficiente para %s ($%.0f)[/color]" % [item_id, cost])

func _on_back_pressed() -> void:
	shop_closed.emit()
	print_rich("[color=cyan]🔙 Saliendo de la tienda[/color]")
