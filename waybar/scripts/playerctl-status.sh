#!/bin/bash

playerctl_call="playerctl --all-players --ignore-player=chromium"

case $1 in
  "player")
    $playerctl_call metadata --format '{"player": "{{playerName}}", "url": "{{xesam:url}}"}' | while read -r json; do
      echo "$json" | jq -r -c '"{\"alt\": \"" + (
        if .url | contains("youtube.com") then
          "youtube"
        elif .url | contains("spotify.com") then
          "spotify"
        elif .url | contains("twitch.tv") then
          "twitch"
        else
          .player
        end
      ) + "\"}"
    '
    done
    ;;
    "title")
      $playerctl_call metadata title
      ;;
    "byline")
        $playerctl_call metadata --format '{"artist": "{{artist}}", "album": "{{album}}"}' | while read -r json; do
          echo "$json" | jq -r -c '
          if .artist != "" then
            if .album != "" then
              .artist + " - " + .album
            else
              .artist
            end
          elif .album != "" then
            .album
          else
            "Unknown"
          end
        '
        done
      ;;
    "time")
      $playerctl_call metadata --format '{{duration(position)}} / {{duration(mpris:length)}}'
      ;;
    *)
        echo "Usage: $0 {player|title|byline|time}"
        exit 1
        ;;
esac
