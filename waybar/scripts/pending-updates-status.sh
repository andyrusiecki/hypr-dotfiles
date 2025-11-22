#!/bin/bash

report_location="/tmp/hypr-pending-updates"
current_time=$(date +%s)

update_after_seconds=3600  # 1 hour

function debug() {
    echo "[$(date)] $1" >> "$HOME/waybar-updates-debug.log" 2>&1
}

debug "----------------------------------------"
debug "Pending updates status script started."

if [ ! -f "$report_location" ]; then
    debug "Report file not found, creating initial report and checking for updates..."
    jq -na --compact-output \
        --arg time $current_time \
        '{"last_checked": $time}' > "$report_location"

    $DOTFILES_DIR/hypr/scripts/check-pending-updates.sh
    debug "Update check complete (1)"
fi

last_checked=$(cat "$report_location" | jq -r '.last_checked')

if (( current_time - last_checked >= update_after_seconds )); then
    debug "Last checked at $last_checked, more than $update_after_seconds seconds ago, checking for updates..."
    jq -na --compact-output \
        --arg time $current_time \
        '{"last_checked": $time}' > "$report_location"

    $DOTFILES_DIR/hypr/scripts/check-pending-updates.sh
    debug "Update check complete (2)"
fi

count=$(cat "$report_location" | jq -r '.count.total')

if [ $count -lt 1 ]; then
    debug "No updates available."
    echo '{"alt": "", "text": ""}'
    exit
fi

debug "$count updates available."
details=$(cat "$report_location" | jq -r '.details')

# waybar module json output
jq -na --compact-output \
    --arg alt "updates" \
    --arg text "$count" \
    --arg tooltip "$details" \
    '{alt: $alt, text: $text, tooltip: $tooltip}'
