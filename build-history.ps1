# 📜 HISTORIAL DE BUILDS - Bar-Sik
param(
    [string]$Platform = "all"
)

Write-Host "📜 Bar-Sik - Historial de Builds" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan

$BuildsDir = Join-Path $PSScriptRoot "builds"

if (-not (Test-Path $BuildsDir)) {
    Write-Host "❌ No se encontró directorio de builds" -ForegroundColor Red
    exit
}

$platforms = @("windows", "web", "android", "linux")
if ($Platform -ne "all") {
    $platforms = @($Platform)
}

foreach ($plat in $platforms) {
    $platDir = Join-Path $BuildsDir $plat

    if (-not (Test-Path $platDir)) {
        continue
    }

    Write-Host "`n🖥️ $($plat.ToUpper())" -ForegroundColor Yellow
    Write-Host "$(''*20)" -ForegroundColor Cyan

    # Obtener todos los directorios timestamped (excluyendo 'latest')
    $timestampDirs = Get-ChildItem $platDir -Directory | Where-Object { $_.Name -ne "latest" } | Sort-Object Name -Descending

    if ($timestampDirs.Count -eq 0) {
        Write-Host "   No hay builds disponibles" -ForegroundColor Gray
        continue
    }

    foreach ($tsDir in $timestampDirs) {
        $timestamp = $tsDir.Name
        $files = Get-ChildItem $tsDir.FullName -File

        if ($files.Count -gt 0) {
            # Parsear timestamp para mostrar fecha legible
            try {
                $parsedDate = [DateTime]::ParseExact($timestamp, "yyyy-MM-dd_HH-mm-ss", $null)
                $friendlyDate = $parsedDate.ToString("dd/MM/yyyy HH:mm:ss")
            } catch {
                $friendlyDate = $timestamp
            }

            Write-Host "   📅 $friendlyDate" -ForegroundColor White
            Write-Host "   📂 $timestamp" -ForegroundColor Gray

            foreach ($file in $files) {
                $size = [math]::Round($file.Length / 1MB, 2)
                $isLatest = ""

                # Verificar si es el latest
                $latestDir = Join-Path $platDir "latest"
                if ((Test-Path $latestDir) -and (Test-Path (Join-Path $latestDir $file.Name))) {
                    $isLatest = " ← latest"
                }

                Write-Host "      📁 $($file.Name) ($size MB)$isLatest" -ForegroundColor White
            }
            Write-Host ""
        }
    }

    # Mostrar stats
    $totalBuilds = $timestampDirs.Count
    $totalSize = ($timestampDirs | ForEach-Object { (Get-ChildItem $_.FullName -File | Measure-Object Length -Sum).Sum } | Measure-Object -Sum).Sum
    $totalSizeMB = [math]::Round($totalSize / 1MB, 2)

    Write-Host "   📊 Total builds: $totalBuilds" -ForegroundColor Cyan
    Write-Host "   💾 Espacio total: $totalSizeMB MB" -ForegroundColor Cyan
}

# Comando de limpieza
Write-Host "`n🧹 COMANDOS DE LIMPIEZA:" -ForegroundColor Yellow
Write-Host "   # Limpiar builds antiguos (mantener últimos 5)"
Write-Host "   .\clean-builds.ps1 -Keep 5" -ForegroundColor Gray
Write-Host "   # Limpiar todo excepto latest"
Write-Host "   .\clean-builds.ps1 -KeepOnlyLatest" -ForegroundColor Gray
