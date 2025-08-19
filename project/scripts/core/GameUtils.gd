extends Node
## GameUtils - Utilidades centralizadas del juego optimizadas
## Eliminar duplicación y centralizar funciones comunes


## Validación robusta de referencias a managers (elimina duplicación)
func is_manager_valid(manager_ref: Node) -> bool:
	"""Validación centralizada para evitar duplicación en paneles"""
	return manager_ref != null and is_instance_valid(manager_ref)


## Formateo de números grandes (optimizado)
func format_large_number(number: float) -> String:
	if not is_finite(number) or is_nan(number):
		return "0"

	var abs_number = abs(number)

	if abs_number < 1000:
		return str(int(abs_number))
	if abs_number < 1000000:
		return "%.1fK" % (abs_number / 1000.0)
	if abs_number < 1000000000:
		return "%.1fM" % (abs_number / 1000000.0)
	if abs_number < 1000000000000:
		return "%.1fB" % (abs_number / 1000000000.0)
	return "%.1fT" % (abs_number / 1000000000000.0)


## Precios de productos usando GameConfig centralizado
func get_product_price(product_type: String) -> float:
	var data = GameConfig.PRODUCT_DATA.get(product_type, null)
	if data != null:
		return data.base_price
	return 1.0


## Precios de ingredientes usando GameConfig centralizado
func get_ingredient_price(ingredient_type: String) -> float:
	var data = GameConfig.RESOURCE_DATA.get(ingredient_type, null)
	if data == null:
		return 0.2
	# Precios basados en tier y configuración
	match ingredient_type:
		"barley":
			return 0.5
		"hops":
			return 0.8
		"water":
			return 0.1
		"yeast":
			return 1.0
		_:
			return 0.2


## Iconos de productos usando GameConfig centralizado
func get_product_icon(product_name: String) -> String:
	var data = GameConfig.PRODUCT_DATA.get(product_name, null)
	if data != null:
		return data.emoji
	return "📦"


## Iconos de ingredientes usando GameConfig centralizado
func get_item_emoji(item_type: String) -> String:
	var resource_data = GameConfig.RESOURCE_DATA.get(item_type, null)
	if resource_data != null:
		return resource_data.emoji

	var product_data = GameConfig.PRODUCT_DATA.get(item_type, null)
	if product_data != null:
		return product_data.emoji

	return "📦"


## Cálculo de costos exponenciales (centralizado)
func calculate_exponential_cost(
	base_cost: float, owned: int, quantity: int, scale_factor: float = 1.15
) -> float:
	var total_cost = 0.0
	for i in range(quantity):
		total_cost += base_cost * pow(scale_factor, owned + i)
	return total_cost


## Factory para calculadoras de costo (elimina duplicación en paneles)
func create_cost_calculator(
	manager_ref: Node, item_id: String, get_cost_method: String
) -> Callable:
	return func(base_price: float, quantity: int) -> float:
		if is_manager_valid(manager_ref) and manager_ref.has_method(get_cost_method):
			return manager_ref.call(get_cost_method, item_id, quantity)
		return base_price * quantity


## Limpiar contenedor de forma segura (elimina duplicación)
func clear_container_children(container: Node) -> void:
	"""Limpiar todos los hijos de un contenedor de forma segura"""
	if not is_instance_valid(container):
		return

	for child in container.get_children():
		if is_instance_valid(child):
			child.queue_free()
