#!/bin/bash

wallpaper_dir="$WALLPAPER_DIR"
wallpaper_config="$HOME/.config/hypr/wallpaper.conf"

if [ -z "$wallpaper_dir" ]; then
  echo "WALLPAPER_DIR is not set. Please set it in your environment."
  exit 1
fi

wallpaper_dir="$(realpath "$wallpaper_dir")"
current_wallpaper=""
if [[ -f "$wallpaper_config" ]]; then
  current_wallpaper="$(cat "$wallpaper_config" | sed 's/\$wallpaper = //')"
fi

wallpaper_options=""
selected=-1
count=0

for wallpaper in $(/usr/bin/ls $wallpaper_dir); do
  full_path="$wallpaper_dir/$wallpaper"
  wallpaper_options+="$wallpaper\0icon\x1f$full_path\n"

  if [ "$full_path" == "$current_wallpaper" ]; then
    selected=$count
  fi
  ((count++))
done

wallpaper="$(echo -ne "$wallpaper_options" | rofi -config $DOTFILES_DIR/rofi/wallpaper.rasi -dmenu -p "Select Wallpaper" -show-icons -selected-row $selected)"

if [ -z "$wallpaper" ]; then
  echo "No Wallpaper selected, exiting."
  exit 1
fi

echo "Current wallpaper: $current_wallpaper"
echo "Selected wallpaper: $wallpaper"

current_theme="$(jq -r '.theme' ~/.cache/wallust/colors.json)"

theme_options=""
selected=-1
count=0

custom_option="wallust-dark\0display\x1fWallust Color Scheme (Dark)\n"
custom_option="${custom_option}wallust-light\0display\x1fWallust Color Scheme (Light)\n"
custom_option="${custom_option}matugen-dark\0display\x1fMatugen Color Scheme (Dark)\n"
custom_option="${custom_option}matugen-light\0display\x1fMatugen Color Scheme (Light)\n"

while read -r line; do
  # ignore header
  if [[ "$line" == *"Available themes:"* ]]; then
    continue
  fi

  # break once we're done with the themes list
  if [[ "$line" == *"Extra:"* ]]; then
    break
  fi

  # unknown line
  if ! [[ "$line" =~ ^- ]]; then
    continue
  fi

  option="${line//- /}"
  display="$option"

  if [[ "$option" == "$current_theme" ]]; then
    display="$display (current theme)"
    selected=$count+3
  fi

  theme_options+="$option\0display\x1f$display\n"
  ((count++))
done < <(wallust theme list)

((selected++))

colorscheme="$(echo -ne "${custom_option}${theme_options}" | rofi -config $DOTFILES_DIR/rofi/config.rasi -dmenu -p "Select Theme" -show-icons -selected-row $selected)"

if [ -z "$colorscheme" ]; then
  echo "No Color Scheme selected, exiting."
  exit 1
fi

if [[ "$wallpaper" != "$current_wallpaper" ]]; then
  echo "Setting wallpaper to $wallpaper_path"
  wallpaper_path="$wallpaper_dir/$wallpaper"

  hyprctl hyprpaper wallpaper ", $wallpaper_path, fill"
  echo "\$wallpaper = $wallpaper_path" > ~/.config/hypr/wallpaper.conf
fi

wallust_prefix="wallust -d $DOTFILES_DIR/wallust"
matugen_prefix="matugen -c $DOTFILES_DIR/matugen/config.toml"

function post_wallust() {
  # kitty
  pkill -SIGUSR1 kitty

  # chrome
  $DOTFILES_DIR/hypr/scripts/set-theme-chrome.sh

  # dunst
  if pgrep dunst >/dev/null; then
    dunstctl reload
  fi

  # swaync
  if pgrep swaync >/dev/null; then
    swaync-client -rs
  fi

  # firefox
  pywalfox update

  # obsidian
  $DOTFILES_DIR/wallust/scripts/set-theme-obsidian.sh
}

function set_dark_mode() {
  echo "Setting dark mode."
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
}

function set_light_mode() {
  echo "Setting light mode."
  gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
}

# Relative luminance of sRGB hex (WCAG): #RRGGBB or RRGGBB → prints 0.0–1.0 to stdout.
function luminance() {
  local h="${1#\#}"
  if [[ ! "$h" =~ ^[0-9a-fA-F]{6}$ ]]; then
    return 0
  fi
  local r=$((0x${h:0:2})) g=$((0x${h:2:2})) b=$((0x${h:4:2}))
  awk -v r="$r" -v g="$g" -v b="$b" '
    function lin(c) {
      v = c / 255
      return (v <= 0.04045) ? (v / 12.92) : ((v + 0.055) / 1.055) ^ 2.4
    }
    BEGIN {
      printf "%f\n", 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
    }
  '
}

function is_wallust_dark_mode() {
  local foreground="$(jq -r '.special.foreground' ~/.cache/wallust/colors.json)"
  local background="$(jq -r '.special.background' ~/.cache/wallust/colors.json)"
  local luminance_foreground="$(luminance "$foreground")"
  local luminance_background="$(luminance "$background")"

  if [ "$(echo "$luminance_foreground < $luminance_background" | bc -l)" -eq 1 ]; then
    return 1
  else
    return 0
  fi
}

case "$colorscheme" in
  "wallust-dark")
    echo "Generating dark color scheme from wallpaper."
    $wallust_prefix run --palette harddark16 "$wallpaper_path"
    set_dark_mode
    post_wallust
    ;;
  "wallust-light")
    echo "Generating light color scheme from wallpaper."
    $wallust_prefix run --palette light16 --saturation 80 "$wallpaper_path"
    set_light_mode
    post_wallust
    ;;
  "matugen-dark")
    echo "Generating dark color scheme from wallpaper."
    $matugen_prefix --mode dark image "$wallpaper_path"
    ;;
  "matugen-light")
    echo "Generating light color scheme from wallpaper."
    $matugen_prefix --mode light image "$wallpaper_path"
    ;;
  *)
    echo "Selected theme: $colorscheme"
    $wallust_prefix theme $colorscheme

    if is_wallust_dark_mode; then
      set_dark_mode
    else
      set_light_mode
    fi

    post_wallust
    ;;
esac

