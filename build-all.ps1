# 🚀 BUILD ALL PLATFORMS - Bar-Sik
param(
    [switch]$Debug,
    [switch]$SkipWeb,
    [switch]$SkipAndroid,
    [switch]$QuickOnly,
    [int]$CleanKeep = 5
)

Write-Host "� Bar-Sik - Compilación Completa Multiplataforma" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan

$startTime = Get-Date
$results = @{}

Write-Host "`n� CONFIGURACIÓN DE BUILD:" -ForegroundColor Green
Write-Host "Debug Mode: $(if($Debug){'✅ Activado'}else{'❌ Desactivado'})" -ForegroundColor White
Write-Host "Skip Web: $(if($SkipWeb){'✅ Sí'}else{'❌ No'})" -ForegroundColor White
Write-Host "Skip Android: $(if($SkipAndroid){'✅ Sí'}else{'❌ No'})" -ForegroundColor White
Write-Host "Quick Only: $(if($QuickOnly){'✅ Solo rápidos'}else{'❌ Todos'})" -ForegroundColor White

# Función para ejecutar build y capturar resultado
function Invoke-Build {
    param($Script, $Platform, $Description)

    Write-Host "`n� COMPILANDO $Description" -ForegroundColor Cyan
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

[physics]
common/enable_pause_aware_picking=true

[input_devices]
pointing/emulate_touch_from_mouse=true
```

---

## 🖥️ **COMPILACIÓN DESKTOP**

### **Windows (.exe)**

#### **Prerrequisitos:**
```powershell
# Instalar Visual Studio Build Tools (si no tienes Visual Studio)
# Descargar desde: https://visualstudio.microsoft.com/downloads/
```

#### **Configuración en Godot:**
1. **Project → Export**
2. **Add Export Preset → Windows Desktop**
3. **Configurar:**

```ini
[preset.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
dedicated_server=false
custom_template_debug=""
custom_template_release=""
debug/export_console_wrapper=true
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
codesign/enable=false
application/modify_resources=true
application/icon_interpolation=4
application/file_version="0.3.0.0"
application/product_version="0.3.0.0"
application/company_name="Tu Empresa"
application/product_name="Bar-sik"
application/file_description="Simulador de bar y cervecería"
application/copyright="Copyright (c) 2025"
application/trademarks=""
application/export_angle=0
ssh_remote_deploy/enabled=false
```

#### **Comando línea:**
```powershell
# Desde terminal en carpeta del proyecto
& "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe" --headless --export-release "Windows Desktop" "../builds/windows/bar-sik.exe"
```

---

### **Linux**

#### **Configuración:**
```ini
[preset.1]
name="Linux/X11"
platform="Linux/X11"
runnable=true
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
ssh_remote_deploy/enabled=false
```

#### **Comando:**
```bash
godot --headless --export-release "Linux/X11" "../builds/linux/bar-sik"
```

---

### **macOS**

#### **Configuración:**
```ini
[preset.2]
name="macOS"
platform="macOS"
runnable=true
binary_format/architecture="universal"
application/icon_interpolation=4
application/bundle_identifier="com.tuempresa.barsik"
application/signature=""
application/app_category="Games"
application/short_version="0.3.0"
application/version="0.3.0"
application/copyright="Copyright (c) 2025"
display/high_res=true
codesign/enable=false
notarization/enable=false
```

---

## 📱 **COMPILACIÓN MOBILE**

### **Android (.apk / .aab)**

#### **Prerrequisitos:**
1. **Android Studio** + **Android SDK**
2. **Java JDK 17** o superior
3. **Configurar variables de entorno:**

```powershell
# Agregar al PATH:
$env:ANDROID_HOME = "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
```

#### **Configurar Godot:**
1. **Editor → Editor Settings → Export → Android**
2. **Configurar rutas:**
   - Android SDK Path: `C:\Users\[user]\AppData\Local\Android\Sdk`
   - Debug Keystore: Auto-generar
   - Java SDK Path: `C:\Program Files\Java\jdk-17`

#### **Preset Android:**
```ini
[preset.3]
name="Android"
platform="Android"
runnable=true
advanced_options=false
dedicated_server=false
custom_template_debug=""
custom_template_release=""
gradle_build/use_gradle_build=true
gradle_build/export_format=0  # 0=APK, 1=AAB
gradle_build/min_sdk=21
gradle_build/compile_sdk=34
gradle_build/target_sdk=34
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
version/code=1
version/name="0.3.0"
package/unique_name="com.tuempresa.barsik"
package/name="Bar-sik"
package/signed=true
launcher_icons/main_192x192=""
launcher_icons/adaptive_foreground_432x432=""
launcher_icons/adaptive_background_432x432=""
screen/immersive_mode=true
screen/orientation=0
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data_backup/allow=false
command_line/extra_args=""
apk_expansion/enable=false
permissions/custom_permissions=[]
permissions/access_checkin_properties=false
permissions/access_coarse_location=false
permissions/access_fine_location=false
permissions/access_location_extra_commands=false
permissions/access_mock_location=false
permissions/access_network_state=false
permissions/access_surface_flinger=false
permissions/access_wifi_state=false
permissions/account_manager=false
permissions/add_voicemail=false
permissions/authenticate_accounts=false
permissions/battery_stats=false
permissions/bind_accessibility_service=false
permissions/bind_appwidget=false
permissions/bind_device_admin=false
permissions/bind_input_method=false
permissions/bind_nfc_service=false
permissions/bind_notification_listener_service=false
permissions/bind_print_service=false
permissions/bind_remoteviews=false
permissions/bind_text_service=false
permissions/bind_vpn_service=false
permissions/bind_wallpaper=false
permissions/bluetooth=false
permissions/bluetooth_admin=false
permissions/bluetooth_privileged=false
permissions/brick=false
permissions/broadcast_package_removed=false
permissions/broadcast_sms=false
permissions/broadcast_sticky=false
permissions/broadcast_wap_push=false
permissions/call_phone=false
permissions/call_privileged=false
permissions/camera=false
permissions/capture_audio_output=false
permissions/capture_secure_video_output=false
permissions/capture_video_output=false
permissions/change_component_enabled_state=false
permissions/change_configuration=false
permissions/change_network_state=false
permissions/change_wifi_multicast_state=false
permissions/change_wifi_state=false
permissions/clear_app_cache=false
permissions/clear_app_user_data=false
permissions/control_location_updates=false
permissions/delete_cache_files=false
permissions/delete_packages=false
permissions/device_power=false
permissions/diagnostic=false
permissions/disable_keyguard=false
permissions/dump=false
permissions/expand_status_bar=false
permissions/factory_test=false
permissions/flashlight=false
permissions/force_back=false
permissions/get_accounts=false
permissions/get_package_size=false
permissions/get_tasks=false
permissions/get_top_activity_info=false
permissions/global_search=false
permissions/hardware_test=false
permissions/inject_events=false
permissions/install_location_provider=false
permissions/install_packages=false
permissions/install_shortcut=false
permissions/internal_system_window=false
permissions/internet=false
permissions/kill_background_processes=false
permissions/location_hardware=false
permissions/manage_accounts=false
permissions/manage_app_tokens=false
permissions/manage_documents=false
permissions/manage_external_storage=false
permissions/master_clear=false
permissions/media_content_control=false
permissions/modify_audio_settings=false
permissions/modify_phone_state=false
permissions/mount_format_filesystems=false
permissions/mount_unmount_filesystems=false
permissions/nfc=false
permissions/persistent_activity=false
permissions/process_outgoing_calls=false
permissions/read_calendar=false
permissions/read_call_log=false
permissions/read_contacts=false
permissions/read_external_storage=false
permissions/read_frame_buffer=false
permissions/read_history_bookmarks=false
permissions/read_input_state=false
permissions/read_logs=false
permissions/read_phone_state=false
permissions/read_profile=false
permissions/read_sms=false
permissions/read_social_stream=false
permissions/read_sync_settings=false
permissions/read_sync_stats=false
permissions/read_user_dictionary=false
permissions/reboot=false
permissions/receive_boot_completed=false
permissions/receive_mms=false
permissions/receive_sms=false
permissions/receive_wap_push=false
permissions/record_audio=false
permissions/reorder_tasks=false
permissions/restart_packages=false
permissions/send_respond_via_message=false
permissions/send_sms=false
permissions/set_activity_watcher=false
permissions/set_alarm=false
permissions/set_always_finish=false
permissions/set_animation_scale=false
permissions/set_debug_app=false
permissions/set_orientation=false
permissions/set_pointer_speed=false
permissions/set_preferred_applications=false
permissions/set_process_limit=false
permissions/set_time=false
permissions/set_time_zone=false
permissions/set_wallpaper=false
permissions/set_wallpaper_hints=false
permissions/signal_persistent_processes=false
permissions/status_bar=false
permissions/subscribed_feeds_read=false
permissions/subscribed_feeds_write=false
permissions/system_alert_window=false
permissions/transmit_ir=false
permissions/uninstall_shortcut=false
permissions/update_device_stats=false
permissions/use_credentials=false
permissions/use_sip=false
permissions/vibrate=false
permissions/wake_lock=false
permissions/write_apn_settings=false
permissions/write_calendar=false
permissions/write_call_log=false
permissions/write_contacts=false
permissions/write_external_storage=false
permissions/write_gservices=false
permissions/write_history_bookmarks=false
permissions/write_profile=false
permissions/write_secure_settings=false
permissions/write_settings=false
permissions/write_sms=false
permissions/write_social_stream=false
permissions/write_sync_settings=false
permissions/write_user_dictionary=false
```

#### **Comandos:**
```powershell
# APK para testing
godot --headless --export-debug "Android" "../builds/android/bar-sik-debug.apk"

# APK release
godot --headless --export-release "Android" "../builds/android/bar-sik.apk"

# AAB para Google Play
# Cambiar export_format=1 en preset, luego:
godot --headless --export-release "Android" "../builds/android/bar-sik.aab"
```

---

### **iOS (.ipa)**

#### **Prerrequisitos:**
- **macOS con Xcode**
- **Apple Developer Account** ($99/año)
- **Certificados y provisioning profiles**

#### **Configuración:**
```ini
[preset.4]
name="iOS"
platform="iOS"
runnable=true
advanced_options=false
dedicated_server=false
custom_template_debug=""
custom_template_release=""
architectures/arm64=true
application/app_store_team_id=""
application/provisioning_profile_uuid_debug=""
application/code_sign_identity_debug=""
application/export_method_debug=1
application/provisioning_profile_uuid_release=""
application/code_sign_identity_release=""
application/export_method_release=0
application/name="Bar-sik"
application/info="Simulador de bar y cervecería"
application/bundle_identifier="com.tuempresa.barsik"
application/signature=""
application/short_version="0.3.0"
application/version="1"
application/copyright="Copyright (c) 2025"
capabilities/access_wifi=false
capabilities/push_notifications=false
privacy/camera_usage_description=""
privacy/microphone_usage_description=""
privacy/photolibrary_usage_description=""
```

---

## 🌐 **COMPILACIÓN WEB (HTML5)**

### **Configuración:**
```ini
[preset.5]
name="Web"
platform="Web"
runnable=true
advanced_options=false
dedicated_server=false
custom_template_debug=""
custom_template_release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
progressive_web_app/offline_page=""
progressive_web_app/display=1
progressive_web_app/orientation=0
progressive_web_app/icon_144x144=""
progressive_web_app/icon_180x180=""
progressive_web_app/icon_512x512=""
progressive_web_app/background_color=Color(0, 0, 0, 1)
```

### **Comando:**
```powershell
godot --headless --export-release "Web" "../builds/web/index.html"
```

---

## 🚀 **SCRIPT DE COMPILACIÓN AUTOMÁTICA**

<function_calls>
<invoke name="create_file">
<parameter name="content">#!/usr/bin/env pwsh
# Script de compilación automática para todas las plataformas
# Uso: .\build-all.ps1 [version]

param(
    [string]$Version = "0.3.0",
    [switch]$Release = $false,
    [switch]$Windows = $false,
    [switch]$Linux = $false,
    [switch]$Android = $false,
    [switch]$Web = $false,
    [switch]$All = $false
)

$ProjectPath = "e:\GitHub\bar-sik\project"
$GodotPath = "E:\2- Descargas\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"
$BuildsPath = "e:\GitHub\bar-sik\builds"
$ExportMode = if ($Release) { "export-release" } else { "export-debug" }
$BuildType = if ($Release) { "release" } else { "debug" }

Write-Host ""
Write-Host "🚀 BAR-SIK BUILD SYSTEM v$Version" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Crear directorio de builds
if (!(Test-Path $BuildsPath)) {
    New-Item -ItemType Directory -Path $BuildsPath -Force | Out-Null
    Write-Host "📁 Directorio builds creado" -ForegroundColor Green
}

# Función para compilar plataforma
function Build-Platform {
    param(
        [string]$Platform,
        [string]$PresetName,
        [string]$OutputFile,
        [string]$Emoji
    )

    Write-Host "$Emoji Compilando $Platform..." -ForegroundColor Yellow

    $OutputDir = Split-Path $OutputFile -Parent
    if (!(Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }

    $StartTime = Get-Date

    try {
        & $GodotPath --path $ProjectPath --headless --$ExportMode $PresetName $OutputFile

        if ($LASTEXITCODE -eq 0) {
            $Duration = (Get-Date) - $StartTime
            $Size = if (Test-Path $OutputFile) {
                "{0:N1} MB" -f ((Get-Item $OutputFile).Length / 1MB)
            } else { "N/A" }

            Write-Host "✅ $Platform completado" -ForegroundColor Green
            Write-Host "   📁 Archivo: $OutputFile" -ForegroundColor White
            Write-Host "   📊 Tamaño: $Size" -ForegroundColor White
            Write-Host "   ⏱️  Tiempo: $($Duration.TotalSeconds.ToString("F1"))s" -ForegroundColor White
            Write-Host ""
        } else {
            throw "Error en compilación"
        }
    }
    catch {
        Write-Host "❌ Error compilando $Platform" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
    }
}

# Compilar plataformas seleccionadas
Write-Host "🎯 Modo: $BuildType" -ForegroundColor Magenta
Write-Host "📦 Versión: $Version" -ForegroundColor Magenta
Write-Host ""

if ($Windows -or $All) {
    Build-Platform "Windows" "Windows Desktop" "$BuildsPath\windows\bar-sik-$Version-$BuildType.exe" "🖥️"
}

if ($Linux -or $All) {
    Build-Platform "Linux" "Linux/X11" "$BuildsPath\linux\bar-sik-$Version-$BuildType" "🐧"
}

if ($Android -or $All) {
    Build-Platform "Android APK" "Android" "$BuildsPath\android\bar-sik-$Version-$BuildType.apk" "🤖"
}

if ($Web -or $All) {
    Build-Platform "Web" "Web" "$BuildsPath\web\index.html" "🌐"
}

# Resumen final
Write-Host "🎉 COMPILACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

if (Test-Path "$BuildsPath\*") {
    Write-Host ""
    Write-Host "📊 Archivos generados:" -ForegroundColor Cyan
    Get-ChildItem -Path $BuildsPath -Recurse -File | ForEach-Object {
        $Size = "{0:N1} MB" -f ($_.Length / 1MB)
        Write-Host "   📁 $($_.FullName) ($Size)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "🚀 ¡Builds listos para distribución!" -ForegroundColor Green
