import QtQuick
import Quickshell.Io

Item {
  id: root
  implicitWidth: 24
  implicitHeight: 30

  Process {
    id: proc
    command: ["bash", "-c", "nmcli -t -f DEVICE,STATE,CONNECTION dev status 2>/dev/null | head -5"]
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        const line = this.text.split("\n").find(l => l.includes(":connected:"))
        root.connected = !!line
        root.connection = line ? line.split(":")[2] || "" : ""
      }
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    onTriggered: proc.running = true
  }
  Component.onCompleted: proc.running = true

  property bool connected: false
  property string connection: ""

  Text {
    anchors.centerIn: parent
    text: root.connected ? "\uf0ac" : "\uf06a"
    font.pixelSize: 14
    font.family: "Symbols Nerd Font Mono"
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      impalaProc.running = true
    }
  }

  Process {
    id: impalaProc
    command: ["uwsm-app", "--", "kitty", "--class", "TUI.float", "impala"]
    running: false
  }
}
