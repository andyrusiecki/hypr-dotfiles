#!/bin/bash

echo "Arch:"
arch_updates="$(checkupdates --nocolor)"
if ! [ "$arch_updates" == "" ]; then
  echo "$arch_updates" | awk '{print "- " $0}' | column -t

else
  echo "No updates available"
fi

echo ""
echo "AUR:"
if ! $DOTFILES_DIR/hypr/scripts/updates-aur-available.sh; then
  echo "ERROR - AUR could not be reached"
else
  aur_updates="$(pacman -Qm | aur vercmp)"
  if ! [ "$aur_updates" == "" ]; then
    echo "$aur_updates" | awk '{print "- " $0}' | column -t
  else
    echo "No updates available"
  fi
fi

echo ""
echo "Flatpak:"
flatpak_updates="$(flatpak remote-ls --updates --columns=app,version)"
if ! [ "$flatpak_updates" == "" ]; then
  echo "$flatpak_updates" | awk '{print "- " $0}' | column -t
else
  echo "No updates available"
fi
