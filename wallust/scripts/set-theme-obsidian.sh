#!/bin/bash

# Sync Wallust theme to all Obsidian vaults
# Adapted from Omarchy: https://github.com/basecamp/omarchy/blob/master/bin/omarchy-theme-set-obsidian

theme_css="$HOME/.cache/wallust/obsidian.css"

[ -f "$theme_css" ] || exit 0

jq -r '.vaults | values[].path' ~/.config/obsidian/obsidian.json 2>/dev/null | while read -r vault_path; do
  [ -d "$vault_path/.obsidian" ] || continue

  theme_dir="$vault_path/.obsidian/themes/Wallust"
  mkdir -p "$theme_dir"

  [ -f "$theme_dir/manifest.json" ] || cat >"$theme_dir/manifest.json" <<'EOF'
{
  "name": "Wallust",
  "version": "1.0.0",
  "minAppVersion": "0.16.0",
  "description": "Automatically syncs with your current Wallust system theme colors and fonts",
  "author": "",
  "authorUrl": ""
}
EOF

  cp "$theme_css" "$theme_dir/theme.css"
done
