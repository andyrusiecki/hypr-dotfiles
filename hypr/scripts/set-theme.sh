#!/bin/bash

wallpaper_dir="$WALLPAPER_DIR"
if [ -z "$wallpaper_dir" ]; then
  echo "WALLPAPER_DIR is not set. Please set it in your environment."
  exit 1
fi

source ~/.cache/wal/colors.sh
current_wallpaper=$(basename "$wallpaper")

wallpaper_options=""
selected=-1
count=0

for wallpaper in $(/usr/bin/ls $wallpaper_dir); do
  wallpaper_options+="$wallpaper\0icon\x1f$(realpath "$wallpaper_dir/$wallpaper")\n"

  if [ "$wallpaper" == "$current_wallpaper" ]; then
    selected=$count
  fi
  ((count++))
done

result="$(echo -ne "$wallpaper_options" | rofi -config $DOTFILES_DIR/rofi/wallpaper.rasi -dmenu -p "Select Wallpaper" -show-icons -selected-row $selected)"
wallpaper="$wallpaper_dir/$result"

if [ -z "$result" ]; then
  echo "No Wallpaper selected, exiting."
  exit 1
fi
echo "Selected wallpaper: $wallpaper"

themes_dir=~/.config/wal/colorschemes

custom_option="Generate Color Scheme from Wallpaper"

cat=""
theme_options=""
selected=-1
count=0

while read -r line; do
  if ! [[ "$line" =~ ^- ]]; then
    cat="$(echo "$line" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")"
    continue
  fi

  if [[ "$cat" == *"User Themes:"* || "$cat" == *"Dark Themes:"* ]]; then
    option="${line//- /}"
    if [[ "$option" == *" (last used)" ]]; then
      option="${option// (last used)/}"
      selected=$count
    fi

    theme_options+="$option\n"
    ((count++))
  fi
done < <(wal --theme)

((selected++))

colorscheme="$(echo -ne "$custom_option\n$theme_options" | rofi -config $DOTFILES_DIR/rofi/config.rasi -dmenu -p "Select Theme" -show-icons -selected-row $selected)"

if [ -z "$colorscheme" ]; then
  echo "No Color Scheme selected, exiting."
  exit 1
fi

if [ "$colorscheme" == "$custom_option" ]; then
  echo "Generating color scheme from wallpaper."
  wal -i $wallpaper
else
  echo "Selected theme: $colorscheme"
  wal -i $wallpaper --theme $colorscheme
fi

# reload/restart apps that wal doesn't handle
dunstctl reload
pywalfox update
