#!/usr/bin/env python3
"""
Script de instalación del pipeline profesional de Godot para BAR-SIK
Instala y configura todas las herramientas necesarias
"""

import subprocess
import sys
import os
from pathlib import Path

def run_command(command, description, shell=True, check=True):
    """Ejecutar comando con manejo de errores"""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(command, shell=shell, check=check,
                              capture_output=True, text=True)
        print(f"✅ {description} - OK")
        if result.stdout.strip():
            print(f"   📋 {result.stdout.strip()}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - ERROR")
        if e.stdout:
            print(f"   📋 STDOUT: {e.stdout}")
        if e.stderr:
            print(f"   📋 STDERR: {e.stderr}")
        return False
    except Exception as e:
        print(f"❌ {description} - ERROR: {e}")
        return False

def check_tool(command, name):
    """Verificar si una herramienta está instalada"""
    print(f"🔍 Verificando {name}...")
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {name} está instalado")
            return True
        else:
            print(f"❌ {name} no está instalado")
            return False
    except:
        print(f"❌ {name} no está disponible")
        return False

def main():
    print("🚀" * 50)
    print("🎯 BAR-SIK PROFESSIONAL GODOT PIPELINE INSTALLER")
    print("🚀" * 50)

    # Verificar herramientas base
    print("\n📋 === VERIFICACIÓN DE DEPENDENCIAS ===")

    tools_status = {
        'python': check_tool('python --version', 'Python'),
        'npm': check_tool('npm --version', 'NPM'),
        'node': check_tool('node --version', 'Node.js'),
        'pip': check_tool('pip --version', 'pip'),
        'git': check_tool('git --version', 'Git')
    }

    missing_tools = [tool for tool, installed in tools_status.items() if not installed]
    if missing_tools:
        print(f"\n❌ ERROR: Herramientas faltantes: {', '.join(missing_tools)}")
        print("Por favor instala las herramientas faltantes e intenta de nuevo.")
        return False

    print("\n✅ Todas las dependencias base están disponibles")

    # Instalar herramientas profesionales
    print("\n🛠️ === INSTALACIÓN DE HERRAMIENTAS PROFESIONALES ===")

    success_count = 0
    total_installs = 0

    # 1. gdtoolkit (formato y lint de GDScript)
    total_installs += 1
    if run_command('pip install gdtoolkit', 'Instalando gdtoolkit (gdformat + gdlint)', check=False):
        success_count += 1

    # 2. jscpd y reportadores
    total_installs += 1
    if run_command('npm install -g jscpd', 'Actualizando jscpd', check=False):
        success_count += 1

    # Instalar reportadores HTML específicos (si no están)
    total_installs += 1
    if run_command('npm install -g @jscpd/html-reporter', 'Instalando HTML reporter para jscpd', check=False):
        success_count += 1

    # 3. pre-commit (hooks de git)
    total_installs += 1
    if run_command('pip install pre-commit', 'Instalando pre-commit', check=False):
        success_count += 1

    print(f"\n📊 === RESULTADOS DE INSTALACIÓN ===")
    print(f"✅ Instalaciones exitosas: {success_count}/{total_installs}")

    # Verificar instalaciones
    print("\n🔍 === VERIFICACIÓN POST-INSTALACIÓN ===")

    verification_results = {
        'gdformat': check_tool('gdformat --help', 'gdformat'),
        'gdlint': check_tool('gdlint --help', 'gdlint'),
        'jscpd': check_tool('jscpd --version', 'jscpd'),
        'pre-commit': check_tool('pre-commit --version', 'pre-commit')
    }

    working_tools = sum(verification_results.values())
    total_tools = len(verification_results)

    print(f"\n📊 Herramientas funcionando: {working_tools}/{total_tools}")

    # Crear configuraciones si no existen
    print("\n⚙️ === CONFIGURACIÓN DE ARCHIVOS ===")

    project_root = Path.cwd()

    # Verificar configuraciones jscpd
    gd_config = project_root / '.jscpd.gd.json'
    tscn_config = project_root / '.jscpd.tscn.json'

    configs_ready = 0
    if gd_config.exists():
        print("✅ .jscpd.gd.json - OK")
        configs_ready += 1
    else:
        print("❌ .jscpd.gd.json - NO EXISTE")

    if tscn_config.exists():
        print("✅ .jscpd.tscn.json - OK")
        configs_ready += 1
    else:
        print("❌ .jscpd.tscn.json - NO EXISTE")

    print(f"\n📊 Configuraciones listas: {configs_ready}/2")

    # Resumen final
    print("\n🎉 === RESUMEN FINAL ===")
    if working_tools == total_tools and configs_ready == 2:
        print("🏆 ¡INSTALACIÓN COMPLETA Y EXITOSA!")
        print("\n🚀 COMANDOS DISPONIBLES:")
        print("   🎨 gdformat $(git ls-files '*.gd')  # Formatear código")
        print("   📝 gdlint $(git ls-files '*.gd')    # Verificar estilo")
        print("   🔍 jscpd --config .jscpd.gd.json   # Detectar duplicados GD")
        print("   🎭 jscpd --config .jscpd.tscn.json # Detectar duplicados TSCN")
        print("\n💡 Usa Ctrl+Shift+P > 'Run Task' para ejecutar tareas desde VS Code")
        return True
    else:
        print("⚠️ INSTALACIÓN PARCIAL")
        print(f"   🛠️ Herramientas: {working_tools}/{total_tools}")
        print(f"   ⚙️ Configuraciones: {configs_ready}/2")
        print("\n💡 Algunas herramientas pueden necesitar instalación manual")
        return False

if __name__ == "__main__":
    main()
