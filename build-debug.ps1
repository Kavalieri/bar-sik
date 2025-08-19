# 🐛 BUILD DEBUG - Bar-Sik
param(
    [string]$Version = "0.3.0"
)

Write-Host "🐛 Bar-Sik - Build Debug v$Version" -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Cyan

# Generar timestamp único
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Write-Host "📅 Timestamp: $timestamp" -ForegroundColor Gray

Write-Host "Este build incluye:" -ForegroundColor White
Write-Host "✅ Consola visible para ver errores" -ForegroundColor Green
Write-Host "✅ Un solo archivo .exe (sin .pck separado)" -ForegroundColor Green
Write-Host "✅ Optimizado para debugging" -ForegroundColor Green
Write-Host "✅ Timestamped para evitar sobreescritura" -ForegroundColor Green

$ProjectRoot = Join-Path $PSScriptRoot "project"
$BuildBaseDir = Join-Path $PSScriptRoot "builds"
$BuildTimestampDir = Join-Path $BuildBaseDir "windows\$timestamp"
$BuildLatestDir = Join-Path $BuildBaseDir "windows\latest"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

# Crear directorios
New-Item -ItemType Directory -Force -Path $BuildTimestampDir | Out-Null

$debugPath = Join-Path $BuildTimestampDir "bar-sik-debug.exe"

Write-Host "`n📦 Generando executable debug..." -ForegroundColor Cyan
Write-Host "   📂 Directorio: builds/windows/$timestamp/" -ForegroundColor Gray

$cmd = "& `"$GodotPath`" --headless --path `"$ProjectRoot`" --export-debug `"Windows Debug`" `"$debugPath`""

try {
    $output = Invoke-Expression $cmd 2>&1

    # Buscar indicadores de éxito/error
    $hasError = $output | Where-Object { $_ -like "*ERROR*" -and $_ -notlike "*completed with warnings*" }
    $hasSuccess = $output | Where-Object { $_ -like "*completed with warnings*" -or $_ -like "*savepack: end*" }

    if (-not $hasError -and ($hasSuccess -or (Test-Path $debugPath))) {
        Write-Host "✅ Build debug completado" -ForegroundColor Green

        # Crear/actualizar symlink latest
        if (Test-Path $BuildLatestDir) {
            Remove-Item $BuildLatestDir -Force -Recurse -ErrorAction SilentlyContinue
        }

        try {
            New-Item -ItemType SymbolicLink -Path $BuildLatestDir -Target $BuildTimestampDir -ErrorAction Stop | Out-Null
            Write-Host "   📂 Symlink 'latest' creado" -ForegroundColor Gray
        } catch {
            Copy-Item $BuildTimestampDir $BuildLatestDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   📂 Directorio 'latest' copiado" -ForegroundColor Gray
        }

        if (Test-Path $debugPath) {
            $size = [math]::Round((Get-Item $debugPath).Length / 1MB, 2)
            Write-Host "   📁 bar-sik-debug.exe ($size MB)" -ForegroundColor White
            Write-Host "   📂 Ubicación timestamped: builds/windows/$timestamp/" -ForegroundColor Gray
            Write-Host "   📂 Acceso rápido: builds/windows/latest/" -ForegroundColor Gray

            Write-Host "`n🚀 PARA EJECUTAR Y VER ERRORES:" -ForegroundColor Yellow
            Write-Host "   cd builds\windows\latest" -ForegroundColor White
            Write-Host "   .\bar-sik-debug.exe" -ForegroundColor White
            Write-Host "   # O usar el path timestamped específico" -ForegroundColor Gray

            Write-Host "`n💡 CARACTERÍSTICAS DEL DEBUG BUILD:" -ForegroundColor Cyan
            Write-Host "   • Consola visible con output detallado" -ForegroundColor White
            Write-Host "   • Un solo archivo (no necesita .pck)" -ForegroundColor White
            Write-Host "   • Símbolos de debug incluidos" -ForegroundColor White
            Write-Host "   • Timestamped para evitar conflictos" -ForegroundColor White
            Write-Host "   • Perfecto para diagnosticar problemas" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Error en build debug" -ForegroundColor Red
        if ($hasError) {
            Write-Host "   Errores encontrados:" -ForegroundColor Yellow
            $hasError | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
        }
    }
} catch {
    Write-Host "❌ Error generando debug build" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 ¿Qué hacer ahora?" -ForegroundColor Green
Write-Host "1. Ejecuta el debug build para ver qué está fallando" -ForegroundColor White
Write-Host "2. Revisa la consola para errores específicos" -ForegroundColor White
Write-Host "3. Una vez corregido, usa .\build-quick.ps1 -Windows para release" -ForegroundColor White
