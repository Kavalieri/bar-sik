#!/usr/bin/env python3
"""
BAR-SIK Code Analysis Tool
Análisis personalizado de duplicación y calidad de código para proyectos Godot/GDScript
"""

import os
import re
import json
from pathlib import Path
from collections import defaultdict, Counter
from difflib import SequenceMatcher

class BarSikCodeAnalyzer:
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.gdscript_files = []
        self.analysis_results = {
            'duplicated_functions': [],
            'similar_patterns': [],
            'unused_scripts': [],
            'complex_files': [],
            'dependencies': defaultdict(list),
            'signal_connections': [],
            'node_references': [],
            'debug_code': []
        }

    def scan_gdscript_files(self):
        """Escanear todos los archivos .gd en el proyecto"""
        for root, dirs, files in os.walk(self.project_path):
            # Ignorar directorios de build y temporales
            dirs[:] = [d for d in dirs if not d.startswith('.') and d not in ['build', 'builds', 'addons']]

            for file in files:
                if file.endswith('.gd'):
                    file_path = Path(root) / file
                    self.gdscript_files.append(file_path)

        print(f"📁 Encontrados {len(self.gdscript_files)} archivos GDScript")

    def extract_functions(self, content):
        """Extraer funciones de un archivo GDScript"""
        functions = []
        lines = content.split('\n')

        for i, line in enumerate(lines):
            # Detectar definiciones de funciones
            func_match = re.match(r'^\s*func\s+(\w+)\s*\([^)]*\)', line.strip())
            if func_match:
                func_name = func_match.group(1)
                # Extraer cuerpo de la función (simplificado)
                func_body = []
                j = i + 1
                indent_level = len(line) - len(line.lstrip())

                while j < len(lines):
                    current_line = lines[j]
                    if current_line.strip() == '':
                        j += 1
                        continue

                    current_indent = len(current_line) - len(current_line.lstrip())
                    if current_indent <= indent_level and current_line.strip():
                        break

                    func_body.append(current_line.strip())
                    j += 1

                functions.append({
                    'name': func_name,
                    'line': i + 1,
                    'body': '\n'.join(func_body),
                    'signature': line.strip()
                })

        return functions

    def analyze_function_similarity(self):
        """Analizar similaridad entre funciones"""
        all_functions = {}

        for file_path in self.gdscript_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    functions = self.extract_functions(content)
                    all_functions[str(file_path)] = functions
            except Exception as e:
                print(f"⚠️  Error leyendo {file_path}: {e}")
                continue

        # Comparar funciones entre archivos
        duplicated = []

        for file1, functions1 in all_functions.items():
            for func1 in functions1:
                for file2, functions2 in all_functions.items():
                    if file1 >= file2:  # Evitar comparaciones duplicadas
                        continue

                    for func2 in functions2:
                        # Comparar cuerpos de funciones
                        similarity = SequenceMatcher(None, func1['body'], func2['body']).ratio()

                        if similarity > 0.7 and len(func1['body']) > 20:  # Umbral de similaridad
                            duplicated.append({
                                'similarity': similarity,
                                'function1': {
                                    'file': file1,
                                    'name': func1['name'],
                                    'line': func1['line'],
                                    'signature': func1['signature']
                                },
                                'function2': {
                                    'file': file2,
                                    'name': func2['name'],
                                    'line': func2['line'],
                                    'signature': func2['signature']
                                }
                            })

        self.analysis_results['duplicated_functions'] = sorted(duplicated, key=lambda x: x['similarity'], reverse=True)

    def detect_debug_code(self):
        """Detectar código de debug en archivos de producción"""
        debug_patterns = [
            r'print\s*\(',
            r'push_warning\s*\(',
            r'#.*DEBUG',
            r'#.*TEST',
            r'#.*TEMP',
            r'extends.*Test',
            r'class_name.*Test',
            r'func.*test_',
            r'func.*debug_'
        ]

        debug_files = []

        for file_path in self.gdscript_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')

                    debug_lines = []
                    for i, line in enumerate(lines):
                        for pattern in debug_patterns:
                            if re.search(pattern, line, re.IGNORECASE):
                                debug_lines.append({
                                    'line_number': i + 1,
                                    'content': line.strip(),
                                    'pattern': pattern
                                })

                    if debug_lines:
                        debug_files.append({
                            'file': str(file_path),
                            'debug_lines': debug_lines,
                            'total_debug_lines': len(debug_lines)
                        })
            except Exception as e:
                continue

        self.analysis_results['debug_code'] = sorted(debug_files, key=lambda x: x['total_debug_lines'], reverse=True)

    def analyze_complexity(self):
        """Analizar complejidad de archivos"""
        complex_files = []

        for file_path in self.gdscript_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    lines = content.split('\n')

                    metrics = {
                        'total_lines': len(lines),
                        'code_lines': len([l for l in lines if l.strip() and not l.strip().startswith('#')]),
                        'functions': len(self.extract_functions(content)),
                        'classes': len(re.findall(r'class\s+\w+', content)),
                        'signals': len(re.findall(r'signal\s+\w+', content)),
                        'properties': len(re.findall(r'@export\s+var\s+\w+', content)),
                        'complexity_score': 0
                    }

                    # Calcular puntuación de complejidad
                    metrics['complexity_score'] = (
                        metrics['code_lines'] * 0.1 +
                        metrics['functions'] * 2 +
                        metrics['classes'] * 5 +
                        metrics['signals'] * 1
                    )

                    if metrics['complexity_score'] > 50:
                        complex_files.append({
                            'file': str(file_path),
                            'metrics': metrics
                        })
            except Exception as e:
                continue

        self.analysis_results['complex_files'] = sorted(complex_files, key=lambda x: x['metrics']['complexity_score'], reverse=True)

    def analyze_dependencies(self):
        """Analizar dependencias entre archivos"""
        dependencies = defaultdict(list)

        for file_path in self.gdscript_files:
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                    # Buscar preloads
                    preload_matches = re.findall(r'preload\s*\(\s*["\']([^"\']+)["\']', content)
                    for match in preload_matches:
                        dependencies[str(file_path)].append({
                            'type': 'preload',
                            'path': match
                        })

                    # Buscar extensiones de clases
                    extends_matches = re.findall(r'extends\s+(\w+)', content)
                    for match in extends_matches:
                        dependencies[str(file_path)].append({
                            'type': 'extends',
                            'class': match
                        })

                    # Buscar referencias a singletons
                    singleton_refs = re.findall(r'\b(GameEvents|SaveSystem|Router|AppConfig|StockManager)\b', content)
                    for ref in set(singleton_refs):
                        dependencies[str(file_path)].append({
                            'type': 'singleton',
                            'name': ref
                        })

            except Exception as e:
                continue

        self.analysis_results['dependencies'] = dict(dependencies)

    def generate_report(self):
        """Generar reporte completo"""
        report = {
            'summary': {
                'total_files': len(self.gdscript_files),
                'duplicated_functions': len(self.analysis_results['duplicated_functions']),
                'debug_files': len(self.analysis_results['debug_code']),
                'complex_files': len(self.analysis_results['complex_files'])
            },
            'analysis': self.analysis_results
        }

        return report

    def run_analysis(self):
        """Ejecutar análisis completo"""
        print("🔍 Iniciando análisis de código BAR-SIK...")

        self.scan_gdscript_files()
        print("📋 Analizando duplicación de funciones...")
        self.analyze_function_similarity()
        print("🐛 Detectando código de debug...")
        self.detect_debug_code()
        print("📊 Analizando complejidad...")
        self.analyze_complexity()
        print("🔗 Analizando dependencias...")
        self.analyze_dependencies()

        print("✅ Análisis completado")
        return self.generate_report()

def main():
    analyzer = BarSikCodeAnalyzer("E:/GitHub/bar-sik/project")
    report = analyzer.run_analysis()

    # Guardar reporte
    output_path = Path("E:/GitHub/bar-sik/docs/analysis/detailed_code_analysis.json")
    output_path.parent.mkdir(exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)

    print(f"📄 Reporte guardado en: {output_path}")

    # Mostrar resumen
    print("\n" + "="*60)
    print("📊 RESUMEN DEL ANÁLISIS")
    print("="*60)
    print(f"📁 Archivos analizados: {report['summary']['total_files']}")
    print(f"🔄 Funciones duplicadas: {report['summary']['duplicated_functions']}")
    print(f"🐛 Archivos con debug: {report['summary']['debug_files']}")
    print(f"📊 Archivos complejos: {report['summary']['complex_files']}")

    if report['analysis']['duplicated_functions']:
        print("\n🔄 TOP 5 DUPLICACIONES:")
        for i, dup in enumerate(report['analysis']['duplicated_functions'][:5]):
            print(f"  {i+1}. {dup['function1']['name']} vs {dup['function2']['name']} ({dup['similarity']:.2%})")

    if report['analysis']['debug_code']:
        print("\n🐛 FILES CON MÁS DEBUG:")
        for i, debug_file in enumerate(report['analysis']['debug_code'][:5]):
            file_name = Path(debug_file['file']).name
            print(f"  {i+1}. {file_name} ({debug_file['total_debug_lines']} líneas)")

    if report['analysis']['complex_files']:
        print("\n📊 ARCHIVOS MÁS COMPLEJOS:")
        for i, complex_file in enumerate(report['analysis']['complex_files'][:5]):
            file_name = Path(complex_file['file']).name
            score = complex_file['metrics']['complexity_score']
            print(f"  {i+1}. {file_name} (score: {score:.1f})")

if __name__ == "__main__":
    main()
