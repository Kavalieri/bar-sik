# 🚀 BUILD RÁPIDO - Bar-Sik
param(
    [string]$Version = "0.3.0",
    [switch]$Windows,
    [switch]$Linux,
    [switch]$Android,
    [switch]$Web,
    [switch]$Debug,
    [switch]$All,
    [switch]$Package,
    [switch]$Clean,
    [string]$BuildType = "release"
)

Write-Host "🎯 Bar-Sik - Build Rápido v$Version" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Cyan

# Generar timestamp único
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
Write-Host "📅 Timestamp: $timestamp" -ForegroundColor Gray

$ProjectRoot = Join-Path $PSScriptRoot "project"
$BuildDir = Join-Path $PSScriptRoot "builds"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

# Función para crear directorio timestamped y symlink latest
function New-TimestampedDir {
    param($Platform, $Timestamp)

    $platformDir = Join-Path $BuildDir $Platform
    $timestampDir = Join-Path $platformDir $Timestamp
    $latestDir = Join-Path $platformDir "latest"

    # Crear directorio timestamped
    New-Item -ItemType Directory -Force -Path $timestampDir | Out-Null

    # Crear/actualizar symlink latest (si es posible)
    if (Test-Path $latestDir) {
        Remove-Item $latestDir -Force -Recurse -ErrorAction SilentlyContinue
    }

    try {
        # Intentar crear symlink (requiere permisos admin)
        New-Item -ItemType SymbolicLink -Path $latestDir -Target $timestampDir -ErrorAction Stop | Out-Null
        Write-Host "   📂 Symlink 'latest' creado" -ForegroundColor Gray
    } catch {
        # Si no se puede crear symlink, copiar directorio
        Copy-Item $timestampDir $latestDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   📂 Directorio 'latest' copiado" -ForegroundColor Gray
    }

    return $timestampDir
}

# Limpiar si se solicita
if ($Clean -and (Test-Path $BuildDir)) {
    Write-Host "🧹 Limpiando builds..." -ForegroundColor Yellow
    Remove-Item $BuildDir -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

# Función de exportación
function Export-Game {
    param($Platform, $OutputPath, $Name)

    Write-Host "📦 Exportando $Name..." -ForegroundColor Cyan

    $cmd = "& `"$GodotPath`" --headless --path `"$ProjectRoot`" --export-$BuildType `"$Platform`" `"$OutputPath`""

    try {
        $output = Invoke-Expression $cmd 2>&1

        # Buscar indicadores de éxito/error en el output
        $hasError = $output | Where-Object { $_ -like "*ERROR*" -and $_ -notlike "*completed with warnings*" }
        $hasSuccess = $output | Where-Object { $_ -like "*completed with warnings*" -or $_ -like "*savepack: end*" }

        if (-not $hasError -and ($hasSuccess -or (Test-Path $OutputPath))) {
            Write-Host "✅ $Name completado" -ForegroundColor Green
            if (Test-Path $OutputPath) {
                $size = [math]::Round((Get-Item $OutputPath).Length / 1MB, 2)
                Write-Host "   📁 $([System.IO.Path]::GetFileName($OutputPath)) ($size MB)" -ForegroundColor White
            }
            return $true
        } else {
            Write-Host "❌ Error en $Name" -ForegroundColor Red
            if ($hasError) {
                Write-Host "   Errores encontrados:" -ForegroundColor Yellow
                $hasError | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
            }
            return $false
        }
    } catch {
        Write-Host "❌ Error en $Name" -ForegroundColor Red
        Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

$success = @()

# Exportaciones
if ($Windows -or $All) {
    $winDir = New-TimestampedDir "windows" $timestamp

    $winPath = Join-Path $winDir "bar-sik-v$Version.exe"
    if (Export-Game "Windows Desktop" $winPath "Windows") { $success += "Windows" }
}

if ($Debug) {
    $winDir = New-TimestampedDir "windows" $timestamp

    $debugPath = Join-Path $winDir "bar-sik-v$Version-debug.exe"
    if (Export-Game "Windows Debug" $debugPath "Windows Debug") { $success += "Windows Debug" }
}

if ($Linux -or $All) {
    $linuxDir = New-TimestampedDir "linux" $timestamp

    $linuxPath = Join-Path $linuxDir "bar-sik-v$Version"
    if (Export-Game "Linux/X11" $linuxPath "Linux") { $success += "Linux" }
}

if ($Android -or $All) {
    $androidDir = New-TimestampedDir "android" $timestamp

    $apkPath = Join-Path $androidDir "bar-sik-v$Version.apk"
    $aabPath = Join-Path $androidDir "bar-sik-v$Version.aab"

    if (Export-Game "Android" $apkPath "Android APK") { $success += "Android APK" }
    if (Export-Game "Android AAB" $aabPath "Android AAB") { $success += "Android AAB" }
}

if ($Web -or $All) {
    $webDir = New-TimestampedDir "web" $timestamp

    $webPath = Join-Path $webDir "index.html"
    if (Export-Game "Web" $webPath "Web") { $success += "Web" }
}

    if (Export-Game "Android" $apkPath "Android APK") { $success += "Android APK" }
    if (Export-Game "Android AAB" $aabPath "Android AAB") { $success += "Android AAB" }
}

if ($Web -or $All) {
    $webDir = Join-Path $BuildDir "web"
    New-Item -ItemType Directory -Force -Path $webDir | Out-Null

    $webPath = Join-Path $webDir "index.html"
    if (Export-Game "Web" $webPath "Web") { $success += "Web" }
}

# Resumen
Write-Host "`n🎉 BUILDS COMPLETADOS" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor White
Write-Host "Exitosos: $($success -join ', ')" -ForegroundColor White
Write-Host "Directorio: $BuildDir" -ForegroundColor Gray

# Mostrar estructura generada
if ($success.Count -gt 0) {
    Write-Host "`n📁 ESTRUCTURA GENERADA:" -ForegroundColor Yellow
    $success | ForEach-Object {
        $platform = switch ($_) {
            "Windows" { "windows" }
            "Windows Debug" { "windows" }
            "Linux" { "linux" }
            "Android APK" { "android" }
            "Android AAB" { "android" }
            "Web" { "web" }
        }
        Write-Host "   📂 builds/$platform/$timestamp/" -ForegroundColor White
        Write-Host "   📂 builds/$platform/latest/ (symlink/copy)" -ForegroundColor Gray
    }
}

# Listar archivos generados
Write-Host "`n📦 ARCHIVOS GENERADOS:" -ForegroundColor Yellow
Get-ChildItem $BuildDir -Recurse -File | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "   📁 $($_.Name) ($size MB)" -ForegroundColor White
}

Write-Host "`n🚀 ¡Listo para distribuir!" -ForegroundColor Green
