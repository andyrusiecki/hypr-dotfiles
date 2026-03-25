#!/bin/bash
# progress-* + status-* classes for #custom-now-playing-progress (same idea as custom/media).

status="$(playerctl status 2>/dev/null | tr '[:upper:]' '[:lower:]')"

if [ -z "$status" ] || [ "$status" == "stopped" ]; then
  jq -n --unbuffered --compact-output \
    --arg text "" \
    --argjson class '["status-stopped"]' \
    '{text: $text, class: $class}'
  exit 0
fi

position=$(playerctl metadata --format '{{ position }}')
length=$(playerctl metadata --format '{{ mpris:length }}')

progress_percent=""

if [[ ${#length} -gt 10 ]]; then
  :
else
  progress_percent="$(( 100 * ${position%:*} / ${length%:*} ))"
  (( progress_percent > 100 )) && progress_percent=100
  (( progress_percent < 0 )) && progress_percent=0
fi

class="[\"status-$status\""
if [ -n "$progress_percent" ]; then
  class+=",\"progress-$progress_percent\""
fi
class+="]"

jq -n --unbuffered --compact-output \
  --arg text " " \
  --argjson class "$class" \
  '{text: $text, class: $class}'
