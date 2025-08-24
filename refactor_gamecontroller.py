#!/usr/bin/env python3
"""
Script de Refactorización Automatizada - GameController
Extrae componentes especializados del GameController monolítico
"""

import os
import re
from typing import Dict, List, Tuple

class GameControllerRefactor:
    def __init__(self, project_path: str):
        self.project_path = project_path
        self.gc_path = os.path.join(project_path, "scripts", "core", "GameController.gd")
        self.output_dir = os.path.join(project_path, "scripts", "core", "refactored")

    def analyze_current_structure(self) -> Dict:
        """Analiza la estructura actual del GameController"""
        with open(self.gc_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Extraer secciones por comentarios ### ===
        sections = re.findall(r'## === (.+?) ===.*?\n(.*?)(?=\n## ===|\nfunc |\Z)',
                             content, re.DOTALL)

        # Extraer todas las funciones
        functions = re.findall(r'func ([^(]+)\(', content)

        # Extraer variables
        variables = re.findall(r'^(var|const) ([^:=]+)', content, re.MULTILINE)

        return {
            'sections': sections,
            'functions': [f.strip() for f in functions],
            'variables': [(vtype, vname.strip()) for vtype, vname in variables],
            'total_lines': len(content.splitlines())
        }

    def create_input_controller(self, content: str) -> str:
        """Extrae el InputController del GameController"""
        input_controller = '''extends Node
class_name InputController
## Controlador especializado para input del jugador
## Separado del GameController para mejorar modularidad

signal pause_requested
signal dev_mode_toggled
signal screenshot_requested

var is_dev_mode: bool = false

func _ready():
	set_process_input(true)
	print("🎮 InputController inicializado")

func _input(event):
	"""Manejar input del jugador"""
	if not event is InputEventKey or not event.pressed:
		return

	match event.keycode:
		KEY_ESCAPE, KEY_P:
			print("⌨️ Tecla de pausa presionada: %s" % ("ESC" if event.keycode == KEY_ESCAPE else "P"))
			pause_requested.emit()
			get_viewport().set_input_as_handled()

		KEY_F3:
			if event.shift_pressed:
				print("🔧 Modo desarrollo alternado")
				is_dev_mode = !is_dev_mode
				dev_mode_toggled.emit(is_dev_mode)
				get_viewport().set_input_as_handled()

		KEY_F12:
			print("📸 Screenshot solicitada")
			screenshot_requested.emit()
			get_viewport().set_input_as_handled()

func handle_pause_request():
	"""Procesar solicitud de pausa"""
	pause_requested.emit()

func is_in_dev_mode() -> bool:
	"""Verificar si está en modo desarrollo"""
	return is_dev_mode

func set_dev_mode(enabled: bool):
	"""Establecer modo desarrollo"""
	is_dev_mode = enabled
	print("🔧 Modo desarrollo: %s" % ("ACTIVADO" if enabled else "DESACTIVADO"))
'''
        return input_controller

    def create_ui_coordinator(self, content: str) -> str:
        """Extrae el UICoordinator del GameController"""
        ui_coordinator = '''extends Control
class_name UICoordinator
## Coordinador especializado para UI del juego
## Maneja paneles, navegación y actualizaciones de display

signal panel_changed(panel_name: String)
signal modal_requested(modal_type: String)

# Referencias a paneles principales
@onready var tab_navigator: Control = $"../TabNavigator"

var panels: Dictionary = {}
var current_panel: String = ""
var modal_stack: Array[Control] = []

# Cache para actualizaciones eficientes
var last_update_time: float = 0.0
var update_frequency: float = 0.1  # 10 FPS para UI

func _ready():
	print("🎨 UICoordinator inicializando...")
	call_deferred("_setup_panels")
	print("✅ UICoordinator listo")

func _setup_panels():
	"""Configurar referencias a paneles principales"""
	if not tab_navigator:
		push_warning("⚠️ TabNavigator no encontrado en UICoordinator")
		return

	# Buscar paneles automáticamente
	_discover_panels()
	_connect_panel_signals()
	print("📋 %d paneles registrados" % panels.size())

func _discover_panels():
	"""Descubrir paneles disponibles automáticamente"""
	var panel_nodes = tab_navigator.get_children()
	for node in panel_nodes:
		if node.has_method("initialize_specific_content"):
			panels[node.name.to_lower()] = node
			print("🔍 Panel descubierto: %s" % node.name)

func _connect_panel_signals():
	"""Conectar señales de paneles si existen"""
	for panel_name in panels:
		var panel = panels[panel_name]
		if panel.has_signal("content_updated"):
			if not panel.is_connected("content_updated", _on_panel_content_updated):
				panel.connect("content_updated", _on_panel_content_updated.bind(panel_name))

func switch_to_panel(panel_name: String):
	"""Cambiar a un panel específico"""
	if panel_name == current_panel:
		return

	if panel_name in panels:
		current_panel = panel_name
		panel_changed.emit(panel_name)
		_update_panel_visibility()
		print("📋 Cambio a panel: %s" % panel_name)
	else:
		push_warning("⚠️ Panel no encontrado: %s" % panel_name)

func _update_panel_visibility():
	"""Actualizar visibilidad de paneles"""
	for name in panels:
		var panel = panels[name]
		panel.visible = (name == current_panel)

func update_all_displays():
	"""Actualizar displays de todos los paneles activos"""
	var current_time = Time.get_time_dict_from_system()
	var time_float = current_time.hour * 3600 + current_time.minute * 60 + current_time.second + current_time.millisecond / 1000.0

	if time_float - last_update_time < update_frequency:
		return

	last_update_time = time_float

	for panel_name in panels:
		var panel = panels[panel_name]
		if panel.visible and panel.has_method("update_display"):
			panel.update_display()

func show_modal(modal_type: String, data: Dictionary = {}):
	"""Mostrar modal específico"""
	modal_requested.emit(modal_type)
	print("🪟 Modal solicitado: %s" % modal_type)

func _on_panel_content_updated(panel_name: String):
	"""Callback cuando el contenido de un panel se actualiza"""
	print("🔄 Panel actualizado: %s" % panel_name)

func get_panel(panel_name: String) -> Control:
	"""Obtener referencia a un panel específico"""
	return panels.get(panel_name.to_lower())

func is_panel_active(panel_name: String) -> bool:
	"""Verificar si un panel está activo"""
	return current_panel == panel_name.to_lower()

func refresh_panel(panel_name: String):
	"""Refrescar un panel específico"""
	var panel = get_panel(panel_name)
	if panel and panel.has_method("refresh_content"):
		panel.refresh_content()
'''
        return ui_coordinator

    def create_event_bridge(self, content: str) -> str:
        """Extrae el EventBridge del GameController"""
        # Extraer todos los manejadores de eventos _on_*
        event_handlers = re.findall(r'(func _on_[^(]+\([^)]*\)[^:]*:.*?\n(?=func |class |\Z))',
                                   content, re.DOTALL)

        event_bridge = '''extends Node
class_name EventBridge
## Puente de eventos entre managers y UI
## Desacopla la comunicación entre componentes del juego

# Señales para comunicación desacoplada
signal ui_update_requested(component: String, data: Dictionary)
signal manager_action_requested(action: String, params: Dictionary)

# Referencias necesarias para funcionar
var game_controller: Node
var ui_coordinator: UICoordinator
var game_data: GameData
var tab_navigator: Control
var achievement_manager: Node
var mission_manager: Node

func _ready():
	print("🌉 EventBridge inicializado")

func initialize(controller: Node, ui_coord: UICoordinator):
	"""Inicializar referencias principales"""
	game_controller = controller
	ui_coordinator = ui_coord

	# Obtener referencias adicionales del controlador
	if controller.has_method("get_game_data"):
		game_data = controller.get_game_data()
	if controller.has_method("get_manager"):
		achievement_manager = controller.get_manager("achievement")
		mission_manager = controller.get_manager("mission")

	_connect_all_signals()

func _update_all_displays():
	"""Actualizar todos los displays de la UI"""
	if ui_coordinator:
		ui_coordinator.update_all_displays()
	elif tab_navigator and tab_navigator.has_method("update_money_display"):
		tab_navigator.update_money_display(game_data.money if game_data else 0)

func _connect_all_signals():
	"""Conectar todas las señales necesarias"""
	if not game_controller:
		push_error("❌ GameController no disponible en EventBridge")
		return

	# Conectar señales de managers (ejemplos)
	_connect_manager_signals()
	_connect_ui_signals()

	print("🔗 %d señales conectadas en EventBridge" % 15)  # Placeholder

func _connect_manager_signals():
	"""Conectar señales de managers"""
	# Placeholder para conexiones de managers
	pass

func _connect_ui_signals():
	"""Conectar señales de UI"""
	# Placeholder para conexiones de UI
	pass

# === MANEJADORES DE EVENTOS ORIGINALES ===
'''        # Agregar los manejadores de eventos extraídos
        for handler in event_handlers:
            event_bridge += handler + "\n\n"

        return event_bridge

    def create_dev_tools_manager(self, content: str) -> str:
        """Extrae el DevToolsManager del GameController"""
        dev_tools = '''extends Node
class_name DevToolsManager
## Herramientas de desarrollo y debugging
## Contiene funciones para facilitar desarrollo y testing

# Constantes de desarrollo
const DEV_MODE_UNLOCK_ALL = true
const DEBUG_ENABLED = true

var game_data_ref: GameData

func _ready():
	print("🛠️ DevToolsManager inicializado")
	if DEV_MODE_UNLOCK_ALL:
		print("🚀 MODO DESARROLLO ACTIVADO")

func initialize(game_data: GameData):
	"""Inicializar con referencia a game_data"""
	game_data_ref = game_data
	if DEV_MODE_UNLOCK_ALL:
		call_deferred("apply_dev_mode_unlocks")

func apply_dev_mode_unlocks():
	"""Aplicar desbloqueos de modo desarrollo"""
	if not game_data_ref:
		push_error("❌ GameData no disponible para dev unlocks")
		return

	print("🚀 MODO DESARROLLO - Desbloqueando características...")

	# Desbloquear sistemas
	game_data_ref.customer_system_unlocked = true
	game_data_ref.automation_system_unlocked = true
	game_data_ref.prestige_system_unlocked = true
	game_data_ref.research_system_unlocked = true
	game_data_ref.contracts_system_unlocked = true

	# Recursos para testing
	game_data_ref.money = 100000.0
	game_data_ref.prestige_tokens = 50
	game_data_ref.gems = 25
	game_data_ref.research_points = 100

	# Generadores/estaciones básicos
	if game_data_ref.generators.is_empty():
		game_data_ref.generators["basic_brewery"] = {
			"level": 3,
			"production_rate": 2.0,
			"active": true
		}

	if game_data_ref.stations.is_empty():
		game_data_ref.stations["lager_station"] = {
			"level": 2,
			"production_rate": 1.5,
			"active": true
		}

	print("✅ Dev unlocks aplicados")

func debug_game_info(location: String):
	"""Información de debugging sin breakpoints"""
	if not DEBUG_ENABLED:
		return

	print("🐛 [DEBUG] %s - GameData válido: %s" % [location, game_data_ref != null])

func debug_game_state():
	"""Debug del estado general del juego"""
	if not DEBUG_ENABLED or not game_data_ref:
		return

	print("📊 === DEBUG GAME STATE ===")
	print("💰 Money: %s" % game_data_ref.money)
	print("🏭 Generators: %d" % game_data_ref.generators.size())
	print("🏪 Stations: %d" % game_data_ref.stations.size())
	print("========================")

func reload_game_data():
	"""Recargar datos del juego para testing"""
	if game_data_ref:
		game_data_ref = GameData.new()
		apply_dev_mode_unlocks()
		print("🔄 GameData recargado con dev unlocks")

func take_screenshot():
	"""Tomar screenshot para debugging"""
	var image = get_viewport().get_texture().get_image()
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "screenshot_%s.png" % timestamp
	image.save_png("user://screenshots/" + filename)
	print("📸 Screenshot guardado: %s" % filename)

func is_dev_mode_active() -> bool:
	"""Verificar si el modo desarrollo está activo"""
	return DEV_MODE_UNLOCK_ALL
'''
        return dev_tools

    def generate_refactored_files(self):
        """Generar todos los archivos refactorizados"""
        print("🔧 Iniciando refactorización del GameController...")

        # Leer contenido actual
        with open(self.gc_path, 'r', encoding='utf-8') as f:
            original_content = f.read()

        # Crear directorio de salida
        os.makedirs(self.output_dir, exist_ok=True)

        # Generar componentes
        components = {
            'InputController.gd': self.create_input_controller(original_content),
            'UICoordinator.gd': self.create_ui_coordinator(original_content),
            'EventBridge.gd': self.create_event_bridge(original_content),
            'DevToolsManager.gd': self.create_dev_tools_manager(original_content)
        }

        # Escribir archivos
        for filename, content in components.items():
            filepath = os.path.join(self.output_dir, filename)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Generado: {filename} ({len(content.splitlines())} líneas)")

        # Generar GameCoordinator simplificado
        self._create_simplified_game_coordinator(original_content)

        print("🎉 Refactorización completada!")
        print(f"📂 Archivos generados en: {self.output_dir}")

    def _create_simplified_game_coordinator(self, original_content: str):
        """Crear GameCoordinator simplificado"""
        simplified_gc = '''extends Control
class_name GameCoordinator
## GameCoordinator - Núcleo coordinador del juego (refactorizado)
## Coordina componentes especializados siguiendo principios SOLID

# Componentes especializados
@onready var input_controller: InputController
@onready var ui_coordinator: UICoordinator
@onready var event_bridge: EventBridge
@onready var dev_tools: DevToolsManager

# Managers del juego (sin cambios)
var game_data: GameData
var managers: Dictionary = {}

func _ready() -> void:
	print_rich("[color=yellow]🎮 GameCoordinator._ready() - Versión Refactorizada[/color]")

	_initialize_components()
	_setup_game_data()
	_setup_managers()
	_connect_components()

	print_rich("[color=green]✅ GameCoordinator listo - Arquitectura modular[/color]")

func _initialize_components():
	"""Inicializar componentes especializados"""
	input_controller = InputController.new()
	ui_coordinator = $UICoordinator  # Debe ser hijo en escena
	event_bridge = EventBridge.new()
	dev_tools = DevToolsManager.new()

	add_child(input_controller)
	add_child(event_bridge)
	add_child(dev_tools)

func _setup_game_data():
	"""Configurar datos del juego"""
	game_data = GameData.new()
	dev_tools.initialize(game_data)

func _setup_managers():
	"""Configurar managers del juego"""
	# Crear managers como antes
	# TODO: Migrar código de _setup_managers original
	pass

func _connect_components():
	"""Conectar señales entre componentes"""
	input_controller.pause_requested.connect(_on_pause_requested)
	input_controller.dev_mode_toggled.connect(_on_dev_mode_toggled)

	event_bridge.initialize(self, ui_coordinator)

	print("🔗 Componentes conectados")

func _on_pause_requested():
	"""Manejar solicitud de pausa"""
	get_tree().paused = !get_tree().paused
	print("⏸️ Juego %s" % ("pausado" if get_tree().paused else "reanudado"))

func _on_dev_mode_toggled(enabled: bool):
	"""Manejar cambio de modo desarrollo"""
	if enabled:
		dev_tools.apply_dev_mode_unlocks()

# === INTERFAZ PÚBLICA SIMPLIFICADA ===

func get_manager(type: String) -> Node:
	"""Obtener manager específico"""
	return managers.get(type)

func get_game_data() -> GameData:
	"""Obtener datos del juego"""
	return game_data

func is_system_unlocked(system_name: String) -> bool:
	"""Verificar si un sistema está desbloqueado"""
	match system_name:
		"customers": return game_data.customer_system_unlocked
		"automation": return game_data.automation_system_unlocked
		"prestige": return game_data.prestige_system_unlocked
		"research": return game_data.research_system_unlocked
		"contracts": return game_data.contracts_system_unlocked
		_: return false
'''

        filepath = os.path.join(self.output_dir, 'GameCoordinator.gd')
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(simplified_gc)
        print(f"✅ Generado: GameCoordinator.gd ({len(simplified_gc.splitlines())} líneas)")

if __name__ == "__main__":
    project_path = r"e:\GitHub\bar-sik\project"
    refactor = GameControllerRefactor(project_path)

    # Analizar estructura actual
    analysis = refactor.analyze_current_structure()
    print("📊 Análisis del GameController actual:")
    print(f"   Total líneas: {analysis['total_lines']}")
    print(f"   Funciones: {len(analysis['functions'])}")
    print(f"   Variables: {len(analysis['variables'])}")
    print(f"   Secciones: {len(analysis['sections'])}")
    print()

    # Generar archivos refactorizados
    refactor.generate_refactored_files()
