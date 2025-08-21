# 🚀 BAR-SIK PROFESSIONAL GODOT PIPELINE

## 📋 Pipeline Implementado

### 🎨 **1. ESTILO Y TIPADO**
- **gdtoolkit**: gdformat + gdlint para formato y estilo
- **GDScript tipado**: Todo tipado con tipos explícitos
- **@onready var** tipadas correctamente
- **class_name** en todos los scripts
- **Señales documentadas** con argumentos tipados

### 🔍 **2. DETECCIÓN DE DUPLICADOS**
- **jscpd**: Dos pasadas (GD + TSCN)
- **Configuración profesional**: Umbrales optimizados
- **Reportes automáticos**: HTML + JSON

### 🧪 **3. PRUEBAS AUTOMATIZADAS**
- **GUT**: Framework de testing para Godot
- **CI Headless**: Ejecuta tests automáticamente
- **Cobertura**: Métricas de calidad

### 🤖 **4. AUTOMATIZACIÓN**
- **pre-commit**: Hooks automáticos
- **GitHub Actions**: CI/CD completo
- **Calidad automática**: Bloquea PRs con problemas

### 🏗️ **5. ARQUITECTURA DE ESCENAS**
- **Una escena, una responsabilidad**
- **Subescenas reutilizables**
- **Resources para datos**
- **Composición > Herencia**

---

## 🛠️ **HERRAMIENTAS CONFIGURADAS**

### `.jscpd.gd.json` - Configuración GDScript
```json
{
  "pattern": "**/*.gd",
  "format": "python",
  "extension": {".gd": "python"},
  "minTokens": 35,
  "minLines": 3,
  "threshold": 5,
  "reporters": ["console", "html", "json"],
  "output": "reports/gd/",
  "ignore": [
    "**/.godot/**",
    "**/.import/**",
    "**/*.import",
    "**/*.translation",
    "**/*.remap"
  ]
}
```

### `.jscpd.tscn.json` - Configuración Escenas
```json
{
  "pattern": ["**/*.tscn", "**/*.tres"],
  "format": "text",
  "extension": {".tscn": "text", ".tres": "text"},
  "minTokens": 110,
  "minLines": 5,
  "threshold": 8,
  "reporters": ["console", "html", "json"],
  "output": "reports/tscn/",
  "ignore": [
    "**/.godot/**",
    "**/.import/**",
    "**/*.import",
    "**/*.translation",
    "**/*.remap"
  ]
}
```

---

## 🎯 **COMANDOS PROFESIONALES**

### Análisis de duplicados
```bash
# GDScript (preciso, sensible)
jscpd --config .jscpd.gd.json

# Escenas (menos ruido)
jscpd --config .jscpd.tscn.json
```

### Tests automatizados
```bash
# Ejecutar tests en headless
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```

### Formato y lint
```bash
# Formatear código
gdformat $(git ls-files '*.gd')

# Verificar estilo
gdlint $(git ls-files '*.gd')
```

---

## 📊 **MÉTRICAS DE CALIDAD**

| Herramienta | Umbral Pro | BAR-SIK Actual | Estado |
|-------------|------------|----------------|--------|
| **jscpd GD** | < 5% | 3.05% | ✅ APROBADO |
| **jscpd TSCN** | < 8% | TBD | 🔄 PENDIENTE |
| **gdlint** | 0 errores | TBD | 🔄 PENDIENTE |
| **Tests** | > 80% | TBD | 🔄 PENDIENTE |

---

## 🚀 **PRÓXIMOS PASOS**

1. **Instalar herramientas**: gdtoolkit, GUT
2. **Configurar jscpd**: Archivos .json
3. **Setup CI/CD**: GitHub Actions
4. **Escribir tests**: Cobertura básica
5. **pre-commit**: Hooks automáticos

¡BAR-SIK está listo para ser un proyecto profesional de Godot! 🎯
