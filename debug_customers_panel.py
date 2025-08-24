#!/usr/bin/env python3
"""
Debug específico del CustomersPanel para ver por qué no muestra contenido
"""

import subprocess
import sys

def debug_customers_panel():
    """Ejecutar Godot y capturar logs específicos del CustomersPanel"""
    print("🔍 DEBUGEANDO CUSTOMERSPANEL - ¿Por qué no hay contenido?")
    print()

    try:
        # Ejecutar Godot y capturar toda la salida
        result = subprocess.run([
            "godot",
            "--path", r"E:\GitHub\bar-sik\project",
            "--main-scene", "res://scenes/GameScene.tscn",
            "--quit-after", "8"
        ], capture_output=True, text=True, timeout=20, check=False)

        print("📋 SALIDA COMPLETA:")

        if result.stdout:
            lines = result.stdout.split('\n')
            for line in lines:
                if any(keyword in line for keyword in [
                    'CustomersPanel', 'clientes', 'customer_system', 'timer', 'MainContainer', 'DEBUG'
                ]):
                    print(f"📌 {line}")

        print("\n📋 ERRORES:")
        if result.stderr:
            lines = result.stderr.split('\n')
            for line in lines:
                if line.strip():
                    print(f"❌ {line}")

        return result.returncode == 0

    except subprocess.TimeoutExpired:
        print("⏰ Timeout - pero probablemente capturó información útil")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

if __name__ == "__main__":
    print("🔬 ANÁLISIS DE CUSTOMERSPANEL")
    print("=" * 50)

    success = debug_customers_panel()

    if success:
        print("\n✅ Debug completado - revisa los logs arriba")
    else:
        print("\n❌ Debug falló")

    print("\n🎯 BUSCA EN LA SALIDA:")
    print("- ¿Se ejecuta _initialize_panel_specific?")
    print("- ¿customer_system_unlocked es true?")
    print("- ¿Se ejecuta _setup_management_panel?")
    print("- ¿Se encuentra TimerContainer?")
    print("- ¿Se ejecuta _create_basic_content?")
    print("- ¿Cuántos hijos tiene MainContainer al final?")
