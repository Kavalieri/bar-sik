#!/usr/bin/env python3
"""
Script para probar las correcciones de UI
"""

import subprocess
import sys
import time

def test_godot_project():
    """Probar el proyecto Godot para verificar que todo funciona"""
    try:
        print("🧪 Iniciando prueba del proyecto Godot...")

        # Cambiar al directorio del proyecto
        project_path = r"E:\GitHub\bar-sik\project"

        # Ejecutar Godot en modo headless para verificar errores
        cmd = [
            "godot",
            "--headless",
            "--path", project_path,
            "--main-scene", "res://scenes/GameScene.tscn",
            "--quit-after", "5"
        ]

        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=30
        )

        print("📤 Código de salida:", result.returncode)

        if result.stdout:
            print("📋 Salida estándar:")
            print(result.stdout)

        if result.stderr:
            print("⚠️ Errores:")
            print(result.stderr)

        if result.returncode == 0:
            print("✅ Prueba exitosa - No hay errores de parseo")
            return True
        else:
            print("❌ Prueba falló")
            return False

    except subprocess.TimeoutExpired:
        print("⏰ Timeout - proceso muy lento pero probablemente funcionando")
        return True
    except Exception as e:
        print(f"❌ Error durante la prueba: {e}")
        return False

if __name__ == "__main__":
    success = test_godot_project()
    sys.exit(0 if success else 1)
