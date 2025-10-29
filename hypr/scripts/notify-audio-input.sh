#!/bin/sh

# Get the microphone level and convert it to a percentage
status=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
volume=$(echo "$status" | awk '{print $2}')
volume=$(echo "( $volume * 100 ) / 1" | bc)
muted=$(echo "$status" | awk '{print $3}')

notify-send -t 1000 -a 'audio' -h int:value:$volume "Microphone: ${volume}% $muted"
