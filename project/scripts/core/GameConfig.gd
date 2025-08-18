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

## Recursos iniciales
static func get_default_resources() -> Dictionary:
	return {
		"barley": 0,
		"hops": 0,
		"water": 0,
		"yeast": 0
	}

## Productos iniciales
static func get_default_products() -> Dictionary:
	return {
		"basic_beer": 0,
		"premium_beer": 0,
		"cocktail": 0
	}

## Generadores iniciales
static func get_default_generators() -> Dictionary:
	return {
		"water_collector": 0,
		"barley_farm": 0,
		"hops_farm": 0
	}

## Estaciones iniciales
static func get_default_stations() -> Dictionary:
	return {
		"brewery": 0,
		"bar_station": 0
	}

## Upgrades iniciales
static func get_default_upgrades() -> Dictionary:
	return {
		"auto_sell_enabled": false,
		"auto_sell_speed": 1.0,
		"auto_sell_efficiency": 1.0,
		"manager_level": 0,
		"faster_customers": false,
		"premium_customers": false,
		"bulk_buyers": false
	}

## Hitos iniciales
static func get_default_milestones() -> Dictionary:
	return {
		"generators": {},
		"stations": {}
	}

## Estadísticas iniciales
static func get_default_statistics() -> Dictionary:
	return {
		"total_money_earned": 0.0,
		"products_sold": 0,
		"customers_served": 0,
		"resources_generated": 0,
		"products_crafted": 0,
		"autosell_earnings": 0.0
	}

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
