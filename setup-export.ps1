# 🔧 SETUP COMPLETO - Bar-Sik Export
param(
    [switch]$CheckOnly,
    [switch]$InstallAndroid,
    [switch]$InstallTemplates,
    [switch]$ConfigureAll
)

Write-Host "🔧 Bar-Sik - Setup de Exportación" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan

$ProjectRoot = $PSScriptRoot
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"

# 📋 VERIFICACIONES
Write-Host "`n📋 VERIFICANDO CONFIGURACIÓN ACTUAL..." -ForegroundColor Yellow

# 1. Verificar Godot
Write-Host "`n1. 🎯 GODOT ENGINE" -ForegroundColor Cyan
try {
    $godotVersion = & $GodotPath --version 2>$null
    Write-Host "   ✅ Godot encontrado: $godotVersion" -ForegroundColor Green
    $godotOk = $true
} catch {
    Write-Host "   ❌ Godot NO encontrado en PATH" -ForegroundColor Red
    Write-Host "      Descarga: https://godotengine.org/download" -ForegroundColor Yellow
    $godotOk = $false
}

# 2. Verificar Export Templates
Write-Host "`n2. 📦 EXPORT TEMPLATES" -ForegroundColor Cyan
$templatesPath = "$env:APPDATA\Godot\export_templates"
if (Test-Path $templatesPath) {
    $templates = Get-ChildItem $templatesPath -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if ($templates) {
        Write-Host "   ✅ Templates encontrados: $($templates.Name)" -ForegroundColor Green
        $templatesOk = $true
    } else {
        Write-Host "   ❌ No hay templates instalados" -ForegroundColor Red
        $templatesOk = $false
    }
} else {
    Write-Host "   ❌ Carpeta de templates no existe" -ForegroundColor Red
    $templatesOk = $false
}

# 3. Verificar Android SDK
Write-Host "`n3. 🤖 ANDROID SDK" -ForegroundColor Cyan
$androidSdk = $env:ANDROID_SDK_ROOT
if (-not $androidSdk) { $androidSdk = $env:ANDROID_HOME }

if ($androidSdk -and (Test-Path $androidSdk)) {
    Write-Host "   ✅ Android SDK: $androidSdk" -ForegroundColor Green

    # Verificar componentes
    $platformTools = Join-Path $androidSdk "platform-tools"
    $buildTools = Join-Path $androidSdk "build-tools"

    if (Test-Path $platformTools) {
        Write-Host "   ✅ Platform Tools encontradas" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Platform Tools faltantes" -ForegroundColor Red
    }

    if (Test-Path $buildTools) {
        $latestBuildTools = Get-ChildItem $buildTools -Directory | Sort-Object Name -Descending | Select-Object -First 1
        Write-Host "   ✅ Build Tools: $($latestBuildTools.Name)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Build Tools faltantes" -ForegroundColor Red
    }

    $androidOk = $true
} else {
    Write-Host "   ❌ Android SDK no encontrado" -ForegroundColor Red
    Write-Host "      Variable ANDROID_SDK_ROOT o ANDROID_HOME no configurada" -ForegroundColor Yellow
    $androidOk = $false
}

# 4. Verificar Java
Write-Host "`n4. ☕ JAVA JDK" -ForegroundColor Cyan
try {
    $javaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    Write-Host "   ✅ Java encontrado: $javaVersion" -ForegroundColor Green
    $javaOk = $true
} catch {
    Write-Host "   ❌ Java no encontrado" -ForegroundColor Red
    Write-Host "      Instala OpenJDK 11 o superior" -ForegroundColor Yellow
    $javaOk = $false
}

# 5. Verificar configuración Godot
Write-Host "`n5. ⚙️ CONFIGURACIÓN GODOT" -ForegroundColor Cyan
$godotConfigPath = "$env:APPDATA\Godot\editor_settings-4.tres"
if (Test-Path $godotConfigPath) {
    $config = Get-Content $godotConfigPath -Raw
    if ($config -match "export/android/android_sdk_path") {
        Write-Host "   ✅ Android SDK configurado en Godot" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Android SDK no configurado en Godot" -ForegroundColor Red
    }
    $configOk = $true
} else {
    Write-Host "   ❌ Configuración de Godot no encontrada" -ForegroundColor Red
    $configOk = $false
}

# 📊 RESUMEN
Write-Host "`n📊 RESUMEN DE CONFIGURACIÓN" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Cyan
Write-Host "Godot Engine:     $(if($godotOk){'✅'}else{'❌'})" -ForegroundColor $(if($godotOk){'Green'}else{'Red'})
Write-Host "Export Templates: $(if($templatesOk){'✅'}else{'❌'})" -ForegroundColor $(if($templatesOk){'Green'}else{'Red'})
Write-Host "Android SDK:      $(if($androidOk){'✅'}else{'❌'})" -ForegroundColor $(if($androidOk){'Green'}else{'Red'})
Write-Host "Java JDK:         $(if($javaOk){'✅'}else{'❌'})" -ForegroundColor $(if($javaOk){'Green'}else{'Red'})
Write-Host "Configuración:    $(if($configOk){'✅'}else{'❌'})" -ForegroundColor $(if($configOk){'Green'}else{'Red'})

if ($CheckOnly) {
    Write-Host "`n🎯 Solo verificación completada." -ForegroundColor Yellow
    exit
}

# 🛠️ INSTALACIÓN/CONFIGURACIÓN AUTOMÁTICA
if (-not $templatesOk -or $InstallTemplates) {
    Write-Host "`n📦 INSTALANDO EXPORT TEMPLATES..." -ForegroundColor Yellow
    Write-Host "   Esto puede tardar varios minutos..." -ForegroundColor Gray

    # Instalar templates via Godot
    & $GodotPath --headless --export-pack

    Write-Host "   ✅ Export templates instalados" -ForegroundColor Green
}

if (-not $androidOk -or $InstallAndroid) {
    Write-Host "`n🤖 CONFIGURACIÓN ANDROID REQUERIDA:" -ForegroundColor Yellow
    Write-Host "   1. Instala Android Studio: https://developer.android.com/studio" -ForegroundColor White
    Write-Host "   2. Abre Android Studio → SDK Manager" -ForegroundColor White
    Write-Host "   3. Instala:" -ForegroundColor White
    Write-Host "      - Android SDK Platform-Tools" -ForegroundColor Gray
    Write-Host "      - Android SDK Build-Tools (latest)" -ForegroundColor Gray
    Write-Host "      - Android SDK Platform API 34" -ForegroundColor Gray
    Write-Host "      - Android SDK Command-line Tools" -ForegroundColor Gray
    Write-Host "   4. Configura variables de entorno:" -ForegroundColor White
    Write-Host "      ANDROID_SDK_ROOT=C:\Users\tu-usuario\AppData\Local\Android\Sdk" -ForegroundColor Gray
}

Write-Host "`n🎯 PRÓXIMOS PASOS:" -ForegroundColor Green
Write-Host "1. Si faltan componentes, instálalos según las instrucciones arriba" -ForegroundColor White
Write-Host "2. Reinicia PowerShell para que las variables de entorno se actualicen" -ForegroundColor White
Write-Host "3. Ejecuta: .\setup-export.ps1 -CheckOnly" -ForegroundColor White
Write-Host "4. Cuando todo esté ✅, usa: .\build-quick.ps1 -All" -ForegroundColor White

Write-Host "`n🚀 Configuración completada!" -ForegroundColor Green
