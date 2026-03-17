import QtQuick
import Quickshell.Io

Item {
  id: root
  implicitWidth: 24
  implicitHeight: 30
  visible: swayncRunning

  Process {
    id: checkProc
    command: ["pgrep", "swaync"]
    running: false
    stdout: StdioCollector { onStreamFinished: root.swayncRunning = this.text.trim().length > 0 }
  }

  Process {
    id: statusProc
    command: ["swaync-client", "-swb"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const s = this.text.trim()
        root.hasNotification = s.includes("notification") || s.includes("dnd-notification")
        root.dnd = s.includes("dnd-")
        root.inhibited = s.includes("inhibited")
      }
    }
  }

  Timer {
    interval: 5000
    running: root.swayncRunning
    repeat: true
    onTriggered: statusProc.running = true
  }

  property bool swayncRunning: false
  property bool hasNotification: false
  property bool dnd: false
  property bool inhibited: false

  Component.onCompleted: checkProc.running = true

  onSwayncRunningChanged: if (swayncRunning) statusProc.running = true

  readonly property string icon: {
    if (dnd && hasNotification) return "\ueb4e"
    if (dnd) return "\ueb4f"
    if (inhibited && hasNotification) return "\ueb50"
    if (inhibited) return "\ueb51"
    if (hasNotification) return "\uf0f3"
    return "\ueb52"
  }

  Text {
    anchors.centerIn: parent
    text: root.icon
    font.pixelSize: 14
    font.family: "Symbols Nerd Font Mono"
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
      if (mouse.button === Qt.RightButton) dndProc.running = true
      else toggleProc.running = true
    }
  }

  Process {
    id: toggleProc
    command: ["swaync-client", "-t", "-sw"]
    running: false
  }

  Process {
    id: dndProc
    command: ["swaync-client", "-d", "-sw"]
    running: false
  }
}
