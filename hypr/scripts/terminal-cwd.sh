#!/bin/bash

blocked_classes=(
  "steam"
)

terminal_pid=$(hyprctl activewindow | awk '/pid:/ {print $2}')
terminal_class=$(hyprctl activewindow | awk '/class:/ {print $2}')

for blocked_class in "${blocked_classes[@]}"; do
  if [[ "$terminal_class" == *"$blocked_class"* ]]; then
    echo "$HOME"
    exit 0
  fi
done

shell_pid=$(pgrep -P "$terminal_pid" | tail -n1)

if [[ -n $shell_pid ]]; then
  cwd=$(readlink -f "/proc/$shell_pid/cwd" 2>/dev/null)

  if [[ -d $cwd ]]; then
    echo "$cwd"
  else
    echo "$HOME"
  fi
else
  echo "$HOME"
fi
