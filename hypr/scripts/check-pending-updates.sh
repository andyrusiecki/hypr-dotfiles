#!/bin/bash

delay=20 # initial delay in seconds
interval=3600  # 1 hour
report_location="/tmp/hypr-pending-updates"

check_for_updates() {
    echo "Checking for pending updates..."

    # only checking AUR is available
    aur_available=$(curl -sf --connect-timeout 30 --retry 3 --retry-delay 3 "https://aur.archlinux.org/rpc/?v=5&type=info&arg=base" >/dev/null)

    if ! $aur_available; then
        echo "Warning: AUR not currently available! Skipping AUR packages..."
    fi

    # get update counts
    num_core_updates=$(checkupdates --nocolor | wc -l)
    num_flatpak_updates=$(flatpak remote-ls --updates | wc -l)

    num_aur_updates=0
    if $aur_available; then
        num_aur_updates=$(pacman -Qm | aur vercmp | wc -l)
    fi

    num_pkg_updates=$((num_core_updates + num_aur_updates))
    num_updates=$((num_pkg_updates + num_flatpak_updates))

    newline=$'\n'
    details=""

    echo "Total updates available: $num_updates (Core: $num_core_updates, AUR: $num_aur_updates, Flatpak: $num_flatpak_updates)"

    if [ $num_updates -gt 0 ]; then
        (
            set -m
            notify-send \
            -a "system-update" \
            -h "string:desktop-entry:System Update" \
            -h "string:private-synchronous:system-update" \
            -i "archlinux-logo" \
            -A "Update" \
            "$num_updates Updates Available" "Core: $num_core_updates\nAUR: $num_aur_updates\nFlatpak: $num_flatpak_updates" \
            &
        )

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

            details+=" $num_pkg_updates Package updates available${newline}"

            if [ $num_pkg_updates -gt 30 ]; then
                priority_updates="$(echo -e "$pkg_updates" | awk '{print "- " $0}' | grep --color=never -E 'linux|nvidia|mesa|glibc|systemd|coreutils|hypr' | column -t)"

                remaining_count=$((num_pkg_updates - $(echo -e "$priority_updates" | wc -l)))

                details+="${priority_updates}${newline}-  And $remaining_count more package updates..."
            else
                details+="$(echo -e "$pkg_updates" | awk '{print "- " $0}' | column -t)"
            fi
        fi

        # flatpak updates
        if [ $num_flatpak_updates -gt 0 ]; then
            flatpak_updates="$(flatpak remote-ls --updates --columns=app,version)"

            if [ $num_pkg_updates -gt 0 ]; then
                details+="${newline}${newline}"
            fi

            details+=" $num_flatpak_updates Flatpak updates available${newline}$(echo -e "$flatpak_updates" | awk '{print "- " $0}' | column -t)"
        fi
    fi

    current_time=$(date +%s)

    # waybar module json output
    jq -na --compact-output \
        --arg num_core_updates "$num_core_updates" \
        --arg num_aur_updates "$num_aur_updates" \
        --arg num_flatpak_updates "$num_flatpak_updates" \
        --arg total_updates "$num_updates" \
        --arg time "$current_time" \
        --arg details "$details" \
        '{"count": {"total": $total_updates, "core": $num_core_updates, "aur": $num_aur_updates, "flatpak": $num_flatpak_updates}, "last_checked": $time, "details": $details}' > "$report_location"

    # signal waybar to refresh
    pkill -SIGRTMIN+1 waybar
}

echo "Starting Hyprland Update Checker..."

sleep $delay

while true; do
    check_for_updates
    sleep $interval
done


