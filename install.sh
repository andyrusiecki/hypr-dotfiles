#!/bin/bash

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

# hypridle config (requires a symlink)
ln -s $root/hypr/hypridle.conf $HOME/.config/hypr/hypridle.conf

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
echo -e "@import \"~/.config/hypr/theme/waybar-colors.css\";\n@import \"$root/waybar/style.css\";" > $HOME/.config/waybar/style.css

# btop configs
if [ -d "$HOME/.config/btop" ]; then
  echo "Backing up existing Btop config to ~/.config/btop.bak"
  mv "$HOME/.config/btop" "$HOME/.config/btop.bak"
fi

mkdir -p "$HOME/.config/btop"
ln -s $root/btop/btop.conf $HOME/.config/btop/btop.conf

# dunst configs
if [ -d "$HOME/.config/dunst" ]; then
  echo "Backing up existing Dunst config to ~/.config/dunst.bak"
  mv "$HOME/.config/dunst" "$HOME/.config/dunst.bak"
fi

mkdir -p "$HOME/.config/dunst"
ln -s $root/dunst/dunstrc $HOME/.config/dunst/dunstrc
mkdir -p "$HOME/.config/dunst/dunstrc.d"
ln -s $HOME/.config/hypr/theme/dunst-theme.conf $HOME/.config/dunst/dunstrc.d/theme.conf

# kitty configs
if [ -d "$HOME/.config/kitty" ]; then
  echo "Backing up existing Kitty config to ~/.config/kitty.bak"
  mv "$HOME/.config/kitty" "$HOME/.config/kitty.bak"
fi

mkdir -p "$HOME/.config/kitty"
ln -s $root/kitty/kitty.conf $HOME/.config/kitty/kitty.conf

# yazi configs
if [ -d "$HOME/.config/yazi" ]; then
  echo "Backing up existing Yazi config to ~/.config/yazi.bak"
  mv "$HOME/.config/yazi" "$HOME/.config/yazi.bak"
fi

mkdir -p "$HOME/.config/yazi"
ln -s $root/yazi/yazi.toml $HOME/.config/yazi/yazi.toml
ln -s $HOME/.config/hypr/theme/yazi-theme.toml $HOME/.config/yazi/theme.yml
