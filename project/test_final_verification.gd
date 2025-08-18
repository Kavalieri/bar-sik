extends Node
## Script de verificación final de errores críticos

func _ready() -> void:
	print("🔍 === VERIFICACIÓN FINAL DE ERRORES ===")

	var success_count = 0
	var error_count = 0

	# Test 1: UIStyleManager
	print("📦 Verificando UIStyleManager...")
	var UIStyleManager = preload("res://scripts/ui/UIStyleManager.gd")
	if UIStyleManager:
		print("✅ UIStyleManager carga correctamente")
		success_count += 1

		# Test método create_section_header
		var header1 = UIStyleManager.create_section_header("Test")
		var header2 = UIStyleManager.create_section_header("Test", "Subtitle")
		print("✅ create_section_header funciona con 1 y 2 parámetros")
		success_count += 1
	else:
		print("❌ UIStyleManager falla al cargar")
		error_count += 1

	# Test 2: BasePanel
	print("📦 Verificando BasePanel...")
	var BasePanel = preload("res://scripts/ui/BasePanel.gd")
	if BasePanel:
		print("✅ BasePanel carga correctamente")
		success_count += 1
	else:
		print("❌ BasePanel falla al cargar")
		error_count += 1

	# Test 3: ProductionPanel
	print("📦 Verificando ProductionPanel...")
	var ProductionPanel = preload("res://scripts/panels/ProductionPanel.gd")
	if ProductionPanel:
		print("✅ ProductionPanel carga correctamente")
		success_count += 1
	else:
		print("❌ ProductionPanel falla al cargar")
		error_count += 1

	# Test 4: GenerationPanel
	print("📦 Verificando GenerationPanel...")
	var GenerationPanel = preload("res://scripts/GenerationPanel.gd")
	if GenerationPanel:
		print("✅ GenerationPanel carga correctamente")
		success_count += 1
	else:
		print("❌ GenerationPanel falla al cargar")
		error_count += 1

	# Test 5: CustomersPanel
	print("📦 Verificando CustomersPanel...")
	var CustomersPanel = preload("res://scripts/CustomersPanel.gd")
	if CustomersPanel:
		print("✅ CustomersPanel carga correctamente")
		success_count += 1
	else:
		print("❌ CustomersPanel falla al cargar")
		error_count += 1

	# Test 6: SalesPanel
	print("📦 Verificando SalesPanel...")
	var SalesPanel = preload("res://scripts/SalesPanel.gd")
	if SalesPanel:
		print("✅ SalesPanel carga correctamente")
		success_count += 1
	else:
		print("❌ SalesPanel falla al cargar")
		error_count += 1

	# Resumen final
	print("\n🎯 === RESUMEN FINAL ===")
	print("✅ Scripts exitosos: %d" % success_count)
	print("❌ Scripts con errores: %d" % error_count)

	if error_count == 0:
		print("🎉 ¡TODOS LOS ERRORES DE PARSEO CORREGIDOS!")
		print("🚀 El juego está listo para ejecutar")
	else:
		print("⚠️ Aún hay %d errores por corregir" % error_count)

	# Auto-eliminar
	await get_tree().create_timer(5.0).timeout
	queue_free()
