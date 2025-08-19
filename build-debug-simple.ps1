# 🚀 BUILD SIMPLE DEBUG - Bar-Sik
Write-Host "🚀 Bar-Sik - Build Simple DEBUG Windows" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Cyan

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ProjectRoot = Join-Path $PSScriptRoot "project"
$BuildDir = Join-Path $PSScriptRoot "builds"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

Write-Host "📅 Timestamp: $timestamp" -ForegroundColor Gray
Write-Host "📁 Proyecto: $ProjectRoot" -ForegroundColor Gray

# Verificar que Godot existe
if (-not (Test-Path $GodotPath)) {
    Write-Host "❌ Godot no encontrado en: $GodotPath" -ForegroundColor Red
    exit 1
}

# Verificar que el proyecto existe
if (-not (Test-Path $ProjectRoot)) {
    Write-Host "❌ Proyecto no encontrado en: $ProjectRoot" -ForegroundColor Red
    exit 1
}

# Crear directorio de builds
$windowsDir = Join-Path $BuildDir "windows"
$timestampDir = Join-Path $windowsDir $timestamp
New-Item -ItemType Directory -Force -Path $timestampDir | Out-Null

$exePath = Join-Path $timestampDir "bar-sik-debug.exe"

Write-Host "`n🎯 Compilando Windows DEBUG EXE..." -ForegroundColor Cyan
Write-Host "Output: $exePath" -ForegroundColor Gray

try {
    $arguments = '--path "' + $ProjectRoot + '" --headless --export-debug "Windows Debug" "' + $exePath + '"'
    Write-Host "Ejecutando: $GodotPath $arguments" -ForegroundColor Gray

    $process = Start-Process -FilePath $GodotPath -ArgumentList $arguments.Split(' ', [StringSplitOptions]::RemoveEmptyEntries) -PassThru -Wait -NoNewWindow

    if ($process.ExitCode -eq 0) {
        if (Test-Path $exePath) {
            $fileSize = (Get-Item $exePath).Length
            $fileSizeMB = [math]::Round($fileSize / 1MB, 2)

            Write-Host "✅ Build DEBUG exitoso!" -ForegroundColor Green
            Write-Host "📦 Archivo: bar-sik-debug.exe ($fileSizeMB MB)" -ForegroundColor White
            Write-Host "📍 Ubicación: $timestampDir" -ForegroundColor Gray

            # Crear enlace latest
            $latestDir = Join-Path $windowsDir "latest-debug"
            if (Test-Path $latestDir) {
                Remove-Item $latestDir -Force -Recurse -ErrorAction SilentlyContinue
            }

            try {
                New-Item -ItemType SymbolicLink -Path $latestDir -Target $timestampDir -ErrorAction Stop | Out-Null
                Write-Host "🔗 Symlink 'latest-debug' creado" -ForegroundColor Gray
            } catch {
                Copy-Item $timestampDir $latestDir -Recurse -Force
                Write-Host "📁 Directorio 'latest-debug' copiado" -ForegroundColor Gray
            }

            Write-Host "`n🚀 Build DEBUG completado exitosamente!" -ForegroundColor Green
            Write-Host "💡 Este build incluye consola para debug" -ForegroundColor Yellow
        } else {
            Write-Host "❌ El archivo EXE no se generó" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Error en el proceso de compilación (código: $($process.ExitCode))" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error ejecutando Godot: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
