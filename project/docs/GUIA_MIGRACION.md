# 🛠️ GUÍA DE MIGRACIÓN - SCENE COMPOSITION

## 🎯 ESTRATEGIA DE MIGRACIÓN

### **ENFOQUE GRADUAL**
1. ✅ **Fase Preparatoria**: Componentes base creados
2. 🔄 **Fase Actual**: Implementación de ejemplos
3. ⏳ **Fase Final**: Migración completa y cleanup

## 🏗️ EJEMPLO: GENERATIONPANEL

### **ANTES (GenerationPanel.gd actual)**
```gdscript
# ❌ Problemático: Referencias directas predefinidas
@onready var gold_amount_label = $ResourcesSection/ResourcesContainer/GoldCard/VBoxContainer/AmountLabel
@onready var barley_amount_label = $ResourcesSection/ResourcesContainer/BarleyCard/VBoxContainer/AmountLabel

func _setup_generator_button(generator_data: Dictionary, button: Button):
    # ❌ Código específico para cada elemento
    # ❌ No reutilizable
    # ❌ Difícil de mantener
```

### **DESPUÉS (GenerationPanel_Modular.gd) ✅**
```gdscript
# ✅ Modular: Componentes reutilizables
@onready var resources_container = $ResourcesSection/ResourcesContainer
@onready var generators_shop = $GeneratorsSection/ShopContainer

func _ready():
    _setup_resource_cards()
    _setup_generators_shop()

func _setup_resource_cards():
    # ✅ Un patrón para TODOS los recursos
    for resource_id in ["gold", "barley", "hops", "water"]:
        var card = ItemListCard_scene.instantiate()
        card.setup_item(get_resource_data(resource_id), get_resource_button_config(resource_id))
        resources_container.add_child(card)
```

## 🔄 MIGRATION ROADMAP

### **1. ProductionPanel → ProductionPanel_Modular**

**COMPONENTES A USAR**:
- `ShopContainer` para estaciones de producción (modo "buy")
- `ItemListCard` para recetas activas
- `ItemListCard` para cola de producción

**CONFIGURACIÓN**:
```gdscript
# Estaciones de producción
var stations_shop = ShopContainer.new()
stations_shop.setup("Estaciones de Producción", "buy")
stations_shop.add_item({
    id = "brewery_station",
    name = "Estación Cervecera",
    description = "Produce cerveza de forma automática",
    base_price = 50.0,
    cost_calculator = station_cost_function
})

# Recetas disponibles
var recipe_card = ItemListCard.new()
recipe_card.setup_item(
    {id = "beer_recipe", name = "Receta: Cerveza", status = "disponible"},
    {text = "Activar", icon = "▶️", action = "activate_recipe"}
)
```

### **2. SalesPanel → SalesPanel_Modular**

**COMPONENTES A USAR**:
- `ShopContainer` para ventas de productos (modo "sell")
- `ItemListCard` para estadísticas de ventas
- `ItemListCard` para clientes activos

**CONFIGURACIÓN**:
```gdscript
# Productos para venta
var products_shop = ShopContainer.new()
products_shop.setup("Productos Disponibles", "sell")
products_shop.add_item({
    id = "beer",
    name = "Cerveza Premium",
    description = "Tu cerveza artesanal",
    base_price = 8.0
})

# Estadísticas de ventas
var stats_card = ItemListCard.new()
stats_card.setup_item(
    {id = "beer_sales", name = "Ventas de Cerveza", amount = "145 unidades"},
    {text = "Ver Detalles", icon = "📊", action = "view_stats"}
)
```

### **3. CustomersPanel → CustomersPanel_Modular**

**COMPONENTES A USAR**:
- `ItemListCard` para cada cliente
- `ShopContainer` para gestión de demandas (modo personalizado)

**CONFIGURACIÓN**:
```gdscript
# Clientes disponibles
var customer_card = ItemListCard.new()
customer_card.setup_item(
    {id = "restaurant", name = "Restaurante El Barril", demand = "Cerveza x50"},
    {text = "Negociar", icon = "🤝", action = "negotiate"}
)
```

## 🔀 SIGNALS ARCHITECTURE

### **FLUJO DE COMUNICACIÓN**
```
Panel_Modular.gd
    ↕️ (purchase_requested/sell_requested/action_requested)
    ↕️
ShopContainer.gd ← → ItemListCard.gd ← → BuyCard.gd
    ↕️                    ↕️               ↕️
(quantity_changed)   (action_requested)  (item_purchased/sold)
```

### **EJEMPLO DE CONEXIONES**:
```gdscript
# En Panel
func _setup_connections():
    generators_shop.purchase_requested.connect(_on_generator_purchase)
    resources_list.action_requested.connect(_on_resource_action)

func _on_generator_purchase(item_id: String, quantity: int, total_cost: float):
    # Delegar al Manager correspondiente
    GeneratorManager.purchase_generator(item_id, quantity)

func _on_resource_action(item_id: String, action: String):
    match action:
        "sell":
            ResourceManager.sell_resource(item_id)
        "details":
            show_resource_details(item_id)
```

## 📋 CHECKLIST DE MIGRACIÓN

### **Para cada Panel existente**:

#### **🔍 ANÁLISIS**
- [ ] Identificar elementos de UI actuales
- [ ] Mapear a componentes modulares
- [ ] Planificar configuración de señales

#### **🏗️ IMPLEMENTACIÓN**
- [ ] Crear Panel_Modular.tscn
- [ ] Instanciar componentes necesarios
- [ ] Configurar propiedades y señales
- [ ] Conectar con Managers existentes

#### **✅ VALIDACIÓN**
- [ ] Probar funcionalidad básica
- [ ] Verificar señales funcionan
- [ ] Validar mobile-friendly
- [ ] Performance test

#### **🧹 CLEANUP**
- [ ] Backup versión anterior
- [ ] Eliminar código obsoleto
- [ ] Actualizar referencias
- [ ] Documentar cambios

## 🎯 OBJETIVOS DE CADA MIGRACIÓN

### **GenerationPanel_Modular**
- [x] **Completado**: Ejemplo funcional creado
- [x] **Recursos**: ItemListCard para gold, barley, hops, water
- [x] **Generadores**: ShopContainer para farms, silos, etc.
- [x] **Señales**: Conectado con GeneratorManager

### **ProductionPanel_Modular**
- [ ] **Estaciones**: ShopContainer para brewery stations
- [ ] **Recetas**: ItemListCard para recetas disponibles
- [ ] **Cola**: ItemListCard para trabajos en progreso
- [ ] **Señales**: Conectar con ProductionManager

### **SalesPanel_Modular**
- [ ] **Productos**: ShopContainer para venta de productos
- [ ] **Estadísticas**: ItemListCard para métricas de venta
- [ ] **Mercado**: ItemListCard para precios del mercado
- [ ] **Señales**: Conectar con SalesManager

### **CustomersPanel_Modular**
- [ ] **Clientes**: ItemListCard para cada cliente
- [ ] **Demandas**: ShopContainer para gestión de órdenes
- [ ] **Contratos**: ItemListCard para contratos activos
- [ ] **Señales**: Conectar con CustomerManager

## ⚡ BENEFICIOS INMEDIATOS

### **Para el Desarrollador**:
- 🧩 **Modularidad**: Cambios en un componente afectan todo el juego
- 🔧 **Mantenimiento**: Un solo lugar para lógica de cada tipo
- 🧪 **Testing**: Componentes independientes testeable
- 📚 **Documentación**: APIs claras y predecibles

### **Para el Usuario**:
- 📱 **Mobile-friendly**: Optimización automática en todos lados
- 🎮 **UX Consistente**: Mismo comportamiento en todos los paneles
- ⚡ **Performance**: Elementos predefinidos, no generación dinámica
- 🔄 **Escalabilidad**: Nuevas features sin rehacer UI

## 🏁 RESULTADO FINAL

### **ANTES**:
```
❌ 4 paneles con código UI duplicado
❌ Generación dinámica problemática
❌ Referencias rotas frecuentes
❌ Mobile UX inconsistente
❌ Mantenimiento complejo
```

### **DESPUÉS**:
```
✅ 3 componentes base + N paneles modulares
✅ Scene Composition predefinido
✅ Referencias siempre válidas
✅ Mobile UX automático y consistente
✅ Mantenimiento centralizado y simple
```

¿Procedemos con la implementación del plan de migración?
