# Quickshell status bar

A QML status bar under `status-bar/` that mirrors the structure of [waybar](../waybar):

- **Left**: Hyprland workspaces (click to switch, scroll to cycle)
- **Center**: Media (MPRIS via `media-status.sh`, play-pause on click)
- **Right**: Expand, Privacy, Screen recording, Updates, Wireplumber (volume), Bluetooth, Network, Swaync, Battery, Clock

## Layout

Same three regions as waybar `config.jsonc`:

- `modules-left` → `Workspaces.qml`
- `modules-center` → `Media.qml`
- `modules-right` → `Expand`, `Privacy`, `ScreenRecording`, `Updates`, `Wireplumber`, `Bluetooth`, `Network`, `Swaync`, `Battery`, `Clock`

Scripts and behavior reuse waybar scripts where applicable (e.g. `waybar/scripts/media-status.sh`, `system-update-status.sh`, `screen-recording-status.sh`, `hypr/scripts/notify-audio-output.sh`, `system-update.sh`). Set `DOTFILES_DIR` so those scripts resolve.

## Run

Point quickshell at the status bar entry:

```bash
quickshell run /path/to/dotfiles/quickshell/status-bar/shell.qml
```

Requires [Quickshell](https://github.com/Quickshell/quickshell) with Hyprland and Wayland support. Font: **Symbols Nerd Font Mono** for icons.
