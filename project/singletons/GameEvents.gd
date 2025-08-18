extends Node
## GameEvents - Sistema de eventos global para BAR-SIK
## Maneja la comunicación entre sistemas de producción, recursos y ventas

# Señales para sistema de recursos
signal resource_generated(resource_type: String, amount: int)
signal resource_consumed(resource_type: String, amount: int)
signal resource_changed(resource_type: String, old_amount: int, new_amount: int)

# Señales para sistema de producción
signal ingredient_produced(ingredient_type: String, amount: int)
signal product_crafted(product_type: String, amount: int, ingredients_used: Dictionary)
signal production_station_upgraded(station_type: String, new_level: int)

# Señales para sistema de ventas
signal customer_arrived(customer_data: Dictionary)
signal customer_served(customer_id: String, products_sold: Array, total_price: float)
signal sale_completed(product_type: String, amount: int, price: float)
signal money_earned(amount: float, source: String)

# Señales para upgrades y generadores
signal generator_purchased(generator_type: String, current_count: int)
signal upgrade_purchased(upgrade_type: String, level: int)

# Señales de UI y sistema
signal ui_update_requested(system: String)
signal notification_show(message: String, type: String)
signal save_data_requested
signal data_loaded


func _ready() -> void:
	print("🎯 GameEvents inicializado - Sistema de eventos BAR-SIK")


## Funciones helper para emitir eventos comunes
func emit_resource_change(resource_type: String, old_amount: int, new_amount: int) -> void:
	resource_changed.emit(resource_type, old_amount, new_amount)
	ui_update_requested.emit("resources")


func emit_money_change(amount: float, source: String) -> void:
	money_earned.emit(amount, source)
	ui_update_requested.emit("currency")


func emit_notification(message: String, notification_type: String = "info") -> void:
	notification_show.emit(message, notification_type)


func request_save() -> void:
	save_data_requested.emit()
