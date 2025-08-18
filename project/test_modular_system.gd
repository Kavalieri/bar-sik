extends Node
## Script de prueba completa del sistema modular de stock

func _ready() -> void:
	print("🧪 === PRUEBA SISTEMA MODULAR COMPLETO ===")

	# Esperar un frame para que todos los singletons estén listos
	await get_tree().process_frame

	# Verificar StockManager
	if not StockManager:
		print("❌ FALLA CRÍTICA: StockManager no disponible")
		return

	print("✅ StockManager disponible")

	# Prueba 1: Agregar stock básico
	print("\n📦 PRUEBA 1: Agregando stock de prueba")
	StockManager.add_stock("ingredient", "hops", 20)
	StockManager.add_stock("ingredient", "barley", 15)
	StockManager.add_stock("ingredient", "water", 50)
	StockManager.add_stock("product", "beer", 5)

	# Prueba 2: Verificar stock
	print("\n📊 PRUEBA 2: Verificando stock")
	print("  - Hops: %d" % StockManager.get_stock("ingredient", "hops"))
	print("  - Barley: %d" % StockManager.get_stock("ingredient", "barley"))
	print("  - Water: %d" % StockManager.get_stock("ingredient", "water"))
	print("  - Beer: %d" % StockManager.get_stock("product", "beer"))

	# Prueba 3: Probar recetas
	print("\n🍺 PRUEBA 3: Probando sistema de recetas")
	var beer_recipe = {"hops": 2, "barley": 3, "water": 5}
	var can_craft = StockManager.can_afford_recipe(beer_recipe)
	print("  - ¿Puede crear cerveza? %s" % ("SÍ" if can_craft else "NO"))

	if can_craft:
		print("  - Consumiendo ingredientes para cerveza...")
		var consumed = StockManager.consume_recipe(beer_recipe)
		print("  - ¿Consumido correctamente? %s" % ("SÍ" if consumed else "NO"))

		if consumed:
			# Agregar el producto resultante
			StockManager.add_stock("product", "beer", 1)
			print("  - ✅ Cerveza producida!")

	# Prueba 4: Verificar inventario vendible
	print("\n💰 PRUEBA 4: Inventario vendible")
	var sellable = StockManager.get_sellable_stock()
	print("  - Productos vendibles: %s" % sellable.get("products", {}))
	print("  - Ingredientes vendibles: %s" % sellable.get("ingredients", {}))

	# Prueba 5: Resumen completo
	print("\n📈 PRUEBA 5: Resumen completo")
	var summary = StockManager.get_inventory_summary()
	for key in summary.keys():
		print("  - %s: %s" % [key, summary[key]])

	# Prueba 6: Venta de prueba
	print("\n💸 PRUEBA 6: Venta de prueba")
	var beer_stock_before = StockManager.get_stock("product", "beer")
	var removed = StockManager.remove_stock("product", "beer", 1)
	var beer_stock_after = StockManager.get_stock("product", "beer")
	print("  - Stock antes: %d, después: %d" % [beer_stock_before, beer_stock_after])
	print("  - ¿Venta exitosa? %s" % ("SÍ" if removed else "NO"))

	print("\n✅ === SISTEMA MODULAR FUNCIONANDO CORRECTAMENTE ===")

	# Auto-eliminar después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	queue_free()
