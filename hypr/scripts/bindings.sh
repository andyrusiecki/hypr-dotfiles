#!/bin/bash

echo -e "Hyprland Keybindings"

grep -hE '^bind.*?d =|^##' $DOTFILES_DIR/hypr/bindings/*.conf | while read -r line; do
  if [[ "$line" == \#\#* ]]; then
    echo -e "\n===== ${line//## /} =====\n"
  else
    line="$(echo "$line" | sed -E 's/bind.*?d = //') | tr -d ' ')"


    if [[ "$line" == ","* ]]; then
      line="${line/,/}"
      read -r key desc < <(echo "$line" | awk -F, '{print $1, $2}')
      echo -e "$key => $desc"
    else
      read -r mod key desc < <(echo "$line" | awk -F, '{print $1, $2, $3}')
      echo -e "$mod + $key => $desc"
    fi
  fi
done

