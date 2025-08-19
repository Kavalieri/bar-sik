# 🧩 COMPONENTES MODULARES - MANUAL DE USO

## 📦 BUYCARD - Tarjeta Universal de Compra/Venta

### **🎯 Propósito**
Componente genérico para mostrar UN item que se puede comprar o vender, con precio, información y estado de asequibilidad automático.

### **📐 Estructura Visual**
```
┌─────────────────────┐ 280x160px
│  [ICON] 📦          │
│  Título del Item    │
│  Descripción corta  │
│  💰 Precio: $100    │
│  [   COMPRAR   ]    │ 55px height
└─────────────────────┘
```

### **⚙️ API de Configuración**
```gdscript
# Setup inicial - OBLIGATORIO
card.setup(item_data: Dictionary, mode: String)

# item_data debe contener:
{
    "id": "unique_item_id",
    "name": "Nombre del Item",
    "description": "Descripción opcional",
    "base_price": 100.0,
    "icon": "🏭" # opcional
}

# mode puede ser:
"buy"   # Botón dirá "Comprar"
"sell"  # Botón dirá "Vender"
```

### **🔧 Configuración Avanzada**
```gdscript
# Calculadora de costo personalizada
card.set_cost_calculator(func(base_price: float, quantity: int) -> float:
    return base_price * pow(1.15, quantity) # Costo exponencial
)

# Control de cantidad
card.set_quantity(5) # Para compras múltiples

# Estado de asequibilidad
card.set_affordability(player_money >= total_cost)
```

### **📡 Señales Disponibles**
```gdscript
# Cuando el usuario compra
card.item_purchased.connect(func(item_id: String, quantity: int, total_cost: float):
    print("Comprado: ", item_id, " x", quantity, " por $", total_cost)
)

# Cuando el usuario vende
card.item_sold.connect(func(item_id: String, quantity: int, total_income: float):
    print("Vendido: ", item_id, " x", quantity, " por $", total_income)
)
```

---

## 🛍️ SHOPCONTAINER - Tienda Modular

### **🎯 Propósito**
Contenedor que gestiona múltiples BuyCards con controles de cantidad globales (x1, x5, x10, x25, x50) y barra de estado.

### **📐 Estructura Visual**
```
┌─────────────────────────────────────┐
│ Título de la Tienda    [x1][x5][x10]│ Header
│                        [x25][x50]   │ 60px height
├─────────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐    │ Content
│ │Card1│ │Card2│ │Card3│ │Card4│    │ ScrollContainer
│ └─────┘ └─────┘ └─────┘ └─────┘    │
│ ┌─────┐ ┌─────┐                    │
│ │Card5│ │Card6│                    │
│ └─────┘ └─────┘                    │
├─────────────────────────────────────┤
│ Total: $500  |  Dinero: $1,200     │ Status Bar
└─────────────────────────────────────┘ 40px height
```

### **⚙️ API de Configuración**
```gdscript
# Setup inicial
shop.setup(title: String, mode: String)

# Ejemplos:
shop.setup("Generadores", "buy")
shop.setup("Venta de Productos", "sell")
shop.setup("Estaciones", "buy")
```

### **📝 Gestión de Items**
```gdscript
# Agregar item (devuelve la BuyCard creada)
var card = shop.add_item({
    "id": "barley_farm",
    "name": "Granja de Cebada",
    "description": "Genera cebada automáticamente",
    "base_price": 15.0,
    "icon": "🌾"
})

# Configurar calculadora específica para este item
card.set_cost_calculator(my_custom_cost_function)

# Limpiar todos los items
shop.clear_items()
```

### **💰 Gestión de Dinero**
```gdscript
# Actualizar dinero del jugador (actualiza asequibilidad)
shop.update_player_money(player_money)

# El componente automáticamente:
# - Actualiza estado de todos los botones
# - Calcula totales con cantidad actual
# - Muestra/oculta estado "No puedes comprar"
```

### **📡 Señales de Tienda**
```gdscript
# Cuando se solicita compra
shop.purchase_requested.connect(func(item_id: String, quantity: int, total_cost: float):
    if GeneratorManager.can_purchase(item_id, quantity):
        GeneratorManager.purchase_generator(item_id, quantity)
        shop.update_player_money(GameData.player_money)
)

# Cuando se solicita venta
shop.sell_requested.connect(func(item_id: String, quantity: int, total_income: float):
    SalesManager.sell_item(item_id, quantity)
    shop.update_player_money(GameData.player_money)
)
```

---

## 📋 ITEMLISTCARD - Lista Universal

### **🎯 Propósito**
Componente genérico para mostrar información de un item con UN botón de acción contextual. Ideal para listas, estadísticas, recursos, clientes, etc.

### **📐 Estructura Visual**
```
┌───────────────────────────────┐ 280x80px
│ 📦 Nombre del Item            │
│    Cantidad: 150              │
│    Estado/Descripción     [📊]│ Botón contextual
└───────────────────────────────┘
```

### **⚙️ API de Configuración**
```gdscript
# Setup completo
card.setup_item(item_data: Dictionary, button_config: Dictionary)

# item_data:
{
    "id": "gold",
    "name": "Oro",
    "amount": 500,           # opcional
    "description": "Recurso premium", # opcional
    "icon": "💰",           # opcional
    "status": "Disponible"  # opcional
}

# button_config:
{
    "text": "Vender",       # Texto del botón
    "icon": "💸",          # Icono opcional
    "action": "sell_gold", # ID de acción
    "enabled": true        # opcional, default true
}
```

### **🔄 Actualización Dinámica**
```gdscript
# Actualizar solo los datos (mantiene configuración)
card.update_data({
    "amount": 750,
    "status": "En producción"
})

# Reconfigurar botón sin tocar datos
card.configure_button({
    "text": "Pausar",
    "icon": "⏸️",
    "action": "pause_production"
})
```

### **📡 Señal de Acción**
```gdscript
# Una sola señal para todas las acciones
card.action_requested.connect(func(item_id: String, action: String):
    match action:
        "sell_gold":
            ResourceManager.sell_resource("gold")
        "pause_production":
            ProductionManager.pause_recipe(item_id)
        "negotiate":
            CustomerManager.start_negotiation(item_id)
)
```

---

## 🌟 EJEMPLOS DE USO REAL

### **🏭 Generadores (GenerationPanel_Modular)**
```gdscript
# Configurar shop de generadores
generators_shop.setup("Mis Generadores", "buy")

# Agregar cada tipo de generador
for gen_data in GeneratorManager.get_available_generators():
    var card = generators_shop.add_item(gen_data)
    card.set_cost_calculator(GeneratorManager.get_cost_function(gen_data.id))

# Conectar compras
generators_shop.purchase_requested.connect(_on_generator_purchase)
```

### **⚗️ Recetas (ProductionPanel_Modular)**
```gdscript
# Lista de recetas activas
for recipe in ProductionManager.get_active_recipes():
    var card = ItemListCard.new()
    card.setup_item(
        {
            id = recipe.id,
            name = recipe.name,
            status = recipe.status,
            progress = str(recipe.progress) + "%"
        },
        {
            text = "Cancelar" if recipe.status == "active" else "Reanudar",
            icon = "❌" if recipe.status == "active" else "▶️",
            action = "toggle_recipe"
        }
    )
    recipes_container.add_child(card)
```

### **👥 Clientes (CustomersPanel_Modular)**
```gdscript
# Lista de clientes disponibles
for customer in CustomerManager.get_available_customers():
    var card = ItemListCard.new()
    card.setup_item(
        {
            id = customer.id,
            name = customer.name,
            demand = customer.current_demand,
            reputation = customer.reputation_level
        },
        {
            text = "Negociar",
            icon = "🤝",
            action = "start_negotiation"
        }
    )
    customers_container.add_child(card)
```

## 🔑 VENTAJAS CLAVE

### **🧩 Modularidad Total**
- Un componente = una responsabilidad
- Reutilización sin modificaciones
- Testing independiente posible

### **📱 Mobile-First**
- Todos los componentes optimizados para touch
- Tamaños consistentes automáticamente
- Iconos grandes y botones accesibles

### **⚡ Performance**
- Elementos predefinidos (no generación dinámica)
- Reutilización de instancias
- Señales eficientes

### **🛠️ Mantenimiento**
- Cambio en componente = cambio global
- Lógica centralizada
- Debugging simplificado

## ✨ PRÓXIMOS PASOS

1. **Probar componentes** con datos reales del juego
2. **Migrar GenerationPanel** como caso de estudio completo
3. **Aplicar patrón** a ProductionPanel y SalesPanel
4. **Eliminar código obsoleto** gradualmente
5. **Optimizar performance** con pooling si es necesario

¿Te parece clara la nueva arquitectura? ¿Empezamos con las migraciones?
