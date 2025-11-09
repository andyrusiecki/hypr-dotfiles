#!/bin/bash

# only checking AUR is available
aur_available=$(curl -sf --connect-timeout 30 --retry 3 --retry-delay 3 "https://aur.archlinux.org/rpc/?v=5&type=info&arg=base" >/dev/null)

# get update counts
num_core_updates=$(checkupdates --nocolor | wc -l)
num_flatpak_updates=$(flatpak remote-ls --updates | wc -l)

num_aur_updates=0
if $aur_available; then
    num_aur_updates=$(pacman -Qm | aur vercmp | wc -l)
fi

num_pkg_updates=$((num_core_updates + num_aur_updates))
num_updates=$((num_pkg_updates + num_flatpak_updates))

# exit early if no updates
if [ $num_updates -lt 1 ]; then
    echo '{"alt": "", "text": ""}'
    exit
fi

# construct tooltip string
tooltip=""
newline=$'\n'

# package updates
if [ $num_pkg_updates -gt 0 ]; then
    pkg_updates=""
    if [ $num_core_updates -gt 0 ]; then
        pkg_updates+="$(checkupdates --nocolor)"
    fi
    if [ $num_aur_updates -gt 0 ]; then
        if [ $num_core_updates -gt 0 ]; then
            pkg_updates+="${newline}"
        fi
        pkg_updates+="$(pacman -Qm | aur vercmp)"
    fi

    tooltip+=" $num_pkg_updates Package updates available${newline}$(echo -e "$pkg_updates" | awk '{print "- " $0}' | column -t)"
fi

# flatpak updates
if [ $num_flatpak_updates -gt 0 ]; then
    flatpak_updates="$(flatpak remote-ls --updates --columns=app,version)"

    if [ $num_pkg_updates -gt 0 ]; then
        tooltip+="${newline}${newline}"
    fi

    tooltip+=" $num_flatpak_updates Flatpak updates available${newline}$(echo -e "$flatpak_updates" | awk '{print "- " $0}' | column -t)"
fi

# waybar module json output
jq -na --compact-output \
    --arg alt "updates" \
    --arg text "$num_updates" \
    --arg tooltip "$tooltip" \
    '{alt: $alt, text: $text, tooltip: $tooltip}'
