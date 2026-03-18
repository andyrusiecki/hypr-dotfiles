#!/bin/bash

set -e

usage() {
  echo "Usage: $0 <name>"
  exit 1
}

[[ $# -eq 1 && -n "$1" ]] || usage
app_name="$1"

app_dir="$HOME/.local/share/applications"
desktop_file="$app_dir/$app_name.desktop"

if [[ ! -f "$desktop_file" ]]; then
  echo "No web app named '$app_name' found at $desktop_file"
  exit 1
fi

# Read connected icon path before removing the desktop file
icon_path=""
if grep -q '^Icon=' "$desktop_file"; then
  icon_path=$(grep '^Icon=' "$desktop_file" | cut -d= -f2-)
fi

# Remove icon if it's under our local share dirs
icons_prefix="$HOME/.local/share/icons"
applications_icons_prefix="$HOME/.local/share/applications/icons"
if [[ -n "$icon_path" && -e "$icon_path" ]]; then
  if [[ "$icon_path" == "$icons_prefix"/* ]] || [[ "$icon_path" == "$applications_icons_prefix"/* ]]; then
    rm -f -- "$icon_path"
    echo "Removed icon: $icon_path"
  fi
fi

rm -f -- "$desktop_file"
echo "Removed web app '$app_name' at $desktop_file"
