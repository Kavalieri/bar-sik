#!/usr/bin/env python3
"""
Test para verificar las correcciones aplicadas
"""

def test_sales_price_fix():
    """Simular la función get_item_price corregida"""

    def get_ingredient_price(ingredient_type):
        """Simular GameUtils.get_ingredient_price"""
        prices = {
            "barley": 0.5,
            "hops": 0.8,
            "water": 0.1,
            "yeast": 1.0
        }
        return prices.get(ingredient_type, 0.2)

    def get_item_price(item_type, item_name):
        """Función corregida del SalesManager"""
        if item_type == "product":
            return 5.0  # Simular precio de producto
        if item_type == "ingredient" or item_type == "resource":
            return get_ingredient_price(item_name)
        return 0.0

    print("🧪 TESTING SALES PRICE FIX...")
    print("=" * 50)

    # Test casos problemáticos
    test_cases = [
        ("resource", "barley", "Problema original - tipo 'resource'"),
        ("ingredient", "barley", "Caso normal - tipo 'ingredient'"),
        ("resource", "hops", "Otro ingrediente como 'resource'"),
        ("product", "basic_beer", "Producto normal")
    ]

    for item_type, item_name, description in test_cases:
        price = get_item_price(item_type, item_name)
        status = "✅ PASS" if price > 0 else "❌ FAIL"
        print(f"{status} {description}: {item_type}/{item_name} = ${price:.2f}")

    print("=" * 50)

def test_station_config_fix():
    """Simular el acceso a GameConfig.STATION_DATA"""

    # Simular GameConfig.STATION_DATA corregido
    STATION_DATA = {
        "brewery": {
            "name": "Cervecería",
            "description": "Produce cerveza",
            "emoji": "🏭",
            "base_price": 50.0,
            "recipe": {"barley": 2, "hops": 1, "water": 3},
            "produces": "basic_beer",
            "products": ["basic_beer", "premium_beer"]
        },
        "bar_station": {
            "name": "Estación de Bar",
            "description": "Prepara cócteles",
            "emoji": "🍸",
            "base_price": 75.0,
            "recipe": {"water": 1, "yeast": 1},
            "produces": "cocktail",
            "products": ["cocktail"]
        }
    }

    def _format_recipe_with_availability(station_id, available_resources):
        station_data = STATION_DATA.get(station_id, {})
        recipe = station_data.get("recipe", {})

        if not recipe:
            return "Sin receta"

        recipe_parts = []
        for ingredient_id in recipe.keys():
            needed_amount = recipe[ingredient_id]
            available_amount = available_resources.get(ingredient_id, 0)
            emoji = {"barley": "🌾", "hops": "🌱", "water": "🧃", "yeast": "🍞"}.get(ingredient_id, "?")

            recipe_parts.append(f"{emoji} {needed_amount}/{available_amount}")

        return " + ".join(recipe_parts)

    print("\n🧪 TESTING STATION CONFIG FIX...")
    print("=" * 50)

    # Simular recursos disponibles
    available_resources = {"barley": 8, "hops": 83, "water": 50, "yeast": 0}

    for station_id in STATION_DATA.keys():
        station_data = STATION_DATA[station_id]
        recipe_text = _format_recipe_with_availability(station_id, available_resources)
        price = station_data.get("base_price", 0)

        status = "✅ PASS" if recipe_text != "Sin receta" and price > 0 else "❌ FAIL"
        print(f"{status} {station_data['name']}: ${price} | {recipe_text}")

    print("=" * 50)

if __name__ == "__main__":
    test_sales_price_fix()
    test_station_config_fix()
    print("\n🎉 TESTS COMPLETED! Si todo pasa, las correcciones deberían funcionar.")
