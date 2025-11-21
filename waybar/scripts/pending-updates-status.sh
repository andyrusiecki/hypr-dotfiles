#!/bin/bash

report_location="/tmp/hypr-pending-updates"
current_time=$(date +%s)

update_after_seconds=3600  # 1 hour

if [ ! -f "$report_location" ]; then
    jq -na --compact-output \
        --arg time $current_time \
        '{"last_checked": $time}' > "$report_location"

    $DOTFILES_DIR/hypr/scripts/check-pending-updates.sh
fi

last_checked=$(cat "$report_location" | jq -r '.last_checked')

if (( current_time - last_checked >= update_after_seconds )); then
    jq -na --compact-output \
        --arg time $current_time \
        '{"last_checked": $time}' > "$report_location"

    $DOTFILES_DIR/hypr/scripts/check-pending-updates.sh
fi

count=$(cat "$report_location" | jq -r '.count.total')

if [ "$count" -lt 1 ]; then
    echo '{"alt": "", "text": ""}'
    exit
fi

details=$(cat "$report_location" | jq -r '.details')

# waybar module json output
jq -na --compact-output \
    --arg alt "updates" \
    --arg text "$count" \
    --arg tooltip "$details" \
    '{alt: $alt, text: $text, tooltip: $tooltip}'
