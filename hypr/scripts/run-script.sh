#!/bin/bash

if [ -z "$HYPR_SCRIPTS_DIR" ]; then
	echo "HYPR_SCRIPTS_DIR is not set. Please set it in your environment."
	exit 1
fi

dir="$(realpath $HYPR_SCRIPTS_DIR)"

options=$(find $dir -type f -executable)
options="${options//$dir\//}"

result=$(echo -ne "$options" | rofi -config $DOTFILES_DIR/rofi/config.rasi -dmenu -p "Select Script")

if [ -z "$result" ]; then
  echo "No Script selected, exiting."
  exit 1
fi

exec $dir/$result
