extends Node
## Script de verificación de sintaxis para componentes

func _ready() -> void:
	print("🔍 === VERIFICACIÓN DE SINTAXIS ===")

	# Verificar que las clases se puedan cargar
	print("📦 Verificando OffersComponent...")
	var offers_test = preload("res://scripts/components/OffersComponent.gd")
	if offers_test:
		print("✅ OffersComponent carga correctamente")
	else:
		print("❌ OffersComponent falla al cargar")

	print("📦 Verificando StockDisplayComponent...")
	var stock_test = preload("res://scripts/components/StockDisplayComponent.gd")
	if stock_test:
		print("✅ StockDisplayComponent carga correctamente")
	else:
		print("❌ StockDisplayComponent falla al cargar")

	print("📦 Verificando StockManager...")
	if StockManager:
		print("✅ StockManager singleton disponible")
	else:
		print("❌ StockManager singleton no disponible")

	print("🎯 === VERIFICACIÓN COMPLETADA ===")

	# Auto-eliminar
	await get_tree().create_timer(2.0).timeout
	queue_free()
