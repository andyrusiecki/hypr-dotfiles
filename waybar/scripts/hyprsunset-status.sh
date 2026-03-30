#!/bin/bash

temperature="$(hyprctl hyprsunset temperature)K"
gamma="$(hyprctl hyprsunset gamma)"

sunrise="$(grep -oP 'sunrise at:\s*\K.+$' ~/.config/hypr/hyprsunset.conf)"
sunset="$(grep -oP 'sunset at:\s*\K.+$' ~/.config/hypr/hyprsunset.conf)"

echo " $temperature|󰃠 $gamma|󰖜 $sunrise|󰖛 $sunset"

# jq -n --unbuffered --compact-output \
#   --arg text "$text" \
#   '{text: $text}'
