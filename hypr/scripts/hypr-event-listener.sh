#!/bin/sh

hyprsunset_default_temp="6000"
hyprsunset_prev_temp=""
current_fullscreen_state=false

# disable hyprsunset when a window goes fullscreen, re-enable it when exiting fullscreen
check_active_fullscreen() {
  fullscreen_state="$(hyprctl activewindow -j | jq -r '.fullscreen')"
  new_fullscreen_state=$([[ "$fullscreen_state" == "2" || "$fullscreen_state" == "3" ]] && echo true || echo false)

  if [[ $current_fullscreen_state == $new_fullscreen_state ]]; then
    return
  fi

  if $new_fullscreen_state; then
    current_fullscreen_state=true
    hyprsunset_prev_temp="$(hyprctl hyprsunset temperature)"

    echo "Fullscreen detected, disabling hyprsunset (setting temp to $hyprsunset_default_temp K)"
    hyprctl hyprsunset temperature $hyprsunset_default_temp
  else
    current_fullscreen_state=false
    # replace with hyprsunset reset once released
    echo "Exiting fullscreen, re-enabling hyprsunset (restoring temp to $hyprsunset_prev_temp K)"
    hyprctl hyprsunset temperature $hyprsunset_prev_temp
  fi
}

handle() {
  case $1 in
    activewindow*|closewindow*|fullscreen*)
      check_active_fullscreen
      ;;
  esac
}

echo "Starting Hypr event listener on socket $XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock" | while read -r line; do handle "$line"; done
