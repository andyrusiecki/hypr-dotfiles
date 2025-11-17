#!/bin/sh

# Get the volume level and convert it to a percentage
status=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
volume=$(echo "$status" | awk '{print $2}')
volume=$(echo "( $volume * 100 ) / 1" | bc)
muted=$(echo "$status" | awk '{print $3}')

notify-send -t 1000 \
  -a 'audio-output-notif' \
  -h int:value:$volume \
  -h string:private-synchronous:audio-output-notif \
  -h boolean:SWAYNC_BYPASS_DND:true \
  "Volume: ${volume}% $muted"
