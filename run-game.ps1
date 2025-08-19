#!/usr/bin/env pwsh
# Script para ejecutar Bar-sik sin abrir Godot Editor
# Uso: .\run-game.ps1 [modo]
# Modos: normal, headless, debug

param(
    [string]$Mode = "normal"
)

$ProjectPath = "e:\GitHub\bar-sik\project"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

Write-Host "🍺 Iniciando Bar-sik..." -ForegroundColor Green
Write-Host "📂 Proyecto: $ProjectPath" -ForegroundColor Cyan
Write-Host "🎯 Godot: $GodotPath" -ForegroundColor Magenta

switch ($Mode.ToLower()) {
    "headless" {
        Write-Host "🖥️  Modo: Headless (sin ventana)" -ForegroundColor Yellow
        & $GodotPath --headless --path $ProjectPath
    }
    "debug" {
        Write-Host "🐛 Modo: Debug (puerto 6007)" -ForegroundColor Yellow
        & $GodotPath --path $ProjectPath --remote-debug tcp://127.0.0.1:6007
    }
    default {
        Write-Host "🎮 Modo: Normal" -ForegroundColor Yellow
        & $GodotPath --path $ProjectPath
    }
}
