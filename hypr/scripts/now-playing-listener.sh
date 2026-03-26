#!/bin/sh

set -u

OUT_JSON="/tmp/now-playing.json"
playerctl_call="playerctl --ignore-player=chromium"

write_status() {
  local tmp="$(mktemp "/tmp/now-playing.XXXXXX.json")"
  if ! playerctl status &>/dev/null; then
    jq -cn '{title:"",artist:"",album:"",artUrl:"",url:""}' >"$tmp" || {
      rm -f -- "$tmp"
      return 1
    }
  else
    local title="$(playerctl metadata -f '{{title}}' 2>/dev/null || true)"
    local artist="$(playerctl metadata -f '{{artist}}' 2>/dev/null || true)"
    local album="$(playerctl metadata -f '{{album}}' 2>/dev/null || true)"
    local artUrl="$(playerctl metadata -f '{{mpris:artUrl}}' 2>/dev/null || true)"
    local url="$(playerctl metadata -f '{{xesam:url}}' 2>/dev/null || true)"
    local player="$(playerctl metadata -f '{{ playerName }}' 2>/dev/null || true)"

    local local_art_path="$($DOTFILES_DIR/waybar/scripts/media-art.sh)"

    local send_notification=false

    # override player based on for browser media players
    if [[ "$player" == "google-chrome" || "$player" == "chromium" || "$player" == "firefox" ]] && [[ -n "$url" ]]; then
      case $url in
        *"spotify.com"*)
          player="spotify"

          # split title to get true title and artist
          local title_parts=(${title// • / })
          title="${title_parts[0]}"
          artist="${title_parts[1]}"
          ;;
        *"youtube.com"*)
          player="youtube"
          ;;
        *"twitch.tv"*)
          player="twitch"
          ;;
      esac
    fi

    case $player in
      "spotify")
        send_notification=true
        # check for empty artist (occurs with podcasts)
        if [ -z "$artist" ] && [ -n "$album" ]; then
          artist="$album"
          album=""
        fi
        ;;
    esac

    # only send notifications for music players (only if currently playing)
    status="$(playerctl status 2>/dev/null | tr '[:upper:]' '[:lower:]')"

    if [[ "$status" == "playing" ]] && [[ "$send_notification" == true ]]; then
      local msg=""
      if [ -n "$artist" ]; then
        msg="$artist"

        if [ -n "$album" ]; then
          msg+=" - $album"
        fi
      elif [ -n "$album" ]; then
        msg="$album"
      fi

      notify-send \
        -a 'now-playing' \
        -h string:private-synchronous:now-playing \
        -h boolean:SWAYNC_BYPASS_DND:true \
        -t 3000 \
        -i "$local_art_path" \
        "$title" "$msg"
    fi

    jq -cn \
      --arg player "$player" \
      --arg title "$title" \
      --arg artist "$artist" \
      --arg album "$album" \
      --arg artUrl "$artUrl" \
      --arg localArtPath "$local_art_path" \
      --arg url "$url" \
      '{player:$player,title:$title,artist:$artist,album:$album,artUrl:$artUrl,localArtPath:$localArtPath,url:$url}' >"$tmp" || {
      rm -f -- "$tmp"
      return 1
    }
  fi
  mv -f -- "$tmp" "$OUT_JSON"

  # signal waybar to refresh
  pkill -SIGRTMIN+4 waybar
}

while true; do
  if playerctl status &>/dev/null; then
    playerctl metadata --format '{{mpris:trackid}}|{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}|{{xesam:url}}' --follow 2>/dev/null |
      while read -r _; do
        write_status
      done
    write_status
  fi
  sleep 1
done
