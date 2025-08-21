class_name GamePanel
extends BasePanel
## GamePanel - Panel especializado para lógica de juego
## Elimina duplicación entre ProductionPanel, GenerationPanel, SalesPanel

# Señales específicas de juego (estandarizadas)
signal item_purchased(item_id: String, quantity: int)
signal item_produced(item_id: String, quantity: int)
signal multiplier_changed(item_id: String, new_multiplier: int)

# Propiedades comunes de juego - ELIMINA DUPLICACIÓN
var game_data: Dictionary = {}
var multiplier_sequence: Array[int] = [1, 5, 10, 25]

func initialize_specific_content():
    """Inicialización específica de GamePanel"""
    super.initialize_specific_content()
    setup_game_layout()
    load_initial_game_data()

func setup_game_layout():
    """Layout específico para paneles de juego"""
    create_game_sections()
    setup_multiplier_system()

# === CREACIÓN ESTANDARIZADA DE ELEMENTOS ===

func create_game_item_panel(item_id: String, item_data: Dictionary, panel_type: String = "generic") -> Panel:
    """Panel estandarizado para items - ELIMINA DUPLICACIÓN MASIVA"""
    var panel = Panel.new()
    panel.custom_minimum_size = Vector2(200, 120)
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    var vbox = VBoxContainer.new()
    vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    vbox.add_theme_constant_override("separation", 8)
    vbox.add_theme_constant_override("margin_left", 12)
    vbox.add_theme_constant_override("margin_right", 12)
    vbox.add_theme_constant_override("margin_top", 12)
    vbox.add_theme_constant_override("margin_bottom", 12)
    
    # Título del item (patrón estándar)
    var title = create_item_title(item_data)
    vbox.add_child(title)
    
    # Información del item
    var info = create_item_info(item_id, item_data, panel_type)
    vbox.add_child(info)
    
    # Botones de acción
    var buttons_container = create_item_buttons(item_id, panel_type)
    vbox.add_child(buttons_container)
    
    panel.add_child(vbox)
    return panel

func create_item_title(item_data: Dictionary) -> Label:
    """Título estandarizado - ELIMINA DUPLICACIÓN DE LABELS"""
    var title_label = Label.new()
    title_label.text = "%s %s" % [item_data.get("emoji", "❓"), item_data.get("name", "Unknown")]
    title_label.add_theme_font_size_override("font_size", 18)
    title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    return title_label

func create_item_info(item_id: String, item_data: Dictionary, panel_type: String) -> Label:
    """Info estandarizada - ELIMINA DUPLICACIÓN DE INFO LABELS"""
    var info_label = Label.new()
    info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    info_label.add_theme_font_size_override("font_size", 14)
    info_label.name = "info_label_" + item_id
    
    # Texto específico según tipo de panel
    match panel_type:
        "production":
            info_label.text = get_station_info_text(item_id, item_data)
        "generation":
            info_label.text = get_generator_info_text(item_id, item_data)
        "sales":
            info_label.text = get_product_info_text(item_id, item_data)
        _:
            info_label.text = "Cantidad: 0"
    
    return info_label

func create_item_buttons(item_id: String, panel_type: String) -> HBoxContainer:
    """Botones estandarizados - ELIMINA DUPLICACIÓN MASIVA DE BOTONES"""
    var hbox = HBoxContainer.new()
    hbox.add_theme_constant_override("separation", 8)
    hbox.alignment = BoxContainer.ALIGNMENT_CENTER
    
    # Botón principal (comprar/producir)
    var main_button = create_standard_button("COMPRAR", Vector2(100, 40))
    main_button.name = "main_button_" + item_id
    main_button.pressed.connect(_on_main_button_pressed.bind(item_id))
    
    # Botón multiplicador
    var mult_button = create_standard_button("x1", Vector2(60, 40))
    mult_button.name = "multiplier_button_" + item_id
    mult_button.pressed.connect(_on_multiplier_button_pressed.bind(item_id))
    
    hbox.add_child(main_button)
    hbox.add_child(mult_button)
    
    # Guardar estado del botón - PATRÓN ESTANDARIZADO
    button_states[item_id] = {
        "main_button": main_button,
        "multiplier_button": mult_button,
        "info_label": null,  # Se asigna después
        "multiplier": 1,
        "item_id": item_id,
        "panel_type": panel_type
    }
    
    return hbox

# === LÓGICA DE MULTIPLICADORES (ANTI-DUPLICACIÓN) ===

func _on_multiplier_button_pressed(item_id: String):
    """Manejador estándar de multiplicadores - ELIMINA DUPLICACIÓN"""
    if update_in_progress or not button_states.has(item_id):
        return
    
    cycle_multiplier(item_id)

func cycle_multiplier(item_id: String):
    """Ciclar multiplicador - PATRÓN ESTANDARIZADO"""
    var state = button_states[item_id]
    var current_idx = multiplier_sequence.find(state.multiplier)
    var next_idx = (current_idx + 1) % multiplier_sequence.size()
    var new_multiplier = multiplier_sequence[next_idx]
    
    state.multiplier = new_multiplier
    state.multiplier_button.text = "x%d" % new_multiplier
    
    multiplier_changed.emit(item_id, new_multiplier)
    print("🔢 Multiplicador cambiado para %s: x%d" % [item_id, new_multiplier])

# === MÉTODOS VIRTUALES PARA OVERRIDE ===

func _on_main_button_pressed(item_id: String):
    """Override: Lógica específica del botón principal"""
    pass

func get_station_info_text(item_id: String, item_data: Dictionary) -> String:
    """Override: Texto de info para estaciones"""
    return "Poseído: 0 | Costo: 100"

func get_generator_info_text(item_id: String, item_data: Dictionary) -> String:
    """Override: Texto de info para generadores"""  
    return "Cantidad: 0 | Costo: 50"

func get_product_info_text(item_id: String, item_data: Dictionary) -> String:
    """Override: Texto de info para productos"""
    return "Stock: 0"

# === UTILIDADES DE JUEGO ===

func load_initial_game_data():
    """Cargar datos iniciales de juego"""
    game_data = get_current_game_data()

func refresh_all_displays():
    """Refrescar todos los displays - MÉTODO ESTANDARIZADO"""
    if update_in_progress:
        return
    
    update_in_progress = true
    game_data = get_current_game_data()
    
    for item_id in button_states.keys():
        update_item_display(item_id)
    
    update_in_progress = false

func update_item_display(item_id: String):
    """Actualizar display de un item específico - PATRÓN ESTANDARIZADO"""
    if not button_states.has(item_id):
        return
    
    var state = button_states[item_id]
    # Implementar en clases hijas según necesidades específicas
