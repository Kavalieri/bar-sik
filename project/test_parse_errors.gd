extends Node
## Script de verificación de errores de parseo

func _ready() -> void:
	print("🔍 === VERIFICACIÓN DE ERRORES DE PARSEO ===")

	# Intentar cargar scripts problemáticos
	print("📦 Verificando UIStyleManager...")
	var ui_style = preload("res://scripts/ui/UIStyleManager.gd")
	if ui_style:
		print("✅ UIStyleManager carga correctamente")
		
		# Probar método create_section_header
		var header1 = UIStyleManager.create_section_header("Test")
		print("✅ create_section_header(1 param) funciona")
		
		var header2 = UIStyleManager.create_section_header("Test", "Subtitle")
		print("✅ create_section_header(2 param) funciona")
	else:
		print("❌ UIStyleManager falla al cargar")

	print("📦 Verificando BasePanel...")
	var base_panel = preload("res://scripts/ui/BasePanel.gd")
	if base_panel:
		print("✅ BasePanel carga correctamente")
	else:
		print("❌ BasePanel falla al cargar")

	print("🎯 === VERIFICACIÓN COMPLETADA ===")
	
	# Auto-eliminar después de 3 segundos
	await get_tree().create_timer(3.0).timeout
	queue_free()
