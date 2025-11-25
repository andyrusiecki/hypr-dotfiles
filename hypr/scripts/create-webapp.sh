#!/bin/bash

set -e

app_name="$1"
url="$2"
icon="$3"

icon_dir="$HOME/.local/share/applications/icons"
app_dir="$HOME/.local/share/applications"

if [ ! -d "$icon_dir" ]; then
  mkdir -p "$icon_dir"
fi

icon_path="$icon_dir/$icon.png"

# Refer to local icon or fetch remotely from URL
if ! [ -f "$icon_path" ]; then
  curl -sL -o "$icon_path" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/$icon.png"
fi

# Create application .desktop file
desktop_file="$app_dir/$app_name.desktop"

cat >"$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Name=$app_name
Comment=$app_name
Exec=/usr/bin/google-chrome-stable --app="$url"
Terminal=false
Type=Application
Icon=$icon_path
StartupNotify=true
EOF

chmod +x "$desktop_file"
echo "Web app '$app_name' created successfully at $desktop_file"
