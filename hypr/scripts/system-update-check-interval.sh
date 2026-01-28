#!/bin/bash

delay=20 # initial delay in seconds
interval=3600  # 1 hour

echo "Starting Hyprland Update Checker..."

sleep $delay

while true; do
    $DOTFILES_DIR/hypr/scripts/system-update-check.sh
    sleep $interval
done


