# 📋 CONFIGURACIÓN DE EXPORT PRESETS - Bar-Sik

## 🔧 **project.godot - Sección [Export]**

```ini
[application]
config/name="Bar-sik"
config/version="0.3.0"
run/main_scene="res://scenes/SplashScreen.tscn"

[display]
window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="mobile"
```

## 🎯 **EXPORT PRESETS REQUERIDOS**

### **1. Windows Desktop**
```ini
[export_presets.0]
name="Windows Desktop"
platform="Windows Desktop"
runnable=true
custom_features=""
export_filter="all_resources"
export_files=PackedStringArray()
exclude_filter=""
export_path="builds/windows/bar-sik.exe"
executable_path=""
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/embed_pck=false
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
binary_format/architecture="x86_64"
codesign/enable=false
```

### **2. Linux/X11**
```ini
[export_presets.1]
name="Linux/X11"
platform="Linux/X11"
runnable=true
export_path="builds/linux/bar-sik"
executable_path=""
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/embed_pck=false
binary_format/architecture="x86_64"
custom_template/debug=""
custom_template/release=""
debug/export_console_wrapper=1
```

### **3. Android**
```ini
[export_presets.2]
name="Android"
platform="Android"
runnable=true
export_path="builds/android/bar-sik.apk"
executable_path=""
package/unique_name="com.barsik.game"
package/name="Bar-sik"
package/signed=true
launcher_icons/main_192x192=""
launcher_icons/adaptive_foreground_432x432=""
launcher_icons/adaptive_background_432x432=""
graphics/opengl_debug=false
xr_features/xr_mode=0
screen/immersive_mode=true
screen/support_small=true
screen/support_normal=true
screen/support_large=true
screen/support_xlarge=true
user_data_backup/allow=false
command_line/extra_args=""
version/code=1
version/name="0.3.0"
version/min_sdk=21
version/target_sdk=34
architectures/armeabi-v7a=false
architectures/arm64-v8a=true
architectures/x86=false
architectures/x86_64=false
keystore/debug=""
keystore/debug_user=""
keystore/debug_password=""
keystore/release=""
keystore/release_user=""
keystore/release_password=""
one_click_deploy/clear_previous_install=false
```

### **4. Android AAB (Google Play)**
```ini
[export_presets.3]
name="Android AAB"
platform="Android"
runnable=false
export_path="builds/android/bar-sik.aab"
export_format=1  # AAB format
package/unique_name="com.barsik.game"
package/name="Bar-sik"
# ... resto igual al preset Android normal
```

### **5. Web**
```ini
[export_presets.4]
name="Web"
platform="Web"
runnable=true
export_path="builds/web/index.html"
executable_path=""
variant/extensions_support=false
variant/thread_support=false
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

## 🚀 **COMANDOS DE EXPORTACIÓN**

### **Uso básico:**
```bash
# Windows
godot --headless --export-release "Windows Desktop" "./builds/bar-sik-windows.exe"

# Android APK
godot --headless --export-release "Android" "./builds/bar-sik.apk"

# Web
godot --headless --export-release "Web" "./builds/web/index.html"
```

### **Scripts PowerShell:**
```bash
# Build completo
.\build-quick.ps1 -All -Version "0.3.0"

# Solo Android
.\build-android.ps1 -Both -Version "0.3.0"

# Web con servidor
.\build-web.ps1 -Serve -Open
```
