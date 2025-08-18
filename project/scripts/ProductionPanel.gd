extends ScrollContainer
## ProductionPanel - Panel de estaciones de producción y crafteo
## Maneja las estaciones que se pueden comprar y usar para producir

@onready var product_container: VBoxContainer = $MainContainer/ProductsSection/ProductContainer
@onready var station_container: VBoxContainer = $MainContainer/StationsSection/StationContainer

# Variables de UI
var product_labels: Dictionary = {}
var station_interfaces: Array[Control] = []

# Señales para comunicación con GameScene
signal station_purchased(station_index: int)
signal manual_production_requested(station_index: int, quantity: int)
signal offer_toggled(station_index: int, enabled: bool)
signal offer_price_requested(station_index: int)


func _ready() -> void:
	print("🍺 ProductionPanel inicializado")
	print("🔍 Verificando nodos:")
	print("   - product_container: ", product_container)
	print("   - station_container: ", station_container)


func setup_products(game_data: Dictionary) -> void:
	# Limpiar contenido existente
	_clear_product_labels()

	# Crear labels para productos
	for product_name in game_data["products"].keys():
		var label = Label.new()
		product_labels[product_name] = label
		product_container.add_child(label)


func setup_stations(production_stations: Array[Dictionary]) -> void:
	# Limpiar interfaces existentes
	_clear_station_interfaces()

	print("🔧 ProductionPanel - Configurando %d estaciones" % production_stations.size())
	print("📦 Contenedor de estaciones: ", station_container)

	# Crear interfaces combinadas para cada estación (compra + producción)
	for i in range(production_stations.size()):
		print("🏗️ Creando interfaz para estación %d: %s" % [i, production_stations[i].name])
		_create_station_interface(production_stations[i], i)


func _create_station_interface(station: Dictionary, station_index: int) -> void:
	# Contenedor principal para esta estación
	var station_group = VBoxContainer.new()
	station_group.add_theme_constant_override("separation", 5)

	# Título de la estación
	var title_label = Label.new()
	title_label.text = station.name
	title_label.add_theme_font_size_override("font_size", 16)
	station_group.add_child(title_label)

	# Botón de compra de estación
	var purchase_button = Button.new()
	purchase_button.pressed.connect(_on_station_purchased.bind(station_index))
	station_group.add_child(purchase_button)

	# Separador
	var separator1 = HSeparator.new()
	station_group.add_child(separator1)

	# Interfaz de producción (botones de cantidad)
	var production_label = Label.new()
	production_label.text = "🔨 Producción Manual:"
	station_group.add_child(production_label)

	var production_buttons = HBoxContainer.new()
	var quantities = [1, 5, 10, 50]
	for quantity in quantities:
		var prod_button = Button.new()
		prod_button.text = "x%d" % quantity
		prod_button.pressed.connect(_on_manual_production_requested.bind(station_index, quantity))
		production_buttons.add_child(prod_button)

	station_group.add_child(production_buttons)

	# Separador para OFERTA
	var separator_offer = HSeparator.new()
	station_group.add_child(separator_offer)

	# Sistema de OFERTA AUTOMÁTICA
	var offer_label = Label.new()
	offer_label.text = "🛒 OFERTA AUTOMÁTICA:"
	station_group.add_child(offer_label)

	var offer_container = HBoxContainer.new()

	# Toggle de activar/desactivar oferta
	var offer_toggle = CheckBox.new()
	offer_toggle.text = "Disponible para clientes"
	offer_toggle.pressed.connect(_on_offer_toggled.bind(station_index))
	offer_container.add_child(offer_toggle)

	# Botón para configurar precio de oferta
	var price_button = Button.new()
	price_button.text = "Precio Automático"
	price_button.pressed.connect(_on_offer_price_requested.bind(station_index))
	offer_container.add_child(price_button)

	station_group.add_child(offer_container)

	# Separador final
	var separator2 = HSeparator.new()
	station_group.add_child(separator2)

	# Agregar al contenedor principal
	station_container.add_child(station_group)
	station_interfaces.append(station_group)


func _format_recipe(recipe: Dictionary) -> String:
	var recipe_parts = []
	for ingredient in recipe.keys():
		recipe_parts.append("%dx %s" % [recipe[ingredient], ingredient])
	return " + ".join(recipe_parts)


func update_product_displays(game_data: Dictionary) -> void:
	for product_name in product_labels.keys():
		var label = product_labels[product_name]
		var amount = game_data["products"].get(product_name, 0)
		var icon = GameUtils.get_product_icon(product_name)
		var price = GameUtils.get_product_price(product_name)
		label.text = (
			"%s %s: %d ($%.1f c/u)"
			% [icon, product_name.replace("_", " ").capitalize(), amount, price]
		)


func _can_afford_production(station: Dictionary, game_data: Dictionary, quantity: int) -> bool:
	# Verificar si hay suficientes ingredientes para la receta
	for ingredient in station.recipe.keys():
		var needed = station.recipe[ingredient] * quantity
		var available = game_data["resources"].get(ingredient, 0)
		if available < needed:
			return false
	return true


func update_station_interfaces(production_stations: Array[Dictionary], game_data: Dictionary) -> void:
	print("🔄 ProductionPanel - Actualizando interfaces de estación")
	print("📊 Estaciones recibidas: %d, interfaces existentes: %d" % [production_stations.size(), station_interfaces.size()])

	# Si no hay interfaces, crearlas primero
	if station_interfaces.size() == 0:
		print("⚠️ No hay interfaces existentes, creando desde cero...")
		setup_stations(production_stations)
		return

	# FORZAR ACTUALIZACIÓN VISIBLE DE RECETAS
	print("🔧 FORZANDO ACTUALIZACIÓN DE RECETAS...")

	for i in range(min(station_interfaces.size(), production_stations.size())):
		var station = production_stations[i]
		var station_group = station_interfaces[i]
		var owned = game_data["stations"].get(station.id, 0)
		var cost = _calculate_station_cost(station, game_data)
		var can_afford = game_data["money"] >= cost
		var is_unlocked = station.get("unlocked", true)  # Default true para compatibilidad

		print("🏗️ Actualizando estación %d (%s): poseída=%d, desbloqueada=%s" % [i, station.name, owned, is_unlocked])

		# Verificar que station_group tiene hijos antes de acceder
		if station_group.get_child_count() < 5:
			print("❌ ERROR: station_group no tiene suficientes hijos (%d)" % station_group.get_child_count())
			continue

		# Actualizar botón de compra (segundo hijo después del título)
		var purchase_button = station_group.get_child(1) as Button

		if not is_unlocked:
			# Estación bloqueada - mostrar requisitos de desbloqueo
			purchase_button.text = "🔒 BLOQUEADO\n%s\nRequisitos: Experimenta con ingredientes..." % station.name
			purchase_button.disabled = true
			purchase_button.visible = true

			# Ocultar interfaz de producción
			var production_label = station_group.get_child(3)
			var production_buttons = station_group.get_child(4)
			production_label.visible = false
			production_buttons.visible = false

		elif owned == 0:
			# No tiene la estación pero está desbloqueada, mostrar botón de compra
			var recipe_text = ""
			for ingredient in station.recipe.keys():
				var ingredient_icon = GameUtils.get_resource_icon(ingredient)
				var amount = station.recipe[ingredient]
				recipe_text += "%s%dx " % [ingredient_icon, amount]

			purchase_button.text = "🏗️ Construir %s\nCosto: $%s\nReceta: %s\n%s" % [
				station.name,
				GameUtils.format_large_number(cost),
				recipe_text.strip_edges(),
				station.description
			]
			purchase_button.disabled = not can_afford
			purchase_button.visible = true

			# Ocultar interfaz de producción
			var production_label = station_group.get_child(3)
			var production_buttons = station_group.get_child(4)
			production_label.visible = false
			production_buttons.visible = false
		else:
			# Ya tiene la estación, ocultar compra y mostrar producción
			purchase_button.visible = false

			# Mostrar interfaz de producción
			var production_label = station_group.get_child(3)
			var production_buttons = station_group.get_child(4)
			production_label.visible = true
			production_buttons.visible = true

			# Actualizar botones de producción
			production_label.text = "🔨 Producción Manual (Tienes: %d):" % owned

			var buttons = production_buttons.get_children()
			for j in range(buttons.size()):
				var button = buttons[j] as Button
				var quantity = int(button.text.substr(1))  # Quitar la 'x'
				var can_produce = _can_produce(station, game_data, quantity)
				button.disabled = not can_produce

				if can_produce:
					button.text = "x%d ✅" % quantity
				else:
					button.text = "x%d ❌" % quantity

			# Actualizar interfaz de ofertas
			var offer_container = station_group.get_child(7) as HBoxContainer  # Contenedor de oferta
			var offer_toggle = offer_container.get_child(0) as CheckBox  # CheckBox
			var price_button = offer_container.get_child(1) as Button   # Botón de precio

			# Obtener estado de la oferta desde GameData
			var offer_state = game_data["offers"].get(station.id, {"enabled": false, "price_multiplier": 1.0})
			var is_enabled = offer_state.get("enabled", false)
			var price_multiplier = offer_state.get("price_multiplier", 1.0)

			# Actualizar checkbox sin disparar señal
			offer_toggle.set_pressed_no_signal(is_enabled)

			# Actualizar texto del botón de precio
			if price_multiplier == 1.0:
				price_button.text = "Precio Normal"
			elif price_multiplier > 1.0:
				price_button.text = "Precio Alto (+%.0f%%)" % ((price_multiplier - 1.0) * 100)
			else:
				price_button.text = "Precio Bajo (%.0f%%)" % (price_multiplier * 100)


func _can_produce(station: Dictionary, game_data: Dictionary, quantity: int) -> bool:
	# Verificar si tiene suficientes ingredientes para producir
	for ingredient in station.recipe.keys():
		var required = station.recipe[ingredient] * quantity
		var available = game_data["resources"].get(ingredient, 0)
		if available < required:
			return false
	return true


func _calculate_station_cost(station: Dictionary, game_data: Dictionary) -> float:
	var owned = game_data["stations"].get(station.id, 0)
	# Precio fijo simple (consistente con ProductionManager)
	return station.base_cost


func _clear_product_labels() -> void:
	for child in product_container.get_children():
		child.queue_free()
	product_labels.clear()


func _clear_station_interfaces() -> void:
	for child in station_container.get_children():
		child.queue_free()
	station_interfaces.clear()


func _on_station_purchased(station_index: int) -> void:
	station_purchased.emit(station_index)


func _on_manual_production_requested(station_index: int, quantity: int) -> void:
	manual_production_requested.emit(station_index, quantity)

func _on_offer_toggled(station_index: int) -> void:
	# Obtener el estado del checkbox
	var station_group = station_interfaces[station_index]
	# Buscar el checkbox en la estructura (posición específica)
	var offer_container = station_group.get_child(7)  # HBoxContainer de oferta
	var offer_toggle = offer_container.get_child(0) as CheckBox  # CheckBox
	var enabled = offer_toggle.button_pressed

	print("🛒 Oferta toggled para estación %d: %s" % [station_index, "ACTIVADA" if enabled else "DESACTIVADA"])
	offer_toggled.emit(station_index, enabled)

func _on_offer_price_requested(station_index: int) -> void:
	print("💰 Configuración de precio solicitada para estación %d" % station_index)
	offer_price_requested.emit(station_index)
