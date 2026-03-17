import QtQuick
import Quickshell.Io

Row {
  id: clock
  spacing: 4

  Process {
    id: dateProc
    command: ["date", "+%I:%M:%S %p %Z"]
    running: true
    stdout: StdioCollector {
      onStreamFinished: timeText.text = this.text.trim()
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
  }

  Text {
    id: iconText
    text: "\ueb53"
    font.pixelSize: 14
    font.family: "Symbols Nerd Font Mono"
  }
  Text {
    id: timeText
    text: "--:--:--"
    font.pixelSize: 12
  }
}
