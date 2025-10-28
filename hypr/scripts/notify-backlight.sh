#!/bin/sh

# Get the backlight level and convert it to a percentage
backlight=$(echo "$(brightnessctl -c backlight get) * 100 / $(brightnessctl -c backlight max)" | bc)

notify-send -t 1000 -a 'backlight' -h int:value:$backlight "Backlight: ${backlight}%"
