#!/bin/bash

playerctl_call="playerctl --ignore-player=chromium"
label_separator=" • "
title_max_length=60
status="$($playerctl_call status | tr '[:upper:]' '[:lower:]')"

if [ -z "$status" ] || [ "$status" == "stopped" ]; then
  # no player active
  jq -n --unbuffered --compact-output \
    --arg alt "none" \
    --arg text "" \
    --argjson class '["status-stopped"]' \
    '{alt: $alt, text: $text, class: $class}'
  exit 0
fi

function truncate() {
  local text="$1"
  local max_length="$2"
  if [[ ${#text} -gt $max_length ]]; then
    echo "${text:0:$max_length}..."
  else
    echo "$text"
  fi
}

player="$($playerctl_call metadata -f '{{ playerName }}')"
title="$($playerctl_call metadata -f '{{title}}')"
artist="$($playerctl_call metadata -f '{{artist}}')"
album="$($playerctl_call metadata -f '{{album}}')"

position=$($playerctl_call metadata -f '{{ position }}')
position_display="$($playerctl_call metadata -f '{{ duration(position) }}')"
length=$($playerctl_call metadata -f '{{ mpris:length }}')
length_display="$($playerctl_call metadata -f '{{ duration(mpris:length) }}')"

url="$($playerctl_call metadata -f '{{xesam:url}}')"
album_art="$($playerctl_call metadata -f '{{mpris:artUrl}}')"

# player - custom options
if [[ "$player" == "google-chrome" || "$player" == "chromium" || "$player" == "firefox" ]] && [[ -n "$url" ]]; then
  case $url in
    *"spotify.com"*)
      player="spotify"

      # Spotify Web often puts "Title • Artist" in the title field; split on first separator only
      label_separator=" • "
      if [[ "$title" == *"$label_separator"* ]]; then
        artist="${title#*"$label_separator"}"
        title="${title%%"$label_separator"*}"
      fi
      ;;
    *"youtube.com"*)
      player="youtube"
      ;;
    *"twitch.tv"*)
      player="twitch"
      ;;
  esac
fi

title="$(truncate "$title" $title_max_length)"

# text output
text="$title"
if [ -n "$artist" ]; then
  text+="$label_separator$artist"
elif [ -n "$album" ]; then
  text+="$label_separator$album"
fi

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

# youtube doesn't properly report current position when paused, so we don't show the progress bar
if [[ "$player" != "youtube" ]] && [ -n "$progress_percent" ]; then
  class+=",\"progress-$progress_percent\""
fi
class+="]"

jq -n --unbuffered --compact-output \
  --arg alt "$player" \
  --arg text "$text" \
  --arg tooltip "$tooltip" \
  --argjson class "$class" \
  '{alt: $alt, text: $text, tooltip: $tooltip, class: $class}'
