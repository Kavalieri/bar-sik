#!/usr/bin/env python3
"""
BAR-SIK Enhanced Code Analyzer with jscpd Integration
Análisis híbrido: jscpd (GDScript como Python) + análisis personalizado
"""

import os
import json
import subprocess
import tempfile
from pathlib import Path
from collections import defaultdict

class EnhancedBarSikAnalyzer:
    def __init__(self, project_path):
        self.project_path = Path(project_path)
        self.results = {
            'jscpd_clones': [],
            'gdscript_analysis': {},
            'summary': {},
            'recommendations': []
        }

    def run_jscpd_analysis(self):
        """Ejecutar jscpd con configuración optimizada para GDScript"""
        print("🔍 Ejecutando análisis jscpd (GDScript como Python)...")

        try:
            # MÉTODO EXITOSO: Usar --formats-exts para tratar .gd como Python
            print("📋 Ejecutando: jscpd --formats-exts 'python:gd' --reporters console,html,json --output reports/ project/")

            result = subprocess.run([
                "jscpd", 
                "--formats-exts", "python:gd",
                "--reporters", "console,html,json", 
                "--output", "reports/",
                "--min-lines", "3",
                "--min-tokens", "25", 
                "--threshold", "10",
                "project/"
            ], 
            cwd=str(self.project_path),
            capture_output=True,
            text=True,
            timeout=120,
            check=False,  # No fallar si encuentra duplicaciones
            shell=True  # CRÍTICO: Necesario en Windows para ejecutar scripts npm
            )            # Leer resultados JSON
            json_report = self.project_path / "reports" / "jscpd-report.json"
            if json_report.exists():
                with open(json_report, 'r', encoding='utf-8') as f:
                    jscpd_data = json.load(f)
                    self.results['jscpd_clones'] = jscpd_data.get('duplicates', [])
                    self.results['jscpd_statistics'] = jscpd_data.get('statistics', {})

            # Parsear estadísticas de salida
            self._parse_jscpd_statistics(result.stdout)

            clone_count = len(self.results['jscpd_clones'])
            print(f"✅ jscpd completado - {clone_count} clones encontrados")

            # Mostrar reporte HTML disponible
            html_report = self.project_path / "reports" / "html" / "index.html"
            if html_report.exists():
                print(f"📄 Reporte HTML: file:///{html_report}")

        except subprocess.TimeoutExpired:
            print("⏰ jscpd timeout - continuando con análisis propio")
        except FileNotFoundError:
            print("⚠️  jscpd no encontrado - usando solo análisis propio")
        except Exception as e:
            print(f"⚠️  Error ejecutando jscpd: {e} - continuando con análisis propio")

    def _parse_jscpd_statistics(self, output):
        """Parsear estadísticas de jscpd desde salida de consola"""
        if not output:
            return

        lines = output.split('\n')
        for line in lines:
            if 'Found' in line and 'clones' in line:
                # Ejemplo: "Found 62 clones."
                try:
                    clone_count = int(line.split()[1])
                    self.results['jscpd_console_clones'] = clone_count
                except (IndexError, ValueError):
                    pass
            elif 'Detection time::' in line:
                # Ejemplo: "Detection time:: 938.888ms"
                try:
                    time_str = line.split('::')[1].strip()
                    self.results['jscpd_detection_time'] = time_str
                except IndexError:
                    pass

    def _parse_console_output(self, output):
        """Parsear salida de consola de jscpd para extraer clones"""
        lines = output.split('\n')
        current_clone = None

        for line in lines:
            if "Clone found" in line:
                # Parsear líneas de clone found
                if " - " in line and " [" in line:
                    parts = line.split(" - ")
                    if len(parts) >= 2:
                        file_info = parts[1].strip()
                        if "[" in file_info:
                            file_path = file_info.split("[")[0].strip()
                            self.results['jscpd_clones'].append({
                                'source': file_path,
                                'type': 'console_parsed',
                                'confidence': 'high'
                            })

    def analyze_gdscript_patterns(self):
        """Análisis personalizado de patrones GDScript"""
        print("🎯 Analizando patrones específicos de GDScript...")

        gdscript_files = list(self.project_path.glob("project/**/*.gd"))
        patterns = {
            'ready_functions': [],
            'signal_connections': [],
            'input_handlers': [],
            'validation_patterns': [],
            'manager_patterns': []
        }

        for file_path in gdscript_files:
            if any(exclude in str(file_path) for exclude in ['debug', 'tests', 'build']):
                continue

            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                    self._analyze_file_patterns(file_path, content, patterns)
            except Exception as e:
                continue

        self.results['gdscript_analysis'] = patterns

    def _analyze_file_patterns(self, file_path, content, patterns):
        """Analizar patrones específicos en un archivo"""
        lines = content.split('\n')

        for i, line in enumerate(lines):
            line_strip = line.strip()

            # Patrones de función _ready duplicadas
            if line_strip.startswith('func _ready('):
                context = self._get_function_context(lines, i, 10)
                patterns['ready_functions'].append({
                    'file': str(file_path),
                    'line': i + 1,
                    'context': context,
                    'signature': line_strip
                })

            # Handlers de input duplicados
            if 'func _input(' in line_strip:
                context = self._get_function_context(lines, i, 5)
                patterns['input_handlers'].append({
                    'file': str(file_path),
                    'line': i + 1,
                    'context': context
                })

            # Patrones de validación
            if any(pattern in line_strip for pattern in ['if not', 'is_instance_valid', 'is_valid']):
                patterns['validation_patterns'].append({
                    'file': str(file_path),
                    'line': i + 1,
                    'pattern': line_strip
                })

            # Conexiones de señales
            if '.connect(' in line_strip:
                patterns['signal_connections'].append({
                    'file': str(file_path),
                    'line': i + 1,
                    'connection': line_strip
                })

    def _get_function_context(self, lines, start_line, max_lines=10):
        """Extraer contexto de una función"""
        context = []
        i = start_line

        while i < len(lines) and len(context) < max_lines:
            line = lines[i].strip()
            if line:
                context.append(line)
                # Si encontramos otra función, parar
                if i > start_line and line.startswith('func '):
                    break
            i += 1

        return context[:max_lines]

    def generate_recommendations(self):
        """Generar recomendaciones basadas en el análisis"""
        recommendations = []

        # Análisis de funciones _ready duplicadas
        ready_funcs = self.results['gdscript_analysis'].get('ready_functions', [])
        if len(ready_funcs) > 5:
            similar_ready = self._find_similar_functions(ready_funcs)
            if similar_ready:
                recommendations.append({
                    'type': 'critical',
                    'title': 'Funciones _ready() Duplicadas',
                    'description': f'Encontradas {len(similar_ready)} funciones _ready() con lógica similar',
                    'suggestion': 'Crear BaseManager class con _ready() estándar',
                    'files': [f['file'] for f in similar_ready[:5]],
                    'priority': 'high'
                })

        # Análisis de validaciones duplicadas
        validations = self.results['gdscript_analysis'].get('validation_patterns', [])
        if len(validations) > 10:
            recommendations.append({
                'type': 'refactor',
                'title': 'Validaciones Duplicadas',
                'description': f'Encontradas {len(validations)} validaciones similares',
                'suggestion': 'Centralizar validaciones en GameUtils',
                'priority': 'medium'
            })

        # Análisis de jscpd clones
        jscpd_clones = len(self.results['jscpd_clones'])
        if jscpd_clones > 10:
            recommendations.append({
                'type': 'critical',
                'title': 'Código Duplicado Masivo',
                'description': f'jscpd detectó {jscpd_clones} bloques de código duplicado',
                'suggestion': 'Refactorizar inmediatamente para eliminar duplicación',
                'priority': 'critical'
            })

        self.results['recommendations'] = recommendations

    def _find_similar_functions(self, functions):
        """Encontrar funciones con contexto similar"""
        similar = []

        for i, func1 in enumerate(functions):
            for func2 in functions[i+1:]:
                similarity = self._calculate_similarity(func1['context'], func2['context'])
                if similarity > 0.7:
                    similar.extend([func1, func2])

        # Eliminar duplicados
        seen = set()
        unique_similar = []
        for func in similar:
            key = f"{func['file']}:{func['line']}"
            if key not in seen:
                seen.add(key)
                unique_similar.append(func)

        return unique_similar

    def _calculate_similarity(self, context1, context2):
        """Calcular similaridad entre dos contextos de función"""
        if not context1 or not context2:
            return 0.0

        # Simple similarity based on common lines
        set1 = set(context1)
        set2 = set(context2)

        if not set1 or not set2:
            return 0.0

        intersection = len(set1.intersection(set2))
        union = len(set1.union(set2))

        return intersection / union if union > 0 else 0.0

    def generate_report(self):
        """Generar reporte completo"""
        # Generar estadísticas de resumen
        self.results['summary'] = {
            'jscpd_clones_count': len(self.results['jscpd_clones']),
            'ready_functions_count': len(self.results['gdscript_analysis'].get('ready_functions', [])),
            'input_handlers_count': len(self.results['gdscript_analysis'].get('input_handlers', [])),
            'validation_patterns_count': len(self.results['gdscript_analysis'].get('validation_patterns', [])),
            'signal_connections_count': len(self.results['gdscript_analysis'].get('signal_connections', [])),
            'critical_recommendations': len([r for r in self.results['recommendations'] if r.get('priority') == 'critical']),
            'total_recommendations': len(self.results['recommendations'])
        }

        return self.results

    def run_complete_analysis(self):
        """Ejecutar análisis completo híbrido"""
        print("🚀 Iniciando análisis híbrido BAR-SIK...")

        # Paso 1: jscpd analysis
        self.run_jscpd_analysis()

        # Paso 2: GDScript patterns analysis
        self.analyze_gdscript_patterns()

        # Paso 3: Generate recommendations
        self.generate_recommendations()

        # Paso 4: Generate final report
        return self.generate_report()

def main():
    analyzer = EnhancedBarSikAnalyzer("E:/GitHub/bar-sik")
    results = analyzer.run_complete_analysis()

    # Guardar resultados
    output_file = Path("E:/GitHub/bar-sik/docs/analysis/enhanced_analysis.json")
    output_file.parent.mkdir(exist_ok=True)

    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    # Mostrar resumen
    print("\n" + "="*80)
    print("📊 ANÁLISIS HÍBRIDO COMPLETADO")
    print("="*80)

    summary = results['summary']
    print(f"🔄 jscpd clones detectados: {summary['jscpd_clones_count']}")
    print(f"📋 Funciones _ready() encontradas: {summary['ready_functions_count']}")
    print(f"🎮 Handlers _input() encontrados: {summary['input_handlers_count']}")
    print(f"✅ Patrones de validación: {summary['validation_patterns_count']}")
    print(f"📡 Conexiones de señales: {summary['signal_connections_count']}")

    print(f"\n🚨 Recomendaciones críticas: {summary['critical_recommendations']}")
    print(f"📝 Total recomendaciones: {summary['total_recommendations']}")

    # Mostrar top recomendaciones
    if results['recommendations']:
        print("\n🎯 TOP RECOMENDACIONES:")
        for i, rec in enumerate(results['recommendations'][:3]):
            priority_emoji = "🚨" if rec['priority'] == 'critical' else "⚠️" if rec['priority'] == 'high' else "💡"
            print(f"  {i+1}. {priority_emoji} {rec['title']}")
            print(f"     {rec['description']}")
            print(f"     💡 {rec['suggestion']}")

    print(f"\n📄 Reporte completo guardado: {output_file}")

if __name__ == "__main__":
    main()
