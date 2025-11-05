#!/bin/bash

prioritize_players=(
  "spotify"
  "firefox"
)

function get_player() {
  # check for active prioritized players
  for player in "${prioritize_players[@]}"; do
    if [ "$(playerctl --player=$player status 2>/dev/null)" == "Playing" ]; then
      echo "$player"
      return
    fi
  done

  # check for any player that is playing
  for player in $(playerctl -l); do
    if [ "$(playerctl --player=$player status 2>/dev/null)" == "Playing" ]; then
      echo "$player" | cut -d'.' -f1
      return
    fi
  done

  # fallback to the first available player
  playerctl -l  2>/dev/null | head -n 1 | cut -d'.' -f1
}

player="$(get_player)"

if [ -z "$player" ]; then
  echo '{"text": "", "alt": "no-player"}'
  exit 0
fi

playerctl --player="$player" metadata --format '{"player":"{{ playerName }}","url":"{{ xesam:url }}","status":"{{ status }}","title":"{{ trunc(title, 40) }}","artist":"{{ artist }}","album":"{{ album }}","position":"{{ duration(position) }}","length":"{{ duration(mpris:length) }}"}' | \
jq -r -c '{
  "alt": if .url | contains("youtube.com") then
    "youtube"
  elif .url | contains("spotify.com") then
    "spotify"
  elif .url | contains("twitch.tv") then
    "twitch"
  else
    .player
  end,
  "text": .title + (
    if .artist != "" then
      " - " + .artist
    elif .album != "" then
      " - " + .album
    else
      ""
    end
  ) + (
    if (.length | length) > 10 then
      " [LIVE]"
    else
      " [" + .position + "/" + .length + "]"
    end
  )
}
'
