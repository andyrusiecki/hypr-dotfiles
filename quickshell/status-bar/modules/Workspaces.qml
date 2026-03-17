import QtQuick
import Quickshell.Hyprland

Row {
  id: root
  spacing: 5
  property var monitor: null

  // Icons match waybar format-icons (Nerd Font): 1=term, 2=code, 3=music, 4=doc, 5=chat, 6=game, 7=media
  property var wsIcons: ["\ue62e", "\ue70c", "\uf001", "\ue799", "\uf086", "\ue21c", "\ue648"]
  Repeater {
    model: 6
    delegate: Item {
      id: wsDelegate
      width: 24
      height: 24
      property int wsNum: index + 1
      property bool active: root.monitor && root.monitor.activeWorkspace && root.monitor.activeWorkspace.name === String(wsNum)
      property bool focused: root.monitor && root.monitor.focused && active

      Text {
        anchors.centerIn: parent
        text: root.wsIcons[index] || String(wsNum)
        font.pixelSize: 15
        font.family: "Symbols Nerd Font Mono"
        opacity: wsDelegate.active || wsDelegate.focused ? 1.0 : 0.5
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace " + wsNum)
        onWheel: function(wheel) {
          if (wheel.angleDelta.y > 0) Hyprland.dispatch("workspace e-1")
          else Hyprland.dispatch("workspace e+1")
        }
      }
    }
  }
}
