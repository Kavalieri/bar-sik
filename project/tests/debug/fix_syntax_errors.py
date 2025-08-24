# Script para corregir automáticamente errores de sintaxis
# Se ejecuta desde VS Code

import os
import re

def fix_string_multiplication_errors(directory):
    """Corrige errores de string * int en archivos .gd"""
    pattern = r'"([^"]*)" \* (\d+)'
    replacement = r'"\1".repeat(\2)'

    files_fixed = []

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.gd'):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()

                    new_content = re.sub(pattern, replacement, content)

                    if content != new_content:
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        files_fixed.append(file_path)
                        print(f"✅ Fixed: {file_path}")

                except Exception as e:
                    print(f"❌ Error processing {file_path}: {e}")

    return files_fixed

if __name__ == "__main__":
    # Ejecutar desde el directorio del proyecto
    test_dir = "./tests"
    if os.path.exists(test_dir):
        print("🔧 Fixing string * int errors...")
        fixed_files = fix_string_multiplication_errors(test_dir)
        print(f"✅ Fixed {len(fixed_files)} files")
    else:
        print("❌ Tests directory not found")
