# 🚀 BUILD ALL PLATFORMS - Bar-Sik
param(
    [switch]$Debug,
    [switch]$SkipWeb,
    [switch]$SkipAndroid,
    [switch]$QuickOnly,
    [int]$CleanKeep = 5
)

Write-Host "🚀 Bar-Sik - Compilación Completa Multiplataforma" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

$startTime = Get-Date
$results = @{}

Write-Host "`n📋 CONFIGURACIÓN DE BUILD:" -ForegroundColor Green
Write-Host "Debug Mode: $(if($Debug){'✅ Activado'}else{'❌ Desactivado'})" -ForegroundColor White
Write-Host "Skip Web: $(if($SkipWeb){'✅ Sí'}else{'❌ No'})" -ForegroundColor White
Write-Host "Skip Android: $(if($SkipAndroid){'✅ Sí'}else{'❌ No'})" -ForegroundColor White
Write-Host "Quick Only: $(if($QuickOnly){'✅ Solo rápidos'}else{'❌ Todos'})" -ForegroundColor White

# Función para ejecutar build y capturar resultado
function Invoke-Build {
    param($Script, $Platform, $Description)

    Write-Host "`n🎯 COMPILANDO $Description" -ForegroundColor Cyan
    Write-Host "=" * 40 -ForegroundColor Gray

    $buildStart = Get-Date

    try {
        if (Test-Path $Script) {
            & $Script
            $success = $LASTEXITCODE -eq 0
        } else {
            Write-Host "❌ Script no encontrado: $Script" -ForegroundColor Red
            $success = $false
        }
    } catch {
        Write-Host "❌ Error ejecutando $Script`: $($_.Exception.Message)" -ForegroundColor Red
        $success = $false
    }

    $buildTime = (Get-Date) - $buildStart

    $results[$Platform] = @{
        Success = $success
        Time = $buildTime
        Description = $Description
    }

    if ($success) {
        Write-Host "✅ $Description completado en $($buildTime.ToString('mm\:ss'))" -ForegroundColor Green
    } else {
        Write-Host "❌ $Description falló después de $($buildTime.ToString('mm\:ss'))" -ForegroundColor Red
    }
}

# 1. WINDOWS
if ($Debug) {
    Invoke-Build ".\build-debug.ps1" "Windows" "WINDOWS DEBUG"
} else {
    Invoke-Build ".\build-quick.ps1" "Windows" "WINDOWS RELEASE"
}

# 2. WEB (si no se salta)
if (-not $SkipWeb -and -not $QuickOnly) {
    Invoke-Build ".\build-web.ps1" "Web" "WEB/HTML5"
}

# 3. ANDROID (si no se salta y no es quick-only)
if (-not $SkipAndroid -and -not $QuickOnly) {
    Invoke-Build ".\build-android.ps1" "Android" "ANDROID APK/AAB"
}

# 4. LIMPIAR BUILDS ANTIGUOS
Write-Host "`n🧹 LIMPIANDO BUILDS ANTIGUOS (manteniendo últimos $CleanKeep)" -ForegroundColor Yellow
try {
    .\clean-builds.ps1 -Keep $CleanKeep
    Write-Host "✅ Limpieza completada" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Error en limpieza: $($_.Exception.Message)" -ForegroundColor Yellow
}

$totalTime = (Get-Date) - $startTime

# RESUMEN FINAL
Write-Host "`n🎉 RESUMEN DE COMPILACIÓN COMPLETA" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Cyan

$successful = 0
$failed = 0

foreach ($platform in $results.Keys) {
    $result = $results[$platform]
    $status = if ($result.Success) { "✅"; $successful++ } else { "❌"; $failed++ }
    $time = $result.Time.ToString('mm\:ss')

    Write-Host "$status $($result.Description) - $time" -ForegroundColor $(if ($result.Success) { "Green" } else { "Red" })
}

Write-Host "`n📊 ESTADÍSTICAS:" -ForegroundColor Cyan
Write-Host "Exitosos: $successful" -ForegroundColor Green
Write-Host "Fallidos: $failed" -ForegroundColor Red
Write-Host "Tiempo total: $($totalTime.ToString('mm\:ss'))" -ForegroundColor White

if ($successful -gt 0) {
    Write-Host "`n📁 Ver builds generados:" -ForegroundColor Gray
    Write-Host "   .\build-history.ps1" -ForegroundColor White
}

if ($failed -eq 0) {
    Write-Host "`n🏆 TODAS LAS COMPILACIONES EXITOSAS!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Algunas compilaciones fallaron. Revisa los logs arriba." -ForegroundColor Yellow
}

Write-Host "`n🚀 Builds disponibles en carpeta 'builds' y enlaces 'latest'" -ForegroundColor Cyan
