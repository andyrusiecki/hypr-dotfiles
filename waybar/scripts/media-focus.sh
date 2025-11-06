#!/bin/bash

player="$(playerctl metadata --format '{{ playerName }}')"

workspace=$(hyprctl -j clients | jq -r '.[] | select((.class | ascii_downcase) == "'$player'") | .workspace.id')

if [ -n "$workspace" ]; then
  hyprctl dispatch workspace "$workspace"
fi
