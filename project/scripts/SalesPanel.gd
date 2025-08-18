extends ScrollContainer
## SalesPanel - Panel de ventas manuales y estadísticas
## Permite vender productos e ingredientes por cantidades específicas

# Señales para comunicación con GameScene
signal item_sell_requested(item_type: String, item_name: String, quantity: int)
# item_type será "product" o "ingredient"

@onready var products_container: VBoxContainer = $MainContainer/SalesSection/ProductsContainer
@onready var ingredients_container: VBoxContainer = $MainContainer/SalesSection/IngredientsContainer
@onready var stats_container: VBoxContainer = $MainContainer/StatisticsSection/StatsContainer

# Variables de UI
var stats_labels: Array[Label] = []
var product_sell_buttons: Dictionary = {}
var ingredient_sell_buttons: Dictionary = {}


func _ready() -> void:
	print("💰 SalesPanel inicializado")
	print("🔍 Verificando nodos:")
	print("   - products_container: ", products_container)
	print("   - ingredients_container: ", ingredients_container)
	print("   - stats_container: ", stats_container)
	_setup_ui()


func _setup_ui() -> void:
	# Crear labels para estadísticas
	_setup_statistics()


func _setup_statistics() -> void:
	# Crear labels para las estadísticas principales
	var stat_names = [
		"💰 Dinero total ganado: $0",
		"🌾 Recursos generados: 0",
		"🍺 Productos fabricados: 0",
		"💸 Productos vendidos: 0",
		"👥 Clientes atendidos: 0"
	]

	for stat_text in stat_names:
		var label = Label.new()
		label.text = stat_text
		stats_container.add_child(label)
		stats_labels.append(label)


func create_sell_interface_for_item(
	item_name: String,
	item_type: String,
	quantity: int,
	price: float
) -> void:
	if quantity <= 0:
		print("❌ No se crea interfaz para %s - cantidad: %d" % [item_name, quantity])
		return

	print("🔧 Creando interfaz para: %s (%s) - cantidad: %d" % [item_name, item_type, quantity])

	var container = ingredients_container if item_type == "ingredient" else products_container
	print("📦 Usando contenedor: ", container)

	if not container:
		print("❌ ERROR: Contenedor no encontrado para %s" % item_type)
		return

	# Crear contenedor horizontal para cada ítem
	var item_container = HBoxContainer.new()
	container.add_child(item_container)

	# Label con información del ítem
	var info_label = Label.new()
	var emoji = GameUtils.get_item_emoji(item_name)
	info_label.text = "%s %s: %d ($%.2f c/u)" % [emoji, item_name.capitalize(), quantity, price]
	info_label.custom_minimum_size = Vector2(200, 0)
	item_container.add_child(info_label)

	# Botones de venta por incrementos
	var increments = [1, 5, 10, "MAX"]
	for increment in increments:
		var button = Button.new()
		var sell_quantity: int
		var is_max_button: bool = false

		# Verificar si es el botón MAX usando str()
		if str(increment) == "MAX":
			is_max_button = true
			sell_quantity = quantity
			button.text = "Vender Todo (%d)" % quantity
		else:
			sell_quantity = increment as int
			button.text = "Vender %d" % increment

		# Deshabilitar si no hay suficiente cantidad
		if not is_max_button and (increment as int) > quantity:
			button.disabled = true

		# Hacer los botones más visibles
		button.custom_minimum_size = Vector2(80, 30)

		button.pressed.connect(func(): _on_sell_button_pressed(item_name, item_type, sell_quantity))
		item_container.add_child(button)


func _on_sell_button_pressed(item_name: String, item_type: String, quantity: int) -> void:
	print("🔥 BOTÓN DE VENTA PRESIONADO:")
	print("   - Item: %s (%s)" % [item_name, item_type])
	print("   - Cantidad: %d" % quantity)
	print("   - Emitiendo señal item_sell_requested...")
	
	# VERIFICAR CONEXIONES DE LA SEÑAL
	var connections = item_sell_requested.get_connections()
	print("   - Señal tiene %d conexiones: %s" % [connections.size(), connections])
	
	item_sell_requested.emit(item_type, item_name, quantity)
	print("   - ✅ Señal emitida")
	
	# FORZAR ACTUALIZACIÓN INMEDIATA PARA DEBUGGING
	await get_tree().process_frame
	print("   - 🔄 Frame procesado, esperando actualización...")


func update_sell_interfaces(game_data: Dictionary) -> void:
	# Limpiar interfaces existentes
	_clear_sell_interfaces()

	print("🔍 SalesPanel - Actualizando interfaces de venta")
	print("📦 Productos disponibles: ", game_data["products"])
	print("🌾 Recursos disponibles: ", game_data["resources"])

	# FORZAR CREACIÓN DE INTERFACES BÁSICAS PARA TESTING
	# Crear al menos una interfaz de prueba para productos
	if not game_data["products"].is_empty():
		print("🎯 CREANDO INTERFACES DE PRODUCTOS...")
		for product_name in game_data["products"].keys():
			var quantity = int(game_data["products"][product_name])  # Forzar int
			if quantity > 0:
				var price = GameUtils.get_product_price(product_name)
				create_sell_interface_for_item(product_name, "product", quantity, price)
	else:
		# Crear interfaz de prueba forzada
		print("⚠️ No hay productos, creando interfaz de prueba")
		create_sell_interface_for_item("basic_beer", "product", 1, 5.0)

	# Crear interfaces para ingredientes (excepto agua)
	print("🌾 CREANDO INTERFACES DE INGREDIENTES...")
	var ingredients_created = 0
	for ingredient_name in game_data["resources"].keys():
		var quantity = int(game_data["resources"][ingredient_name])  # Forzar int
		if quantity > 0 and ingredient_name != "water":
			var price = GameUtils.get_ingredient_price(ingredient_name)
			create_sell_interface_for_item(ingredient_name, "ingredient", quantity, price)
			ingredients_created += 1
			print("✅ Ingrediente creado: %s (cantidad: %d)" % [ingredient_name, quantity])

	# Si no hay ingredientes, crear al menos uno de prueba
	if ingredients_created == 0:
		print("⚠️ No hay ingredientes, creando interfaz de prueba")
		create_sell_interface_for_item("barley", "ingredient", 5, 0.5)


func _clear_sell_interfaces() -> void:
	# Limpiar contenedores (excepto labels)
	for child in products_container.get_children():
		if child.name != "ProductsLabel":
			child.queue_free()

	for child in ingredients_container.get_children():
		if child.name != "IngredientsLabel":
			child.queue_free()


func update_statistics(game_data: Dictionary) -> void:
	var stats = game_data["statistics"]
	if stats_labels.size() >= 5:
		stats_labels[0].text = "💰 Dinero total ganado: $%.2f" % stats.get("total_money_earned", 0)
		stats_labels[1].text = "🌾 Recursos generados: %d" % stats.get("resources_generated", 0)
		stats_labels[2].text = "🍺 Productos fabricados: %d" % stats.get("products_crafted", 0)
		stats_labels[3].text = "💸 Productos vendidos: %d" % stats.get("products_sold", 0)
		stats_labels[4].text = "👥 Clientes atendidos: %d" % stats.get("customers_served", 0)
