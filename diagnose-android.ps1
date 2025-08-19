# 🔍 DIAGNÓSTICO ANDROID - Bar-Sik
Write-Host "🔍 DIAGNÓSTICO COMPLETO ANDROID SETUP" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan

# 1. JAVA
Write-Host "`n☕ JAVA SETUP:" -ForegroundColor Yellow
Write-Host "JAVA_HOME: $env:JAVA_HOME" -ForegroundColor White
try {
    $javaVer = java -version 2>&1 | Select-Object -First 1
    Write-Host "Java Version: $javaVer" -ForegroundColor Green
} catch {
    Write-Host "❌ Java no encontrado en PATH" -ForegroundColor Red
}

# 2. ANDROID SDK
Write-Host "`n📱 ANDROID SDK:" -ForegroundColor Yellow
Write-Host "ANDROID_HOME: $env:ANDROID_HOME" -ForegroundColor White

$sdkPaths = @(
    "C:\Android\sdk",
    "C:\Android\Sdk",
    "$env:LOCALAPPDATA\Android\sdk",
    "$env:LOCALAPPDATA\Android\Sdk",
    "$env:USERPROFILE\AppData\Local\Android\sdk"
)

$foundSdkPath = $null
foreach ($path in $sdkPaths) {
    if (Test-Path $path) {
        $foundSdkPath = $path
        Write-Host "✅ SDK encontrado en: $path" -ForegroundColor Green
        break
    }
}

if ($foundSdkPath) {
    # Verificar estructura del SDK
    Write-Host "`n📋 COMPONENTES DEL SDK:" -ForegroundColor Cyan

    $components = @{
        "Platform Tools" = "platform-tools\adb.exe"
        "Build Tools" = "build-tools"
        "NDK" = "ndk"
        "Platforms" = "platforms"
        "Command Line Tools" = "cmdline-tools\latest\bin\sdkmanager.bat"
    }

    foreach ($comp in $components.GetEnumerator()) {
        $compPath = Join-Path $foundSdkPath $comp.Value
        if (Test-Path $compPath) {
            Write-Host "   ✅ $($comp.Key)" -ForegroundColor Green

            # Detalles adicionales para algunos componentes
            if ($comp.Key -eq "NDK") {
                $ndkVersions = Get-ChildItem $compPath -Directory -ErrorAction SilentlyContinue
                if ($ndkVersions) {
                    Write-Host "      Versions: $($ndkVersions.Name -join ', ')" -ForegroundColor Gray
                }
            }
            if ($comp.Key -eq "Build Tools") {
                $buildTools = Get-ChildItem $compPath -Directory -ErrorAction SilentlyContinue
                if ($buildTools) {
                    Write-Host "      Versions: $($buildTools.Name -join ', ')" -ForegroundColor Gray
                }
            }
        } else {
            Write-Host "   ❌ $($comp.Key) - No encontrado" -ForegroundColor Red
        }
    }
} else {
    Write-Host "❌ Android SDK no encontrado" -ForegroundColor Red
}

# 3. GODOT EXPORT PRESETS
Write-Host "`n🎯 GODOT EXPORT PRESETS:" -ForegroundColor Yellow
if (Test-Path "project\export_presets.cfg") {
    Write-Host "✅ export_presets.cfg encontrado" -ForegroundColor Green

    # Buscar presets Android
    $content = Get-Content "project\export_presets.cfg"
    $androidPresets = $content | Select-String 'name=".*Android.*"'

    if ($androidPresets) {
        Write-Host "📱 Presets Android encontrados:" -ForegroundColor Cyan
        foreach ($preset in $androidPresets) {
            Write-Host "   $($preset.Line)" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ No se encontraron presets Android" -ForegroundColor Red
    }
} else {
    Write-Host "❌ export_presets.cfg no encontrado" -ForegroundColor Red
}

# 4. RECOMENDACIONES
Write-Host "`n💡 RECOMENDACIONES:" -ForegroundColor Yellow

if (-not $env:ANDROID_HOME) {
    if ($foundSdkPath) {
        Write-Host "🔧 Configurar ANDROID_HOME:" -ForegroundColor Cyan
        Write-Host "   [Environment]::SetEnvironmentVariable('ANDROID_HOME', '$foundSdkPath', 'User')" -ForegroundColor White
    } else {
        Write-Host "📥 Instalar Android SDK:" -ForegroundColor Cyan
        Write-Host "   Usa Android Studio o Command Line Tools" -ForegroundColor White
    }
}

if ($foundSdkPath -and -not (Test-Path "$foundSdkPath\ndk")) {
    Write-Host "🔧 Instalar NDK (crítico para Godot):" -ForegroundColor Cyan
    Write-Host "   sdkmanager 'ndk;25.1.8937393'" -ForegroundColor White
}

Write-Host "`n🚀 ESTADO GENERAL:" -ForegroundColor Green
$readyCount = 0
if ($env:JAVA_HOME -or (Get-Command java -ErrorAction SilentlyContinue)) { $readyCount++ }
if ($foundSdkPath) { $readyCount++ }
if ($foundSdkPath -and (Test-Path "$foundSdkPath\ndk")) { $readyCount++ }

switch ($readyCount) {
    3 { Write-Host "✅ TODO LISTO para builds Android!" -ForegroundColor Green }
    2 { Write-Host "⚠️ PARCIALMENTE listo - faltan algunos componentes" -ForegroundColor Yellow }
    1 { Write-Host "❌ SETUP INCOMPLETO - faltan componentes críticos" -ForegroundColor Red }
    0 { Write-Host "❌ SETUP NO INICIADO - instalar desde cero" -ForegroundColor Red }
}
