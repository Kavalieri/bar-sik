extends Node
## LayoutFixHelper - Ayuda a configurar layouts dinámicos para componentes modulares
## Soluciona problemas de anchoring y sizing cuando se crean componentes en runtime

# class_name LayoutFixHelper  # Comentado temporalmente para evitar conflictos RefCounted


## Configurar un componente recién creado con layout responsivo
static func configure_dynamic_component(component: Control) -> void:
	"""
	Configura un componente dinámico con layout responsivo correcto
	"""
	if not component:
		return

	# Configuración básica de tamaño
	component.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	component.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	# Si es un Panel/contenedor, asegurar tamaño mínimo
	if component is Panel or component is VBoxContainer or component is HBoxContainer:
		component.custom_minimum_size = Vector2(300, 60)

	# Para componentes de tienda (ShopContainer), configurar layout especial
	if component.has_method("setup") and str(component.get_script()).contains("ShopContainer"):
		_configure_shop_container(component)

	# Para tarjetas (ItemListCard/BuyCard), configurar layout especial
	elif component is Panel:
		_configure_card_layout(component)


## Configuración específica para ShopContainer
static func _configure_shop_container(shop: Control) -> void:
	"""Configurar layout específico para ShopContainer"""
	shop.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop.custom_minimum_size = Vector2(350, 300)

	print("🛍️ LayoutFix: ShopContainer configurado con layout responsivo")


## Configuración específica para Cards
static func _configure_card_layout(card: Panel) -> void:
	"""Configurar layout específico para cards (BuyCard, ItemListCard)"""
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	card.custom_minimum_size = Vector2(280, 80)

	print("🃏 LayoutFix: Card configurado con layout responsivo")


## Configurar contenedor padre para manejar hijos dinámicos
static func configure_parent_container(container: Control) -> void:
	"""Configurar contenedor padre para componentes dinámicos con orientación vertical para mobile"""
	if not container:
		return

	# Para VBoxContainer, configurar separación vertical
	if container is VBoxContainer:
		container.add_theme_constant_override("separation", 12)
		print("📱 VBoxContainer configurado con separación vertical para mobile")

	# Para HBoxContainer, cambiar a VBoxContainer si es mobile
	elif container is HBoxContainer:
		# Convertir HBoxContainer a comportamiento vertical para mobile
		print("📱 Aplicando layout vertical para mobile en HBoxContainer")

		# Configurar para comportarse como vertical en mobile
		container.custom_minimum_size = Vector2(0, 0)
		container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Para contenedores genéricos, configurar layout flexible
	else:
		container.custom_minimum_size = Vector2(0, 0)
		container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		print("📱 Container genérico configurado para layout responsive")

	# Configuraciones comunes para mobile
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("margin_left", 8)
	container.add_theme_constant_override("margin_right", 8)
	container.add_theme_constant_override("margin_top", 8)
	container.add_theme_constant_override("margin_bottom", 8)


## Forzar actualización de layout después de agregar componentes
static func force_layout_update(container: Control) -> void:
	"""
	Fuerza una actualización del layout después de agregar componentes dinámicos
	"""
	if not container:
		return

	# Forzar recálculo del layout
	container.queue_redraw()
	container.call_deferred("queue_redraw")

	# Si es ScrollContainer, asegurar que funcione correctamente
	if container is ScrollContainer:
		container.call_deferred("ensure_control_visible", container)

	print("🔄 LayoutFix: Layout actualizado forzadamente")


## Debug: Mostrar información de un componente
static func debug_component_layout(component: Control, name: String = "Component") -> void:
	"""Debug helper para ver información de layout"""
	if not component:
		return

	print("🐛 LayoutFix Debug: %s" % name)
	print("   Size: %s" % str(component.size))
	print("   Position: %s" % str(component.position))
	print("   Custom min size: %s" % str(component.custom_minimum_size))
	print("   Size flags H: %d, V: %d" % [
		component.size_flags_horizontal,
		component.size_flags_vertical
	])
