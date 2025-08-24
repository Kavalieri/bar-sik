extends Node
class_name EventBridge
## Puente de eventos entre managers y UI - Versión Simplificada
## Desacopla la comunicación entre componentes usando señales

# Señales para comunicación desacoplada
signal ui_update_requested(component: String, data: Dictionary)
signal manager_action_requested(action: String, params: Dictionary)
signal save_game_requested
signal pause_menu_requested
signal prestige_panel_requested

# Referencias mínimas necesarias
var game_controller: Node
var ui_coordinator: UICoordinator

func _ready():
	print("🌉 EventBridge inicializado - Versión Simplificada")

func initialize(controller: Node, ui_coord: UICoordinator):
	"""Inicializar referencias principales"""
	game_controller = controller
	ui_coordinator = ui_coord
	_connect_all_signals()
	print("🔗 EventBridge inicializado con GameController")

func _connect_all_signals():
	"""Conectar señales básicas"""
	# Las señales específicas se conectarán desde el GameController
	print("📡 EventBridge listo para recibir señales")

func _update_all_displays():
	"""Solicitar actualización de displays via señal"""
	ui_update_requested.emit("all", {})

# === MANEJADORES DE EVENTOS SIMPLIFICADOS ===
# Estos métodos emiten señales en lugar de ejecutar lógica directamente

func _on_generator_purchased(generator_id: String, quantity: int) -> void:
	"""Manejar compra de generador via señal"""
	print("📡 EventBridge: Generador comprado - %dx %s" % [quantity, generator_id])
	manager_action_requested.emit("generator_purchased", {
		"generator_id": generator_id,
		"quantity": quantity
	})
	ui_update_requested.emit("generation", {})

func _on_resource_generated(resource_type: String, amount: int) -> void:
	"""Manejar generación de recursos via señal"""
	print("📡 EventBridge: Recurso generado - %dx %s" % [amount, resource_type])
	manager_action_requested.emit("resource_generated", {
		"resource_type": resource_type,
		"amount": amount
	})
	ui_update_requested.emit("money", {})

func _on_station_purchased(station_id: String) -> void:
	"""Manejar compra de estación via señal"""
	print("📡 EventBridge: Estación comprada - %s" % station_id)
	manager_action_requested.emit("station_purchased", {
		"station_id": station_id
	})
	ui_update_requested.emit("production", {})

func _on_product_produced(product_type: String, amount: int) -> void:
	"""Manejar producción via señal"""
	print("📡 EventBridge: Producto producido - %dx %s" % [amount, product_type])
	manager_action_requested.emit("product_produced", {
		"product_type": product_type,
		"amount": amount
	})
	ui_update_requested.emit("production", {})

func _on_item_sold(item_type: String, item_name: String, quantity: int, price: float, total_earnings: float) -> void:
	"""Manejar venta via señal"""
	print("📡 EventBridge: Item vendido - %dx %s por $%s" % [quantity, item_name, total_earnings])
	manager_action_requested.emit("item_sold", {
		"item_type": item_type,
		"item_name": item_name,
		"quantity": quantity,
		"price": price,
		"total_earnings": total_earnings
	})
	ui_update_requested.emit("sales", {})

func _on_customer_served(customer_name: String, satisfaction: float, tip: float) -> void:
	"""Manejar cliente servido via señal"""
	print("📡 EventBridge: Cliente servido - %s (satisfacción: %s)" % [customer_name, satisfaction])
	manager_action_requested.emit("customer_served", {
		"customer_name": customer_name,
		"satisfaction": satisfaction,
		"tip": tip
	})
	ui_update_requested.emit("customers", {})

func _on_pause_pressed() -> void:
	"""Solicitar mostrar menú de pausa"""
	print("📡 EventBridge: Pausa solicitada")
	pause_menu_requested.emit()

func _on_prestige_button_pressed() -> void:
	"""Solicitar mostrar panel de prestigio"""
	print("📡 EventBridge: Panel de prestigio solicitado")
	prestige_panel_requested.emit()

func _on_ui_generator_purchase_requested(generator_id: String, quantity: int) -> void:
	"""Procesar solicitud de compra de generador desde UI"""
	print("📡 EventBridge: Compra de generador solicitada - %dx %s" % [quantity, generator_id])
	manager_action_requested.emit("ui_generator_purchase", {
		"generator_id": generator_id,
		"quantity": quantity
	})

func _on_ui_station_purchase_requested(station_id: String, multiplier: int = 1) -> void:
	"""Procesar solicitud de compra de estación desde UI"""
	print("📡 EventBridge: Compra de estación solicitada - %s (x%d)" % [station_id, multiplier])
	manager_action_requested.emit("ui_station_purchase", {
		"station_id": station_id,
		"multiplier": multiplier
	})

func _on_ui_manual_production_requested(station_index: int, quantity: int) -> void:
	"""Procesar solicitud de producción manual desde UI"""
	print("📡 EventBridge: Producción manual solicitada - Estación %d, cantidad %d" % [station_index, quantity])
	manager_action_requested.emit("ui_manual_production", {
		"station_index": station_index,
		"quantity": quantity
	})

func _on_ui_item_sell_requested(item_type: String, item_name: String, quantity: int) -> void:
	"""Procesar solicitud de venta desde UI"""
	print("📡 EventBridge: Venta solicitada - %dx %s" % [quantity, item_name])
	manager_action_requested.emit("ui_item_sell", {
		"item_type": item_type,
		"item_name": item_name,
		"quantity": quantity
	})

# === FUNCIONES DE UTILIDAD ===

func request_save():
	"""Solicitar guardado del juego"""
	save_game_requested.emit()

func request_ui_update(component: String, data: Dictionary = {}):
	"""Solicitar actualización específica de UI"""
	ui_update_requested.emit(component, data)

func request_manager_action(action: String, params: Dictionary = {}):
	"""Solicitar acción específica de manager"""
	manager_action_requested.emit(action, params)
