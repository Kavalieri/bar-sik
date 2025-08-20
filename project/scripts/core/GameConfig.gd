extends Resource
class_name GameConfig
## GameConfig - Configuración centralizada del juego
## Define constantes, balances y configuraciones del gameplay

## === CONFIGURACIÓN ECONÓMICA ===

## Dinero inicial del jugador
const STARTING_MONEY: float = 50.0

## Factores de escalado de costos
const GENERATOR_SCALE_FACTOR: float = 1.10
const STATION_SCALE_FACTOR: float = 1.15

## === CONFIGURACIÓN DE TIMERS ===

## Tiempos de generación de recursos (en segundos)
const RESOURCE_GENERATION_INTERVAL: float = 3.0

## Tiempo base entre clientes automáticos
const BASE_CUSTOMER_INTERVAL: float = 8.0

## Tiempo de guardado automático
const AUTO_SAVE_INTERVAL: float = 30.0

## === CONFIGURACIÓN DE BALANCEADO ===

## Multiplicadores de upgrades de clientes
const PREMIUM_CUSTOMER_MULTIPLIER: float = 1.5
const FASTER_CUSTOMER_MULTIPLIER: float = 0.6  # Reduce el tiempo
const BULK_BUYER_MAX_QUANTITY: int = 3

## === CONFIGURACIÓN DE DATOS INICIALES ===

## Definición centralizada de recursos
const RESOURCE_DATA = {
	"barley":
	{
		"name": "Cebada",
		"emoji": "🌾",
		"tier": 1,
		"base_generation": 1,
		"max_storage": 100,
		"unlock_cost": 0,
		"unlocked": true
	},
	"hops":
	{
		"name": "Lúpulo",
		"emoji": "🌱",
		"tier": 1,
		"base_generation": 1,
		"max_storage": 100,
		"unlock_cost": 0,
		"unlocked": true
	},
	"water":
	{
		"name": "Agua",
		"emoji": "🧃",
		"tier": 1,
		"base_generation": 1,
		"max_storage": 50,
		"unlock_cost": 0,
		"unlocked": true
	},
	"yeast":
	{
		"name": "Levadura",
		"emoji": "🍞",
		"tier": 1,
		"base_generation": 1,
		"max_storage": 25,
		"unlock_cost": 0,
		"unlocked": true
	}
}

## Definición centralizada de productos
const PRODUCT_DATA = {
	"basic_beer":
	{
		"name": "Cerveza Básica",
		"emoji": "🍺",
		"base_price": 5.0,
		"recipe": {"barley": 1, "water": 1, "yeast": 1}
	},
	"premium_beer":
	{
		"name": "Cerveza Premium",
		"emoji": "🍻",
		"base_price": 12.0,
		"recipe": {"barley": 2, "hops": 1, "water": 2, "yeast": 1}
	},
	"cocktail":
	{"name": "Cóctel", "emoji": "🍹", "base_price": 20.0, "recipe": {"water": 1, "yeast": 1}}
}

## Definición centralizada de generadores
const GENERATOR_DATA = {
	"barley_farm":
	{
		"name": "Granja de Cebada",
		"description": "Genera cebada automáticamente",
		"emoji": "🚜",
		"base_price": 10.0,
		"resource_type": "barley"
	},
	"hops_farm":
	{
		"name": "Granja de Lúpulo",
		"description": "Genera lúpulo para cerveza",
		"emoji": "🌿",
		"base_price": 15.0,
		"resource_type": "hops"
	},
	"water_collector":
	{
		"name": "Recolector de Agua",
		"description": "Recolecta agua pura",
		"emoji": "💧",
		"base_price": 8.0,
		"resource_type": "water"
	}
}

## Definición centralizada de estaciones
const STATION_DATA = {
	"brewery":
	{
		"name": "Cervecería",
		"description": "Produce cerveza",
		"emoji": "🏭",
		"base_price": 50.0,
		"recipe": {"barley": 2, "hops": 1, "water": 3},
		"produces": "basic_beer",
		"products": ["basic_beer", "premium_beer"]
	},
	"bar_station":
	{
		"name": "Estación de Bar",
		"description": "Prepara cócteles",
		"emoji": "🍸",
		"base_price": 75.0,
		"recipe": {"water": 1, "yeast": 1},
		"produces": "cocktail",
		"products": ["cocktail"]
	}
}


## Productos iniciales
static func get_default_products() -> Dictionary:
	var dict = {}
	for key in PRODUCT_DATA.keys():
		dict[key] = 0
	return dict


## Generadores iniciales
static func get_default_generators() -> Dictionary:
	var dict = {}
	for key in GENERATOR_DATA.keys():
		dict[key] = 0
	return dict


## Estaciones iniciales
static func get_default_stations() -> Dictionary:
	var dict = {}
	for key in STATION_DATA.keys():
		dict[key] = 0
	return dict


## === VALIDACIÓN DE CONFIGURACIÓN ===


## Validar que la configuración es coherente
static func validate_config() -> bool:
	var valid = true

	if STARTING_MONEY <= 0:
		print("⚠️ STARTING_MONEY debe ser mayor que 0")
		valid = false

	if GENERATOR_SCALE_FACTOR <= 1.0:
		print("⚠️ GENERATOR_SCALE_FACTOR debe ser mayor que 1.0")
		valid = false

	if STATION_SCALE_FACTOR <= 1.0:
		print("⚠️ STATION_SCALE_FACTOR debe ser mayor que 1.0")
		valid = false

	return valid
