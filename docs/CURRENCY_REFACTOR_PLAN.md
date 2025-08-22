# 🏗️ CURRENCY REFACTOR - Arquitectura Optimizada

## 🎯 **CAMBIOS PROPUESTOS**

### ❌ **ELIMINAR**
1. **CurrencyManager como Node singleton**
2. **Sincronización bidireccional compleja**
3. **Multi-currency costs** (nunca se usarán)
4. **Signals currency_changed** (innecesario)

### ✅ **NUEVA ARQUITECTURA**

#### 1. **Currencies directas en GameData**
```gdscript
# GameData.gd - Solo datos
@export var money: float = 50.0      # 💵 Gameplay principal
@export var tokens: int = 0          # 🪙 Clientes automáticos
@export var gems: int = 100          # 💎 Unlocks especiales

# Métodos simples
func add_money(amount: float): money += amount
func spend_money(amount: float) -> bool:
    if money >= amount: money -= amount; return true
    return false

func add_tokens(amount: int): tokens += amount
func spend_gems(amount: int) -> bool:
    if gems >= amount: gems -= amount; return true
    return false
```

#### 2. **SaveSystem persistencia directa**
```gdscript
# Ya funciona - SaveSystem.save_game_data_with_encryption()
# Guarda GameData.to_dict() → user://barsik_save.dat
# Triple backup, encriptación, checksum
```

#### 3. **UI updates directos**
```gdscript
# GameController._update_all_displays()
# Actualiza UI directamente desde game_data.money, tokens, gems
# Sin signals, sin managers intermedios
```

## 🎮 **CURRENCIES POR PROPÓSITO ESPECÍFICO**

### 💵 **CASH - Gameplay Principal**
- **Fuente**: Ventas de productos, clientes manuales
- **Uso**: Comprar generadores, estaciones, expansión
- **Display**: Siempre visible, formato $123.45K

### 🪙 **TOKENS - Recompensas Automáticas**
- **Fuente**: Clientes automáticos (cada 8s), misiones completadas
- **Uso**: Acelerar producción, upgrades especiales
- **Display**: Visible cuando >0, formato 1,234

### 💎 **GEMS - Currency Premium**
- **Fuente**: Logros especiales, eventos raros
- **Uso**: Desbloquear sistema clientes (50💎), funciones premium
- **Display**: Siempre visible, formato exacto

**NO HABRÁ COSTES MIXTOS** - Cada item usa 1 sola currency

## 📁 **IMPLEMENTACIÓN**

### Fase 1: Eliminar CurrencyManager
- Remover de GameController
- Integrar métodos en GameData
- Actualizar UI calls directos

### Fase 2: Simplificar SaveSystem
- GameData currencies → SaveSystem automático
- Ya está implementado, sin cambios

### Fase 3: UI directo
- TabNavigator usa game_data directamente
- Sin signals, actualización en _update_all_displays()

## ✅ **BENEFICIOS**
- **-100 líneas código** - Eliminamos CurrencyManager.gd completo
- **-1 singleton** - Menos complejidad arquitectural
- **+Performance** - Sin signals innecesarios, updates directos
- **+Mantenibilidad** - Currencies en GameData, persistencia automática
