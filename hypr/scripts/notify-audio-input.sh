#!/bin/sh

# Get the microphone level and convert it to a percentage
volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@)
volume=$(echo "$volume" | awk '{print $2}')
volume=$(echo "( $volume * 100 ) / 1" | bc)

notify-send -t 1000 -a 'audio' -h int:value:$volume "Microphone: ${volume}%"
