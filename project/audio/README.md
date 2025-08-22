# 🎵 Carpeta de Audio - Bar-Sik

Coloca aquí todos los archivos de audio del juego:
- SFX (efectos de sonido): res://audio/sfx/
- Música: res://audio/music/

## Ejemplo de estructura:
- audio/
  - sfx/
    - button_click.wav
    - purchase_success.wav
    - error.wav
    - customer_purchase.wav
    - production_complete.wav
    - prestige_chord.wav
  - music/
    - ambient_brewery.ogg
    - main_theme.ogg

## Recomendaciones
- Formato preferido: .wav para SFX, .ogg para música
- Volúmenes normalizados (-6dB SFX, -12dB música)
- Nombres descriptivos para cada asset

## Integración
- Usa AudioManager.gd para reproducir y gestionar todos los sonidos
- Los assets se cargan automáticamente al iniciar el juego
