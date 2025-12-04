#!/bin/bash
function notify() {
  notify-send \
    -a "tailscale" \
    -i "network-workgroup" \
    -h string:private-synchronous:tailscale-notif \
    -h boolean:SWAYNC_BYPASS_DND:true \
    "$1"
}

function toggle_state() {
  state=$(tailscale status --json | jq -r '.BackendState'| tr '[:upper:]' '[:lower:]')
  case $state in
    "stopped")
      tailscale up
      new_status=$(tailscale status --json | jq -r '.BackendState'| tr '[:upper:]' '[:lower:]')

      if [ "$new_status" == "running" ]; then
        notify "Connected Successfully."
      else
        notify "Failed to start. Tailscale is still stopped."
      fi
      ;;
    "needslogin")
      auth_url=$(tailscale status --json | jq -r '.AuthURL')
      xdg-open "$auth_url"
      ;;
    "running")
      tailscale down
      new_status=$(tailscale status --json | jq -r '.BackendState'| tr '[:upper:]' '[:lower:]')

      if [ "$new_status" == "stopped" ]; then
        notify "Stopped Successfully."
      else
        notify "Failed to stop. Tailscale is still running."
      fi
      ;;
  esac
}

function toggle_account() {
  accounts=($(tailscale switch --list | awk 'NR>1 {print $3}'))
  count=${#accounts[@]}

  # not enough accounts to switch
  if [ $count -lt 2 ]; then
    return
  fi

  current_index=0
  for i in "${!accounts[@]}"; do
    if [[ "${accounts[$i]}" == *'*' ]]; then
      current_index=$i
      break
    fi
  done

  current_index+=1
  if [ $current_index -ge $count ]; then
    current_index=0
  fi

  new_account="${accounts[$current_index]}"
  tailscale switch "$new_account"
  notify "Switched to account: $new_account"
}

case "$1" in
  "state")
    toggle_state
    ;;
  "account")
    toggle_account
    ;;
  *)
    echo "Invalid argument. Use 'state' or 'account'."
    exit 1
    ;;
esac


