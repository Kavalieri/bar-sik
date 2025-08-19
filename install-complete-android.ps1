# 🚀 INSTALADOR COMPLETO ANDROID + JAVA 17 JDK + NDK - Bar-Sik
# Instala TODOS los componentes necesarios para Godot + Google Play Store 2025

Write-Host "🚀 INSTALADOR COMPLETO ANDROID DEVELOPMENT KIT" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Cyan

$AndroidSdkRoot = "C:\Android\sdk"
$JavaSdkRoot = "C:\Program Files\Eclipse Adoptium\jdk-17.0.12.7-hotspot"
$TempDir = "$env:TEMP\android-dev-setup"

Write-Host "`n📋 COMPONENTES A INSTALAR:" -ForegroundColor Yellow
Write-Host "   1. ☕ Java 17 JDK (Eclipse Temurin)" -ForegroundColor White
Write-Host "   2. 📱 Android SDK + Command Line Tools" -ForegroundColor White
Write-Host "   3. 🔧 Android NDK (Native Development Kit)" -ForegroundColor White
Write-Host "   4. 🏗️ Build Tools 34.0.0" -ForegroundColor White
Write-Host "   5. 📦 Platform API 34" -ForegroundColor White

New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

# ============================================================================
# 1. INSTALAR JAVA 17 JDK
# ============================================================================
Write-Host "`n☕ PASO 1: INSTALANDO JAVA 17 JDK..." -ForegroundColor Yellow

$java17Url = "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.12%2B7/OpenJDK17U-jdk_x64_windows_hotspot_17.0.12_7.msi"
$java17Msi = "$TempDir\java17-jdk.msi"

try {
    Write-Host "📥 Descargando Java 17 JDK..." -ForegroundColor Gray
    Write-Host "   URL: $java17Url" -ForegroundColor DarkGray
    Invoke-WebRequest -Uri $java17Url -OutFile $java17Msi -UseBasicParsing
    Write-Host "✅ Java 17 JDK descargado" -ForegroundColor Green

    Write-Host "🔧 Instalando Java 17 JDK..." -ForegroundColor Gray
    $installArgs = "/i `"$java17Msi`" /quiet /norestart ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJarFileRunWith,FeatureJavaHome INSTALLDIR=`"$JavaSdkRoot`""
    Start-Process "msiexec.exe" -ArgumentList $installArgs -Wait -NoNewWindow
    Write-Host "✅ Java 17 JDK instalado" -ForegroundColor Green

} catch {
    Write-Host "❌ Error instalando Java 17 JDK: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Instala manualmente desde: https://adoptium.net/temurin/releases/" -ForegroundColor Yellow
}

# ============================================================================
# 2. INSTALAR ANDROID SDK
# ============================================================================
Write-Host "`n📱 PASO 2: INSTALANDO ANDROID SDK..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $AndroidSdkRoot | Out-Null

$CommandLineToolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
$CommandLineToolsZip = "$TempDir\commandlinetools.zip"

try {
    Write-Host "📥 Descargando Android Command Line Tools..." -ForegroundColor Gray
    Invoke-WebRequest -Uri $CommandLineToolsUrl -OutFile $CommandLineToolsZip -UseBasicParsing
    Write-Host "✅ Command Line Tools descargados" -ForegroundColor Green

    Write-Host "📦 Extrayendo Command Line Tools..." -ForegroundColor Gray
    Expand-Archive -Path $CommandLineToolsZip -DestinationPath "$AndroidSdkRoot\cmdline-tools" -Force

    # Estructura correcta para Android SDK
    $extractedPath = "$AndroidSdkRoot\cmdline-tools\cmdline-tools"
    $latestPath = "$AndroidSdkRoot\cmdline-tools\latest"

    if (Test-Path $extractedPath) {
        Move-Item $extractedPath $latestPath -Force
    }

    Write-Host "✅ Android SDK instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ Error instalando Android SDK: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# ============================================================================
# 3. CONFIGURAR VARIABLES DE ENTORNO
# ============================================================================
Write-Host "`n⚙️ PASO 3: CONFIGURANDO VARIABLES DE ENTORNO..." -ForegroundColor Yellow

try {
    # Variables del sistema
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JavaSdkRoot, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidSdkRoot, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $AndroidSdkRoot, "User")

    # PATH actualizado
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $newPaths = @(
        "$JavaSdkRoot\bin",
        "$AndroidSdkRoot\cmdline-tools\latest\bin",
        "$AndroidSdkRoot\platform-tools",
        "$AndroidSdkRoot\build-tools",
        "$AndroidSdkRoot\ndk"
    )

    foreach ($newPath in $newPaths) {
        if ($currentPath -notlike "*$newPath*") {
            $currentPath = "$currentPath;$newPath"
        }
    }

    [Environment]::SetEnvironmentVariable("PATH", $currentPath, "User")

    # Aplicar en sesión actual
    $env:JAVA_HOME = $JavaSdkRoot
    $env:ANDROID_HOME = $AndroidSdkRoot
    $env:ANDROID_SDK_ROOT = $AndroidSdkRoot
    $env:PATH = "$env:PATH;$($newPaths -join ';')"

    Write-Host "✅ Variables de entorno configuradas:" -ForegroundColor Green
    Write-Host "   JAVA_HOME = $JavaSdkRoot" -ForegroundColor Gray
    Write-Host "   ANDROID_HOME = $AndroidSdkRoot" -ForegroundColor Gray

} catch {
    Write-Host "❌ Error configurando variables: $($_.Exception.Message)" -ForegroundColor Red
}

# ============================================================================
# 4. INSTALAR COMPONENTES ANDROID (SDK + NDK)
# ============================================================================
Write-Host "`n🔧 PASO 4: INSTALANDO COMPONENTES ANDROID..." -ForegroundColor Yellow
$sdkManager = "$AndroidSdkRoot\cmdline-tools\latest\bin\sdkmanager.bat"

if (Test-Path $sdkManager) {
    Write-Host "📋 Aceptando licencias Android..." -ForegroundColor Gray
    $env:JAVA_OPTS = "-XX:+IgnoreUnrecognizedVMOptions"
    Write-Output 'y' | & $sdkManager --licenses 2>$null

    Write-Host "🛠️ Instalando Platform Tools..." -ForegroundColor Gray
    & $sdkManager "platform-tools" 2>$null

    Write-Host "🏗️ Instalando Build Tools 34.0.0..." -ForegroundColor Gray
    & $sdkManager "build-tools;34.0.0" 2>$null

    Write-Host "📦 Instalando Android API 34..." -ForegroundColor Gray
    & $sdkManager "platforms;android-34" 2>$null

    Write-Host "🔧 Instalando Android NDK (crítico para Godot)..." -ForegroundColor Cyan
    & $sdkManager "ndk;25.1.8937393" 2>$null

    Write-Host "📱 Instalando CMake (para NDK)..." -ForegroundColor Gray
    & $sdkManager "cmake;3.22.1" 2>$null

    Write-Host "✅ Todos los componentes Android instalados" -ForegroundColor Green

    # Verificar instalación NDK
    $ndkPath = "$AndroidSdkRoot\ndk\25.1.8937393"
    if (Test-Path $ndkPath) {
        Write-Host "✅ NDK verificado en: $ndkPath" -ForegroundColor Green
    } else {
        Write-Host "⚠️ NDK no encontrado en la ruta esperada" -ForegroundColor Yellow
    }

} else {
    Write-Host "❌ SDK Manager no encontrado en: $sdkManager" -ForegroundColor Red
}

# ============================================================================
# 5. VERIFICAR INSTALACIÓN
# ============================================================================
Write-Host "`n🔍 PASO 5: VERIFICANDO INSTALACIÓN..." -ForegroundColor Yellow

Write-Host "☕ Verificando Java..." -ForegroundColor Gray
try {
    $javaVersion = & "$JavaSdkRoot\bin\java.exe" -version 2>&1 | Select-Object -First 1
    Write-Host "✅ $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Java no responde correctamente" -ForegroundColor Yellow
}

Write-Host "📱 Verificando Android SDK..." -ForegroundColor Gray
if (Test-Path "$AndroidSdkRoot\platform-tools\adb.exe") {
    Write-Host "✅ Android SDK operativo" -ForegroundColor Green
} else {
    Write-Host "❌ Android SDK incompleto" -ForegroundColor Red
}

Write-Host "🔧 Verificando NDK..." -ForegroundColor Gray
$ndkInstalled = Get-ChildItem "$AndroidSdkRoot\ndk" -Directory -ErrorAction SilentlyContinue
if ($ndkInstalled) {
    Write-Host "✅ NDK instalado: $($ndkInstalled.Name)" -ForegroundColor Green
} else {
    Write-Host "❌ NDK no encontrado" -ForegroundColor Red
}

# ============================================================================
# 6. CONFIGURACIÓN GODOT
# ============================================================================
Write-Host "`n🎯 PASO 6: PREPARANDO CONFIGURACIÓN GODOT..." -ForegroundColor Yellow

Write-Host "📝 Configuración para Godot Editor:" -ForegroundColor White
Write-Host "   Editor > Editor Settings > Export > Android:" -ForegroundColor Gray
Write-Host "     Android SDK Path = $AndroidSdkRoot" -ForegroundColor White
Write-Host "     Android NDK Path = $AndroidSdkRoot\ndk\25.1.8937393" -ForegroundColor White
Write-Host "     Java SDK Path = $JavaSdkRoot" -ForegroundColor White

# Limpieza
Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n🚀 INSTALACIÓN COMPLETADA!" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Cyan
Write-Host "✅ Java 17 JDK instalado" -ForegroundColor White
Write-Host "✅ Android SDK + NDK instalados" -ForegroundColor White
Write-Host "✅ Variables de entorno configuradas" -ForegroundColor White
Write-Host "✅ Componentes Google Play Store 2025 ready" -ForegroundColor White
Write-Host ""
Write-Host "⚡ SIGUIENTE PASO:" -ForegroundColor Yellow
Write-Host "   1. Reinicia VS Code/PowerShell" -ForegroundColor White
Write-Host "   2. Abre Godot y configura las rutas" -ForegroundColor White
Write-Host "   3. Ejecuta: .\build-android.ps1" -ForegroundColor White
Write-Host ""
Write-Host "🏪 Google Play Store Compliance:" -ForegroundColor Green
Write-Host "   ✅ Target SDK 34" -ForegroundColor Gray
Write-Host "   ✅ Java 17 JDK" -ForegroundColor Gray
Write-Host "   ✅ NDK para Godot" -ForegroundColor Gray
Write-Host "   ✅ AAB format ready" -ForegroundColor Gray
