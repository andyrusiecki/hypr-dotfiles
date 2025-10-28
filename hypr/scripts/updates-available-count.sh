#!/bin/bash

arch_updates=$(checkupdates | wc -l)
aur_updates=$(pacman -Qm | aur vercmp | wc -l)
flatpak_updates=$(flatpak remote-ls --updates | wc -l)

echo $((arch_updates + aur_updates + flatpak_updates))
exit 0
