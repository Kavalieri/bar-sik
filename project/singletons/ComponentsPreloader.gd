extends Node

# =============================================================================
# ComponentsPreloader - Singleton para precargar componentes modulares
# =============================================================================
# Elimina duplicación de preloads en todos los paneles
# Centraliza las referencias a los componentes de Scene Composition

# Scene Composition Components - Preloaded una sola vez
const ITEM_LIST_CARD_SCENE = preload("res://scenes/ui/components/ItemListCard.tscn")
const SHOP_CONTAINER_SCENE = preload("res://scenes/ui/components/ShopContainer.tscn")
const BUY_CARD_SCENE = preload("res://scenes/ui/components/BuyCard.tscn")

# Factory methods para crear instancias
func create_item_list_card() -> Control:
	return ITEM_LIST_CARD_SCENE.instantiate()

func create_shop_container() -> Control:
	return SHOP_CONTAINER_SCENE.instantiate()

func create_buy_card() -> Control:
	return BUY_CARD_SCENE.instantiate()

# Verificación de componentes disponibles
func has_component(component_name: String) -> bool:
	match component_name:
		"ItemListCard", "item_list_card":
			return true
		"ShopContainer", "shop_container":
			return true
		"BuyCard", "buy_card":
			return true
		_:
			return false

func _ready():
	print("ComponentsPreloader: Scene Composition components loaded")
