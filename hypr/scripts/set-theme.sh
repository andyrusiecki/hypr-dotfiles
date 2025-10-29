#!/bin/bash

themes_dir=$DOTFILES_DIR/themes
avail_themes="$(/usr/bin/ls $themes_dir)"

theme="$1"

list_themes() {
  echo "Available themes:"
  for t in $avail_themes; do
    echo " - $t"
  done
}

if [ -z "$theme" ]; then
  echo "No theme specified."
  list_themes
  exit 1
elif ! echo "$avail_themes" | grep -q "^$theme$"; then
  echo "Theme '$theme' not found."
  list_themes
  exit 1
fi

ln -s -f $themes_dir/$theme ~/.config/hypr/theme

# set wallpaper
#hyprctl hyprpaper reload , ~/.config/hypr/theme/background

# reload/restart programs with new colors
hyprctl reload
dunstctl reload
pkill -SIGUSR1 kitty
pkill -SIGUSR2 waybar
pkill -SIGUSR2 btop

