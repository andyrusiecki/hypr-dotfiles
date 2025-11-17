#!/bin/sh

hyprsunset_default_temp="6000"
hyprsunset_prev_temp=""
is_fullscreen=false

# disable hyprsunset when a window goes fullscreen, re-enable it when exiting fullscreen
check_active_fullscreen() {
  if [[ "$(hyprctl activewindow -j | jq -r '.fullscreen')" == "2" ]]; then
    is_fullscreen=true
    hyprsunset_prev_temp="$(hyprctl hyprsunset temperature)"

    echo "Fullscreen detected, disabling hyprsunset (setting temp to $hyprsunset_default_temp K)"
    hyprctl hyprsunset temperature $hyprsunset_default_temp
  elif $is_fullscreen; then
    is_fullscreen=false
    # replace with hyprsunset reset once released
    echo "Exiting fullscreen, re-enabling hyprsunset (restoring temp to $hyprsunset_prev_temp K)"
    hyprctl hyprsunset temperature $hyprsunset_prev_temp
  fi
}

handle() {
  case $1 in
    activewindow*|fullscreen*)
      check_active_fullscreen
      ;;
  esac
}


socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do handle "$line"; done
