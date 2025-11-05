#!/bin/bash
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {output|region|window}"
  exit 1
fi

geometry=""
case "$1" in
  output)
    geometry="$(slurp -or -f "%wx%h+%x+%y")"
    ;;
  region)
    geometry="$(slurp -d -f "%wx%h+%x+%y")"
    ;;
  window)
    monitors=`hyprctl -j monitors`
    clients=`hyprctl -j clients | jq -r '[.[] | select(.workspace.id | contains('$(echo $monitors | jq -r 'map(.activeWorkspace.id) | join(",")')'))]'`

    boxes="$(echo $clients | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1]) \(.title)"' | cut -f1,2 -d' ')"
    geometry="$(slurp -r -f "%wx%h+%x+%y" <<< "$boxes")"
    ;;
  *)
    echo "Usage: $0 {output|region|window}"
    exit 1
    ;;
esac

if [ -z "$geometry" ]; then
  echo "No geometry selected, exiting."
  exit 1
fi

# output file
out_dir="$(xdg-user-dir VIDEOS)/Screen Recordings"
if [ ! -d "$out_dir" ]; then
  mkdir -p "$out_dir"
fi

filename="$(date +'%Y-%m-%d-%H%M%S_screen_recording.mp4')"

pkill -SIGRTMIN+3 waybar

gpu-screen-recorder -w region -region "$geometry" -a "default_output" -o "$out_dir/$filename"

action="$(notify-send -A open=open "Screen recording saved" "Recorded to $out_dir/$filename")"

echo "$action"
case "$action" in
  open)
    uwsm-app -- nautilus -s "$out_dir/$filename"
    ;;
esac
