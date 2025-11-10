#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {output|region|window}"
  exit 1
fi

mode="$1"

if [[ "$mode" != "window" && "$mode" != "region" && "$mode" != "output" ]]; then
  echo "Invalid option: $mode"
  echo "Usage: $0 {output|region|window}"
  exit 1
fi


# output file
out_dir="$(xdg-user-dir PICTURES)/Screenshots"
if [ ! -d "$out_dir" ]; then
  mkdir -p "$out_dir"
fi

filename="$(date +'%Y-%m-%d-%H%M%S')_screenshot.png"

hyprshot -m $mode -o "$out_dir" -f "$filename"
