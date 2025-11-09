#!/bin/bash

arch_updates=$(checkupdates --nocolor | wc -l)
flatpak_updates=$(flatpak remote-ls --updates | wc -l)

aur_updates=0

if $DOTFILES_DIR/hypr/scripts/updates-aur-available.sh; then
  aur_updates=$(pacman -Qm | aur vercmp | wc -l)
fi

echo $((arch_updates + aur_updates + flatpak_updates))
exit 0
