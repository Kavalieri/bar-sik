#!/usr/bin/env python3
"""
Análisis de líneas de código en archivos .gd del proyecto Bar-Sik
Identifica archivos grandes que pueden necesitar refactorización
"""

import os
import glob
from pathlib import Path
from typing import List, Tuple

def count_lines_in_file(filepath: str) -> Tuple[int, int, int]:
    """
    Cuenta líneas totales, líneas de código y líneas de comentarios
    Returns: (total_lines, code_lines, comment_lines)
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        total_lines = len(lines)
        code_lines = 0
        comment_lines = 0

        for line in lines:
            stripped = line.strip()
            if not stripped:  # Línea vacía
                continue
            elif stripped.startswith('#'):  # Comentario
                comment_lines += 1
            else:  # Código
                code_lines += 1

        return total_lines, code_lines, comment_lines
    except Exception as e:
        print(f"Error leyendo {filepath}: {e}")
        return 0, 0, 0

def analyze_gd_files(project_path: str):
    """Analiza todos los archivos .gd del proyecto"""

    # Buscar todos los archivos .gd
    pattern = os.path.join(project_path, '**', '*.gd')
    gd_files = glob.glob(pattern, recursive=True)

    file_stats = []

    print("🔍 Analizando archivos .gd del proyecto...")
    print("=" * 80)

    for filepath in gd_files:
        total, code, comments = count_lines_in_file(filepath)
        rel_path = os.path.relpath(filepath, project_path)

        file_stats.append({
            'path': rel_path,
            'total_lines': total,
            'code_lines': code,
            'comment_lines': comments
        })

    # Ordenar por líneas totales (descendente)
    file_stats.sort(key=lambda x: x['total_lines'], reverse=True)

    # Mostrar estadísticas generales
    total_files = len(file_stats)
    total_all_lines = sum(f['total_lines'] for f in file_stats)
    total_code_lines = sum(f['code_lines'] for f in file_stats)
    total_comment_lines = sum(f['comment_lines'] for f in file_stats)

    print(f"📊 ESTADÍSTICAS GENERALES")
    print(f"Archivos .gd analizados: {total_files}")
    print(f"Total líneas: {total_all_lines:,}")
    print(f"Líneas de código: {total_code_lines:,}")
    print(f"Líneas de comentarios: {total_comment_lines:,}")
    print()

    # TOP 20 archivos más largos
    print("🚨 TOP 20 ARCHIVOS MÁS LARGOS (candidatos a refactorización)")
    print("=" * 80)
    print(f"{'Archivo':<50} {'Total':<8} {'Código':<8} {'Coment':<8}")
    print("-" * 80)

    for i, stats in enumerate(file_stats[:20]):
        path = stats['path']
        if len(path) > 47:
            path = "..." + path[-44:]

        print(f"{path:<50} {stats['total_lines']:<8} {stats['code_lines']:<8} {stats['comment_lines']:<8}")

    print()

    # Archivos que exceden umbrales críticos
    print("⚠️  ARCHIVOS QUE EXCEDEN UMBRALES CRÍTICOS")
    print("=" * 80)

    large_files = [f for f in file_stats if f['total_lines'] > 500]
    very_large_files = [f for f in file_stats if f['total_lines'] > 1000]
    huge_files = [f for f in file_stats if f['total_lines'] > 2000]

    if huge_files:
        print(f"🔥 ARCHIVOS ENORMES (>2000 líneas): {len(huge_files)}")
        for f in huge_files:
            print(f"   {f['path']} - {f['total_lines']} líneas")
        print()

    if very_large_files:
        print(f"🚨 ARCHIVOS MUY GRANDES (>1000 líneas): {len(very_large_files)}")
        for f in very_large_files:
            if f['total_lines'] <= 2000:  # No repetir los huge
                print(f"   {f['path']} - {f['total_lines']} líneas")
        print()

    if large_files:
        print(f"⚠️  ARCHIVOS GRANDES (>500 líneas): {len(large_files)}")
        for f in large_files:
            if f['total_lines'] <= 1000:  # No repetir los anteriores
                print(f"   {f['path']} - {f['total_lines']} líneas")
        print()

    # Análisis por directorios
    print("📂 ANÁLISIS POR DIRECTORIOS")
    print("=" * 80)

    dir_stats = {}
    for stats in file_stats:
        dir_path = os.path.dirname(stats['path'])
        if not dir_path:
            dir_path = "root"

        if dir_path not in dir_stats:
            dir_stats[dir_path] = {
                'files': 0,
                'total_lines': 0,
                'code_lines': 0
            }

        dir_stats[dir_path]['files'] += 1
        dir_stats[dir_path]['total_lines'] += stats['total_lines']
        dir_stats[dir_path]['code_lines'] += stats['code_lines']

    # Ordenar directorios por líneas totales
    sorted_dirs = sorted(dir_stats.items(), key=lambda x: x[1]['total_lines'], reverse=True)

    print(f"{'Directorio':<40} {'Archivos':<8} {'Total':<8} {'Código':<8} {'Promedio':<8}")
    print("-" * 80)

    for dir_path, stats in sorted_dirs:
        avg_lines = stats['total_lines'] // stats['files'] if stats['files'] > 0 else 0
        dir_display = dir_path
        if len(dir_display) > 37:
            dir_display = "..." + dir_display[-34:]

        print(f"{dir_display:<40} {stats['files']:<8} {stats['total_lines']:<8} {stats['code_lines']:<8} {avg_lines:<8}")

    # Recomendaciones de refactorización
    print()
    print("💡 RECOMENDACIONES DE REFACTORIZACIÓN")
    print("=" * 80)

    if huge_files:
        print("🔥 PRIORIDAD CRÍTICA:")
        for f in huge_files:
            print(f"   • {f['path']} ({f['total_lines']} líneas)")
            print("     → Dividir inmediatamente en múltiples archivos")
            print("     → Separar responsabilidades usando patrones como MVC o Component")
            print()

    if very_large_files and len(very_large_files) > len(huge_files):
        print("⚠️  PRIORIDAD ALTA:")
        for f in very_large_files:
            if f['total_lines'] <= 2000:
                print(f"   • {f['path']} ({f['total_lines']} líneas)")
                print("     → Evaluar división en módulos especializados")
                print()

    print("📋 ESTRATEGIAS RECOMENDADAS:")
    print("• Aplicar principio de responsabilidad única (SRP)")
    print("• Extraer clases auxiliares y utilidades")
    print("• Usar patrones como Strategy, Command, Observer")
    print("• Crear interfaces/abstracciones para desacoplar")
    print("• Dividir funcionalidad en componentes reutilizables")

if __name__ == "__main__":
    project_path = r"e:\GitHub\bar-sik\project"
    analyze_gd_files(project_path)
