# 🏗️ ARQUITECTURA MODULAR UI - SCENE COMPOSITION

## 🎯 OBJETIVO
Refactorizar completamente la UI hacia un enfoque modular usando Scene Composition de Godot, eliminando la generación dinámica problemática y creando componentes reutilizables y escalables.

## 📐 PRINCIPIOS DE DISEÑO

### 🔹 **Separación de Responsabilidades**
- **BuyCard**: Maneja UN solo item de compra/venta
- **ShopContainer**: Coordina MÚLTIPLES BuyCards con controles globales
- **ItemListCard**: Muestra información + acción contextual
- **Panels**: Solo conectan datos con componentes, sin lógica de UI

### 🔹 **Loose Coupling (Acoplamiento Débil)**
- Componentes NO conocen su contexto padre
- Comunicación vía señales únicamente
- Configuración por inyección de dependencias
- Reutilización sin modificaciones

### 🔹 **Scene Composition**
- Cada .tscn es independiente y testeable
- Instanciación dinámica cuando sea necesario
- Anidación de escenas dentro de escenas
- Separación clara entre estructura y lógica

## 🧩 COMPONENTES CREADOS

### 📦 **BuyCard.tscn + BuyCard.gd**
**Propósito**: Tarjeta genérica de compra/venta
**Características**:
- ✅ Icono, título, descripción, precio, botón
- ✅ Modo "buy" o "sell" configurable
- ✅ Calculadora de costo personalizable
- ✅ Estado de asequibilidad automático
- ✅ Señales: item_purchased, item_sold

**API Principal**:
```gdscript
# Configuración
card.setup(item_data: Dictionary, mode: String)
card.set_cost_calculator(calculator: Callable)
card.set_quantity(quantity: int)
card.set_affordability(can_afford: bool)

# Señales
card.item_purchased.connect(callback)
card.item_sold.connect(callback)
```

### 🛍️ **ShopContainer.tscn + ShopContainer.gd**
**Propósito**: Contenedor modular con controles de cantidad globales
**Características**:
- ✅ Botones x1, x5, x10, x25, x50 sincronizados
- ✅ Grid de tarjetas BuyCard
- ✅ Barra de estado con totales
- ✅ Gestión automática de asequibilidad
- ✅ Modo compra/venta configurable

**API Principal**:
```gdscript
# Configuración
shop.setup(title: String, mode: String)
shop.add_item(item_data: Dictionary) -> BuyCard
shop.update_player_money(money: float)
shop.clear_items()

# Señales
shop.purchase_requested.connect(callback)
shop.sell_requested.connect(callback)
```

### 📋 **ItemListCard.tscn + ItemListCard.gd**
**Propósito**: Lista genérica con botón contextual
**Características**:
- ✅ Información del item (nombre, cantidad, descripción)
- ✅ Botón configurable por contexto
- ✅ Actualización eficiente de datos
- ✅ Acción personalizable

**API Principal**:
```gdscript
# Configuración
card.setup_item(data: Dictionary, btn_config: Dictionary)
card.update_data(new_data: Dictionary)
card.configure_button(btn_config: Dictionary)

# Señales
card.action_requested.connect(callback)
```

## 🏛️ ARQUITECTURA DE IMPLEMENTACIÓN

### **FASE 1: COMPONENTES BASE** ✅
- [x] BuyCard.tscn + BuyCard.gd
- [x] ShopContainer.tscn + ShopContainer.gd
- [x] ItemListCard.tscn + ItemListCard.gd
- [x] GenerationPanel_Modular.tscn (ejemplo)

### **FASE 2: REFACTORIZACIÓN DE PANELES**
- [ ] **GenerationPanel**: Usar ShopContainer para generadores + ItemListCard para recursos
- [ ] **ProductionPanel**: Usar ShopContainer para estaciones + ItemListCard para recetas
- [ ] **SalesPanel**: Usar ShopContainer para ventas + ItemListCard para estadísticas
- [ ] **CustomersPanel**: Usar ItemListCard para clientes + botones de gestión

### **FASE 3: COMPONENTES AVANZADOS**
- [ ] **RecipeCard**: Tarjeta especializada para recetas (ingredientes → producto)
- [ ] **CustomerCard**: Tarjeta especializada para clientes (preferencias, órdenes)
- [ ] **InventoryContainer**: Contenedor especializado para inventarios
- [ ] **StatsContainer**: Contenedor para estadísticas y métricas

## 🚀 BENEFICIOS DE LA NUEVA ARQUITECTURA

### ✅ **Eliminación de Problemas Actuales**
- ❌ No más errores de alineación dinámica
- ❌ No más referencias rotas a elementos generados
- ❌ No más código duplicado de UI
- ❌ No más mezcla de lógica UI con lógica de negocio

### ✅ **Nuevas Capacidades**
- ✅ Componentes 100% reutilizables
- ✅ Testing independiente de cada componente
- ✅ Fácil escalabilidad (nuevos paneles = combinar componentes)
- ✅ Mantenimiento simplificado
- ✅ Performance mejorada (elementos predefinidos)

### ✅ **Cumplimiento con Best Practices**
- ✅ SOLID principles
- ✅ Scene Composition pattern
- ✅ Dependency Injection
- ✅ Signal-based communication
- ✅ Loose coupling

## 🎯 PLAN DE MIGRACIÓN

### **Paso 1: Validar Componentes Base**
```gdscript
# Test ShopContainer con generadores
var shop = preload("res://scenes/ui/components/ShopContainer.tscn").instantiate()
shop.setup("Test Generadores", "buy")
shop.add_item({id="test", name="Test Item", base_price=100.0})
```

### **Paso 2: Crear GenerationPanel_V2**
- Reemplazar elementos predefinidos con ShopContainer
- Usar ItemListCard para recursos
- Mantener mismas señales para compatibilidad

### **Paso 3: Migrar ProductionPanel y SalesPanel**
- Aplicar mismos patrones
- Configurar botones contextuales específicos
- Unificar sistema de señales

### **Paso 4: Cleanup y Optimización**
- Eliminar UIComponentsFactory obsoleto
- Consolidar estilos en UITheme
- Documentar componentes públicos

## 🔧 PATRONES DE USO

### **Para Compras (Generadores, Estaciones)**:
```gdscript
var shop = ShopContainer.new()
shop.setup("Mis Generadores", "buy")
shop.add_item({
    id = "barley_farm",
    name = "Granja de Cebada",
    base_price = 10.0,
    cost_calculator = my_cost_function
})
shop.purchase_requested.connect(_on_purchase)
```

### **Para Ventas (Productos, Ingredientes)**:
```gdscript
var shop = ShopContainer.new()
shop.setup("Mis Ventas", "sell")
shop.add_item({
    id = "beer",
    name = "Cerveza",
    base_price = 5.0
})
shop.sell_requested.connect(_on_sell)
```

### **Para Listas de Información**:
```gdscript
var list_card = ItemListCard.new()
list_card.setup_item(
    {id = "resource", name = "Cebada", amount = 150},
    {text = "Vender", icon = "💰", action = "sell"}
)
list_card.action_requested.connect(_on_action)
```

## 🎖️ RESULTADOS ESPERADOS

### **Código Más Limpio**
- 📊 -70% líneas de código en paneles
- 📊 -90% código de generación dinámica
- 📊 +100% reutilización de componentes

### **Mantenimiento Simplificado**
- 🔧 Un solo lugar para lógica de tarjetas
- 🔧 Testing independiente por componente
- 🔧 Cambios UI centralizados

### **Escalabilidad Mejorada**
- 🚀 Nuevos paneles = composición de componentes existentes
- 🚀 Nuevos tipos de items = configuración, no código
- 🚀 Nuevos comportamientos = nuevos componentes modulares

## 📝 PRÓXIMOS PASOS

1. **Probar componentes base** con datos reales
2. **Refactorizar GenerationPanel** como ejemplo completo
3. **Aplicar patrón** a ProductionPanel y SalesPanel
4. **Eliminar código obsoleto** y consolidar

¿Te parece bien esta arquitectura? ¿Procedemos con la implementación completa?
