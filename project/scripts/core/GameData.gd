extends Resource
class_name GameData
## GameData - Estructura centralizada de datos del juego
## Separar datos de lógica para mejor mantenibilidad

## Datos económicos
@export var money: float = 50.0

## Recursos disponibles
@export var resources: Dictionary = {
	"barley": 0,
	"hops": 0,
	"water": 0,
	"yeast": 0
}

## Productos fabricados
@export var products: Dictionary = {
	"basic_beer": 0,
	"premium_beer": 0,
	"cocktail": 0
}

## Generadores poseídos
@export var generators: Dictionary = {
	"water_collector": 0,
	"barley_farm": 0,
	"hops_farm": 0
}

## Estaciones de producción
@export var stations: Dictionary = {
	"brewery": 0,
	"bar_station": 0
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
@export var milestones: Dictionary = {
	"generators": {},
	"stations": {}
}

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
	upgrades = data.get("upgrades", upgrades)
	milestones = data.get("milestones", milestones)
	statistics = data.get("statistics", statistics)
