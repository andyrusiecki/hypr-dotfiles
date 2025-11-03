#!/bin/bash

default_wallpaper="/usr/share/hypr/wall0.png"

root="$(realpath $(dirname $0))"

# packages
echo "Installing packages from $root/packages.txt"
paru -S --needed - < $root/packages.txt

# hyprland configs
if [ -d "$HOME/.config/hypr" ]; then
  echo "Backing up existing Hypr config to $HOME/.config/hypr.bak"
  mv "$HOME/.config/hypr" "$HOME/.config/hypr.bak"
fi

mkdir -p "$HOME/.config/hypr"
echo -e "\$dotfiles = $root\n#\$wallpapers = <Set Wallpaper directory here to use Theme Selector>\n#\$code_dir = <Set Code Directory here to use VS Code Quick Launch>\nsource = \$dotfiles/hypr/hyprland.conf\n\nsource = $HOME/.config/hypr/monitors.conf\n" > $HOME/.config/hypr/hyprland.conf

# add empty monitor config to avoid errors before running hyprdynamicmonitors
touch $HOME/.config/hypr/monitors.conf

# hypridle config (requires a symlink)
ln -s $root/hypr/hypridle.conf $HOME/.config/hypr/hypridle.conf

# hyprsunset config (requires a symlink)
ln -s $root/hypr/hyprsunset.conf $HOME/.config/hypr/hyprsunset.conf

# waybar configs
if [ -d "$HOME/.config/waybar" ]; then
  echo "Backing up existing Waybar config to $HOME/.config/waybar.bak"
  mv "$HOME/.config/waybar" "$HOME/.config/waybar.bak"
fi

mkdir -p "$HOME/.config/waybar"
echo -e "{\n  \"include\": [\n    \"$root/waybar/config.jsonc\"\n  ]\n}" > $HOME/.config/waybar/config.jsonc
echo -e "@import \"$HOME/.cache/wal/colors-waybar.css\";\n@import \"$root/waybar/style.css\";" > $HOME/.config/waybar/style.css

# btop configs
if [ -d "$HOME/.config/btop" ]; then
  echo "Backing up existing Btop config to $HOME/.config/btop.bak"
  mv "$HOME/.config/btop" "$HOME/.config/btop.bak"
fi

mkdir -p "$HOME/.config/btop"
ln -s $root/btop/btop.conf $HOME/.config/btop/btop.conf

# dunst configs
if [ -d "$HOME/.config/dunst" ]; then
  echo "Backing up existing Dunst config to $HOME/.config/dunst.bak"
  mv "$HOME/.config/dunst" "$HOME/.config/dunst.bak"
fi

mkdir -p "$HOME/.config/dunst"
ln -s $root/dunst/dunstrc $HOME/.config/dunst/dunstrc
mkdir -p "$HOME/.config/dunst/dunstrc.d"
ln -s $HOME/.cache/wal/colors-dunst.conf $HOME/.config/dunst/dunstrc.d/theme.conf

# kitty configs
if [ -d "$HOME/.config/kitty" ]; then
  echo "Backing up existing Kitty config to $HOME/.config/kitty.bak"
  mv "$HOME/.config/kitty" "$HOME/.config/kitty.bak"
fi

mkdir -p "$HOME/.config/kitty"
ln -s $root/kitty/kitty.conf $HOME/.config/kitty/kitty.conf

# pywal configs
if [ -d "$HOME/.config/wal" ]; then
  echo "Backing up existing Pywal config to $HOME/.config/wal.bak"
  mv "$HOME/.config/wal" "$HOME/.config/wal.bak"
fi

ln -s $root/wal $HOME/.config/wal

# yazi configs
if [ -d "$HOME/.config/yazi" ]; then
  echo "Backing up existing Yazi config to $HOME/.config/yazi.bak"
  mv "$HOME/.config/yazi" "$HOME/.config/yazi.bak"
fi

mkdir -p "$HOME/.config/yazi"
ln -s $root/yazi/yazi.toml $HOME/.config/yazi/yazi.toml
ln -s $HOME/.config/hypr/theme/yazi-theme.toml $HOME/.config/yazi/theme.yml

# set default wallpaper and color scheme
echo "Setting default wallpaper to $default_wallpaper"
echo "Generating color scheme with pywal"
wal -i $default_wallpaper
