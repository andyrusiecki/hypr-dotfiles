#!/bin/bash

set -e

usage() {
  echo "Usage: $0 [--icon <icon>|--mimetypes <mime types>|--exec <exec>] <name> <url>"
  exit 1
}

icon=""
mime_types=""
custom_exec=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --icon)
      [[ -n "${2:-}" && "$2" != --* ]] || usage
      icon="$2"
      shift 2
      ;;
    --mimetypes)
      [[ -n "${2:-}" && "$2" != --* ]] || usage
      mime_types="$2"
      shift 2
      ;;
    --exec)
      [[ -n "${2:-}" && "$2" != --* ]] || usage
      custom_exec="$2"
      shift 2
      ;;
    -*)
      usage
      ;;
    *)
      break
      ;;
  esac
done

[[ $# -ge 2 ]] || usage
app_name="$1"
url="$2"

icon_dir="$HOME/.local/share/applications/icons"
app_dir="$HOME/.local/share/applications"

# Default exec: Chrome in app mode
exec_cmd="${custom_exec:-/usr/bin/google-chrome-stable --app=\"$url\"}"

if [ ! -d "$icon_dir" ]; then
  mkdir -p "$icon_dir"
fi

# Icon: use path if provided and it looks like a path, else treat as icon name and fetch
if [[ -n "$icon" ]]; then
  if [[ "$icon" == /* ]] || [[ "$icon" == .* ]]; then
    icon_path="$icon"
  else
    icon_path="$icon_dir/$icon.png"
    if ! [ -f "$icon_path" ]; then
      curl -sL -o "$icon_path" "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/$icon.png"
    fi
  fi
else
  icon_path=""
fi

# Create application .desktop file
desktop_file="$app_dir/$app_name.desktop"

cat >"$desktop_file" <<EOF
[Desktop Entry]
Version=1.0
Name=$app_name
Comment=$app_name
Exec=$exec_cmd
Terminal=false
Type=Application
StartupNotify=true
EOF

if [[ -n "$icon_path" ]]; then
  echo "Icon=$icon_path" >>"$desktop_file"
fi

if [[ -n "$mime_types" ]]; then
  echo "MimeType=$mime_types" >>"$desktop_file"
fi

chmod +x "$desktop_file"
echo "Web app '$app_name' created successfully at $desktop_file"
