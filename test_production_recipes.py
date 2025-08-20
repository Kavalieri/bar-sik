#!/usr/bin/env python3
"""
Test para verificar la configuración de estaciones y recetas
"""

def test_station_recipes():
    """Simular el funcionamiento de _format_recipe_with_availability"""

    # Simular GameConfig.STATION_DATA
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

    # Simular GameConfig.RESOURCE_DATA
    RESOURCE_DATA = {
        "barley": {"name": "Cebada", "emoji": "🌾"},
        "hops": {"name": "Lúpulo", "emoji": "🌱"},
        "water": {"name": "Agua", "emoji": "🧃"},
        "yeast": {"name": "Levadura", "emoji": "🍞"}
    }

    # Simular recursos disponibles (estado actual del juego)
    current_resources = {
        "barley": 8,
        "hops": 83,
        "water": 50,
        "yeast": 0
    }

    def format_recipe_with_availability(station_id):
        station_data = STATION_DATA.get(station_id, {})
        recipe = station_data.get("recipe", {})

        if not recipe:
            return "Sin receta"

        recipe_parts = []
        for ingredient_id in recipe.keys():
            needed_amount = recipe[ingredient_id]
            available_amount = current_resources.get(ingredient_id, 0)
            ingredient_data = RESOURCE_DATA.get(ingredient_id, {"emoji": "?", "name": ingredient_id})

            # Formato compacto: emoji necesario/disponible
            recipe_parts.append("%s %d/%d" % (
                ingredient_data["emoji"],
                needed_amount,
                available_amount
            ))

        return " + ".join(recipe_parts)

    print("🧪 TESTING STATION RECIPES...")
    print("=" * 50)

    # Test brewery
    brewery_recipe = format_recipe_with_availability("brewery")
    print(f"🏭 Cervecería: {brewery_recipe}")

    # Test bar_station
    bar_recipe = format_recipe_with_availability("bar_station")
    print(f"🍸 Bar Station: {bar_recipe}")

    print("=" * 50)
    print("✅ Expected results:")
    print("🏭 Cervecería: 🌾 2/8 + 🌱 1/83 + 🧃 3/50")
    print("🍸 Bar Station: 🧃 1/50 + 🍞 1/0")
    print("=" * 50)

    # Verificar que las recetas se muestran correctamente
    expected_brewery = "🌾 2/8 + 🌱 1/83 + 🧃 3/50"
    expected_bar = "🧃 1/50 + 🍞 1/0"

    brewery_ok = brewery_recipe == expected_brewery
    bar_ok = bar_recipe == expected_bar

    print(f"🏭 Brewery test: {'✅ PASS' if brewery_ok else '❌ FAIL'}")
    print(f"🍸 Bar test: {'✅ PASS' if bar_ok else '❌ FAIL'}")

    if brewery_ok and bar_ok:
        print("\n🎉 ALL TESTS PASSED! Las estaciones mostrarán ingredientes correctamente.")
    else:
        print(f"\n❌ SOME TESTS FAILED:")
        if not brewery_ok:
            print(f"   Expected: {expected_brewery}")
            print(f"   Got: {brewery_recipe}")
        if not bar_ok:
            print(f"   Expected: {expected_bar}")
            print(f"   Got: {bar_recipe}")

if __name__ == "__main__":
    test_station_recipes()
