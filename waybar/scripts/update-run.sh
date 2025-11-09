#!/bin/bash

echo "Starting System Update..."
echo ""
# Arch + AUR updates
echo "Packages:"
paru -Syu

# flatpak updates
echo ""
echo "Flatpak:"
flatpak update

# signal waybar to refresh
pkill -SIGRTMIN+1 waybar

# close
echo ""
read -p "System Update Complete! Press Any Key to Close"
