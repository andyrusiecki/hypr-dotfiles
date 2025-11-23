#!/bin/bash

config_dir="$HOME/.config/obsidian"
pywal_theme="$HOME/.cache/wal/colors-obsidian.css"

if [ ! -d "$config_dir" ]; then
  echo "Obsidian config directory not found at $config_dir"
  exit 1
fi

if [ ! -f "$pywal_theme" ]; then
  echo "Pywal theme file not found at $pywal_theme"
  exit 1
fi

vaults="$(jq -r '.vaults[].path' $config_dir/obsidian.json)"

for vault in $vaults; do
  themes_dir="$vault/.obsidian/themes"
  if [ ! -d "$vault/.obsidian" ]; then
    echo "Vault at $vault: .obsidian directory not found, skipping..."
    continue
  fi

  if [ ! -d "$vault/.obsidian/snippets" ]; then
    echo "Vault at $vault: .obsidian/snippets directory not found, skipping..."
    continue
  fi

  target_theme="$vault/.obsidian/snippets/pywal.css"
  cp "$pywal_theme" "$target_theme"
  echo "Vault $vault: Installed pywal theme"

  appearance_file="$vault/.obsidian/appearance.json"
  if [ ! -f "$appearance_file" ]; then
    echo "Vault at $vault: appearance.json not found, skipping..."
    continue
  fi

  accent_color="$(jq -r '.colors.color1' $HOME/.cache/wal/colors.json)"

  jq --arg color "$accent_color" -r '.accentColor = $color | if (.enabledCssSnippets | contains(["pywal"])) then . else (.enabledCssSnippets |= . + ["pywal"]) end' "$appearance_file" > "$appearance_file.tmp"
  mv "$appearance_file.tmp" "$appearance_file"

  echo "Vault $vault: Updated appearance.json to at $appearance_file"
done
