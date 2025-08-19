class_name CurrencyManager
extends Node
## Sistema de gestión de monedas múltiples
## Maneja Cash (dinero), Tokens (misiones) y Stars (prestigio)

# Señales para notificar cambios
signal currency_changed(currency_type: String, old_amount: int, new_amount: int)
signal purchase_attempted(item_id: String, cost: Dictionary, success: bool)
signal not_enough_currency(currency_type: String, required: int, available: int)

# Tipos de moneda
enum CurrencyType { CASH, TOKENS, STARS }  # 💵 Dinero - Venta de bebidas  # 🎯 Tokens - Misiones completadas  # ⭐ Estrellas - Sistema de prestigio

# Datos de las monedas
var currencies: Dictionary = {
	"cash":  # Histórico para estadísticas
	{"amount": 0, "total_earned": 0, "emoji": "💵", "name": "Dinero", "resets_on_prestige": true},
	"tokens":
	{"amount": 0, "total_earned": 0, "emoji": "🎯", "name": "Tokens", "resets_on_prestige": false},
	"stars":
	{"amount": 0, "total_earned": 0, "emoji": "⭐", "name": "Estrellas", "resets_on_prestige": false}
}


func _ready() -> void:
	print("💰 CurrencyManager inicializado")

	# Dar algo de dinero inicial para testing
	if AppConfig.is_debug:
		add_currency("cash", 100)


## Añadir cantidad a una moneda
func add_currency(currency_type: String, amount: int) -> bool:
	if not currencies.has(currency_type):
		push_error("❌ Tipo de moneda no válido: " + currency_type)
		return false

	if amount <= 0:
		return false

	var old_amount = currencies[currency_type].amount
	var new_amount = old_amount + amount

	currencies[currency_type].amount = new_amount
	currencies[currency_type].total_earned += amount

	currency_changed.emit(currency_type, old_amount, new_amount)

	if AppConfig.is_debug:
		print("💰 ", currencies[currency_type].name, ": ", old_amount, " → ", new_amount)

	return true


## Remover cantidad de una moneda (para compras)
func spend_currency(currency_type: String, amount: int) -> bool:
	if not currencies.has(currency_type):
		push_error("❌ Tipo de moneda no válido: " + currency_type)
		return false

	var current_amount = currencies[currency_type].amount

	if current_amount < amount:
		not_enough_currency.emit(currency_type, amount, current_amount)
		return false

	var new_amount = current_amount - amount
	currencies[currency_type].amount = new_amount

	currency_changed.emit(currency_type, current_amount, new_amount)

	if AppConfig.is_debug:
		print("💸 Gastado ", amount, " ", currencies[currency_type].name)

	return true


## Verificar si se puede pagar un costo múltiple
func can_afford(cost: Dictionary) -> bool:
	for currency_type in cost:
		var required = cost[currency_type]
		var available = get_currency_amount(currency_type)
		if available < required:
			return false
	return true


## Realizar compra con costo múltiple
func make_purchase(item_id: String, cost: Dictionary) -> bool:
	# Verificar si se puede pagar
	if not can_afford(cost):
		purchase_attempted.emit(item_id, cost, false)
		return false

	# Realizar el pago
	var success = true
	for currency_type in cost:
		if not spend_currency(currency_type, cost[currency_type]):
			success = false
			break

	purchase_attempted.emit(item_id, cost, success)

	if success and AppConfig.is_debug:
		print("✅ Compra realizada: ", item_id)

	return success


## Obtener cantidad actual de una moneda
func get_currency_amount(currency_type: String) -> int:
	if not currencies.has(currency_type):
		return 0
	return currencies[currency_type].amount


## Obtener cantidad total ganada históricamente
func get_total_earned(currency_type: String) -> int:
	if not currencies.has(currency_type):
		return 0
	return currencies[currency_type].total_earned


## Obtener datos de display de una moneda
func get_currency_display(currency_type: String) -> Dictionary:
	if not currencies.has(currency_type):
		return {}

	var data = currencies[currency_type]
	return {
		"emoji": data.emoji,
		"name": data.name,
		"amount": data.amount,
		"formatted": format_currency(data.amount)
	}


## Formatear número de moneda para mostrar
func format_currency(amount: int) -> String:
	if amount < 1000:
		return str(amount)
	elif amount < 1000000:
		return "%.1fK" % (amount / 1000.0)
	elif amount < 1000000000:
		return "%.1fM" % (amount / 1000000.0)
	else:
		return "%.1fB" % (amount / 1000000000.0)


## Calcular ingresos por venta de bebida
func sell_beverage(beverage_id: String, base_price: int, quantity: int = 1) -> int:
	# Aplicar multiplicadores globales aquí
	var final_price = base_price * quantity

	# TODO: Aplicar bonificaciones de upgrades y prestigio
	# final_price *= UpgradeManager.get_income_multiplier()

	add_currency("cash", final_price)

	if AppConfig.is_debug:
		print("🍹 Vendido ", quantity, "x ", beverage_id, " por ", final_price, " cash")

	return final_price


## Sistema de prestigio - resetear monedas que corresponda
func reset_for_prestige() -> Dictionary:
	var reset_data = {}

	for currency_type in currencies:
		var currency_data = currencies[currency_type]
		if currency_data.resets_on_prestige:
			reset_data[currency_type] = currency_data.amount
			currencies[currency_type].amount = 0
			currency_changed.emit(currency_type, reset_data[currency_type], 0)

	print("🔄 Monedas reseteadas para prestigio")
	return reset_data


## Calcular estrellas de prestigio basado en dinero total
func calculate_prestige_stars() -> int:
	var total_cash = get_total_earned("cash")

	# Fórmula: 1 estrella por cada 10M de cash total histórico
	var stars = int(total_cash / 10000000.0)

	return max(stars, 1)  # Mínimo 1 estrella


## Recompensas de misiones
func complete_mission(mission_id: String, token_reward: int) -> void:
	add_currency("tokens", token_reward)
	GameEvents.emit_custom_event("mission_completed", {"id": mission_id, "reward": token_reward})


## Obtener estado para guardado
func get_save_data() -> Dictionary:
	return {"currencies": currencies}


## Cargar estado desde guardado
func load_save_data(data: Dictionary) -> void:
	if data.has("currencies"):
		currencies = data.currencies

		# Emitir señales para actualizar UI
		for currency_type in currencies:
			currency_changed.emit(currency_type, 0, currencies[currency_type].amount)


## Método de conveniencia para obtener tipos como strings
func get_currency_types() -> Array:
	return ["cash", "tokens", "stars"]


## Debug: Añadir monedas de testing
func debug_add_currencies() -> void:
	if AppConfig.is_debug:
		add_currency("cash", 10000)
		add_currency("tokens", 100)
		add_currency("stars", 10)
		print("🧪 Monedas de debug añadidas")
