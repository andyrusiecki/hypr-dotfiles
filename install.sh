#!/bin/bash

default_wallpaper="/usr/share/hypr/wall0.png"

root="$(realpath $(dirname $0))"
dotfile_marker_file=".dotfiles_installed"

function is_dotfiles_installed() {
  if [ -f "$1/$dotfile_marker_file" ]; then
    return 0
  else
    return 1
  fi
}

function create_dotfile_dir() {
  if ! [ -d "$1" ]; then
    echo "Creating directory at $1"
    mkdir -p "$1"
    touch "$1/$dotfile_marker_file"
  fi
}

function set_symlink() {
  if ! [ -e "$2" ]; then
    ln -s "$1" "$2"
    exit 0
  fi

  if ! [ -L "$2" ]; then
    rm "$2"
    ln -s "$1" "$2"
    exit 0
  fi

  target=$(readlink "$2")
  if [ "$target" != "$1" ]; then
    rm "$2"
    ln -s "$1" "$2"
  fi
}

# packages
echo "Installing packages from $root/packages.txt"
paru -S --needed $(<$root/packages.txt)

# hyprland configs
if is_dotfiles_installed "$HOME/.config/hypr"; then
  echo "Updating Hyprland hyprland.conf file may require manual intervention."

  if ! [ -f "$HOME/.config/hypr/monitors.conf" ]; then
    touch $HOME/.config/hypr/monitors.conf
  fi

  set_symlink $root/hypr/hypridle.conf $HOME/.config/hypr/hypridle.conf
else
  echo "Installing Hyprland config files..."

  if [ -d "$HOME/.config/hypr" ]; then
    echo "Backing up existing Hypr config to $HOME/.config/hypr.bak"
    mv "$HOME/.config/hypr" "$HOME/.config/hypr.bak"
  fi

  create_dotfile_dir "$HOME/.config/hypr"
  echo -e "\$dotfiles = $root\n#\$wallpapers = <Set Wallpaper directory here to use Theme Selector>\n#\$code_dir = <Set Code Directory here to use VS Code Quick Launch>\n#\$scripts_dir = <Set Script directory here to use Custom Script Runner>\nsource = \$dotfiles/hypr/hyprland.conf\n\nsource = $HOME/.config/hypr/monitors.conf\n" > $HOME/.config/hypr/hyprland.conf

  # add empty monitor config to avoid errors before running hyprdynamicmonitors
  touch $HOME/.config/hypr/monitors.conf

  # hypridle config (requires a symlink)
  ln -s $root/hypr/hypridle.conf $HOME/.config/hypr/hypridle.conf
fi

# waybar configs
if is_dotfiles_installed "$HOME/.config/waybar"; then
  echo "Updating Waybar config.jsonc and style.css files may require manual intervention."
else
  echo "Installing Waybar config files..."

  if [ -d "$HOME/.config/waybar" ]; then
    echo "Backing up existing Waybar config to $HOME/.config/waybar.bak"
    mv "$HOME/.config/waybar" "$HOME/.config/waybar.bak"
  fi

  create_dotfile_dir "$HOME/.config/waybar"
  echo -e "{\n  \"include\": [\n    \"$root/waybar/config.jsonc\"\n  ]\n}" > $HOME/.config/waybar/config.jsonc
  echo -e "@import \"$HOME/.cache/wal/colors-waybar.css\";\n@import \"$root/waybar/style.css\";" > $HOME/.config/waybar/style.css
fi

# swaync configs
if is_dotfiles_installed "$HOME/.config/swaync"; then
  set_symlink $root/swaync/config.json $HOME/.config/swaync/config.json
  echo -e "@import \"$HOME/.cache/wal/colors-waybar.css\";\n@import \"$root/swaync/style.css\";" > $HOME/.config/swaync/style.css
else
  echo "Installing Swaync config files..."

  if [ -d "$HOME/.config/swaync" ]; then
    echo "Backing up existing Swaync config to $HOME/.config/swaync.bak"
    mv "$HOME/.config/swaync" "$HOME/.config/swaync.bak"
  fi

  create_dotfile_dir "$HOME/.config/swaync"
  ln -s $root/swaync/config.json $HOME/.config/swaync/config.json
  echo -e "@import \"$HOME/.cache/wal/colors-waybar.css\";\n@import \"$root/swaync/style.css\";" > $HOME/.config/swaync/style.css
fi

# kitty configs
if is_dotfiles_installed "$HOME/.config/kitty"; then
  set_symlink $root/kitty/kitty.conf $HOME/.config/kitty/kitty.conf
else
  echo "Installing Kitty config files..."

  if [ -d "$HOME/.config/kitty" ]; then
    echo "Backing up existing Kitty config to $HOME/.config/kitty.bak"
    mv "$HOME/.config/kitty" "$HOME/.config/kitty.bak"
  fi

  create_dotfile_dir "$HOME/.config/kitty"
  ln -s $root/kitty/kitty.conf $HOME/.config/kitty/kitty.conf
fi


# pywal configs
if is_dotfiles_installed "$HOME/.config/wal"; then
  set_symlink $root/wal/colorschemes $HOME/.config/wal/colorschemes
  set_symlink $root/wal/templates $HOME/.config/wal/templates
else
  echo "Installing Pywal config files..."

  if [ -d "$HOME/.config/wal" ]; then
    echo "Backing up existing Pywal config to $HOME/.config/wal.bak"
    mv "$HOME/.config/wal" "$HOME/.config/wal.bak"
  fi

  create_dotfile_dir "$HOME/.config/wal"
  ln -s $root/wal/colorschemes $HOME/.config/wal/colorschemes
  ln -s $root/wal/templates $HOME/.config/wal/templates
fi

# python venv for pywal16 and pywalfox
if ! [ -d "$root/python" ]; then
  echo "Creating python venv and installing pywal16 and pywalfox..."
  $root/scripts/install-python-deps.sh
fi

# set default wallpaper and color scheme if none exist
if ! [ -f "$HOME/.cache/wal/wal" ]; then
  echo "Setting default wallpaper to $default_wallpaper"
  echo "Generating color scheme with pywal"
  $root/python/bin/wal -stne -i $default_wallpaper
fi
