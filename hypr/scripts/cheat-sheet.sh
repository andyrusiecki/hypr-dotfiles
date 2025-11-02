#!/bin/bash


function read_bindings() {
  grep -hE '^bind.*?d =|^##' $DOTFILES_DIR/hypr/bindings/*.conf | while read -r line; do
    if [[ "$line" == \#\#* ]]; then
      echo -e "\n===== ${line//## /} =====\n"
    else
      line="$(echo "$line" | sed -E 's/bind.*?d = //') | tr -d ' ')"
      read -r mod key desc < <(echo "$line" | awk -F, '{print $1, $2, $3}')

      if [[ "$line" == ",*" ]]; then
        echo -e "$key => $desc"
      else
        echo -e "$mod + $key => $desc"
      fi
    fi
  done
}

read_bindings
