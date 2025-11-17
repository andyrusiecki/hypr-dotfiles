#!/bin/sh

# Get the backlight level and convert it to a percentage
backlight=$(echo "$(brightnessctl -c backlight get) * 100 / $(brightnessctl -c backlight max)" | bc)

notify-send -t 1000 \
  -a 'backlight-notif' \
  -h int:value:$backlight \
  -h string:private-synchronous:backlight-notif \
  -h boolean:SWAYNC_BYPASS_DND:true \
  "Backlight: ${backlight}%"
