#!/bin/bash

label_separator=" • "
title_max_length=60
status="$(playerctl status | tr '[:upper:]' '[:lower:]')"

if [ -z "$status" ] || [ "$status" == "stopped" ]; then
  # no player active
  jq -n --unbuffered --compact-output \
    --arg alt "none" \
    --arg text "" \
    --argjson class '["status-stopped"]' \
    '{alt: $alt, text: $text, class: $class}'
  exit 0
fi

player="$(playerctl metadata --format '{{ playerName }}')"
title="$(playerctl metadata --format "{{ trunc(title, $title_max_length) }}")"
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
  text+="$label_separator$artist"
elif [ -n "$album" ]; then
  text+="$label_separator$album"
fi

# youtube.com keeps the position running even while paused, this can be fixed with an extension: https://github.com/LurkAndLoiter/youtube-mpris-fix
progress_display=""
progress_percent=""

if [[ ${#length} -gt 10 ]]; then
  progress_display="LIVE"
else
  progress_display="$position_display/$length_display"
  progress_percent="$(( 100 * ${position%:*} / ${length%:*} ))"
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
