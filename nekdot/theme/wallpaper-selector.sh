#!/bin/bash

# 1. Caminhos
WALLPAPER_DIR="$HOME/.config/nekdot/wallpapers"
MATUGEN_CONFIG="$HOME/.config/nekdot/theme/matugen/config.toml"

# 2. Garantir que o swww-daemon está rodando
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 0.5
fi

# 3. Detectar monitor atual
MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused==true).name')

# 4. Gerar a lista para o Rofi
choices=""
while IFS= read -r file; do
    filename=$(basename "$file")
    choices+="$filename\x00icon\x1f$file\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" \))

# 5. Chamar o Rofi
selected=$(echo -e "$choices" | rofi -config ~/.config/nekdot/theme/rofi/wallsel.rasi \
    -dmenu -i -p "Selecionar Wallpaper" \
    -show-icons -theme-str 'element-icon { size: 120px; } listview { columns: 3; }')

# 6. Aplicar com SWWW e Matugen
if [ -n "$selected" ]; then
    FULL_PATH="$WALLPAPER_DIR/$selected"
    
    # Aplica o Wallpaper
    swww img "$FULL_PATH" \
        --outputs "$MONITOR" \
        --transition-type grow \
        --transition-pos center \
        --transition-step 90 \
        --transition-fps 60

    # 7. Executar o Matugen com config personalizada
    # -c aponta para o seu arquivo de configuração específico
    matugen -c "$MATUGEN_CONFIG" image "$FULL_PATH"
    
    # Notificação opcional
    notify-send "Wallpaper Alterado" "Cores extraídas de: $selected" -i "$FULL_PATH"
fi