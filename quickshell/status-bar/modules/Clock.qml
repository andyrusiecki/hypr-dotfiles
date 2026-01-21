import Quickshell

Scope {
  Text {
    id: clock
    anchors.centerIn: parent

    Process {
      id: dateProc
      command: ["date", "+\"%a %b %e %H:%M:%S %p\""]
      running: true

      stdout: StdioCollector {
        onStreamFinished: clock.text = this.text
      }
    }

    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: dateProc.running = true
    }
  }
}
