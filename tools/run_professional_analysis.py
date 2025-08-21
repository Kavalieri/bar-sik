#!/usr/bin/env python3
"""
BAR-SIK Professional Pipeline - Análisis de Duplicación
Ejecuta análisis usando los comandos que funcionan correctamente
"""

import subprocess
import sys
from pathlib import Path

def run_command(command, description):
    """Ejecutar comando con manejo de errores"""
    print(f"🔄 {description}...")
    try:
        result = subprocess.run(command, shell=True, check=True,
                              capture_output=True, text=True,
                              encoding='utf-8', errors='ignore')
        print(f"✅ {description} - COMPLETADO")
        if result.stdout.strip():
            print(result.stdout)
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ {description} - ERROR")
        if e.stdout:
            print(f"STDOUT: {e.stdout}")
        if e.stderr:
            print(f"STDERR: {e.stderr}")
        return False
    except Exception as e:
        print(f"❌ {description} - ERROR: {e}")
        return False

def main():
    print("🚀" * 50)
    print("🎯 BAR-SIK PROFESSIONAL ANALYSIS PIPELINE")
    print("🚀" * 50)

    success_count = 0
    total_tasks = 2

    # 1. Análisis GDScript (comando que funciona)
    gd_command = 'jscpd --formats-exts "python:gd" --output "reports/gd/" --reporters console,html,json --min-tokens 35 --min-lines 3 project/'
    if run_command(gd_command, "Análisis de duplicados GDScript"):
        success_count += 1

    # 2. Análisis de escenas TSCN (comando básico)
    tscn_command = 'jscpd --pattern "project/**/*.tscn" --min-tokens 50 --min-lines 3 --reporters console --output "reports/tscn/"'
    if run_command(tscn_command, "Análisis de duplicados TSCN"):
        success_count += 1

    # Resumen
    print("\n📊 === RESUMEN ===")
    print(f"✅ Tareas completadas: {success_count}/{total_tasks}")

    if success_count == total_tasks:
        print("🎉 ¡PIPELINE EJECUTADO EXITOSAMENTE!")
        print("\n📄 Reportes disponibles:")
        print("   🌐 reports/gd/index.html - Duplicados GDScript")
        print("   📊 reports/enhanced_analysis_report.txt - Análisis completo")
        return True
    else:
        print("⚠️ PIPELINE COMPLETADO PARCIALMENTE")
        return False

if __name__ == "__main__":
    main()
