#!/bin/bash

echo "Starting System Update..."
echo ""

# Arch + AUR updates
echo "===== Packages ====="

aur_helper=""
if command -v yay >/dev/null 2>&1; then
	aur_helper="yay"
elif command -v paru >/dev/null 2>&1; then
	aur_helper="paru"
fi

if [ -z "$aur_helper" ]; then
	echo "No AUR helper found! Please install yay or paru to enable AUR updates."
	echo "Proceeding with standard pacman update..."
	sudo pacman -Syu
elif ! $aur_available; then
	echo "Note: AUR not currently available! Skipping AUR packages..."
	sudo pacman -Syu
else
	echo "Using AUR helper: $aur_helper"
	$aur_helper -Syu
fi

# flatpak updates
echo ""
echo "===== Flatpak ====="
flatpak update

# clearing existing update notifications
notify-send \
	-h "string:private-synchronous:system-update" \
	-e -t 1 \
	"Clearing Notifications"

# update report for waybar
echo "Checking for any remaining updates..."
(
	set -m
	$DOTFILES_DIR/hypr/scripts/check-pending-updates.sh > /dev/null 2>&1 &
)

# close
echo ""
read -p "System Update Complete! Press Any Key to Close"
