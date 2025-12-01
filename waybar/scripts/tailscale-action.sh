#!/bin/bash
function notify() {
  notify-send -a "tailscale" -i "network-workgroup" "Tailscale" "$2"
}

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
