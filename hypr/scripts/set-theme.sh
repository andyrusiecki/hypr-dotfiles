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

custom_option="custom-dark\0display\x1fGenerate Color Scheme from Wallpaper (Dark)\n"
custom_option="${custom_option}custom-light\0display\x1fGenerate Color Scheme from Wallpaper (Light)\n"

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
    selected=$count+1
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

if [[ "$colorscheme" == "custom-dark" ]]; then
  echo "Generating dark color scheme from wallpaper."
  $wallust_prefix run --palette dark16 "$wallpaper_path"
elif [[ "$colorscheme" == "custom-light" ]]; then
  echo "Generating light color scheme from wallpaper."
  $wallust_prefix run --palette light16 --saturation 80 "$wallpaper_path"
else
  echo "Selected theme: $colorscheme"
  $wallust_prefix theme $colorscheme
fi

# reload/restart apps for new theme

# kitty
#pkill -SIGUSR1 kitty

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
