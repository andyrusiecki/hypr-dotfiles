import QtQuick
import Quickshell.Io

Item {
  id: root
  implicitWidth: 24
  implicitHeight: 30

  Process {
    id: volProc
    command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const m = this.text.match(/Volume:\s*[\d.]+\s*\[([M]*)\]/)
        root.muted = m && m[1] === "M"
        const v = this.text.match(/Volume:\s*([\d.]+)/)
        root.volume = v ? Math.round(parseFloat(v[1]) * 100) : 0
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: volProc.running = true
  }
  Component.onCompleted: volProc.running = true

  property bool muted: false
  property int volume: 0

  readonly property string icon: muted ? "\ueb4a" : (volume <= 33 ? "\ueb4b" : (volume <= 66 ? "\ueb4c" : "\ueb4d"))

  Text {
    anchors.centerIn: parent
    text: root.icon
    font.pixelSize: 14
    font.family: "Symbols Nerd Font Mono"
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      // waybar: uwsm-app -- kitty --class TUI.float wiremix --tab output
      wiremixProc.running = true
    }
    onWheel: function(wheel) {
      const delta = wheel.angleDelta.y > 0 ? "1%+" : "1%-"
      scrollProc.command = ["bash", "-c", "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " + delta + " && \"$DOTFILES_DIR/hypr/scripts/notify-audio-output.sh\""]
      scrollProc.environment = { "DOTFILES_DIR": root.dotfilesDir }
      scrollProc.running = true
    }
  }

  property string dotfilesDir: Qt.environment.value("DOTFILES_DIR") || (Qt.environment.value("HOME") + "/.dotfiles")

  Process {
    id: wiremixProc
    command: ["uwsm-app", "--", "kitty", "--class", "TUI.float", "wiremix", "--tab", "output"]
    running: false
  }

  Process {
    id: scrollProc
    command: []
    running: false
  }
}
