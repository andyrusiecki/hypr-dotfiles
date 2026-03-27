#!/bin/bash

options="Shutdown\0icon\x1fshutdown\nSuspend\0icon\x1fsuspend\nReboot\0icon\x1freboot\nLogout\0icon\x1flogout\n"

selected=$(echo -ne "$options" | rofi -config $DOTFILES_DIR/rofi/config-noinput.rasi -dmenu -mesg "Uptime: $(uptime -p | sed 's/up\s//')")

notify_timeout=5000
notify_timeout_seconds=$((notify_timeout / 1000))

cmd=""
msg=""
case $selected in
  "Shutdown")
    cmd="systemctl poweroff"
    msg="Shutting down"
    ;;
  "Suspend")
    cmd="systemctl suspend"
    msg="Suspending"
    ;;
  "Reboot")
    cmd="systemctl reboot"
    msg="Rebooting"
    ;;
  "Logout")
    cmd="loginctl terminate-user \"\""
    msg="Logging out"
    ;;
  *)
    echo "No option selected, exiting."
    exit 1
  ;;
esac

remaining=$notify_timeout_seconds
while [ "$remaining" -gt 0 ]; do
  if [ "$remaining" -eq 1 ]; then
    unit=second
    timeout=1000
  else
    unit=seconds
    timeout=2000
  fi

  notify-send -t $timeout \
    -a 'powermenu-notif' \
    -h string:private-synchronous:powermenu-notif \
    -h boolean:SWAYNC_BYPASS_DND:true \
    "$msg in $remaining $unit..."

  sleep 1
  remaining=$((remaining - 1))
done

if [ -n "$cmd" ]; then
  $cmd
fi
