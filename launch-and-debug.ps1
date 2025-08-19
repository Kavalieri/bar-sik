#!/usr/bin/env pwsh
# Script para launch & debug en dos pasos
# Esto simula lo que funcionó en la primera ocasión

param(
    [int]$Port = 6007,
    [string]$Address = "127.0.0.1"
)

$ProjectPath = "e:\GitHub\bar-sik\project"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

Write-Host "🎯 DEBUGGING HÍBRIDO - PASO A PASO" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📝 PASO 1: Lanzando Godot con debugging habilitado..." -ForegroundColor Yellow
Write-Host "🎯 Proyecto: $ProjectPath" -ForegroundColor White
Write-Host "🔗 Puerto: $Port" -ForegroundColor White
Write-Host "📡 Address: $Address" -ForegroundColor White
Write-Host ""

# Paso 1: Lanzar Godot con debugging
Write-Host "🚀 Iniciando Godot..." -ForegroundColor Green
Start-Process -FilePath $GodotPath -ArgumentList "--path", $ProjectPath, "--remote-debug", "tcp://${Address}:${Port}" -NoNewWindow

Write-Host ""
Write-Host "⏳ Esperando 3 segundos para que Godot inicie..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "✅ PASO 1 COMPLETADO" -ForegroundColor Green
Write-Host ""
Write-Host "📋 PASO 2: Instrucciones para VS Code" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "1. Ve al panel de Debug en VS Code (Ctrl+Shift+D)" -ForegroundColor White
Write-Host "2. Selecciona '🔗 Godot Attach (Manual)'" -ForegroundColor White
Write-Host "3. Presiona F5 para conectar VS Code al debugging" -ForegroundColor White
Write-Host "4. ¡Ahora tendrás debugging completo!" -ForegroundColor White
Write-Host ""
Write-Host "🎮 Tu juego está corriendo con debugging en puerto $Port" -ForegroundColor Green
Write-Host "🔍 Puedes poner breakpoints en VS Code y funcionarán" -ForegroundColor Green
Write-Host ""
Write-Host "Para terminar: Presiona Ctrl+C" -ForegroundColor Red

# Mantener el script corriendo
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
}
catch {
    Write-Host "🛑 Terminando script..." -ForegroundColor Red
}
