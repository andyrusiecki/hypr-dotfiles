import QtQuick
import Quickshell.Io

Item {
  implicitWidth: 24
  implicitHeight: 30

  Text {
    anchors.centerIn: parent
    text: "\ueb54"
    font.pixelSize: 14
    font.family: "Adwaita Nerd Font Mono"
  }

  MouseArea {
    anchors.fill: parent
    onClicked: bluetuiProc.running = true
  }

  Process {
    id: bluetuiProc
    command: ["uwsm-app", "--", "kitty", "--class", "TUI.float", "bluetui"]
    running: false
  }
}
