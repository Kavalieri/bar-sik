# 🎬 Guía: Creación de Escenas en Godot

## 📋 Escenas a crear en este orden:

### 1. **SplashScreen.tscn**

1. **Scene > New Scene**
2. **Seleccionar `Control` como nodo raíz**
3. **Renombrar** el nodo a `SplashScreen`
4. **Agregar nodos hijos**:
   ```
   SplashScreen (Control)
   ├── Background (ColorRect)
   │   └── Color: #2F2F2F (gris oscuro)
   ├── LogoContainer (CenterContainer)
   │   └── VBoxContainer
   │       ├── LogoLabel (Label)
   │       └── SubtitleLabel (Label)
   ├── LoadingContainer (VBoxContainer)
   │   ├── LoadingLabel (Label)
   │   └── ProgressBar (ProgressBar)
   └── VersionLabel (Label)
   ```

5. **Configurar propiedades**:
   - `SplashScreen`: Anchors -> Full Rect
   - `Background`: Anchors -> Full Rect, Color -> #2F2F2F
   - `LogoContainer`: Anchors -> Center, Size -> 400x200
   - `LogoLabel`: Text -> "🍺 BAR-SIK", Font Size -> 48
   - `SubtitleLabel`: Text -> "Idle Bar Management", Font Size -> 24
   - `LoadingContainer`: Anchors -> Bottom Center
   - `VersionLabel`: Anchors -> Bottom Right

6. **Attach Script**: Seleccionar `SplashScreen` → Attach Script → `res://scripts/SplashScreen.gd`
7. **Guardar**: `Ctrl+S` → `res://scenes/SplashScreen.tscn`

---

### 2. **MainMenu.tscn**

1. **Scene > New Scene**
2. **Control** como raíz → Renombrar a `MainMenu`
3. **Estructura**:
   ```
   MainMenu (Control)
   ├── Background (ColorRect) - Color: #8B4513 (marrón)
   ├── VBoxContainer (centrado)
   │   ├── TitleLabel (Label) - "🍺 BAR-SIK"
   │   ├── StartButton (Button) - "Iniciar Juego"
   │   ├── SettingsButton (Button) - "Configuración"
   │   ├── CreditsButton (Button) - "Créditos"
   │   └── QuitButton (Button) - "Salir"
   └── VersionLabel (Label) - "v0.1.0"
   ```

4. **Attach Script**: `res://scripts/MainMenu.gd`
5. **Guardar**: `res://scenes/MainMenu.tscn`

---

### 3. **GameScene.tscn** (La escena más importante)

1. **Control** como raíz → `GameScene`
2. **Estructura**:
   ```
   GameScene (Control)
   ├── Background (ColorRect) - Color: #1a1a1a
   ├── MainContainer (VBoxContainer) - Anchors: Full Rect
   │   ├── TopPanel (HBoxContainer) - Custom Min Size: 1080x80
   │   │   └── CurrencyContainer (HBoxContainer)
   │   ├── ResourcesPanel (HSplitContainer) - Size Flags: Expand Fill
   │   │   ├── ScrollContainer
   │   │   │   └── ResourceContainer (VBoxContainer)
   │   │   └── BeveragePanel (VBoxContainer)
   │   │       └── ScrollContainer
   │   │           └── BeverageContainer (VBoxContainer)
   │   └── StatsPanel (Panel) - Custom Min Size: 1080x150
   │       └── ScrollContainer
   │           └── StatsContainer (VBoxContainer)
   ```

3. **Attach Script**: `res://scripts/GameScene.gd`
4. **Guardar**: `res://scenes/GameScene.tscn`

---

### 4. **PauseMenu.tscn**

1. **Control** como raíz → `PauseMenu`
2. **Estructura**:
   ```
   PauseMenu (Control)
   ├── BackgroundBlur (ColorRect) - Color: #000000, Alpha: 0.7
   └── CenterContainer
       └── VBoxContainer
           ├── PauseLabel (Label) - "Juego Pausado"
           ├── ResumeButton (Button) - "Continuar"
           ├── SettingsButton (Button) - "Configuración"
           └── MainMenuButton (Button) - "Menú Principal"
   ```

3. **Attach Script**: `res://scripts/PauseMenu.gd`
4. **Guardar**: `res://scenes/PauseMenu.tscn`

---

### 5. **SettingsMenu.tscn** (Básico por ahora)

1. **Control** → `SettingsMenu`
2. **Estructura simple**:
   ```
   SettingsMenu (Control)
   ├── Background (ColorRect)
   ├── VBoxContainer
   │   ├── TitleLabel (Label) - "Configuración"
   │   ├── LanguageOption (OptionButton)
   │   ├── VolumeSlider (HSlider)
   │   └── BackButton (Button) - "Atrás"
   ```

3. **Crear script básico** o usar uno temporal
4. **Guardar**: `res://scenes/SettingsMenu.tscn`

---

### 6. **Credits.tscn** (Básico)

1. **Control** → `Credits`
2. **Estructura**:
   ```
   Credits (Control)
   ├── Background (ColorRect)
   ├── ScrollContainer
   │   └── VBoxContainer
   │       ├── TitleLabel (Label) - "Créditos"
   │       ├── CreditsText (RichTextLabel) - "Desarrollo: Tu Nombre"
   │       └── BackButton (Button) - "Atrás"
   ```

3. **Guardar**: `res://scenes/Credits.tscn`

---

## ⚙️ **Configuración del Proyecto tras crear las escenas:**

### 1. **Establecer Main Scene**
- `Project > Project Settings > Application > Run`
- **Main Scene**: `res://scenes/SplashScreen.tscn`

### 2. **Configurar Input Map**
- `Project > Project Settings > Input Map`
- **Añadir acciones**:
  ```
  game_action: Mouse Left Button, Touch Screen
  game_pause: Escape, P
  ```

### 3. **Configurar Localization**
- `Project > Project Settings > Localization > Translations`
- **Add**: `res://res/locales/ui_strings.csv`
- **Locale Filter**: Show Selected Only
- **Selected**: es, en, fr, de, pt

### 4. **Test Build**
- **Presionar F5**
- **Seleccionar** `res://scenes/SplashScreen.tscn` como Main Scene
- **Verificar** que aparezcan los mensajes de autoloads en la consola

---

## 🎯 **Orden de testing:**

1. **Splash Screen** → debe mostrar logo y transicionar al menú
2. **Main Menu** → botones deben funcionar (aunque lleven a escenas vacías)
3. **Game Scene** → debe mostrar interfaz básica sin errores
4. **Pause Menu** → debe permitir pausar/reanudar

---

## ⚠️ **Notas importantes:**

- **Usa nombres exactos** de nodos como están en los scripts
- **Anchors importantes**: Full Rect para backgrounds, Center para menús
- **Custom minimum sizes** para mantener proporciones en portrait
- **Tamaño de botones**: mínimo 200x60 para mobile
- **Font sizes**: título 48px, subtítulo 24px, botones 16px

**¡Una vez creadas todas las escenas, tendremos un loop básico jugable!** 🍺
