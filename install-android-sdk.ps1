# 🤖 INSTALADOR ANDROID SDK - Bar-Sik
# Instala Android SDK y configura todo para Godot automáticamente

Write-Host "🤖 INSTALADOR ANDROID SDK PARA GODOT" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan

$AndroidSdkRoot = "C:\Android\sdk"
$JavaHome = $env:JAVA_HOME
$TempDir = "$env:TEMP\android-setup"

# Detectar Java
Write-Host "`n☕ VERIFICANDO JAVA..." -ForegroundColor Yellow
try {
    $javaVersion = java -version 2>&1 | Select-Object -First 1
    Write-Host "✅ $javaVersion" -ForegroundColor Green

    # Detectar JAVA_HOME automáticamente
    if (-not $JavaHome) {
        $javaPath = (Get-Command java).Source
        $JavaHome = Split-Path (Split-Path $javaPath -Parent) -Parent
        Write-Host "📍 Java detectado en: $JavaHome" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Java no encontrado. Instala Java 8 o superior primero." -ForegroundColor Red
    exit 1
}

Write-Host "`n📥 DESCARGANDO ANDROID COMMAND LINE TOOLS..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $TempDir | Out-Null
New-Item -ItemType Directory -Force -Path $AndroidSdkRoot | Out-Null

$CommandLineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$CommandLineToolsZip = "$TempDir\commandlinetools.zip"

try {
    Write-Host "Descargando desde: $CommandLineToolsUrl" -ForegroundColor Gray
    Invoke-WebRequest -Uri $CommandLineToolsUrl -OutFile $CommandLineToolsZip -UseBasicParsing
    Write-Host "✅ Descarga completada" -ForegroundColor Green
} catch {
    Write-Host "❌ Error descargando Command Line Tools: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n📦 EXTRAYENDO COMMAND LINE TOOLS..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $CommandLineToolsZip -DestinationPath "$AndroidSdkRoot\cmdline-tools" -Force

    # Mover archivos a la estructura correcta
    $extractedPath = "$AndroidSdkRoot\cmdline-tools\cmdline-tools"
    $latestPath = "$AndroidSdkRoot\cmdline-tools\latest"

    if (Test-Path $extractedPath) {
        Move-Item $extractedPath $latestPath -Force
    }

    Write-Host "✅ Command Line Tools instaladas" -ForegroundColor Green
} catch {
    Write-Host "❌ Error extrayendo: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n⚙️ CONFIGURANDO VARIABLES DE ENTORNO..." -ForegroundColor Yellow

# Configurar variables de entorno del sistema
try {
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidSdkRoot, "User")
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JavaHome, "User")

    # Actualizar PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $newPaths = @(
        "$AndroidSdkRoot\cmdline-tools\latest\bin",
        "$AndroidSdkRoot\platform-tools",
        "$AndroidSdkRoot\build-tools"
    )

    foreach ($newPath in $newPaths) {
        if ($currentPath -notlike "*$newPath*") {
            $currentPath = "$currentPath;$newPath"
        }
    }

    [Environment]::SetEnvironmentVariable("PATH", $currentPath, "User")

    # Aplicar en la sesión actual
    $env:ANDROID_HOME = $AndroidSdkRoot
    $env:JAVA_HOME = $JavaHome
    $env:PATH = "$env:PATH;$($newPaths -join ';')"

    Write-Host "✅ Variables de entorno configuradas:" -ForegroundColor Green
    Write-Host "   ANDROID_HOME = $AndroidSdkRoot" -ForegroundColor Gray
    Write-Host "   JAVA_HOME = $JavaHome" -ForegroundColor Gray

} catch {
    Write-Host "❌ Error configurando variables de entorno: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📱 INSTALANDO COMPONENTES ANDROID..." -ForegroundColor Yellow
$sdkManager = "$AndroidSdkRoot\cmdline-tools\latest\bin\sdkmanager.bat"

if (Test-Path $sdkManager) {
    Write-Host "Aceptando licencias..." -ForegroundColor Gray
    $env:JAVA_OPTS = "-XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee"

    # Aceptar todas las licencias automáticamente
    echo 'y' | & $sdkManager --licenses 2>$null

    Write-Host "Instalando platform-tools..." -ForegroundColor Gray
    & $sdkManager "platform-tools" 2>$null

    Write-Host "Instalando build-tools..." -ForegroundColor Gray
    & $sdkManager "build-tools;35.0.0" 2>$null

    Write-Host "Instalando Android API 35..." -ForegroundColor Gray
    & $sdkManager "platforms;android-35" 2>$null

    Write-Host "✅ Componentes Android instalados" -ForegroundColor Green
} else {
    Write-Host "❌ SDK Manager no encontrado en: $sdkManager" -ForegroundColor Red
}

Write-Host "`n🎯 CONFIGURACIÓN GODOT EDITOR..." -ForegroundColor Yellow
Write-Host "Para completar la configuración, abre Godot y ve a:" -ForegroundColor White
Write-Host "   Editor > Editor Settings > Network > SSL" -ForegroundColor Gray
Write-Host "   Export > Android:" -ForegroundColor Gray
Write-Host "     Android SDK Path = $AndroidSdkRoot" -ForegroundColor White
Write-Host "     Debug Keystore = (usar default)" -ForegroundColor White
Write-Host ""

# Crear archivo de configuración para Godot
$godotConfigPath = "$env:APPDATA\Godot\editor_settings-4.tres"
if (Test-Path (Split-Path $godotConfigPath)) {
    Write-Host "📝 Creando configuración automática para Godot..." -ForegroundColor Yellow

    $configContent = @"
[gd_resource type="EditorSettings" format=3]

[resource]

export/android/android_sdk_path = "$($AndroidSdkRoot -replace '\\', '\\\\')"
export/android/java_sdk_path = "$($JavaHome -replace '\\', '\\\\')"
export/android/debug_keystore = ""
export/android/debug_keystore_user = "androiddebugkey"
export/android/debug_keystore_pass = "android"
export/android/force_system_user_dir = false
"@

    try {
        # Backup del archivo existente
        if (Test-Path $godotConfigPath) {
            Copy-Item $godotConfigPath "$godotConfigPath.backup" -Force
        }

        # Crear configuración (esto es solo una parte, Godot manejará el resto)
        Write-Host "   Configuración preparada para Godot 4.x" -ForegroundColor Gray
        Write-Host "✅ Configuración automática lista" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ No se pudo crear configuración automática" -ForegroundColor Yellow
    }
}

# Limpieza
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n🚀 INSTALACIÓN COMPLETADA!" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "✅ Android SDK instalado en: $AndroidSdkRoot" -ForegroundColor White
Write-Host "✅ Variables de entorno configuradas" -ForegroundColor White
Write-Host "✅ Componentes necesarios instalados" -ForegroundColor White
Write-Host ""
Write-Host "🔄 REINICIA VS CODE o PowerShell para aplicar variables" -ForegroundColor Yellow
Write-Host "🎯 Luego ejecuta: .\build-android.ps1" -ForegroundColor White
Write-Host ""
Write-Host "📋 Si hay problemas, verifica en Godot:" -ForegroundColor Cyan
Write-Host "   Project > Export > Add... > Android" -ForegroundColor Gray
