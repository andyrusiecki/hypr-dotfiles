#!/bin/bash

stored_art_id="/tmp/waybar-media-art-hash"
stored_art_dir="/tmp/waybar-media-art"

if [[ ! -d $stored_art_dir ]]; then
  mkdir -p "$stored_art_dir"
fi

function clearMediaArt() {
  rm -f "$stored_art_id"
}

# if [[ "$(playerctl status 2>/dev/null)" != "Playing" ]]; then
#   # no media playing
#   clearMediaArt
#   exit 1
# fi

player="$(playerctl metadata --format '{{ playerName }}')"

album_art="$(playerctl --player="$player" metadata mpris:artUrl 2>/dev/null)"
art_type="artUrl"

if [[ -z $album_art ]]; then
  album_art="$(playerctl --player="$player" metadata xesam:url 2>/dev/null)"
  art_type="url"
fi

if [[ -z $album_art ]]; then
  # no art to grab
  clearMediaArt
  echo "NULL"
  exit 1
fi

art_hash=$(echo -n "$art_type:$album_art" | sha256sum | awk '{print $1}')

if [[ -f "$stored_art_id" ]]; then
  cached_art_hash=$(<"$stored_art_id")

  if [[ "$cached_art_hash" == "$art_hash" ]]; then
    echo "$stored_art_dir/$art_hash"
    exit 0
  fi
fi

# still have cached artwork
if [[ -f "$stored_art_dir/$art_hash" ]]; then
  echo "$stored_art_dir/$art_hash"
  echo "$art_hash" > "$stored_art_id"
  exit 0
fi

# downloading new artwork
if [[ $album_art == http* ]]; then
  if [[ $art_type == "artUrl" ]]; then
    # direct link to art
    curl -s "${album_art}" --output "$stored_art_dir/$art_hash"
    echo "$art_hash" > "$stored_art_id"
    echo "$stored_art_dir/$art_hash"
    exit 0
  fi

  # need to scrape page for art
  new_album_art="$(curl -s "$album_art" | grep -oP 'meta property="og:image" content="(.*?)"' | sed -E 's/.*content="(.*?)".*/\1/')"

  if [[ -z $new_album_art ]]; then
    # no art to grab
    clearMediaArt
    echo "NULL"
    exit 1
  fi

  curl -s "${new_album_art}" --output "$stored_art_dir/$art_hash"
  echo "$art_hash" > "$stored_art_id"
  echo "$stored_art_dir/$art_hash"
  exit 0
fi

if [[ $album_art == file://* ]]; then
  new_album_art="${album_art/file:\/\//}"
  echo "$art_hash" > "$stored_art_id"
  cp "$new_album_art" "$stored_art_dir/$art_hash"
  echo "$stored_art_dir/$art_hash"
  exit 0
fi

# unknown protocol
clearMediaArt
echo "NULL"
exit 1
