@echo off
REM Script para ejecutar Bar-sik sin abrir Godot Editor
REM Uso: run-game.bat [normal|headless|debug]

set PROJECT_PATH="e:\GitHub\bar-sik\project"
set GODOT_PATH="E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"
set MODE=%1

echo 🍺 Iniciando Bar-sik...
echo 📂 Proyecto: %PROJECT_PATH%
echo 🎯 Godot: %GODOT_PATH%

if "%MODE%"=="headless" (
    echo 🖥️  Modo: Headless (sin ventana)
    %GODOT_PATH% --headless --path %PROJECT_PATH%
) else if "%MODE%"=="debug" (
    echo 🐛 Modo: Debug (puerto 6007)
    %GODOT_PATH% --path %PROJECT_PATH% --remote-debug tcp://127.0.0.1:6007
) else (
    echo 🎮 Modo: Normal
    %GODOT_PATH% --path %PROJECT_PATH%
)

pause
