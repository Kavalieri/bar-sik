extends Node
## Sistema de internacionalización (idiomas)
## Maneja la localización del juego para múltiples idiomas

# Idiomas soportados (expandir según necesidades)
const SUPPORTED_LANGUAGES = {
    "es": "Español",
    "en": "English",
    "fr": "Français",
    "de": "Deutsch",
    "pt": "Português"
}

# Idioma actual
var current_language: String = "es"

func _ready() -> void:
    print("🌍 Locale inicializado")

    # Detectar idioma del sistema
    var system_language = OS.get_locale_language()
    print("📱 Idioma del sistema: ", system_language)

    # Usar idioma del sistema si está soportado, sino español por defecto
    if SUPPORTED_LANGUAGES.has(system_language):
        current_language = system_language
    else:
        current_language = "es"  # Español por defecto

    # Aplicar el idioma
    set_language(current_language)

## Cambiar idioma del juego
func set_language(language_code: String) -> void:
    if not SUPPORTED_LANGUAGES.has(language_code):
        push_warning("⚠️ Idioma no soportado: " + language_code)
        return

    current_language = language_code
    TranslationServer.set_locale(language_code)

    print("🔄 Idioma cambiado a: ", SUPPORTED_LANGUAGES[language_code])

    # Emitir señal para que las escenas se actualicen
    language_changed.emit(language_code)

## Obtener idioma actual
func get_current_language() -> String:
    return current_language

## Obtener nombre del idioma actual
func get_current_language_name() -> String:
    return SUPPORTED_LANGUAGES.get(current_language, "Unknown")

## Obtener lista de idiomas soportados
func get_supported_languages() -> Dictionary:
    return SUPPORTED_LANGUAGES

## Verificar si un idioma está soportado
func is_language_supported(language_code: String) -> bool:
    return SUPPORTED_LANGUAGES.has(language_code)

## Traducir un texto usando la clave
func translate(key: String) -> String:
    return tr(key)

## Traducir texto con parámetros (ej: "Hello {player}")
func translate_with_params(key: String, params: Dictionary) -> String:
    var text = tr(key)
    for param_key in params:
        text = text.replace("{" + param_key + "}", str(params[param_key]))
    return text

# Señal que se emite cuando cambia el idioma
signal language_changed(new_language: String)

## Ejemplo de uso:
## Locale.translate("ui_start_game")  # devuelve "Iniciar Juego" en español
## Locale.translate_with_params("ui_score", {"score": 1500})  # "Puntuación: 1500"
