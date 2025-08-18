# 📖 Blueprint profesional multiplataforma — Proyecto Godot 4.x

Este documento define la **base técnica y organizativa** de un proyecto en **Godot 4.x** orientado a **Windows + Android**, con soporte futuro para **iOS**.
Debe servir como **prompt inicial** para un agente IA de desarrollo en Visual Studio Code u otro IDE, asegurando buenas prácticas, consistencia y calidad profesional.

---

## 🎯 Principios

- **Multiplataforma real**: un único proyecto exportable a Windows, Android y, más adelante, iOS.
- **Convenciones de comunidad**: estilo de código, estructura y configuración alineados con estándares Godot/GDScript.
- **Reproducible y mantenible**: exportación estable, CI/CD, secretos fuera del repositorio.
- **Evolutivo**: se amplía solo cuando el género/funcionalidad lo exige (ej. pooling, monetización).

---

## 🛠️ Requisitos técnicos

**Godot**
- Editor + Export Templates: **Godot 4.4.x**

**Windows**
- Exportación directa a `.exe` con plantillas oficiales.

**Android**
- **JDK 17** (Temurin recomendado).
- **Android SDK**: API 34 + Build-Tools 34.0.0.
- **NDK**: r25c (25.1.8937393).
- Variables: `JAVA_HOME`, `ANDROID_HOME`, PATH con `platform-tools`, `cmdline-tools/latest/bin`, `build-tools/34.0.0`.

**iOS (futuro)**
- macOS con Xcode, certificados y perfiles correctos.

---

## 📂 Estructura de repositorio

```
yourgame/
  .github/workflows/      # CI/CD (Android, Windows)
  docs/                   # documentación técnica, GDD, políticas
  tools/                  # scripts build/validación
  project/                # raíz del proyecto Godot
    addons/               # plugins verificados
    assets_src/           # originales (psd, wav, svg) – no en build
    res/                  # recursos empaquetados
      gfx/
      sfx/
      fonts/
      locales/
    scenes/
    scripts/
      core/               # utilidades, helpers
      platform/           # integraciones específicas
      gameplay/           # lógicas de juego (cuando existan)
    ui/
    data/                 # datos estáticos
    singletons/           # Autoloads esenciales
    tests/
    export/               # iconos, presets, signing
  build/                  # artefactos (.exe, .aab) (gitignored)
  .editorconfig
  .gitattributes
  .gitignore
  README.md
  LICENSE
```

**Reglas**
- `assets_src/` nunca se empaqueta.
- Secretos (keystore Android, contraseñas) **fuera del repo**.

---

## ⚙️ Configuración de proyecto

**Display / Window**
- Resolución base: 1080×1920 (portrait) o 1920×1080 (landscape).
- Stretch: `canvas_items`, aspect: `keep_width`/`keep_height`.
- HiDPI ON.

**Rendering**
- Renderer: `Forward Mobile`.
- Texturas: ETC2 (Android), BCn (Windows).
- Half precision: ON si no afecta calidad.

**Application**
- Nombre, descripción e icono 512×512 definidos.
- Main Scene configurada.

**Input Map**
- Define acciones genéricas (`ui_accept`, `ui_cancel`, …).
- Añade alias táctiles; evita mouse emulation en Android.

**Android export**
- `min_sdk = 23`, `target_sdk = 34`.
- Orientación fija.
- Paquete único `com.company.yourgame`.

**Logs & depuración**
- Usa `print()`, `printerr()`, `push_warning()`, `push_error()`.
- En release: sin logs verbosos (`if OS.is_debug_build()`).

**Paths**
- Lectura: `res://`
- Escritura: `user://`

---

## 🔌 Autoloads esenciales

Registrar en **Project > Project Settings > AutoLoad**:

**AppConfig.gd**
```gdscript
extends Node
var is_debug := OS.is_debug_build()
var build_label := ProjectSettings.get_setting("application/config/version", "0.1.0")
```

**Router.gd**
```gdscript
extends Node
var _current: Node = null

func goto(scene_path: String) -> void:
    var root := get_tree().root
    var next := load(scene_path).instantiate()
    if _current: _current.queue_free()
    root.add_child(next)
    _current = next
```

**Locale.gd**
```gdscript
extends Node
func _ready() -> void:
    var lang := OS.get_locale_language()
    TranslationServer.set_locale(lang)
```

---

## 🖼️ UI y recursos

- UI con **Containers** y anchors (no posiciones absolutas).
- Fuentes: DynamicFont, tamaños relativos.
- Safe areas: `DisplayServer.screen_get_usable_rect()`.
- Texturas: potencias de 2 si es posible, atlas para sprites repetidos.
- Audio: música OGG, efectos WAV/OGG mono.
- Shaders: simples.

---

## 📦 Export presets

### Android
- Tipo: **AAB**.
- Architectures: `arm64-v8a` (añadir `armeabi-v7a` solo si necesario).
- Versioning:
  - `version_code` entero autoincremental.
  - `version_name` semver (`1.0.0`).

### Windows
- Exportar a `.exe`.
- Icono `.ico`.
- Empaquetar `.zip` con licencia y README.

### iOS (cuando toque)
- Bundle ID, team ID, signing en Mac.
- Iconos/splash según guías Apple.

---

## 🤖 CI/CD (GitHub Actions)

- Exportar **Windows** y **Android** en cada tag `v*`.
- Artefactos listos (`.exe`, `.aab`).
- Secretos en `secrets`: `ANDROID_HOME`, `ANDROID_NDK_HOME`, `ANDROID_STOREPASS`, `ANDROID_KEYPASS`.

Ejemplo (resumen):
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix: { target: [windows, android] }
    steps:
      - uses: actions/checkout@v4
      - name: Export
        run: godot-headless --headless --path project              --export-release "${{ matrix.target }}" build/out
```

---

## 🧹 Calidad y convenciones

**.editorconfig**
```
[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
```

**.gitattributes**
```
* text=auto eol=lf
*.png binary
*.ogg binary
*.wav binary
```

- Estilo GDScript: snake_case, PascalCase en clases, señales en `signal_name`.
- Formateo opcional con `gdformat`.

---

## ✅ Checklist de publicación

**Windows**
- `.exe` empaquetado `.zip`.
- Sin dependencias externas.

**Android**
- `.aab` firmado.
- `targetSdk=34`.
- Permisos mínimos.
- Política de privacidad si hay ads/analytics.

**iOS (futuro)**
- Firmado con certificados válidos.
- ATT si hay tracking.
- Pruebas en TestFlight.

---

## 🚫 Errores típicos a evitar

- Usar JDK 11 → incompatibilidad con targetSdk 34.
- Exportar con renderer **Forward+** en móvil → FPS bajos.
- Guardar en `res://` en runtime → falla en Android/iOS.
- Incluir permisos que no se usan → rechazo en tienda.
- Plugins abandonados → builds frágiles.

---

## 📌 Roadmap inicial

1. Inicializar repo con estructura + configs.
2. Definir Project Settings (Display, Rendering, Application, Input).
3. Añadir autoloads básicos (`AppConfig`, `Router`, `Locale`).
4. Configurar export_presets para Windows/Android.
5. Crear workflow de CI/CD.
6. Probar Hello Scene en Windows + Android real.
7. Iterar sobre gameplay.

---
