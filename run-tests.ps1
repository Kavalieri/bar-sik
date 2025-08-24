#!/usr/bin/env pwsh
# Bar-Sik Testing Suite Runner - Compatible con VS Code
# Ejecuta tests de Godot y Python desde Visual Studio Code

param(
    [Parameter(Position=0)]
    [ValidateSet("all", "unit", "integration", "ui", "performance", "python", "master", "gui", "help")]
    [string]$Category = "help",

    [Parameter(Position=1)]
    [string]$TestFile = "",

    [switch]$Headless = $false,
    [switch]$VerboseOutput = $false
)

# Colores para output
$Green = "`e[32m"
$Blue = "`e[34m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Reset = "`e[0m"

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "$Blue════════════════════════════════════════$Reset" -ForegroundColor Blue
    Write-Host "$Blue  🧪 Bar-Sik Testing Suite - $Title$Reset" -ForegroundColor Blue
    Write-Host "$Blue════════════════════════════════════════$Reset" -ForegroundColor Blue
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "$Green✅ $Message$Reset" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "$Blue🔍 $Message$Reset" -ForegroundColor Blue
}

function Write-Warning {
    param([string]$Message)
    Write-Host "$Yellow⚠️  $Message$Reset" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "$Red❌ $Message$Reset" -ForegroundColor Red
}

function Run-GodotTests {
    param([string]$TestDir, [string]$Description)

    Write-Info "Ejecutando $Description..."

    $godotArgs = @(
        "--headless"
        "--path"
        "./project"
        "res://addons/gut/gut_cmdln.gd"
        "-gdir=$TestDir"
        "-gexit"
    )

    if ($VerboseOutput) {
        $godotArgs += "-glog=2"
    }

    $process = Start-Process -FilePath "godot" -ArgumentList $godotArgs -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -eq 0) {
        Write-Success "$Description completados exitosamente"
        return $true
    } else {
        Write-Error "$Description fallaron (Exit Code: $($process.ExitCode))"
        return $false
    }
}

function Run-PythonTests {
    Write-Info "Ejecutando tests Python..."

    $pythonArgs = @(
        "-m"
        "pytest"
        "./project/tests/debug/"
        "-v"
    )

    if ($VerboseOutput) {
        $pythonArgs += "--tb=long"
    } else {
        $pythonArgs += "--tb=short"
    }

    $process = Start-Process -FilePath "python" -ArgumentList $pythonArgs -Wait -PassThru -NoNewWindow

    if ($process.ExitCode -eq 0) {
        Write-Success "Tests Python completados exitosamente"
        return $true
    } else {
        Write-Error "Tests Python fallaron (Exit Code: $($process.ExitCode))"
        return $false
    }
}

function Run-SingleTest {
    param([string]$FilePath)

    Write-Info "Ejecutando test individual: $FilePath"

    $extension = [System.IO.Path]::GetExtension($FilePath)

    if ($extension -eq ".py") {
        $process = Start-Process -FilePath "python" -ArgumentList @("-m", "pytest", $FilePath, "-v") -Wait -PassThru -NoNewWindow
    } elseif ($extension -eq ".gd") {
        $process = Start-Process -FilePath "godot" -ArgumentList @("--headless", "--path", "./project", $FilePath) -Wait -PassThru -NoNewWindow
    } else {
        Write-Error "Tipo de archivo no soportado: $extension"
        return $false
    }

    return $process.ExitCode -eq 0
}

# Main execution logic
switch ($Category) {
    "help" {
        Write-Header "Ayuda"
        Write-Host "Uso: ./run-tests.ps1 <categoria> [opciones]"
        Write-Host ""
        Write-Host "Categorías disponibles:"
        Write-Host "  📦 all          - Ejecutar todos los tests"
        Write-Host "  🔬 unit         - Tests unitarios"
        Write-Host "  🔗 integration  - Tests de integración"
        Write-Host "  🎨 ui           - Tests de interfaz"
        Write-Host "  ⚡ performance  - Tests de rendimiento"
        Write-Host "  🐍 python       - Tests Python de validación"
        Write-Host "  🎯 master       - Test Master Suite"
        Write-Host "  🏃 gui          - Abrir Test Runner GUI"
        Write-Host ""
        Write-Host "Opciones:"
        Write-Host "  -TestFile <path>    - Ejecutar test individual"
        Write-Host "  -VerboseOutput      - Output detallado"
        Write-Host "  -Headless           - Modo sin interfaz"
        Write-Host ""
        Write-Host "Ejemplos:"
        Write-Host "  ./run-tests.ps1 unit"
        Write-Host "  ./run-tests.ps1 all -VerboseOutput"
        Write-Host "  ./run-tests.ps1 -TestFile './project/tests/unit/test_gamedata.gd'"
    }

    "all" {
        Write-Header "Todos los Tests"
        $success = $true

        $success = (Run-GodotTests "res://tests/unit/" "Unit Tests") -and $success
        $success = (Run-GodotTests "res://tests/integration/" "Integration Tests") -and $success
        $success = (Run-GodotTests "res://tests/ui/" "UI Tests") -and $success
        $success = (Run-PythonTests) -and $success

        if ($success) {
            Write-Success "🎉 Todos los tests completados exitosamente!"
        } else {
            Write-Error "❌ Algunos tests fallaron"
            exit 1
        }
    }

    "unit" {
        Write-Header "Unit Tests"
        $success = Run-GodotTests "res://tests/unit/" "Unit Tests"
        if (-not $success) { exit 1 }
    }

    "integration" {
        Write-Header "Integration Tests"
        $success = Run-GodotTests "res://tests/integration/" "Integration Tests"
        if (-not $success) { exit 1 }
    }

    "ui" {
        Write-Header "UI Tests"
        $success = Run-GodotTests "res://tests/ui/" "UI Tests"
        if (-not $success) { exit 1 }
    }

    "performance" {
        Write-Header "Performance Tests"
        $success = Run-GodotTests "res://tests/performance/" "Performance Tests"
        if (-not $success) { exit 1 }
    }

    "python" {
        Write-Header "Python Tests"
        $success = Run-PythonTests
        if (-not $success) { exit 1 }
    }

    "master" {
        Write-Header "Test Master Suite"
        Write-Info "Ejecutando Test Master Suite..."

        $process = Start-Process -FilePath "godot" -ArgumentList @("--headless", "--path", "./project", "res://tests/test_master_suite.gd") -Wait -PassThru -NoNewWindow

        if ($process.ExitCode -eq 0) {
            Write-Success "Test Master Suite completado"
        } else {
            Write-Error "Test Master Suite falló"
            exit 1
        }
    }

    "gui" {
        Write-Header "Test Runner GUI"
        Write-Info "Abriendo Test Runner en modo GUI..."

        Start-Process -FilePath "godot" -ArgumentList @("--path", "./project", "res://tests/runners/TestRunner.tscn") -NoWait
        Write-Success "Test Runner GUI iniciado"
    }
}

# Ejecutar test individual si se especifica
if ($TestFile) {
    Write-Header "Test Individual"
    $success = Run-SingleTest $TestFile
    if (-not $success) {
        exit 1
    }
}

Write-Host ""
Write-Success "Testing completado!"
