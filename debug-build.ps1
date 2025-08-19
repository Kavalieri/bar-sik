# 🔍 DEBUG BUILD - Ver errores exactos
param(
    [string]$Platform = "Windows Desktop",
    [string]$OutputPath = "E:\GitHub\bar-sik\builds\debug-test.exe"
)

Write-Host "🔍 Debug Build - $Platform" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan

$ProjectPath = "E:\GitHub\bar-sik\project"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

# Crear directorio
New-Item -ItemType Directory -Force -Path (Split-Path $OutputPath) | Out-Null

Write-Host "📋 CONFIGURACIÓN:" -ForegroundColor Cyan
Write-Host "   Godot: $GodotPath" -ForegroundColor Gray
Write-Host "   Proyecto: $ProjectPath" -ForegroundColor Gray
Write-Host "   Plataforma: $Platform" -ForegroundColor Gray
Write-Host "   Salida: $OutputPath" -ForegroundColor Gray

# Verificar archivos
Write-Host "`n🔍 VERIFICACIONES:" -ForegroundColor Cyan
Write-Host "   Godot existe: $(Test-Path $GodotPath)" -ForegroundColor White
Write-Host "   project.godot existe: $(Test-Path "$ProjectPath\project.godot")" -ForegroundColor White
Write-Host "   export_presets.cfg existe: $(Test-Path "$ProjectPath\export_presets.cfg")" -ForegroundColor White

# Comando completo
$cmd = "& `"$GodotPath`" --headless --verbose --path `"$ProjectPath`" --export-release `"$Platform`" `"$OutputPath`""
Write-Host "`n🚀 COMANDO:" -ForegroundColor Cyan
Write-Host "   $cmd" -ForegroundColor White

Write-Host "`n📦 EJECUTANDO..." -ForegroundColor Yellow
try {
    $output = Invoke-Expression $cmd 2>&1
    Write-Host "SALIDA COMPLETA:" -ForegroundColor Green
    $output | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ ÉXITO!" -ForegroundColor Green
        if (Test-Path $OutputPath) {
            $size = [math]::Round((Get-Item $OutputPath).Length / 1MB, 2)
            Write-Host "   📁 Archivo generado: $size MB" -ForegroundColor White
        }
    } else {
        Write-Host "`n❌ ERROR (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
    }
} catch {
    Write-Host "`n💥 EXCEPCIÓN:" -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
}
