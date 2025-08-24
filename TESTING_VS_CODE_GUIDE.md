# 🧪 Guía Completa de Testing en Visual Studio Code - Bar-Sik

## 🎯 Acceso Completo a Tests desde VS Code

Ahora tienes **acceso completo** a todos los tests de Bar-Sik directamente desde Visual Studio Code mediante múltiples métodos.

## 🔍 Tests Visibles en VS Code

### ✅ Tests Python (Automáticamente Detectados)
- **Ubicación**: `project/tests/debug/`
- **Archivos**: `test_fixes_validation.py`, `test_production_recipes.py`, `test_production_fix.py`
- **Vista**: Aparecen automáticamente en el **Test Explorer** de VS Code
- **Ejecución**: Click derecho > "Run Test" o usar el icono de play

### ✅ Tests Godot (.gd) (Configuración Completa)
- **Ubicación**: `project/tests/unit/`, `integration/`, `ui/`, `performance/`
- **Total**: 39+ archivos de test organizados
- **Ejecutor**: Script PowerShell `run-tests.ps1`
- **Integración**: Tasks, keybindings y terminal personalizado

## 🚀 Formas de Ejecutar Tests

### 1. 📊 **Test Explorer** (Sidebar)
```
- Abrir Test Explorer (icono de tubo de ensayo)
- Ver tests Python automáticamente
- Click en cualquier test para ejecutar
```

### 2. ⌨️ **Atajos de Teclado**
```
Ctrl+Shift+T  - Ejecutar todos los tests
Ctrl+Shift+U  - Ejecutar unit tests
Ctrl+Shift+I  - Ejecutar integration tests
Ctrl+Shift+P  - Ejecutar tests Python
Ctrl+Alt+T    - Abrir terminal de tests
```

### 3. 🎯 **Command Palette** (Ctrl+Shift+P)
```
> Tasks: Run Task
  🧪 Run All Tests (GUT)
  🔬 Run Unit Tests
  🔗 Run Integration Tests
  🎨 Run UI Tests
  ⚡ Run Performance Tests
  🎯 Run Test Master Suite
  🏃 Run Test Runner (GUI)
  🐍 Run Python Tests
```

### 4. 📂 **Context Menu** (Right-Click)
```
- Right-click en cualquier archivo .gd de test
- Seleccionar "Run Current Test File"
- El test se ejecutará automáticamente
```

### 5. 🖥️ **Terminal Integrado**
```
- Abrir terminal en VS Code
- Usar: ./run-tests.ps1 <categoria>
- Terminal personalizado "Godot Tests" disponible
```

### 6. 🎮 **Desde Run & Debug Panel**
```
- Abrir Run & Debug (Ctrl+Shift+D)
- Seleccionar configuración de testing
- Presionar F5 para ejecutar
```

## 📋 Script Principal: `run-tests.ps1`

### Categorías Disponibles:
```powershell
./run-tests.ps1 all          # 🏆 Todos los tests
./run-tests.ps1 unit         # 🔬 Tests unitarios (16 archivos)
./run-tests.ps1 integration  # 🔗 Tests integración (7 archivos)
./run-tests.ps1 ui           # 🎨 Tests UI (2 archivos)
./run-tests.ps1 performance  # ⚡ Tests performance (2 archivos)
./run-tests.ps1 python       # 🐍 Tests Python (3 archivos)
./run-tests.ps1 master       # 🎯 Master Suite
./run-tests.ps1 gui          # 🏃 GUI Runner
```

### Opciones Avanzadas:
```powershell
# Test individual
./run-tests.ps1 -TestFile "./project/tests/unit/test_gamedata.gd"

# Modo verbose
./run-tests.ps1 all -VerboseOutput

# Modo headless
./run-tests.ps1 unit -Headless
```

## 🛠️ Configuración Aplicada

### ✅ VS Code Settings
- Python testing habilitado automáticamente
- Test discovery configurado
- Terminal personalizado "Godot Tests"
- Asociaciones de archivos Godot

### ✅ Tasks Configuration
- 8 tasks de testing predefinidas
- Accesibles desde Command Palette
- Output integrado en VS Code

### ✅ Launch Configuration
- Configuraciones de debug para tests
- Soporte para breakpoints en tests
- Múltiples modos de ejecución

### ✅ Keybindings
- Atajos rápidos para testing
- Acceso directo a categorías principales
- Terminal de tests con Ctrl+Alt+T

## 📊 Estructura de Tests Visible

```
tests/                           # 🏠 Directorio principal
├── 🔬 unit/           (16)      # Tests unitarios
├── 🔗 integration/    (7)       # Tests de integración
├── 🎨 ui/             (2)       # Tests de UI
├── ⚡ performance/    (2)       # Tests de performance
├── 🐍 debug/          (3 .py)   # Tests Python (visible en Test Explorer)
├── 🎭 fixtures/       (2)       # Datos de prueba
├── 🏃 runners/        (5)       # Ejecutores de tests
└── 📄 Suite files     (6)       # Tests principales
```

## 🎉 Resultado Final

### ✅ Completamente Integrado
- **Todos** los tests accesibles desde VS Code
- **Múltiples** formas de ejecutar
- **Feedback visual** en Test Explorer
- **Atajos** rápidos configurados

### ✅ Profesional
- Scripts PowerShell con colores
- Output formateado y claro
- Manejo de errores robusto
- Documentación completa

### ✅ Escalable
- Fácil agregar nuevos tests
- Estructura organizada
- Compatible con CI/CD
- Soporte para todos los frameworks

---

## 🚀 **¡Ya tienes acceso completo a todos los tests desde Visual Studio Code!**

**No más búsquedas** - todo está integrado, organizado y accesible con un click o atajo de teclado.
