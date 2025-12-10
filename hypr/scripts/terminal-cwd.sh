#!/bin/bash

approved_classes=(
  "code"
  "kitty"
)


window_class="$(hyprctl activewindow -j | jq -r '.class')"

approved=false
for approved_class in "${approved_classes[@]}"; do
  if [[ "$window_class" == "$approved_class" ]]; then
    approved=true
  fi
done

if ! $approved; then
  echo "$HOME"
  exit 0
fi

cwd="$HOME"

case "$window_class" in
  "code")
    # VSCode stores the last opened folder in a JSON file
    # not always accurate but better than nothing
    storage="$HOME/.config/Code/User/globalStorage/storage.json"
    if ! [ -f "$storage" ]; then
      break
    fi

    last_dir="$(jq -r '.windowsState.lastActiveWindow.folder' "$storage")"
    if [ -z "$last_dir" ] || [ "$last_dir" == "null" ]; then
      break
    fi

    last_dir="${last_dir//file:\/\//}"
    if [ -d "$last_dir" ]; then
      cwd="$last_dir"
    fi
    ;;
  "kitty")
    window_pid="$(hyprctl activewindow -j | jq -r '.pid')"
    shell_pid=$(pgrep -P "$window_pid" | tail -n1)
    last_dir=$(readlink -f "/proc/$shell_pid/cwd" 2>/dev/null)

    if [ -d "$last_dir" ]; then
      cwd="$last_dir"
    fi
    ;;
esac

echo "$cwd"
