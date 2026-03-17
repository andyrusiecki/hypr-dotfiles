import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root
  implicitWidth: mediaRow.width + 14
  implicitHeight: 30

  property string dotfilesDir: Qt.environment.value("DOTFILES_DIR") || (Qt.environment.value("HOME") + "/.dotfiles")

  Process {
    id: mediaProc
    command: ["bash", "-c", "status=$(playerctl status 2>/dev/null); [ \"$status\" != \"Stopped\" ] && [ -n \"$status\" ] && exec \"$DOTFILES_DIR/waybar/scripts/media-status.sh\" 2>/dev/null || echo '{\"alt\":\"none\",\"text\":\"\",\"class\":[\"status-stopped\"]}'"]
    environment: ({ "DOTFILES_DIR": root.dotfilesDir })
    running: false
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const raw = this.text.trim()
          const line = raw.split("\n").filter(l => l.length).pop() || "{}"
          const j = JSON.parse(line)
          root.alt = j.alt || "none"
          root.text = j.text || ""
          root.tooltip = j.tooltip || ""
          root.statusClass = (j.class && j.class.join(" ")) || "status-stopped"
          root.progressClass = (j.class && j.class.find(c => c.startsWith("progress-"))) || ""
        } catch (_) {
          root.alt = "none"
          root.text = ""
          root.tooltip = ""
          root.statusClass = "status-stopped"
          root.progressClass = ""
        }
      }
    }
    function run() {
      mediaProc.running = true
    }
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: mediaProc.run()
  }

  Component.onCompleted: mediaProc.run()

  property string alt: "none"
  property string text: ""
  property string tooltip: ""
  property string statusClass: "status-stopped"
  property string progressClass: ""

  readonly property var playerIcons: ({
    "default": "\uf001",
    "chrome": "\uf268",
    "chromium": "\uf268",
    "firefox": "\ue787",
    "spotify": "\uf1bc",
    "twitch": "\uf1e8",
    "youtube": "\uf167"
  })
  readonly property string icon: playerIcons[alt] || playerIcons["default"]

  Row {
    id: mediaRow
    anchors.centerIn: parent
    spacing: 4
    opacity: statusClass === "status-stopped" ? 0.5 : 1

    Text {
      text: root.icon
      font.pixelSize: 20
      font.family: "Symbols Nerd Font Mono"
      anchors.verticalCenter: parent.verticalCenter
    }
    Column {
      visible: root.text.length > 0
      spacing: 0
      Text {
        text: root.text.length > 100 ? root.text.slice(0, 97) + "…" : root.text
        font.pixelSize: 12
        font.bold: true
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: playPauseProc.running = true
  }

  Process {
    id: playPauseProc
    command: ["playerctl", "play-pause"]
    running: false
  }
}
