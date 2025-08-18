extends Button
## BeverageButton - Botón especializado para bebidas del juego idle
## Muestra información de la bebida, cantidad y permite crearla

# class_name BeverageButton  # Comentado temporalmente para evitar conflictos

@export var beverage_type: String = ""
@export var show_quantity: bool = true
@export var show_ingredients: bool = false

@onready var beverage_icon: Label = $HBoxContainer/BeverageIcon
@onready var beverage_info: VBoxContainer = $HBoxContainer/BeverageInfo
@onready var beverage_name_label: Label = $HBoxContainer/BeverageInfo/BeverageName
@onready var quantity_label: Label = $HBoxContainer/BeverageInfo/QuantityLabel
@onready var ingredients_label: Label = $HBoxContainer/BeverageInfo/IngredientsLabel

signal beverage_clicked(beverage_type: String)

var current_quantity: float = 0.0

func _ready() -> void:
    pressed.connect(_on_pressed)

    if beverage_type != "":
        setup_beverage(beverage_type)

func setup_beverage(type: String) -> void:
    beverage_type = type

    # Configurar icono y nombre basado en el tipo
    match beverage_type:
        "lemonade":
            beverage_icon.text = "🍋"
            beverage_name_label.text = "Limonada"
        "iced_water":
            beverage_icon.text = "🧊"
            beverage_name_label.text = "Agua Fría"
        "cocktail":
            beverage_icon.text = "🍹"
            beverage_name_label.text = "Cóctel"
        "coffee":
            beverage_icon.text = "☕"
            beverage_name_label.text = "Café"
        _:
            beverage_icon.text = "🥤"
            beverage_name_label.text = "Bebida"

    update_display()

func update_display() -> void:
    if !is_node_ready():
        return

    # Para componente UI, usar datos placeholder por ahora
    if show_quantity:
        current_quantity = 0.0  # Placeholder
        quantity_label.text = str(int(current_quantity)) + " disponibles"
        quantity_label.visible = true
    else:
        quantity_label.visible = false

    if show_ingredients:
        ingredients_label.text = "Necesita ingredientes"
        ingredients_label.visible = true
    else:
        ingredients_label.visible = false

func _on_pressed() -> void:
    print("🥤 Bebida clickeada: ", beverage_type)
    beverage_clicked.emit(beverage_type)

    # Efecto visual del click
    _play_click_effect()

func _play_click_effect() -> void:
    var tween = create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BOUNCE)

    scale = Vector2(0.9, 0.9)
    tween.tween_property(self, "scale", Vector2.ONE, 0.2)
