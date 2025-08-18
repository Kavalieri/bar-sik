# 🍺 Bar-Sik - Game Design Document v1.0

## 🎯 Concepto Principal

**Bar-Sik** es un **idle clicker de gestión de bar** donde el jugador comienza como un bartender novato y progresa hasta construir un imperio de bares. El gameplay se centra en la **producción, procesamiento y venta de bebidas** con progresión infinita y sistema de prestigio.

---

## 📱 Especificaciones Técnicas

- **Plataforma**: Windows + Android (iOS futuro)
- **Orientación**: Portrait (1080×1920)
- **Género**: Idle Clicker / Resource Management / Simulation
- **Audiencia**: 13+ (gestión, sin contenido inapropiado)
- **Duración de sesión**: 2-15 minutos (típico de idle games)
- **Monetización**: Ética - Tienda, aceleradores, donaciones

---

## 🎮 Core Loop (Bucle Principal)

```
GENERAR Ingredientes → PROCESAR en Bebidas → VENDER por Dinero → MEJORAR Capacidades → REPETIR
                                    ↓
                           DESBLOQUEAR Nuevos Items
                                    ↓
                         COMPLETAR Misiones → Tokens → Nuevas Recetas
                                    ↓
                            PRESTIGIO → Bonificaciones Permanentes
```

---

## 💰 Sistema de Currencies

### 1. **Dinero (Cash)** 💵
- Moneda principal obtenida vendiendo bebidas
- Usado para: upgrades básicos, automatización, velocidad de producción
- Se resetea parcialmente con prestigio

### 2. **Tokens de Misión** 🎯
- Obtenido completando objetivos específicos
- Usado para: desbloquear nuevos ingredientes, recetas especiales
- NO se resetea con prestigio

### 3. **Estrellas de Prestigio** ⭐
- Obtenido al hacer prestigio (resetear progreso)
- Usado para: bonificaciones permanentes, multipliers globales
- Moneda más valiosa y permanente

---

## 🍹 Sistema de Recursos

### **Tier 1 - Básicos** (Disponibles al inicio)
- 🫐 **Agua**: Ingrediente base, generación por click
- 🍋 **Limón**: Primer ingrediente especial
- 🧊 **Hielo**: Necesario para bebidas frías

### **Tier 2 - Intermedio** (Desbloqueables)
- 🍊 **Naranja**: Para cócteles cítricos
- 🍓 **Fresa**: Para bebidas dulces
- 🌿 **Menta**: Para mojitos y refrescos

### **Tier 3 - Premium** (Prestigio requerido)
- 🥃 **Whiskey**: Bebidas de alta gama
- 🍷 **Vino**: Productos premium
- 🍾 **Champán**: Máximo tier

### **Procesamiento**
```
Ingredientes Básicos → Estaciones de Preparación → Bebidas Finales → Venta
```

**Ejemplos de Recetas**:
- Agua + Limón + Hielo = Limonada (5 cash)
- Agua + Fresa + Hielo = Agua de Fresa (8 cash)
- Whiskey + Hielo = Whiskey on the rocks (50 cash)

---

## ⚙️ Sistema de Upgrades

### **Generación** (Dinero)
1. **Click Power**: Más ingredientes por click
2. **Auto-Clickers**: Generación automática
3. **Velocidad**: Frecuencia de auto-generación
4. **Capacidad**: Límite de almacenamiento

### **Procesamiento** (Dinero)
1. **Estaciones de Trabajo**: Más tipos de bebidas simultáneas
2. **Velocidad de Preparación**: Bebidas más rápido
3. **Eficiencia**: Menos ingredientes requeridos
4. **Calidad**: Mejores precios de venta

### **Premium** (Tokens/Estrellas)
1. **Recetas Especiales**: Nuevas combinaciones
2. **Multipliers**: Bonificaciones globales permanentes
3. **Automatización Avanzada**: Sistemas que se manejan solos
4. **Prestigio Boosts**: Ventajas para futuros reinicios

---

## 🎯 Sistema de Misiones

### **Diarias** (Reset cada 24h)
- "Vende 50 Limonadas" → 10 Tokens
- "Genera 1000 Limones" → 5 Tokens
- "Alcanza 10K de dinero" → 15 Tokens

### **Semanales** (Reset cada lunes)
- "Completa 5 misiones diarias" → 50 Tokens
- "Desbloquea una nueva receta" → 30 Tokens
- "Automatiza 3 ingredientes" → 40 Tokens

### **Logros** (Una sola vez)
- "Primera Venta" → 5 Tokens
- "Millonario" → 100 Tokens
- "Master Bartender" → 200 Tokens
- "Prestigio Novato" → 500 Tokens

---

## ⭐ Sistema de Prestigio

### **Requisitos**
- Haber alcanzado al menos 1M de dinero total
- Tener completados 10 logros básicos

### **Lo que se resetea**
- Dinero actual
- Niveles de upgrades básicos
- Ingredientes almacenados
- Progreso de algunas misiones

### **Lo que se mantiene**
- Tokens de misión
- Estrellas de prestigio (nuevas)
- Recetas desbloqueadas
- Logros completados
- Bonificaciones permanentes

### **Bonificaciones de Prestigio** (Estrellas)
1. **Income Multiplier**: +10% dinero por venta (1 estrella)
2. **Speed Boost**: +15% velocidad global (2 estrellas)
3. **Auto-Start**: Comienza con auto-clickers básicos (5 estrellas)
4. **Rare Ingredients**: Posibilidad de ingredientes raros (10 estrellas)

---

## 💎 Monetización Ética

### **Tienda In-App** (opcional, nunca obligatorio)
1. **Paquete Starter**: 2.99€ - Boost inicial + 100 tokens
2. **Auto-Manager**: 4.99€ - Automatización avanzada
3. **Premium Currency**: 0.99€ - 50 tokens / 1.99€ - 120 tokens
4. **Acelerador Temporal**: 0.99€ - 2x velocidad por 24h

### **Donaciones**
- "☕ Cómprame un café": 1.99€
- "🍺 Cómprame una cerveza": 4.99€
- "🥃 Cómprame un whiskey": 9.99€

### **Filosofía**
- ❌ **SIN** anuncios forzosos
- ❌ **SIN** pay-to-win
- ✅ **SÍ** progresión completamente gratuita
- ✅ **SÍ** compras opcionales que aceleran (no bloquean)

---

## 📊 Métricas y Analytics

### **Retención**
- Sesiones por día
- Tiempo de juego por sesión
- Días consecutivos jugando

### **Progresión**
- Nivel máximo alcanzado
- Dinero total generado
- Prestigios completados
- Recetas desbloqueadas

### **Monetización**
- Conversión a compra
- Valor promedio por usuario
- Retención post-compra

### **Futuro Ranking Online**
- Total de dinero histórico
- Prestigios completados
- Velocidad de progreso
- Logros raros conseguidos

---

## 🎨 Estilo Visual

### **Paleta de Colores**
- **Primario**: Marrón cálido (#8B4513) - Madera del bar
- **Secundario**: Dorado (#FFD700) - Monedas y elementos premium
- **Acento**: Verde menta (#00FF7F) - Ingredientes frescos
- **UI**: Gris oscuro (#2F2F2F) con toques dorados

### **Estética**
- Pixel art moderno (no retro)
- Interfaz limpia y minimalista
- Animaciones suaves y satisfactorias
- Iconos reconocibles y claros

---

## 🚀 Roadmap de Desarrollo

### **Fase 1 - MVP (2-3 semanas)**
- [x] Configuración base del proyecto
- [ ] Sistema básico de resources (agua, limón, hielo)
- [ ] 1 tipo de bebida (limonada)
- [ ] UI básica funcional
- [ ] Sistema de save/load
- [ ] Primera build exportable

### **Fase 2 - Core Features (2-3 semanas)**
- [ ] 3-4 ingredientes más
- [ ] 5-6 recetas de bebidas
- [ ] Sistema de upgrades básico
- [ ] Misiones diarias básicas
- [ ] Animaciones y polish

### **Fase 3 - Monetización (1-2 semanas)**
- [ ] Tienda in-app integrada
- [ ] Sistema de tokens completo
- [ ] Balanceo económico
- [ ] Analytics básicos

### **Fase 4 - Prestigio (2-3 semanas)**
- [ ] Sistema de prestigio completo
- [ ] Bonificaciones permanentes
- [ ] Contenido de alto nivel
- [ ] Polish y optimización

### **Fase 5 - Launch & Beyond**
- [ ] Marketing assets
- [ ] Store presence (Google Play)
- [ ] Community features
- [ ] Contenido post-launch

---

## ✅ Criterios de Éxito

### **Técnicos**
- 60 FPS estables en dispositivos objetivo
- Tiempo de carga < 3 segundos
- Tamaño APK < 50MB
- 0 crashes críticos

### **Gameplay**
- Sesión promedio > 5 minutos
- Retención D1 > 40%
- Retención D7 > 15%
- Rate de conversión > 2%

### **Monetización**
- ARPU > 0.50€
- LTV > 5.00€
- Payback period < 30 días

---

*Este GDD es un documento vivo que se actualizará según el desarrollo y feedback.*
