import QtQuick
import Quickshell.Io

Item {
  id: root
  implicitWidth: text.length > 0 ? recIcon.width + 8 : 0
  implicitHeight: 30
  visible: text.length > 0

  property string dotfilesDir: Qt.environment.value("DOTFILES_DIR") || (Qt.environment.value("HOME") + "/.dotfiles")

  Process {
    id: proc
    command: ["bash", "-c", "pgrep -f '^gpu-screen-recorder' >/dev/null && echo '{\"alt\":\"active\",\"tooltip\":\"Stop recording\",\"class\":\"active\"}' || echo '{\"text\":\"\"}'"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const j = JSON.parse(this.text.trim().split("\n").pop() || "{}")
          root.text = j.text || (j.class === "active" ? "\uf03d" : "")
          root.tooltip = j.tooltip || ""
          root.active = j.class === "active"
        } catch (_) {
          root.text = ""
          root.active = false
        }
      }
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: proc.running = true
  }

  property string text: ""
  property string tooltip: ""
  property bool active: false

  Text {
    id: recIcon
    anchors.centerIn: parent
    text: root.text
    font.pixelSize: 14
    font.family: "Symbols Nerd Font Mono"
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      if (root.active) killProc.running = true
    }
  }

  Process {
    id: killProc
    command: ["pkill", "-SIGINT", "-f", "gpu-screen-recorder"]
    running: false
  }
}
