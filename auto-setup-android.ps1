# 🚀 AUTO-SETUP ANDROID COMPLETO - Bar-Sik
# Encuentra e instala todo automáticamente

Write-Host "🚀 AUTO-SETUP ANDROID COMPLETO" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Cyan

# PASO 1: ENCONTRAR O INSTALAR JAVA 17
Write-Host "`n1️⃣ JAVA 17 SETUP:" -ForegroundColor Yellow

$java17Found = $false
$java17Path = $null

# Buscar Java 17 existente
$searchPaths = @(
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Java",
    "C:\Program Files\Microsoft"
)

foreach ($path in $searchPaths) {
    if (Test-Path $path) {
        $java17Dirs = Get-ChildItem $path -Directory -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -match "jdk.*17|17\.|temurin.*17"
        }

        foreach ($dir in $java17Dirs) {
            $javaExe = Join-Path $dir.FullName "bin\java.exe"
            if (Test-Path $javaExe) {
                try {
                    $version = & $javaExe -version 2>&1 | Select-Object -First 1
                    if ($version -match "17\.") {
                        $java17Found = $true
                        $java17Path = $dir.FullName
                        Write-Host "✅ Java 17 encontrado: $java17Path" -ForegroundColor Green
                        break
                    }
                } catch { }
            }
        }
        if ($java17Found) { break }
    }
}

# Si no existe, instalarlo
if (-not $java17Found) {
    Write-Host "📥 Instalando Java 17..." -ForegroundColor Cyan
    try {
        winget install Eclipse.Temurin.17.JDK --silent --accept-package-agreements --accept-source-agreements
        Write-Host "✅ Java 17 instalado" -ForegroundColor Green

        # Buscar la nueva instalación
        Start-Sleep 2
        $java17Path = "C:\Program Files\Eclipse Adoptium\jdk-17.0.12.7-hotspot"
        if (-not (Test-Path $java17Path)) {
            # Buscar dinámicamente
            $adoptiumPath = "C:\Program Files\Eclipse Adoptium"
            if (Test-Path $adoptiumPath) {
                $java17Dirs = Get-ChildItem $adoptiumPath -Directory | Where-Object { $_.Name -match "jdk.*17" }
                if ($java17Dirs) {
                    $java17Path = $java17Dirs[0].FullName
                }
            }
        }
    } catch {
        Write-Host "❌ Error instalando Java 17" -ForegroundColor Red
        exit 1
    }
}

# PASO 2: BUSCAR ANDROID SDK EXISTENTE
Write-Host "`n2️⃣ ANDROID SDK SETUP:" -ForegroundColor Yellow

$androidSdkPath = $null
$androidSdkPaths = @(
    "$env:USERPROFILE\Android\Sdk",
    "$env:LOCALAPPDATA\Android\Sdk",
    "C:\Android\sdk",
    "C:\Android\Sdk"
)

foreach ($path in $androidSdkPaths) {
    if (Test-Path $path) {
        Write-Host "✅ Android SDK encontrado: $path" -ForegroundColor Green
        $androidSdkPath = $path
        break
    }
}

# Si no existe SDK, crear ubicación estándar
if (-not $androidSdkPath) {
    $androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"
    New-Item -ItemType Directory -Force -Path $androidSdkPath | Out-Null
    Write-Host "📁 Creado directorio SDK: $androidSdkPath" -ForegroundColor Cyan
}

# PASO 3: CONFIGURAR VARIABLES DE ENTORNO
Write-Host "`n3️⃣ CONFIGURANDO VARIABLES:" -ForegroundColor Yellow

[Environment]::SetEnvironmentVariable("JAVA_HOME", $java17Path, "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSdkPath, "User")
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidSdkPath, "User")

# Para la sesión actual
$env:JAVA_HOME = $java17Path
$env:ANDROID_HOME = $androidSdkPath
$env:ANDROID_SDK_ROOT = $androidSdkPath

Write-Host "✅ Variables configuradas:" -ForegroundColor Green
Write-Host "   JAVA_HOME = $java17Path" -ForegroundColor Gray
Write-Host "   ANDROID_HOME = $androidSdkPath" -ForegroundColor Gray

# PASO 4: DESCARGAR E INSTALAR COMMAND LINE TOOLS
Write-Host "`n4️⃣ ANDROID COMMAND LINE TOOLS:" -ForegroundColor Yellow

$cmdlineToolsPath = "$androidSdkPath\cmdline-tools\latest"
if (-not (Test-Path "$cmdlineToolsPath\bin\sdkmanager.bat")) {
    Write-Host "📥 Descargando Command Line Tools..." -ForegroundColor Cyan

    $tempDir = "$env:TEMP\android-cmdline-tools"
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

    $toolsUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    $toolsZip = "$tempDir\cmdline-tools.zip"

    try {
        Invoke-WebRequest -Uri $toolsUrl -OutFile $toolsZip -UseBasicParsing
        Expand-Archive -Path $toolsZip -DestinationPath "$androidSdkPath\cmdline-tools" -Force

        # Reorganizar estructura
        $extractedPath = "$androidSdkPath\cmdline-tools\cmdline-tools"
        if (Test-Path $extractedPath) {
            Move-Item $extractedPath $cmdlineToolsPath -Force
        }

        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Command Line Tools instalados" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error descargando Command Line Tools" -ForegroundColor Red
        exit 1
    }
}

# PASO 5: INSTALAR COMPONENTES ANDROID
Write-Host "`n5️⃣ INSTALANDO COMPONENTES ANDROID:" -ForegroundColor Yellow

$sdkManager = "$cmdlineToolsPath\bin\sdkmanager.bat"
if (Test-Path $sdkManager) {
    $env:JAVA_OPTS = "-XX:+IgnoreUnrecognizedVMOptions"

    Write-Host "📋 Aceptando licencias..." -ForegroundColor Cyan
    'y' | & $sdkManager --licenses | Out-Null

    $components = @(
        "platform-tools",
        "build-tools;34.0.0",
        "platforms;android-34",
        "ndk;25.1.8937393"
    )

    foreach ($component in $components) {
        Write-Host "📦 Instalando $component..." -ForegroundColor Cyan
        & $sdkManager $component
    }

    Write-Host "✅ Todos los componentes instalados" -ForegroundColor Green
} else {
    Write-Host "❌ SDK Manager no encontrado" -ForegroundColor Red
    exit 1
}

# PASO 6: VERIFICACIÓN FINAL
Write-Host "`n6️⃣ VERIFICACIÓN FINAL:" -ForegroundColor Yellow

$verification = @{
    "Java 17" = (Test-Path "$java17Path\bin\java.exe")
    "Platform Tools" = (Test-Path "$androidSdkPath\platform-tools\adb.exe")
    "Build Tools" = (Test-Path "$androidSdkPath\build-tools")
    "NDK" = (Test-Path "$androidSdkPath\ndk")
    "Android API 34" = (Test-Path "$androidSdkPath\platforms\android-34")
}

$allGood = $true
foreach ($item in $verification.GetEnumerator()) {
    if ($item.Value) {
        Write-Host "   ✅ $($item.Key)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $($item.Key)" -ForegroundColor Red
        $allGood = $false
    }
}

if ($allGood) {
    Write-Host "`n🚀 SETUP COMPLETADO - PROBANDO BUILD:" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Cyan

    # Probar build Android
    .\build-android.ps1 -APKOnly
} else {
    Write-Host "`n❌ SETUP INCOMPLETO - revisar errores arriba" -ForegroundColor Red
}
