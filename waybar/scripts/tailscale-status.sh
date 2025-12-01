#!/bin/bash

state=$(tailscale status --json | jq -r '.BackendState'| tr '[:upper:]' '[:lower:]')
accounts=$(tailscale switch --list | awk 'NR>1 {print $3}')

newline=$'\n'

if [ "$state" == "stopped" ] || [ "$state" == "nostate" ] || [ -z "$state" ]; then
  state="stopped"
  tooltip="Tailscale is stopped. Click to start Tailscale.${newline}${newline}"
  tooltip+="<b>Available accounts</b>:${newline}$accounts"
elif [ "$state" == "needslogin" ]; then
  tooltip="Tailscale needs login. Click to open the login page in your browser.${newline}${newline}"
  tooltip+="<b>Available accounts</b>:${newline}$accounts"
elif [ "$state" == "running" ]; then
  tooltip="Tailscale is connected.${newline}${newline}"
  tooltip+="<b>Available accounts</b>:${newline}$accounts"
fi

jq -n --unbuffered --compact-output \
  --arg alt "$state" \
  --arg tooltip "$tooltip" \
  --arg class "$state" \
  '{alt: $alt, tooltip: $tooltip, class: $class}'
