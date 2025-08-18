extends Node
## GameUtils - Utilidades centralizadas del juego
## Eliminar duplicación y centralizar funciones comunes

## Formateo de números grandes (robusto)
func format_large_number(number: float) -> String:
	# Validar entrada
	if not is_finite(number) or is_nan(number):
		return "0"

	# Asegurar que sea positivo
	var abs_number = abs(number)

	if abs_number < 1000:
		return str(int(abs_number))
	elif abs_number < 1000000:
		return "%.1fK" % (abs_number / 1000.0)
	elif abs_number < 1000000000:
		return "%.1fM" % (abs_number / 1000000.0)
	elif abs_number < 1000000000000:
		return "%.1fB" % (abs_number / 1000000000.0)
	elif abs_number < 1000000000000000:
		return "%.1fT" % (abs_number / 1000000000000.0)
	else:
		return "%.1fQ" % (abs_number / 1000000000000000.0)

## Precios de productos
func get_product_price(product_type: String) -> float:
	match product_type:
		"basic_beer":
			return 5.0
		"premium_beer":
			return 12.0
		"cocktail":
			return 20.0
		_:
			return 1.0

## Precios de ingredientes
func get_ingredient_price(ingredient_type: String) -> float:
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

## Iconos de productos
func get_product_icon(product_name: String) -> String:
	match product_name:
		"basic_beer":
			return "🍺"
		"premium_beer":
			return "🍻"
		"cocktail":
			return "🍹"
		_:
			return "🥤"

## Iconos de recursos
func get_resource_icon(resource_name: String) -> String:
	match resource_name:
		"barley":
			return "🌾"
		"hops":
			return "🌿"
		"water":
			return "💧"
		"yeast":
			return "🦠"
		_:
			return "📦"

## Iconos de ítems generales
func get_item_emoji(item_name: String) -> String:
	match item_name:
		"barley": return "🌾"
		"hops": return "🌿"
		"water": return "💧"
		"yeast": return "🦠"
		"basic_beer": return "🍺"
		"premium_beer": return "🍻"
		"cocktail": return "🍹"
		_: return "📦"

## Validar suficientes recursos para receta
func can_afford_recipe(resources: Dictionary, recipe: Dictionary, quantity: int = 1) -> bool:
	for ingredient in recipe.keys():
		var needed = recipe[ingredient] * quantity
		var available = resources.get(ingredient, 0)
		if available < needed:
			return false
	return true

## Consumir ingredientes de una receta
func consume_recipe(resources: Dictionary, recipe: Dictionary, quantity: int = 1) -> bool:
	if not can_afford_recipe(resources, recipe, quantity):
		return false

	for ingredient in recipe.keys():
		var needed = recipe[ingredient] * quantity
		resources[ingredient] -= needed

	return true

## Calcular costo con escalado exponencial
func calculate_exponential_cost(base_cost: float, owned: int, quantity: int, scale_factor: float = 1.15) -> float:
	var total_cost = 0.0
	for i in range(quantity):
		var cost = base_cost * pow(scale_factor, owned + i)
		total_cost += cost
	return total_cost
