#!/bin/bash

echo "Starting System Update..."
echo ""

# Arch + AUR updates
echo "Packages:"

# only updating AUR packages if AUR is available
aur_available=$(curl -sf --connect-timeout 30 --retry 3 --retry-delay 3 "https://aur.archlinux.org/rpc/?v=5&type=info&arg=base" >/dev/null)
if $aur_available; then
	paru -Syu
else
	echo "Note: AUR not currently available! Skipping AUR packages..."
	sudo pacman -Syu
fi

# flatpak updates
echo ""
echo "Flatpak:"
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

#TODO: dismiss any update notifications after update is complete

# close
echo ""
read -p "System Update Complete! Press Any Key to Close"
