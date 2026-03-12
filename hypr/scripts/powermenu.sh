#!/bin/bash

options="Shutdown\0icon\x1fshutdown\nSuspend\0icon\x1fsuspend\nReboot\0icon\x1freboot\nLogout\0icon\x1flogout\n"

selected=$(echo -ne "$options" | rofi -config $DOTFILES_DIR/rofi/config-noinput.rasi -dmenu -mesg "Uptime: $(uptime -p | sed 's/up\s//')")

if [ -z "$selected" ]; then
  echo "No option selected, exiting."
  exit 1
fi

notify-send "Selected option: $selected"
