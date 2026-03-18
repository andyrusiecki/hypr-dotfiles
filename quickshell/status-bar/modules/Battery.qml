import QtQuick
import Quickshell.Io

Item {
  id: root
  implicitWidth: batText.width + 8
  implicitHeight: 30

  Process {
    id: proc
    command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const parts = this.text.trim().split("\n")
        root.capacity = parts[0] ? parseInt(parts[0], 10) : 100
        root.status = (parts[1] || "Unknown").toLowerCase()
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: proc.running = true
  }
  Component.onCompleted: proc.running = true

  property int capacity: 0
  property string status: "unknown"

  readonly property string icon: {
    if (status === "charging" || status === "full") return "\ueb58"
    const i = Math.min(9, Math.floor(capacity / 10))
    const icons = ["\ueb59", "\ueb5a", "\ueb5b", "\ueb5c", "\ueb5d", "\ueb5e", "\ueb5f", "\ueb60", "\ueb61", "\ueb58"]
    return icons[i] || "\ueb59"
  }

  Row {
    id: batRow
    anchors.centerIn: parent
    spacing: 2
    Text {
      text: root.capacity + "%"
      font.pixelSize: 12
    }
    Text {
      id: batText
      text: root.icon
      font.pixelSize: 14
      font.family: "Adwaita Nerd Font Mono"
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: joltProc.running = true
  }

  Process {
    id: joltProc
    command: ["uwsm-app", "--", "kitty", "--class", "TUI.float", "jolt"]
    running: false
  }
}
