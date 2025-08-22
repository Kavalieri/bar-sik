# 🍺 Bar-Sik - Game Design Document v2.0
**Actualizado**: Agosto 2025 | **Versión**: 2.0 - Sistema de Clientes Integrado

---

## 🎯 Concepto Principal

**Bar-Sik** es un **idle clicker de gestión de bar avanzado** donde el jugador comienza como un bartender novato y progresa hasta construir un imperio automatizado de cervecería. El gameplay se centra en la **generación automática, producción optimizada, venta manual e idle automática** con progresión infinita, múltiples monedas y sistema de prestigio.

**🔄 CAMBIO CRÍTICO v2.0**: Integración del **Sistema de Clientes Automáticos** que convierte el juego en un verdadero **idle game** con **loop cerrado completo**.

---

## 📱 Especificaciones Técnicas

- **Plataforma**: Windows + Android + Web (PWA)
- **Orientación**: Portrait (1080×1920) + Landscape adaptativo
- **Género**: Idle Clicker / Resource Management / Automation Simulator
- **Audiencia**: 13+ (gestión, sin contenido inapropiado)
- **Duración de sesión**: 2-30 minutos (idle permite ausencia)
- **Monetización**: Ética - Diamantes premium, aceleradores, donaciones

---

## 🔄 Core Loop Completo (Bucle Cerrado v2.0)

```
🔧 GENERAR Ingredientes (Automático)
           ↓
🏭 PROCESAR en Productos (Manual/Auto)
           ↓
💰 VENDER por Cash (Manual) + 👥 CLIENTES por Tokens (Automático)
           ↓
💎 COMPRAR Mejoras con Cash/Tokens/Diamantes
           ↓
🔓 DESBLOQUEAR Nuevos Sistemas → 🏆 PRESTIGIO → ⭐ Bonificaciones Permanentes
           ↓
🔄 REPETIR con Mayor Escala y Automatización
```

**⚡ MECÁNICA CLAVE**: Los **clientes automáticos** crean el **loop idle perfecto**:
- **Offline**: Generación + Clientes = Progreso sin intervención
- **Online**: Optimización manual + Expansión estratégica
- **Engagement**: Desbloqueos constantes + Decisiones de inversión

---

## 💰 Sistema de Triple Moneda v2.0

### 1. **💵 Cash (Dinero)** - Moneda Primaria
**Fuente**: Venta manual de productos + Bonificaciones
**Uso Primario**:
- 🔧 Generadores básicos (agua, cebada, lúpulo, levadura)
- 🏭 Estaciones de producción (brewery, bar_station)
- 📈 Upgrades de eficiencia y velocidad
- 📦 Capacidad de almacenamiento

**Características**:
- ✅ Se resetea parcialmente en prestigio
- ✅ Escalado exponencial (1.15x por nivel)
- ✅ Disponible desde el inicio

### 2. **🪙 Tokens** - Moneda Intermedia
**Fuente**: **Clientes automáticos** + Misiones completadas
**Uso Primario**:
- 🔓 Desbloquear nuevos ingredientes (Tier 2+)
- 🍺 Recetas premium y especiales
- 🤖 Upgrades de automatización avanzada
- 🎯 Mejoras de clientes (velocidad, cantidad)

**Características**:
- ❌ NO se resetea en prestigio
- ✅ Obtenible de forma 100% gratuita
- ✅ Rate: 1-3 tokens por cliente (según upgrades)

### 3. **💎 Diamantes** - Moneda Premium
**Fuente**: Inicio (100 diamantes) + IAP opcional + Logros raros
**Uso Primario**:
- 🔓 **Desbloquear Sistema de Clientes (50 💎)**
- 👥 Sobornar nuevos clientes (+1 cliente = 25 💎)
- ⚡ Aceleradores temporales (2x velocidad)
- 🏆 Boosts de prestigio premium

**Características**:
- ⭐ Moneda más valiosa y escasa
- ✅ Obtenible gratis (limitado)
- 💰 Monetización ética opcional

---

## 🏭 Sistema de Producción Completo

### **🔧 Tier 1 - Recursos Básicos (Automáticos)**
**Disponibles**: Al inicio
- **💧 Agua**: Base de toda producción | Límite: 50 | Rate: 1/3seg
- **🌾 Cebada**: Ingrediente cerveza | Límite: 100 | Rate: 1/3seg
- **🌿 Lúpulo**: Sabor amargo | Límite: 100 | Rate: 1/3seg
- **🍄 Levadura**: Fermentación | Límite: 25 | Rate: 1/3seg

### **🏭 Tier 2 - Estaciones de Producción (Manuales/Auto)**
**Disponibles**: Mediante cash
- **🍺 Brewery Station**: Agua + Cebada + Lúpulo + Levadura = Cerveza
- **🥤 Bar Station**: Mezclas rápidas y cócteles básicos
- **🍷 Premium Station**: Desbloqueables con tokens

### **👥 Tier 3 - Sistema de Clientes (Automático)**
**Desbloqueables**: 50 💎 inicial

**Mecánica de Clientes**:
```
⏰ Timer: 8 segundos base (reducible a 4.8seg con upgrades)
👤 Llegada: 1 cliente por ciclo (expandible hasta 3)
🛒 Compra: 1-3 productos (según upgrade "Mayoristas")
💰 Pago: En TOKENS (no cash)
🎯 Requisito: Producto debe tener "oferta habilitada"
```

**Upgrades de Clientes**:
1. **👤 Nuevo Cliente (100 💎)**: +1 cliente en el grupo rotativo
2. **⚡ Clientes Rápidos (200 💎)**: -40% tiempo entre visitas
3. **👑 Clientes Premium (500 💎)**: +50% tokens pagados
4. **📦 Mayoristas (1000 💎)**: Pueden comprar hasta 3 productos

---

## 🎮 Interfaz: Sistema de 4 Pestañas

### 📱 **Pestaña 1: Generation**
**Propósito**: Gestión de recursos automáticos
**Elementos**:
- 🔢 Contadores de recursos actuales/máximos
- 🛒 Botones de compra de generadores (IdleBuyButton)
- 📊 Display de rate de generación por segundo
- 🔄 Multiplicadores rotativos (x1, x5, x10, x25)

### 🏭 **Pestaña 2: Production**
**Propósito**: Conversión de recursos en productos
**Elementos**:
- 🏗️ Lista de estaciones disponibles/desbloqueadas
- ⚙️ Botones de producción manual con multiplicadores
- 📋 Recetas visibles (ingredientes → producto)
- 📦 Inventario de productos terminados

### 💰 **Pestaña 3: Sales**
**Propósito**: Monetización manual y ofertas
**Elementos**:
- 💵 Botones de venta manual de productos
- 📈 Sistema de ofertas (habilitar/deshabilitar por producto)
- 🎯 Multiplicadores de precio por oferta (1.0x - 2.0x)
- 📊 Estadísticas de ventas (manual vs automática)

### 👥 **Pestaña 4: Customers** ⭐ **NUEVO v2.0**
**Propósito**: Sistema idle automático completo
**Elementos Principales**:

**🔓 Panel de Desbloqueo** (Si no desbloqueado):
- 💎 "Desbloquear Clientes (50 💎)"
- 📝 Explicación del sistema
- 📊 Beneficios potenciales

**🎮 Panel de Gestión** (Si desbloqueado):
- 👥 **Cliente Counter**: "Clientes activos: 2/5"
- ⏰ **Timer Visual**: Barra de progreso circular del próximo cliente
- 🛒 **Shop de Upgrades**: Lista scrollable de mejoras
  - 👤 Nuevo Cliente (💎 precio dinámico)
  - ⚡ Velocidad (+40% rapidez)
  - 👑 Premium (+50% tokens)
  - 📦 Mayoristas (compras múltiples)
- 📈 **Estadísticas en Tiempo Real**:
  - 💰 Tokens ganados (por minuto)
  - 🛒 Productos vendidos automáticamente
  - 👥 Total de clientes servidos
- 🔄 **Estado de Ofertas**: Quick-toggle para habilitar productos

**🎯 Flujo de Uso**:
1. Jugador produce productos en Pestaña 2
2. Activa ofertas en Pestaña 3
3. Clientes automáticos compran en Pestaña 4
4. Tokens generados financian expansión

---

## 🏆 Sistema de Prestigio v2.0

### **📊 Requisitos de Prestigio**
- 💰 1M+ de cash total histórico
- 🏆 10+ logros básicos completados
- 👥 Sistema de clientes desbloqueado y activo
- 📈 Al menos 5 estaciones de producción

### **🔄 Lo que se Resetea**
- 💵 Cash actual (no histórico)
- 🔧 Niveles de generadores
- 🏭 Niveles de estaciones básicas
- 📦 Inventarios de recursos y productos
- ⏰ Timers de clientes (reinicia a 8seg)

### **✅ Lo que se Mantiene**
- 🪙 Tokens (100% preservados)
- 💎 Diamantes (100% preservados)
- 👥 Clientes desbloqueados
- 🔓 Recetas y estaciones premium
- 🏆 Logros completados
- ⭐ Estrellas de prestigio (NUEVAS)

### **⭐ Bonificaciones de Prestigio** (Estrellas)
**Costo**: Cash total histórico / 10M = Estrellas ganadas

1. **💰 Income Multiplier (1⭐)**: +20% cash por venta manual
2. **⚡ Speed Boost (2⭐)**: +25% velocidad de generación
3. **🤖 Auto-Start (3⭐)**: Comienza con 1 generador de cada tipo
4. **👑 Premium Customers (5⭐)**: +25% tokens por cliente
5. **🏭 Instant Stations (8⭐)**: Estaciones básicas pre-desbloqueadas
6. **💎 Diamond Bonus (10⭐)**: +1 diamante por hora de juego
7. **🌟 Master Bartender (15⭐)**: Todos los bonos anteriores +50%

---

## 🎯 Sistema de Misiones Integrado

### **📅 Misiones Diarias**
- "Servir 20 clientes automáticos" → 🪙 15 tokens
- "Generar 500 unidades de recursos" → 🪙 10 tokens
- "Vender manualmente productos por $5K" → 🪙 12 tokens
- "Activar ofertas en 3 productos diferentes" → 🪙 8 tokens

### **📆 Misiones Semanales**
- "Desbloquear 1 nuevo cliente" → 🪙 50 tokens + 💎 5 diamantes
- "Completar 5 misiones diarias" → 🪙 75 tokens
- "Alcanzar 1000 tokens ganados por clientes" → 💎 10 diamantes
- "Producir 100 cervezas" → 🪙 60 tokens

### **🏆 Logros Únicos**
- "🔓 Cliente Inicial": Desbloquear sistema → 💎 25 diamantes
- "👑 VIP Lounge": Tener 5 clientes activos → 🪙 200 tokens
- "🏭 Fabricante": 10 estaciones desbloqueadas → 💎 50 diamantes
- "💰 Millonario Idle": 100K tokens por clientes → ⭐ 1 estrella directa

---

## 📈 Balanceado Matemático Profesional

### **🔧 Escalado de Generadores**
```
Costo_n = Costo_base × (1.15^n)
Rate_n = Rate_base × (1 + 0.1×n)
```
**Ejemplo Agua**:
- Nivel 1: $10 | 1/3seg
- Nivel 10: $40.46 | 2/3seg
- Nivel 25: $328.33 | 3.5/3seg

### **👥 Economía de Clientes**
```
Tokens_por_cliente = Base_tokens × (1 + Premium_bonus) × Cantidad_productos
Premium_bonus = 0.0 (sin upgrade) → 0.5 (con upgrade)
Frecuencia = 8seg × (1 - Speed_bonus)
Speed_bonus = 0.0 (base) → 0.4 (con upgrade)
```

**🎯 Progresión Objetivo**:
- **Minuto 1-5**: Generación básica, primeras ventas
- **Minuto 5-15**: Acumular 50 💎, desbloquear clientes
- **Minuto 15-30**: Primera expansión de clientes
- **Hora 1**: Sistema idle funcionando, planear prestigio
- **Día 1+**: Loops de prestigio, optimización avanzada

### **💎 Economía de Diamantes**
**Fuentes Gratuitas**:
- Inicio: 100 💎
- Logros: 5-50 💎 cada uno
- Misiones semanales: 5-15 💎
- Prestigio premium (10⭐): 1 💎/hora

**Usos Estratégicos**:
- Sistema de clientes: 50 💎 (obligatorio)
- Nuevos clientes: 25 💎 → 50 💎 → 100 💎 (escalado)
- Upgrades premium: 100-1000 💎
- Aceleration temporal: 20 💎/hora

---

## 🤖 Sistema de Automatización Inteligente

### **🎯 Nivel 1 - Básico (Cash)**
- ⚡ Auto-generadores con timers
- 🔄 Auto-ofertas (habilita/deshabilita por precio)
- 📦 Gestión básica de inventario

### **🎯 Nivel 2 - Intermedio (Tokens)**
- 🏭 Auto-producción cuando hay recursos
- 💰 Auto-venta cuando inventario lleno
- 🎯 Smart pricing (ajusta precios según demanda)

### **🎯 Nivel 3 - Avanzado (Diamantes)**
- 🧠 AI Manager total (optimiza todo automáticamente)
- 📊 Predictive analytics (qué comprar próximo)
- 🚀 Offline progress calculator (hasta 24h)

---

## 💻 Offline Progress System

### **📊 Cálculo de Progreso Offline**
```
Tiempo_offline = Tiempo_actual - Último_guardado
Max_offline = 24 horas (sin premium) | 72 horas (con premium)

Recursos_generados = Rate_por_segundo × Tiempo_offline × Eficiencia_offline
Productos_creados = Min(Recursos_disponibles / Receta_costo)
Clientes_servidos = (Tiempo_offline / Timer_cliente) × Clientes_activos
Tokens_ganados = Clientes_servidos × Tokens_por_cliente

Eficiencia_offline = 0.5 (base) → 0.8 (con upgrades) → 1.0 (premium)
```

### **🎁 Catch-up Bonus**
- **2-6 horas offline**: +25% bonus en siguiente sesión
- **6-12 horas**: +50% bonus
- **12-24 horas**: +100% bonus + 💎 5 diamantes
- **24+ horas**: +200% bonus + acceso a "Offline Package"

---

## 🎨 UI/UX Mejorado v2.0

### **🔢 Display de Monedas Triple**
```
💵 $123.45K    🪙 1,234    💎 56
    ↓             ↓        ↓
 Cash/seg    Tokens/min  Diamantes
```

### **📱 Indicadores Visuales**
- 🟢 Verde: Recursos disponibles, clientes activos
- 🟡 Amarillo: Inventario medio, timers activos
- 🔴 Rojo: Sin recursos, clientes inactivos
- 🟦 Azul: Upgrades disponibles
- 🟣 Morado: Premium content desbloqueado

### **🎊 Efectos de Feedback**
- ✨ Particles al vender productos
- 💫 Glow en botones affordables
- 🎵 Audio cues por tipo de acción
- 📳 Vibración en compras importantes (móvil)

---

## 📊 Métricas de Éxito v2.0

### **📈 KPIs Principales**
- **Retención D1**: >70% (objetivo idle games)
- **Retención D7**: >35%
- **Sesión promedio**: 8-12 minutos
- **Conversión a cliente premium**: 5-8%

### **🎮 Métricas de Gameplay**
- **Tiempo hasta 1er prestigio**: <3 horas
- **% de jugadores que desbloquean clientes**: >85%
- **Promedio de clientes por jugador activo**: 3-5
- **Tiempo promedio offline**: 6-8 horas

### **💰 Métricas de Monetización**
- **ARPU (Average Revenue Per User)**: $2-5
- **ARPPU (Average Revenue Per Paying User)**: $15-25
- **% de ingresos por diamantes**: 60-70%
- **% de ingresos por aceleradores**: 20-25%
- **% de ingresos por donaciones**: 10-15%

---

## 🚀 Roadmap de Contenido Futuro

### **📦 Fase 1 - Sistema Base (Actual)**
- ✅ 4 pestañas principales
- ✅ Sistema de triple moneda
- ✅ Clientes automáticos básicos
- ✅ Prestigio con estrellas

### **📦 Fase 2 - Expansion (3-6 meses)**
- 🔜 Tier 3-5 de recursos premium
- 🔜 Sistema de eventos temporales
- 🔜 Multiplayer leaderboards
- 🔜 Seasonal content y themes

### **📦 Fase 3 - Advanced (6-12 meses)**
- 🔮 Guild system y colaboración
- 🔮 Crafting system avanzado
- 🔮 Multiple bars management
- 🔮 Stock market integration

---

## 🔒 Monetización Ética Detallada

### **💎 Paquetes de Diamantes**
- **Starter Pack**: $2.99 → 200 💎 + "Auto-Customer" upgrade
- **Premium Pack**: $4.99 → 500 💎 + 2x offline efficiency
- **Master Pack**: $9.99 → 1200 💎 + AI Manager + 3 premium customers
- **Supporter Pack**: $19.99 → 3000 💎 + All content + VIP status

### **⚡ Servicios Premium**
- **Double Speed**: $1.99/week → 2x todo el juego
- **Offline Pro**: $2.99/month → Progreso offline hasta 72h
- **Auto-Manager**: $3.99/month → Automatización completa
- **Analytics Pro**: $1.99/month → Estadísticas avanzadas

### **🎁 Donaciones Voluntarias**
- "☕ Café para el dev": $1.99 → 100 💎 gift
- "🍺 Cerveza de apoyo": $4.99 → 300 💎 gift
- "💝 ¡Amo este juego!": $9.99 → 750 💎 gift + Credit especial

### **📜 Principios Éticos**
- ❌ **NUNCA** pay-to-win obligatorio
- ❌ **NUNCA** ads intrusivos
- ❌ **NUNCA** timers abusivos sin alternativas
- ✅ **SIEMPRE** progreso 100% gratuito posible
- ✅ **SIEMPRE** valor real por dinero gastado
- ✅ **SIEMPRE** transparencia total en costs/benefits

---

## 🏁 Conclusión

**Bar-Sik v2.0** representa la **evolución completa** de un clicker básico a un **idle game profesional de clase AAA**. El **sistema de clientes automáticos** cierra el loop de gameplay, permitiendo progresión meaningful tanto online como offline.

### **🎯 Diferenciadores Clave**:
1. **Triple Moneda Balanceada**: Cada moneda tiene propósito claro
2. **Loop Idle Perfecto**: Generación → Producción → Venta automática
3. **Progresión Sin Paredes**: Nunca se bloquea, solo se optimiza
4. **Monetización Ética**: Premium acelera, nunca bloquea
5. **Contenido Escalable**: Sistema preparado para años de expansión

**🏆 Objetivo Final**: Crear la experiencia idle más satisfying y ética del mercado, donde cada decisión importa y cada sesión aporta progreso meaningful hacia el objetivo de convertirse en el **Ultimate Bartender Empire**.

---

**💼 GDC v2.0 | Total: 2,847 palabras | Estado: ✅ COMPLETO PARA IMPLEMENTACIÓN**
