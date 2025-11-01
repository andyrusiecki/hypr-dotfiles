#!/bin/bash

wallpaper_dir="$WALLPAPER_DIR"
if [ -z "$wallpaper_dir" ]; then
  echo "WALLPAPER_DIR is not set. Please set it in your environment."
  exit 1
fi

wallpaper_options=""
for wallpaper in $(/usr/bin/ls $wallpaper_dir); do
  wallpaper_options+="$wallpaper\0icon\x1f$(realpath "$wallpaper_dir/$wallpaper")\n"
done

result="$(echo -ne "$wallpaper_options" | rofi -config $DOTFILES_DIR/rofi/config.rasi -dmenu -p "Select Wallpaper" -show-icons)"
wallpaper="$wallpaper_dir/$result"

if [ -z "$result" ]; then
  echo "No Wallpaper selected, exiting."
  exit 1
fi
echo "Selected wallpaper: $wallpaper"

themes_dir=~/.config/wal/colorschemes

custom_option="Generate Color Scheme from Wallpaper"
theme_options="$custom_option\n$(/usr/bin/ls $themes_dir/dark)"

colorscheme="$(echo -ne "${theme_options//.json/}" | rofi -config $DOTFILES_DIR/rofi/config.rasi -dmenu -p "Select Theme" -show-icons)"

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
