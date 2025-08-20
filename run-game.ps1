# ======================================================================
# Run Game Script - Bar-Sik Development
# ======================================================================
# Script mejorado para ejecutar el juego con consola limpia y debug

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("normal", "debug", "headless", "verbose")]
    [string]$Mode = "normal"
)

# Limpiar consola siempre al inicio
Clear-Host
Write-Host "🎮 BAR-SIK - Game Runner" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# Recargar PATH para asegurar que godot funciona
$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")
Write-Host "✅ PATH recargado correctamente" -ForegroundColor Green

# Verificar que Godot está disponible
if (-not (Get-Command "godot" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERROR: Comando 'godot' no encontrado en PATH" -ForegroundColor Red
    Write-Host "   Asegúrate de que Godot esté en C:\Program Files\Godot\" -ForegroundColor Yellow
    exit 1
}

# Cambiar al directorio del proyecto
Set-Location "$PSScriptRoot\project"
Write-Host "📁 Directorio de proyecto: $(Get-Location)" -ForegroundColor Blue

# Ejecutar según el modo
switch ($Mode) {
    "normal" {
        Write-Host "🚀 Ejecutando juego en modo normal..." -ForegroundColor Green
        & godot
    }
    "debug" {
        Write-Host "🐛 Ejecutando juego en modo debug..." -ForegroundColor Yellow
        Write-Host "   Puerto de debug: 6007" -ForegroundColor Gray
        & godot --remote-debug 127.0.0.1:6007 --debug
    }
    "headless" {
        Write-Host "🤖 Ejecutando juego en modo headless..." -ForegroundColor Magenta
        & godot --headless --quit
    }
    "verbose" {
        Write-Host "📝 Ejecutando juego con output verbose..." -ForegroundColor Cyan
        & godot --verbose
    }
}

Write-Host "✅ Ejecución completada" -ForegroundColor Green
