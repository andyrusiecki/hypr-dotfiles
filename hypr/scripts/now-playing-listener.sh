#!/bin/sh

set -u

OUT_JSON="/tmp/now-playing.json"

write_status() {
  local tmp="$(mktemp "${TMPDIR:-/tmp}/now-playing.XXXXXX.json")"
  if ! playerctl status &>/dev/null; then
    jq -cn '{title:"",artist:"",album:"",artUrl:"",url:""}' >"$tmp" || {
      rm -f -- "$tmp"
      return 1
    }
  else
    local title="$(playerctl metadata title 2>/dev/null || true)"
    local artist="$(playerctl metadata artist 2>/dev/null || true)"
    local album="$(playerctl metadata album 2>/dev/null || true)"
    local artUrl="$(playerctl metadata mpris:artUrl 2>/dev/null || true)"
    local url="$(playerctl metadata xesam:url 2>/dev/null || true)"
    local player="$(playerctl metadata -f '{{ playerName }}' 2>/dev/null || true)"

    local local_art_path="$($DOTFILES_DIR/waybar/scripts/media-art.sh)"

    # only send notifications for music players
    if [[ "$player" == "spotify" ]]; then
      notify-send \
        -a 'now-playing' \
        -h string:private-synchronous:now-playing \
        -h boolean:SWAYNC_BYPASS_DND:true \
        -t 3000 \
        -i "$local_art_path" \
        "$title" "$artist - $album"
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
