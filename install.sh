#!/bin/bash

#TODO:
# - rofi power menu
# - rofi theme switcher
#   - with wallpaper switcher?
# - rofi code launcher
# - add second theme
default_theme="matugen"

root="$(realpath $(dirname $0))"

# packages
echo "Installing packages from $root/packages.txt"
paru -S --needed - < $root/packages.txt

# hyprland configs
if [ -d "$HOME/.config/hypr" ]; then
  echo "Backing up existing Hypr config to ~/.config/hypr.bak"
  mv "$HOME/.config/hypr" "$HOME/.config/hypr.bak"
fi

mkdir -p "$HOME/.config/hypr"
echo -e "\$dotfiles = $root\nsource = \$dotfiles/hypr/hyprland.conf" > $HOME/.config/hypr/hyprland.conf

# hyprsunset config (requires a symlink)
ln -s $root/hypr/hyprsunset.conf $HOME/.config/hypr/hyprsunset.conf

# set default theme
ln -s $root/themes/$default_theme $HOME/.config/hypr/theme

# waybar configs
if [ -d "$HOME/.config/waybar" ]; then
  echo "Backing up existing Waybar config to ~/.config/waybar.bak"
  mv "$HOME/.config/waybar" "$HOME/.config/waybar.bak"
fi

mkdir -p "$HOME/.config/waybar"
echo -e "{\n  \"include\": [\n    \"$root/waybar/config.jsonc\"\n  ]\n}" > $HOME/.config/waybar/config.jsonc
echo -e "@import "~/.config/hypr/theme/waybar-colors.css";\n@import \"$root/waybar/style.css\";" > $HOME/.config/waybar/style.css

# btop configs
if [ -d "$HOME/.config/btop" ]; then
  echo "Backing up existing Btop config to ~/.config/btop.bak"
  mv "$HOME/.config/btop" "$HOME/.config/btop.bak"
fi

mkdir -p "$HOME/.config/btop"
ln -s $root/btop/btop.conf $HOME/.config/btop/btop.conf

# kitty configs
if [ -d "$HOME/.config/kitty" ]; then
  echo "Backing up existing Kitty config to ~/.config/kitty.bak"
  mv "$HOME/.config/kitty" "$HOME/.config/kitty.bak"
fi

mkdir -p "$HOME/.config/kitty"
ln -s $root/kitty/kitty.conf $HOME/.config/kitty/kitty.conf

# mako configs
if [ -d "$HOME/.config/mako" ]; then
  echo "Backing up existing Mako config to ~/.config/mako.bak"
  mv "$HOME/.config/mako" "$HOME/.config/mako.bak"
fi

mkdir -p "$HOME/.config/mako"
echo "include=$root/mako/config" > $HOME/.config/mako/config

# yazi configs
if [ -d "$HOME/.config/yazi" ]; then
  echo "Backing up existing Yazi config to ~/.config/yazi.bak"
  mv "$HOME/.config/yazi" "$HOME/.config/yazi.bak"
fi

mkdir -p "$HOME/.config/yazi"
ln -s $root/yazi/yazi.toml $HOME/.config/yazi/yazi.toml
ln -s ~/.config/hypr/theme/yazi-theme.toml $HOME/.config/yazi/theme.yml
