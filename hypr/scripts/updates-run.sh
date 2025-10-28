#!/bin/bash

# Arch + AUR updates
paru -Syu

# flatpak updates
flatpak update

# close
echo ""
read -p "Press Enter to Close"
