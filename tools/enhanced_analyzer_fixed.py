#!/usr/bin/env python3
"""
BAR-SIK Enhanced Code Analyzer with jscpd Integration
Análisis híbrido: jscpd (GDScript como Python) + análisis personalizado
"""

import os
import json
import subprocess
import logging
from pathlib import Path
from collections import defaultdict

# Configurar logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

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
            shell=True,  # CRÍTICO: Necesario en Windows para ejecutar scripts npm
            encoding='utf-8',  # FIX: Manejo explicito de encoding
            errors='ignore'  # FIX: Ignorar errores de encoding Unicode
            )

            # Procesar output con manejo de errores de encoding
            if result.stdout:
                print("✅ jscpd Output:")
                try:
                    print(result.stdout)
                except UnicodeError:
                    print("📋 Output contiene caracteres Unicode - análisis completado")

            if result.stderr:
                print("⚠️ jscpd Warnings/Errors:")
                try:
                    print(result.stderr)
                except UnicodeError:
                    print("📋 Stderr contiene caracteres Unicode")

            # Parsear estadísticas de la salida
            self._parse_jscpd_statistics(result.stdout if result.stdout else "")

            # Leer resultados JSON
            json_path = self.project_path / "reports" / "jscpd-report.json"
            if json_path.exists():
                with open(json_path, 'r', encoding='utf-8') as f:
                    jscpd_data = json.load(f)
                    self.results['jscpd_clones'] = jscpd_data.get('duplicates', [])
                    print(f"✅ Cargados {len(self.results['jscpd_clones'])} clones desde JSON")
            else:
                print("⚠️ No se encontró jscpd-report.json")

            return True

        except subprocess.TimeoutExpired:
            logging.error("❌ Timeout ejecutando jscpd (120 segundos)")
            return False
        except subprocess.CalledProcessError as e:
            logging.error(f"❌ Error ejecutando jscpd: {e}")
            return False
        except FileNotFoundError:
            logging.error("❌ jscpd no encontrado - instálelo: npm install -g jscpd")
            return False
        except Exception as e:
            logging.error(f"❌ Error inesperado ejecutando jscpd: {e}")
            return False

    def _parse_jscpd_statistics(self, output):
        """Parsear estadísticas de jscpd desde salida de consola"""
        if not output:
            return

        lines = output.split('\n')

        for line in lines:
            line = line.strip()
            if 'clones found' in line:
                try:
                    clones = int(line.split()[0])
                    self.results['summary']['total_clones'] = clones
                    print(f"📊 Total clones encontrados: {clones}")
                except (ValueError, IndexError):
                    pass
            elif 'duplicated lines out of' in line:
                try:
                    parts = line.split()
                    duplicated = int(parts[0])
                    total = int(parts[4])
                    percentage = round((duplicated / total) * 100, 2)
                    self.results['summary']['duplicated_lines'] = duplicated
                    self.results['summary']['total_lines'] = total
                    self.results['summary']['duplication_percentage'] = percentage
                    print(f"📊 Líneas duplicadas: {duplicated}/{total} ({percentage}%)")
                except (ValueError, IndexError):
                    pass

    def analyze_gdscript_patterns(self):
        """Análisis específico de patrones GDScript"""
        print("🔍 Analizando patrones específicos de GDScript...")

        gdscript_files = list(self.project_path.glob("**/*.gd"))
        print(f"📁 Encontrados {len(gdscript_files)} archivos .gd")

        analysis = {
            'total_files': len(gdscript_files),
            'patterns': defaultdict(list),
            'duplicate_functions': defaultdict(list),
            'common_blocks': []
        }

        for file_path in gdscript_files:
            if 'addons' in str(file_path):
                continue

            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    self._analyze_file_patterns(file_path, content, analysis)
            except Exception as e:
                print(f"⚠️ Error leyendo {file_path}: {e}")

        self.results['gdscript_analysis'] = analysis
        return analysis

    def _analyze_file_patterns(self, file_path, content, analysis):
        """Analizar patrones en un archivo específico"""
        lines = content.split('\n')
        relative_path = file_path.relative_to(self.project_path)

        # Patrones comunes a buscar
        patterns = {
            '_ready()': r'func _ready\(\):',
            '_process()': r'func _process\(',
            '_input()': r'func _input\(',
            'get_node()': r'get_node\(',
            '$': r'\$',
            'connect()': r'\.connect\(',
            'signal': r'signal ',
            'export': r'export ',
            'onready': r'onready ',
        }

        for pattern_name, pattern in patterns.items():
            import re
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                analysis['patterns'][pattern_name].append({
                    'file': str(relative_path),
                    'count': len(matches)
                })

        # Detectar funciones duplicadas por nombre
        func_pattern = r'func\s+([a-zA-Z_][a-zA-Z0-9_]*)\s*\('
        functions = re.findall(func_pattern, content)
        for func_name in functions:
            analysis['duplicate_functions'][func_name].append(str(relative_path))

    def generate_comprehensive_report(self):
        """Generar reporte comprehensivo"""
        print("📋 Generando reporte comprehensivo...")

        # Estadísticas generales
        total_clones = self.results['summary'].get('total_clones', 0)
        duplication_percentage = self.results['summary'].get('duplication_percentage', 0)
        duplicated_lines = self.results['summary'].get('duplicated_lines', 0)
        total_lines = self.results['summary'].get('total_lines', 0)

        report = []
        report.append("=" * 80)
        report.append("🎯 BAR-SIK ENHANCED CODE ANALYSIS REPORT")
        report.append("=" * 80)
        report.append("")

        # Resumen ejecutivo
        report.append("📊 RESUMEN EJECUTIVO")
        report.append("-" * 40)
        report.append(f"🔍 Total de clones detectados: {total_clones}")
        report.append(f"📏 Líneas duplicadas: {duplicated_lines:,} de {total_lines:,} ({duplication_percentage}%)")

        if duplication_percentage > 10:
            report.append("🚨 CRÍTICO: Nivel de duplicación muy alto (>10%)")
        elif duplication_percentage > 5:
            report.append("⚠️ ALTO: Nivel de duplicación alto (>5%)")
        else:
            report.append("✅ ACEPTABLE: Nivel de duplicación bajo (<5%)")

        report.append("")

        # Top clones por tamaño
        if self.results['jscpd_clones']:
            report.append("🔥 TOP 10 CLONES MÁS GRANDES")
            report.append("-" * 40)

            sorted_clones = sorted(
                self.results['jscpd_clones'],
                key=lambda x: x.get('linesCount', 0),
                reverse=True
            )[:10]

            for i, clone in enumerate(sorted_clones, 1):
                lines_count = clone.get('linesCount', 0)
                tokens_count = clone.get('tokensCount', 0)
                fragment = clone.get('fragment', '')[:100] + "..." if len(clone.get('fragment', '')) > 100 else clone.get('fragment', '')

                report.append(f"{i}. {lines_count} líneas, {tokens_count} tokens")
                report.append(f"   📄 Fragmento: {fragment}")

                if 'duplicationMap' in clone:
                    for dup in clone['duplicationMap'][:2]:  # Solo primeros 2
                        source_file = dup.get('sourceId', 'Unknown')
                        start_line = dup.get('start', {}).get('line', 0)
                        report.append(f"   📍 {source_file}:{start_line}")
                report.append("")

        # Patrones GDScript
        if 'patterns' in self.results['gdscript_analysis']:
            report.append("🎮 ANÁLISIS DE PATRONES GDSCRIPT")
            report.append("-" * 40)

            patterns = self.results['gdscript_analysis']['patterns']
            for pattern_name, occurrences in patterns.items():
                total_count = sum(item['count'] for item in occurrences)
                unique_files = len(occurrences)
                report.append(f"📌 {pattern_name}: {total_count} usos en {unique_files} archivos")

                if unique_files > 5:  # Mostrar solo si está muy distribuido
                    top_files = sorted(occurrences, key=lambda x: x['count'], reverse=True)[:3]
                    for file_info in top_files:
                        report.append(f"   🏆 {file_info['file']}: {file_info['count']} usos")
            report.append("")

        # Recomendaciones
        report.append("💡 RECOMENDACIONES DE REFACTORIZACIÓN")
        report.append("-" * 40)

        recommendations = []

        if duplication_percentage > 15:
            recommendations.append("🚨 URGENTE: Crear clases base para eliminar duplicación masiva")
        if duplication_percentage > 10:
            recommendations.append("⚡ ALTA: Extraer métodos comunes en utilidades compartidas")
        if duplication_percentage > 5:
            recommendations.append("📋 MEDIA: Consolidar patrones repetidos en componentes")

        # Recomendaciones específicas basadas en patrones
        patterns = self.results['gdscript_analysis'].get('patterns', {})
        if '_ready()' in patterns and len(patterns['_ready()']) > 10:
            recommendations.append("🔧 Crear BasePanel con _ready() común")
        if 'get_node()' in patterns:
            total_get_node = sum(item['count'] for item in patterns['get_node()'])
            if total_get_node > 50:
                recommendations.append("🎯 Implementar sistema de referencias por @onready")

        if recommendations:
            for i, rec in enumerate(recommendations, 1):
                report.append(f"{i}. {rec}")
        else:
            report.append("✅ Código en buen estado, sin refactorizaciones críticas")

        report.append("")
        report.append("=" * 80)

        # Guardar reporte
        report_content = "\n".join(report)
        report_path = self.project_path / "reports" / "enhanced_analysis_report.txt"

        # Crear directorio si no existe
        report_path.parent.mkdir(exist_ok=True)

        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(report_content)

        print("📄 Reporte guardado en: reports/enhanced_analysis_report.txt")
        print(report_content)

        return report_content

    def run_full_analysis(self):
        """Ejecutar análisis completo"""
        print("🚀 Iniciando análisis completo de BAR-SIK...")

        # 1. Análisis jscpd
        if not self.run_jscpd_analysis():
            print("❌ Error en análisis jscpd, continuando con análisis GDScript...")

        # 2. Análisis específico GDScript
        self.analyze_gdscript_patterns()

        # 3. Generar reporte
        self.generate_comprehensive_report()

        return self.results

def main():
    """Función principal"""
    project_path = Path(__file__).parent.parent  # Directorio del proyecto (bar-sik)

    print(f"📁 Analizando proyecto en: {project_path}")
    print("🔧 Versión: Enhanced Analyzer v2.0 con jscpd integration")

    analyzer = EnhancedBarSikAnalyzer(project_path)
    results = analyzer.run_full_analysis()

    print("\n🎉 ¡Análisis completado!")
    print("📄 Revisa los reportes en la carpeta 'reports/'")
    print("🌐 HTML Report: reports/jscpd-report.html")
    print("📋 Text Report: reports/enhanced_analysis_report.txt")

if __name__ == "__main__":
    main()
