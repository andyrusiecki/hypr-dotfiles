#!/bin/sh

# Print all current client windows
echo "=== Initial Clients ==="
hyprctl clients -j | jq '.[]'

# Listen for new windows via Hyprland IPC socket
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do
  case "$line" in
    openwindow\>\>*)
      # Format: openwindow>>ADDRESS,WORKSPACE,CLASS,TITLE
      address="0x${line#openwindow>>}"
      address="${address%%,*}"
      echo "=== New Window at $(date +"%Y-%m-%d %H:%M:%S.%N")"
      hyprctl clients -j | jq -c --arg addr "$address" '.[] | select(.address == $addr)'
      ;;
  esac
done
