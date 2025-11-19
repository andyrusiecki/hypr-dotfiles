#!/bin/bash

approved_classes=(
  "code"
  "kitty"
)

window_pid=$(hyprctl activewindow | awk '/pid:/ {print $2}')
window_class=$(hyprctl activewindow | awk '/class:/ {print $2}')

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

shell_pid=$(pgrep -P "$window_pid" | tail -n1)

cwd="$HOME"

if [[ "$window_class" == "code" ]]; then
  cwd="$(strings "/proc/$window_pid/cmdline" | tail -n 1)"
elif [[ -n $shell_pid ]]; then
  cwd=$(readlink -f "/proc/$shell_pid/cwd" 2>/dev/null)
fi

if [[ -d $cwd ]]; then
  echo "$cwd"
else
  echo "$HOME"
fi

