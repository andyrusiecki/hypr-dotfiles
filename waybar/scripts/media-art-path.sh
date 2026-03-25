#!/bin/sh

if [[ ! -f "/tmp/waybar-media-art-hash" ]]; then
  echo ""
  exit 1
fi

echo "/tmp/waybar-media-art/$(/bin/cat /tmp/waybar-media-art-hash)"

