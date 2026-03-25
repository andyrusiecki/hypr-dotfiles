#!/bin/bash
# Usage: now-playing-status.sh {player|title|artist}
# JSON for Waybar custom modules (player → format-icons alt; title/artist → text + class).

title_max_length=60
mode="${1:?usage: $0 player|title|artist}"

status="$(playerctl status 2>/dev/null | tr '[:upper:]' '[:lower:]')"

if [ -z "$status" ] || [ "$status" == "stopped" ]; then
  case "$mode" in
    player)
      jq -n --unbuffered --compact-output --arg alt "none" '{alt: $alt}'
      ;;
    title|artist)
      jq -n --unbuffered --compact-output \
        --arg text "" \
        --argjson class '["status-stopped"]' \
        '{text: $text, class: $class}'
      ;;
    *)
      echo "usage: $0 player|title|artist" >&2
      exit 1
      ;;
  esac
  exit 0
fi

player="$(playerctl metadata --format '{{ playerName }}')"
url="$(playerctl metadata --format '{{ xesam:url }}')"
if [ -n "$url" ]; then
  if [[ "$url" == *"youtube.com"* ]]; then
    player="youtube"
  elif [[ "$url" == *"spotify.com"* ]]; then
    player="spotify"
  elif [[ "$url" == *"twitch.tv"* ]]; then
    player="twitch"
  fi
fi

case "$mode" in
  player)
    jq -n --unbuffered --compact-output \
      --arg alt "$player" \
      --arg st "$status" \
      '{alt: $alt, class: [("status-" + $st)]}'
    ;;
  title)
    title="$(playerctl metadata --format "{{ trunc(title, $title_max_length) }}")"
    [[ -n "$title" ]] || title="Unknown"
    artist="$(playerctl metadata --format '{{ artist }}')"
    album="$(playerctl metadata --format '{{ album }}')"
    nl=$'\n'
    tooltip="Track: $title"
    tooltip+="${nl}Artist: ${artist:-—}"
    if [ -n "$album" ]; then
      tooltip+="${nl}Album: $album"
    fi
    class="[\"status-$status\"]"
    jq -n --unbuffered --compact-output \
      --arg text "$title" \
      --arg tooltip "$tooltip" \
      --argjson class "$class" \
      '{text: $text, tooltip: $tooltip, class: $class}'
    ;;
  artist)
    artist="$(playerctl metadata --format '{{ artist }}')"
    album="$(playerctl metadata --format '{{ album }}')"
    byline="$artist"
    if [[ -z "$byline" ]]; then
      byline="$album"
    fi
    if [[ -z "$byline" ]]; then
      byline="—"
    fi
    class="[\"status-$status\"]"
    jq -n --unbuffered --compact-output \
      --arg text "$byline" \
      --argjson class "$class" \
      '{text: $text, class: $class}'
    ;;
  *)
    echo "usage: $0 player|title|artist" >&2
    exit 1
    ;;
esac
