#!/bin/bash

if [ "$(dunstctl is-paused)" == true ]; then
  dunstctl set-pause-level 0
  notify-send -a do-not-disturb "Enabled Notifications"
else
  dunstctl set-pause-level 80
  notify-send -a do-not-disturb "Silenced Notifications"
fi
