#!/bin/bash

if [ -z "$CODE_DIR" ]; then
	echo "CODE_DIR is not set. Please set it in your environment."
	exit 1
fi

cmd="code"
launcher=""
if command -v $cmd &> /dev/null; then
  launcher="$(which $cmd)"
else
  echo "ide launcher command '$cmd' is not installed. Please install $cmd to use this script."
  exit 1
fi

dir="$(realpath $CODE_DIR)"

options=$(find $dir -maxdepth 3 -type d -exec test -d '{}/.git' ';' -print)
options="${options//$dir\//}"

result=$(echo -ne "$options" | rofi -i -config $DOTFILES_DIR/rofi/config.rasi -dmenu -p "Select Respository")

if [ -z "$result" ]; then
  echo "No Repository selected, exiting."
  exit 1
fi

uwsm-app -- $launcher $dir/$result

