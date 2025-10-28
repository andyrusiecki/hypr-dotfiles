#!/bin/bash

num_updates=$($DOTFILES_DIR/hypr/scripts/updates-available-count.sh)

if [ $num_updates -lt 1 ]; then
    echo '{"alt": "", "text": ""}'
else
    jq -n --compact-output \
        --arg alt "updates" \
        --arg text "$num_updates" \
        --arg tooltip "$($DOTFILES_DIR/hypr/scripts/updates-available-details.sh)" \
        '{alt: $alt, text: $text, tooltip: $tooltip}'
fi
