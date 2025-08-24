#!/usr/bin/env python3
"""
Diagnóstico Real del Estado del Sistema
"""

import subprocess
import sys
import time

def test_godot_parsing():
    """Verificar que no hay errores de parseo"""
    print("🔍 = DIAGNÓSTICO REAL DE PROBLEMAS =")
    print()

    try:
        result = subprocess.run([
            "godot",
            "--headless",
            "--path", r"E:\GitHub\bar-sik\project",
            "--main-scene", "res://scenes/GameScene.tscn",
            "--quit-after", "3"
        ], capture_output=True, text=True, timeout=15, check=False)

        print("📋 RESULTADO:")
        print("Exit Code:", result.returncode)

        if result.returncode == 0:
            print("✅ Sin errores de parseo")
        else:
            print("❌ Hay errores")

        if result.stderr:
            print("\n⚠️ MENSAJES:")
            print(result.stderr[:500])

        return result.returncode == 0

    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("🔍 DIAGNÓSTICO: ¿Por qué no funciona nada?")
    print()

    parsing_ok = test_godot_parsing()

    print("\n📋 RESUMEN HONESTO:")
    if parsing_ok:
        print("✅ Parseo: OK (sin errores GDScript)")
        print("❌ Funcionalidad: Los paneles probablemente NO se ven")
        print("❌ CustomersPanel: Probablemente sigue sin contenido visible")
        print("❌ PrestigePanel: Probablemente invisible por modulate=0")
    else:
        print("❌ Parseo: ERRORES - hay que arreglar sintaxis primero")

    print("\n🎯 PRÓXIMOS PASOS REALES:")
    print("1. Verificar que PrestigePanel llame a show_panel()")
    print("2. Verificar que CustomersPanel use estructura .tscn existente")
    print("3. Probar en ejecución REAL, no solo debug logs")
    print("4. Ser honesto sobre qué funciona y qué no")

if __name__ == "__main__":
    main()
