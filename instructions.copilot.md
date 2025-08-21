# Instrucciones para GitHub Copilot - BAR-SIK

## Análisis de Código con jscpd

### Configuración Exitosa de jscpd para GDScript

**Comando funcional verificado:**
```bash
jscpd --formats-exts "python:gd" --reporters console,html,json --output reports/ project/
```

#### Parámetros Clave:
- `--formats-exts "python:gd"`: **CRÍTICO** - Trata archivos .gd como Python para análisis
- `--reporters console,html,json`: Genera reportes en múltiples formatos
- `--output reports/`: Directorio de salida para reportes
- `project/`: Directorio a analizar (contiene scripts GDScript)

#### Resultados del Último Análisis:
- **62 clones encontrados**
- **8.3% de código duplicado** (995 líneas de 11,987 total)
- Tiempo de detección: ~939ms
- Reportes generados:
  - HTML: `reports/html/index.html`
  - JSON: `reports/jscpd-report.json`

### Archivos de Configuración

#### .jscpd.json (Configuración principal)
```json
{
  "threshold": 5,
  "minTokens": 20,
  "minLines": 3,
  "maxLines": 1000,
  "include": ["**/*.gd"],
  "exclude": [
    "**/debug/**",
    "**/tests/**",
    "**/build/**",
    "**/builds/**",
    "**/.godot/**",
    "**/addons/**"
  ],
  "format": "python",
  "reporters": ["console", "html", "json"],
  "output": "./reports",
  "blame": false,
  "silent": false,
  "verbose": false
}
```

### Scripts de Análisis

#### enhanced_analyzer.py
- **Ubicación**: `tools/enhanced_analyzer.py`
- **Función**: Análisis híbrido con jscpd + análisis personalizado
- **Comando jscpd integrado**: Actualizado con configuración funcional
- **Uso**: `python tools/enhanced_analyzer.py`

### Problemas Resueltos

#### 1. Detección de GDScript
- **Problema**: jscpd no reconocía archivos .gd nativamente
- **Solución**: `--formats-exts "python:gd"` mapea .gd como Python
- **Razón**: Sintaxis de GDScript es similar a Python

#### 2. Reportes HTML/JSON
- **Problema**: Reportes no se generaban correctamente
- **Solución**: Instalar reportes con `--reporters console,html,json`
- **Verificación**: Archivos generados en `reports/` directory

#### 3. Exclusiones
- **Problema**: Análisis de archivos temporales/debug
- **Solución**: Configurar excludes en .jscpd.json
- **Directorios excluidos**: debug, tests, build, .godot, addons

#### 4. Ejecución desde Python (Windows)
- **Problema**: `subprocess.run()` no encontraba jscpd en PATH
- **Solución**: Agregar `shell=True` al subprocess.run
- **Razón**: jscpd se instala como script PowerShell (jscpd.ps1) via npm
- **Código corregido**: `subprocess.run([...], shell=True)`

### Principales Duplicaciones Encontradas

#### Patrones Críticos:
1. **ProductionPanelBasic** - 4 variantes idénticas
2. **Validación de inputs** - Patrones repetidos en múltiples paneles
3. **Funciones _ready()** - Inicialización duplicada
4. **Gestión de UI** - Código común en diferentes escenas

#### Plan de Refactoring:
1. **BasePanel**: Clase base para paneles comunes
2. **ValidationManager**: Centralizar validaciones
3. **ComponentRegistry**: Sistema de componentes reutilizables
4. **UIHelpers**: Utilidades comunes de UI

### Uso en Desarrollo

#### Para Análisis Rutinario:
```bash
# Ejecutar desde raíz del proyecto
jscpd --formats-exts "python:gd" --reporters console,html,json --output reports/ project/

# Ver reporte HTML
start reports/html/index.html
```

#### Para Análisis Profundo:
```bash
# Ejecutar script completo
python tools/enhanced_analyzer.py

# Ver todos los reportes generados
ls -la reports/
```

### Notas Importantes

1. **Formato GDScript**: Siempre usar `--formats-exts "python:gd"`
2. **Reportes**: HTML para visualización, JSON para procesamiento
3. **Umbral**: threshold=5 para detectar duplicaciones mínimas
4. **Exclusiones**: Mantener actualizadas para evitar falsos positivos

### Próximos Pasos

1. **Implementar BasePanel**: Clase base para componentes comunes
2. **Centralizar Validaciones**: ValidationManager singleton
3. **Refactorizar ProductionPanels**: Usar herencia en lugar de duplicación
4. **Optimizar _ready()**: Patrón común para inicialización

---

*Configuración verificada el 2025-01-19. Comando funcional preservado para uso futuro.*
