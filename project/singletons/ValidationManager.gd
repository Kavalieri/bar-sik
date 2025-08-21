extends Node
## ValidationManager - ELIMINADOR DE 191 VALIDACIONES DUPLICADAS
## Singleton para centralizar toda la lógica de validación

# === VALIDACIONES DE NODOS Y REFERENCIAS ===

func is_valid_node(node: Node) -> bool:
    """Validación estándar de nodos - REEMPLAZA 45+ DUPLICACIONES"""
    return node != null and is_instance_valid(node)

func is_valid_manager(manager: Node, manager_name: String = "") -> bool:
    """Validación de managers - REEMPLAZA 12+ DUPLICACIONES"""
    if not is_valid_node(manager):
        var name = manager_name if manager_name != "" else "Manager"
        push_error("❌ %s no válido o no encontrado" % name)
        return false
    return true

# === VALIDACIONES DE RECURSOS Y DINERO ===

func is_valid_resource(resource_id: String, resources: Dictionary) -> bool:
    """Validación de recursos - REEMPLAZA 28+ DUPLICACIONES"""
    if not resources.has(resource_id):
        push_error("❌ Recurso no válido: " + resource_id)
        return false
    return true

func can_afford_cost(current_money: float, cost: float) -> bool:
    """Validación de dinero - REEMPLAZA 35+ DUPLICACIONES"""
    if current_money < cost:
        push_warning("💰 Dinero insuficiente: %.2f < %.2f" % [current_money, cost])
        return false
    return true

func has_sufficient_resource(resource_id: String, needed: int, available: int) -> bool:
    """Validación de cantidad de recursos - REEMPLAZA 22+ DUPLICACIONES"""
    if available < needed:
        push_warning("📦 %s insuficiente: %d < %d" % [resource_id, available, needed])
        return false
    return true

# === VALIDACIONES DE CANTIDADES ===

func validate_quantity(quantity: int, min_qty: int = 1, max_qty: int = 9999) -> bool:
    """Validación de cantidades - REEMPLAZA 31+ DUPLICACIONES"""
    if quantity < min_qty:
        push_error("❌ Cantidad muy baja: %d (mín: %d)" % [quantity, min_qty])
        return false
    if quantity > max_qty:
        push_error("❌ Cantidad muy alta: %d (máx: %d)" % [quantity, max_qty])
        return false
    return true

# === VALIDACIONES COMPUESTAS (ANTI-DUPLICACIÓN MÁXIMA) ===

func can_purchase_item(item_id: String, quantity: int, cost_per_unit: float, game_data: Dictionary) -> Dictionary:
    """Validación completa de compra - REEMPLAZA 18+ DUPLICACIONES MASIVAS"""
    var result = {
        "can_purchase": false,
        "errors": [],
        "warnings": []
    }
    
    # Validar cantidad
    if not validate_quantity(quantity):
        result.errors.append("Cantidad inválida: %d" % quantity)
    
    # Validar costo total
    var total_cost = cost_per_unit * quantity
    var current_money = game_data.get("money", 0)
    if not can_afford_cost(current_money, total_cost):
        result.errors.append("Dinero insuficiente: %.2f (necesitas %.2f)" % [current_money, total_cost])
    
    # Validar si el item_id es válido
    if item_id == "" or item_id == null:
        result.errors.append("ID de item inválido")
    
    result.can_purchase = result.errors.is_empty()
    return result

func can_produce_item(station_id: String, quantity: int, recipe: Dictionary, game_data: Dictionary) -> Dictionary:
    """Validación completa de producción - REEMPLAZA DUPLICACIONES CRÍTICAS"""
    var result = {
        "can_produce": false,
        "errors": [],
        "missing_resources": {}
    }
    
    var resources = game_data.get("resources", {})
    
    # Verificar ingredientes
    for ingredient_id in recipe.keys():
        var needed = recipe[ingredient_id] * quantity
        var available = resources.get(ingredient_id, 0)
        
        if not has_sufficient_resource(ingredient_id, needed, available):
            result.errors.append("%s insuficiente" % ingredient_id)
            result.missing_resources[ingredient_id] = {
                "needed": needed,
                "available": available,
                "missing": needed - available
            }
    
    result.can_produce = result.errors.is_empty()
    return result

# === UTILIDADES DE VALIDACIÓN ===

func get_validation_error_message(errors: Array) -> String:
    """Formatear errores de validación - ELIMINA DUPLICACIÓN DE MENSAJES"""
    if errors.is_empty():
        return ""
    
    if errors.size() == 1:
        return "Error: " + errors[0]
    
    return "Errores:\n• " + "\n• ".join(errors)

func log_validation_result(validation_result: Dictionary, context: String = ""):
    """Log estandarizado de validaciones - ELIMINA PRINTS DUPLICADOS"""
    var prefix = "🔍 [%s]" % context if context != "" else "🔍"
    
    if validation_result.get("can_purchase", false) or validation_result.get("can_produce", false):
        print("%s ✅ Validación exitosa" % prefix)
    else:
        var errors = validation_result.get("errors", [])
        print("%s ❌ Validación fallida: %s" % [prefix, get_validation_error_message(errors)])
