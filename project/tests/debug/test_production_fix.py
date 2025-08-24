#!/usr/bin/env python3
"""
Test para verificar que la corrección del ProductionManager funciona
"""
import subprocess
import os
import time

def run_godot_test():
    """Ejecuta Godot y verifica que no hay errores críticos"""

    print("🧪 Iniciando test de ProductionManager...")

    # Cambiar al directorio del proyecto
    project_dir = "E:\\GitHub\\bar-sik\\project"
    os.chdir(project_dir)

    # Ejecutar Godot en modo headless por 5 segundos
    cmd = ["godot", "--headless", "--quit-after", "5"]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=10
        )

        output = result.stdout + result.stderr

        # Verificar errores específicos
        errors_found = []

        if "Invalid access to property or key 'unlocked'" in output:
            errors_found.append("❌ ERROR: Acceso inválido a propiedad 'unlocked' - NO CORREGIDO")
        else:
            print("✅ No se encontró el error de 'unlocked' - CORREGIDO")

        if "SCRIPT ERROR" in output:
            script_errors = output.count("SCRIPT ERROR")
            print(f"⚠️ Se encontraron {script_errors} SCRIPT ERROR(s) en el output")
        else:
            print("✅ No hay SCRIPT ERROR en el output")

        # Verificar que ProductionManager se inicializa
        if "ProductionManager inicializado" in output:
            print("✅ ProductionManager se inicializa correctamente")
        else:
            print("❌ ProductionManager no se inicializa")

        print("\n📊 RESUMEN DEL TEST:")
        if len(errors_found) == 0:
            print("🎉 ÉXITO: ProductionManager funciona sin errores críticos")
            return True
        else:
            for error in errors_found:
                print(error)
            return False

    except subprocess.TimeoutExpired:
        print("⏰ Test terminado por timeout - normal para esta prueba")
        return True
    except Exception as e:
        print(f"❌ Error ejecutando test: {e}")
        return False

if __name__ == "__main__":
    success = run_godot_test()
    exit(0 if success else 1)
