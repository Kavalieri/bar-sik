#!/usr/bin/env pwsh
# Script optimizado para debugging real con VS Code

param()

$ProjectPath = "e:\GitHub\bar-sik\project"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

Write-Host ""
Write-Host "🎯 DEBUGGING COMPLETO ACTIVADO" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

Write-Host "� Configurando debugging:" -ForegroundColor Yellow
Write-Host "   ✅ LSP habilitado (puerto 6005)" -ForegroundColor White
Write-Host "   ✅ Remote debugging (puerto 6007)" -ForegroundColor White
Write-Host "   ✅ Breakpoints automáticos habilitados" -ForegroundColor White
Write-Host ""

# Habilitar breakpoints automáticos
$env:GODOT_DEBUG_BREAKPOINTS = "1"

Write-Host "🚀 Lanzando Godot con debugging completo..." -ForegroundColor Green

# Lanzar con LSP + Remote Debugging + variable de entorno
& $GodotPath --path $ProjectPath --lsp-port 6005 --remote-debug tcp://127.0.0.1:6007

Write-Host ""
Write-Host "✅ Sesión de debugging terminada" -ForegroundColor Green
Write-Host "🔧 Variables de entorno limpiadas" -ForegroundColor White

# Limpiar variable de entorno
Remove-Item Env:GODOT_DEBUG_BREAKPOINTS -ErrorAction SilentlyContinue
