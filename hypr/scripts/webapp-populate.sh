#!/bin/bash

# Populate default webapps

# YouTube
$DOTFILES_DIR/hypr/scripts/webapp-create.sh --icon youtube  YouTube "https://www.youtube.com"

# Zoom
$DOTFILES_DIR/hypr/scripts/webapp-create.sh --icon zoom --mimetypes "x-scheme-handler/zoommtg;x-scheme-handler/zoomus" --exec "$DOTFILES_DIR/hypr/scripts/webapp-launch-zoom.sh %u" Zoom "https://app.zoom.us/wc/home"

