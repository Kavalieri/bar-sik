#!/usr/bin/env python3
"""
BAR-SIK Pre-commit Setup
Instala y configura hooks de pre-commit para desarrollo profesional
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
    print("🔧 SETUP PRE-COMMIT HOOKS - BAR-SIK")
    print("🚀" * 50)

    # 1. Instalar pre-commit
    if run_command("pip install pre-commit", "Instalando pre-commit"):
        
        # 2. Instalar hooks
        if run_command("pre-commit install", "Instalando hooks"):
            
            # 3. Ejecutar en todos los archivos (opcional)
            print("\n🔍 ¿Desea ejecutar pre-commit en todos los archivos? (y/N)")
            response = input().lower().strip()
            
            if response in ['y', 'yes', 's', 'si']:
                run_command("pre-commit run --all-files", "Ejecutando pre-commit en todo el proyecto")
            
            print("\n🎉 Pre-commit configurado exitosamente!")
            print("📝 Los siguientes hooks se ejecutarán automáticamente en cada commit:")
            print("   • gdformat - Formateo automático de GDScript")
            print("   • gdlint - Análisis de estilo")
            print("   • jscpd-check - Verificación de duplicados (opcional)")
            print("\n💡 Para saltear hooks temporalmente: git commit --no-verify")
            
        else:
            print("❌ Error instalando hooks")
    else:
        print("❌ Error instalando pre-commit")

if __name__ == "__main__":
    main()
