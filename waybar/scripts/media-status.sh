#!/bin/bash

playerctl metadata --format '{"player":"{{ playerName }}","url":"{{ xesam:url }}","status":"{{ status }}","title":"{{ trunc(title, 40) }}","artist":"{{ artist }}","album":"{{ album }}","position":"{{ duration(position) }}","length":"{{ duration(mpris:length) }}", "art_url": "{{ mpris:artUrl }}"}' | \
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
  ),
  "tooltip": "Track: " + .title + "\n" +
    "Artist: " + .artist + "\n" +
    "Album: " + .album + "\n" +
    "Progress: " + (
      if (.length | length) > 10 then
        "LIVE"
      else
        .position + "/" + .length
      end
    )
}
'
