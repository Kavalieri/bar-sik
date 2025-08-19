extends Resource
class_name GameData
## GameData - Estructura centralizada de datos del juego
## Separar datos de lógica para mejor mantenibilidad

## Datos económicos
@export var money: float = 50.0

## Estado del tutorial
@export var tutorial_completed: bool = false
@export var first_generator_bought: bool = false

## Recursos disponibles
@export var resources: Dictionary = {"barley": 0, "hops": 0, "water": 0, "yeast": 0}

## Límites máximos de recursos (capacidad de almacenamiento)
@export var resource_limits: Dictionary = {"barley": 100, "hops": 100, "water": 50, "yeast": 25}

## Productos fabricados
@export var products: Dictionary = GameConfig.get_default_products()

## Generadores poseídos
@export var generators: Dictionary = GameConfig.get_default_generators()

## Estaciones de producción
@export var stations: Dictionary = GameConfig.get_default_stations()

## Sistema de ofertas automáticas para clientes
@export var offers: Dictionary = {
	"brewery": {"enabled": false, "price_multiplier": 1.0},  # Multiplicador del precio base
	"bar_station": {"enabled": false, "price_multiplier": 1.0}
}

## Sistema de upgrades
@export var upgrades: Dictionary = {
	"auto_sell_enabled": false,
	"auto_sell_speed": 1.0,
	"auto_sell_efficiency": 1.0,
	"manager_level": 0,
	"faster_customers": false,
	"premium_customers": false,
	"bulk_buyers": false
}

## Hitos desbloqueados
@export var milestones: Dictionary = {"generators": {}, "stations": {}}

## Estadísticas del juego
@export var statistics: Dictionary = {
	"total_money_earned": 0.0,
	"products_sold": 0,
	"customers_served": 0,
	"resources_generated": 0,
	"products_crafted": 0,
	"autosell_earnings": 0.0
}


## Validar integridad de datos
func validate() -> bool:
	return money >= 0.0 and resources.size() > 0


## Obtener datos como diccionario (compatibilidad legacy)
func to_dict() -> Dictionary:
	return {
		"money": money,
		"resources": resources,
		"products": products,
		"generators": generators,
		"stations": stations,
		"offers": offers,
		"upgrades": upgrades,
		"milestones": milestones,
		"statistics": statistics
	}


## Cargar desde diccionario
func from_dict(data: Dictionary) -> void:
	money = data.get("money", 50.0)
	resources = data.get("resources", resources)
	products = data.get("products", products)
	generators = data.get("generators", generators)
	stations = data.get("stations", stations)
	offers = data.get("offers", offers)
	upgrades = data.get("upgrades", upgrades)
	milestones = data.get("milestones", milestones)
	statistics = data.get("statistics", statistics)
