#!/bin/bash

report_location="/tmp/hypr-pending-updates"

if [ ! -f "$report_location" ]; then
    echo '{"alt": "", "text": ""}'
    exit
fi

count=$(cat "$report_location" | jq -r '.count.total')

if [ $count -lt 1 ]; then
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
