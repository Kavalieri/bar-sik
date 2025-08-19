## GUÍA DE MIGRACIÓN - GameScene.gd → Arquitectura Modular
## =====================================================================

ANTES (GameScene.gd - 739 líneas):
```gdscript
extends Control
var game_data: Dictionary = {}
var resource_generators: Array[Dictionary] = [...]
var production_stations: Array[Dictionary] = [...]

func _generate_resources() -> void: # 20+ líneas
func _on_generator_purchased() -> void: # 15+ líneas
func _on_station_purchased() -> void: # 20+ líneas
func _on_manual_production_requested() -> void: # 30+ líneas
func _on_item_sell_requested() -> void: # 25+ líneas
func _process_automatic_customers() -> void: # 40+ líneas
# ... 30+ funciones más
```

DESPUÉS (GameController.gd - 250 líneas):
```gdscript
extends Control
class_name GameController

var game_data: GameData
var generator_manager: GeneratorManager
var production_manager: ProductionManager
var sales_manager: SalesManager
var customer_manager: CustomerManager

func _on_ui_generator_purchase_requested(generator_index: int, quantity: int) -> void:
    generator_manager.purchase_generator(generator_id, quantity)  # 1 línea!

func _on_ui_manual_production_requested(station_index: int, quantity: int) -> void:
    production_manager.manual_production(station_id, quantity)  # 1 línea!
```

## PASOS DE MIGRACIÓN:

### 1. REEMPLAZAR GameScene.gd por GameController.gd
```bash
# Respaldar archivo actual
cp GameScene.gd GameScene_backup.gd

# Reemplazar contenido con GameController
cp core/GameController.gd GameScene.gd
```

### 2. ACTUALIZAR project.godot
```ini
[autoload]
GameManager="*res://singletons/GameManager.gd"
```

### 3. CONECTAR MANAGERS EN GameController._setup_managers()
```gdscript
# Ya implementado - los managers se conectan automáticamente
```

### 4. ELIMINAR CÓDIGO DUPLICADO DE PANELES

## EN GenerationPanel.gd - REEMPLAZAR:
```gdscript
# ELIMINAR esta función duplicada:
func _format_large_number(number: float) -> String: # 15 líneas
    # ... código duplicado

# USAR GameUtils en su lugar:
GameUtils.format_large_number(total_cost)
```

## EN ProductionPanel.gd - REEMPLAZAR:
```gdscript
# ELIMINAR estas funciones duplicadas:
func _get_product_price(product_type: String) -> float: # 10 líneas
func _get_product_icon(product_name: String) -> String: # 8 líneas
func _format_large_number(number: float) -> String: # 15 líneas

# USAR GameUtils:
GameUtils.get_product_price(product_name)
GameUtils.get_product_icon(product_name)
GameUtils.format_large_number(cost)
```

## EN SalesPanel.gd - REEMPLAZAR:
```gdscript
# ELIMINAR funciones duplicadas:
func _get_product_price() -> float: # 10 líneas
func _get_ingredient_price() -> float: # 10 líneas
func _get_item_emoji() -> String: # 8 líneas

# USAR GameUtils:
GameUtils.get_product_price(product_name)
GameUtils.get_ingredient_price(ingredient_name)
GameUtils.get_item_emoji(item_name)
```

## EN TabNavigator.gd - REEMPLAZAR:
```gdscript
# ELIMINAR función duplicada:
func _format_large_number(number: float) -> String: # 15 líneas

# USAR GameUtils:
GameUtils.format_large_number(amount)
```

### 5. RESULTADOS ESPERADOS:

REDUCCIÓN DE LÍNEAS:
- GameScene.gd: 739 → 250 líneas (-66%)
- GenerationPanel.gd: 161 → 120 líneas (-25%)
- ProductionPanel.gd: 256 → 180 líneas (-30%)
- SalesPanel.gd: 162 → 100 líneas (-38%)
- TabNavigator.gd: 204 → 170 líneas (-17%)

TOTAL: ~1,522 → ~820 líneas (-46% de código)

ELIMINACIÓN DE DUPLICADOS:
- _format_large_number: 4 copias → 1 centralizada ✅
- _get_product_price: 3 copias → 1 centralizada ✅
- _get_ingredient_price: 2 copias → 1 centralizada ✅
- _get_*_icon: 3 copias → 1 centralizada ✅

BENEFICIOS:
✅ Código 46% más pequeño
✅ 0% código duplicado
✅ Fácil añadir nuevos ingredientes/recetas
✅ Testing individual por módulo
✅ Mantenimiento simplificado
✅ Separación clara de responsabilidades
