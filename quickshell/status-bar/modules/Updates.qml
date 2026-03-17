import QtQuick
import Quickshell.Io

Item {
  id: root
  implicitWidth: count > 0 ? updatesText.width + 12 : 0
  implicitHeight: 30
  visible: count > 0

  Process {
    id: proc
    command: ["bash", "-c", "[ -f /tmp/hypr-pending-updates ] && jq -r '.count.total' /tmp/hypr-pending-updates || echo 0"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const n = parseInt(this.text.trim(), 10)
        root.count = isNaN(n) ? 0 : n
      }
    }
  }

  Timer {
    interval: 300000
    running: true
    repeat: true
    onTriggered: proc.running = true
  }
  Component.onCompleted: proc.running = true

  property int count: 0

  Row {
    anchors.centerIn: parent
    spacing: 4
    Text {
      text: "\uf0ad"
      font.pixelSize: 14
      font.family: "Symbols Nerd Font Mono"
    }
    Text {
      id: updatesText
      text: root.count
      font.pixelSize: 12
    }
  }

  property string dotfilesDir: Qt.environment.value("DOTFILES_DIR") || (Qt.environment.value("HOME") + "/.dotfiles")

  MouseArea {
    anchors.fill: parent
    onClicked: {
      runScript.environment = { "DOTFILES_DIR": root.dotfilesDir }
      runScript.running = true
    }
  }

  Process {
    id: runScript
    command: ["bash", "-c", "exec \"$DOTFILES_DIR/hypr/scripts/system-update.sh\""]
    environment: ({ "DOTFILES_DIR": root.dotfilesDir })
    running: false
  }
}
