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


## Cálculo de costos exponenciales (centralizado) - DEPRECADO
## Usar get_scaled_cost() para nuevo sistema de balance
func calculate_exponential_cost(
	base_cost: float, owned: int, quantity: int, scale_factor: float = 1.15
) -> float:
	var total_cost = 0.0
	for i in range(quantity):
		total_cost += base_cost * pow(scale_factor, owned + i)
	return total_cost


## ═══════════════════════════════════════════════════════════════════════════════════
## T024 - SISTEMA DE ESCALADO DE COSTOS REBALANCEADO
## ═══════════════════════════════════════════════════════════════════════════════════


## Obtener costo escalado con curvas específicas por tipo de item
func get_scaled_cost(base_cost: float, level: int, item_type: String = "default") -> float:
	"""
	Sistema de escalado rebalanceado para mejor progresión:
	- Early game: Progresión suave
	- Mid game: Aceleración gradual
	- Late game: Desafío exponencial
	"""
	var multiplier = 1.15  # Default fallback

	match item_type.to_lower():
		"generator":
			# Generadores: Escalado variable por fase del juego
			if level <= 10:
				multiplier = 1.12  # Early game suave (12% por nivel)
			elif level <= 25:
				multiplier = 1.18  # Mid game acelerado (18% por nivel)
			else:
				multiplier = 1.25  # Late game desafiante (25% por nivel)

		"station":
			# Estaciones de producción: Más caras, inversión significativa
			multiplier = 1.20

		"upgrade":
			# Upgrades: Mucho más caros, decisiones estratégicas
			multiplier = 1.30

		"customer":
			# Upgrades de clientes: Balance tokens vs beneficio
			if level <= 5:
				multiplier = 1.15  # Primeros levels accesibles
			else:
				multiplier = 1.22  # Después más costosos

		"automation":
			# Automation upgrades: Premium features
			multiplier = 1.35

		"prestige":
			# Prestige upgrades: Muy costosos, beneficios permanentes
			multiplier = 2.0

		_:
			# Default para otros tipos
			multiplier = 1.15

	# Aplicar el escalado exponencial
	return base_cost * pow(multiplier, level - 1)


## Calcular costo total para comprar múltiples niveles
func get_bulk_scaled_cost(
	base_cost: float, current_level: int, quantity: int, item_type: String = "default"
) -> float:
	"""Calcular costo total para comprar 'quantity' niveles desde 'current_level'"""
	var total_cost = 0.0

	for i in range(quantity):
		var level_to_buy = current_level + i + 1
		total_cost += get_scaled_cost(base_cost, level_to_buy, item_type)

	return total_cost


## Verificar si el jugador puede permitirse un upgrade
func can_afford_scaled_upgrade(
	currency_amount: float, base_cost: float, level: int, item_type: String = "default"
) -> bool:
	"""Verificar si se puede permitir un upgrade con el nuevo sistema"""
	var cost = get_scaled_cost(base_cost, level, item_type)
	return currency_amount >= cost


## Obtener información detallada de costo (para UI)
func get_cost_info(base_cost: float, level: int, item_type: String = "default") -> Dictionary:
	"""Retornar información completa del costo para displays de UI"""
	var cost = get_scaled_cost(base_cost, level, item_type)
	var next_cost = get_scaled_cost(base_cost, level + 1, item_type)
	var growth_rate = (next_cost - cost) / cost if cost > 0 else 0.0

	return {
		"current_cost": cost,
		"next_cost": next_cost,
		"growth_rate": growth_rate,
		"formatted_cost": format_large_number(cost),
		"formatted_next": format_large_number(next_cost),
		"growth_percentage": growth_rate * 100.0
	}


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
