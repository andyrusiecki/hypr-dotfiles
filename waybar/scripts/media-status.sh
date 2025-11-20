#!/bin/bash

player="$(playerctl metadata --format '{{ playerName }}')"
status="$(playerctl status | tr '[:upper:]' '[:lower:]')"
title="$(playerctl metadata --format '{{ trunc(title, 40) }}')"
artist="$(playerctl metadata --format '{{ artist }}')"
album="$(playerctl metadata --format '{{ album }}')"

position=$(playerctl metadata --format '{{ position }}')
position_display="$(playerctl metadata --format '{{ duration(position) }}')"
length=$(playerctl metadata --format '{{ mpris:length }}')
length_display="$(playerctl metadata --format '{{ duration(mpris:length) }}')"

url="$(playerctl metadata --format '{{ xesam:url }}')"
album_art="$(playerctl metadata --format '{{ mpris:artUrl }}')"

# player - custom options
if [ -n "$url" ]; then
  if [[ "$url" == *"youtube.com"* ]]; then
    player="youtube"
  elif [[ "$url" == *"spotify.com"* ]]; then
    player="spotify"
  elif [[ "$url" == *"twitch.tv"* ]]; then
    player="twitch"
  fi
fi

# text output
text="$title"
if [ -n "$artist" ]; then
  text+=" - $artist"
elif [ -n "$album" ]; then
  text+=" - $album"
fi

# youtube.com keeps the position running even while paused, so we skip time display for it
progress_display=""
progress_percent=""
if [[ "$player" != "youtube" ]]; then
  if [[ ${#length} -gt 10 ]]; then
    progress_display="LIVE"
  else
    progress_display="$position_display/$length_display"
    progress_percent="$(( 100 * ${position%:*} / ${length%:*} ))"
  fi
fi

# if [ -n "$progress_display" ]; then
#   text+=" [$progress_display]"
# fi

newline=$'\n'
tooltip="Track: $title"

if [ -n "$artist" ]; then
  tooltip+="${newline}Artist: $artist"
fi

if [ -n "$album" ]; then
  tooltip+="${newline}Album: $album"
fi

if [ -n "$progress_display" ]; then
  tooltip+="${newline}Time: $progress_display"
fi

class="[\"status-$status\""
if [ -n "$progress_percent" ]; then
  class+=",\"progress-$progress_percent\""
fi
class+="]"

jq -n --unbuffered --compact-output \
  --arg alt "$player" \
  --arg text "$text" \
  --arg tooltip "$tooltip" \
  --argjson class "$class" \
  '{alt: $alt, text: $text, tooltip: $tooltip, class: $class}'
