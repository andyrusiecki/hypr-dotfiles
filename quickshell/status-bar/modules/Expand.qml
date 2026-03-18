import QtQuick

// Placeholder for expand drawer (waybar group/expand). Click could toggle a drawer of tray/cpu/memory/etc.
Item {
  implicitWidth: 24
  implicitHeight: 30

  Text {
    anchors.centerIn: parent
    text: "\ue804"  // chevron / expand icon
    font.pixelSize: 14
    font.family: "Adwaita Nerd Font Mono"
  }

  MouseArea {
    anchors.fill: parent
    onClicked: { /* could open drawer with tray, cpu, memory, power-profiles, exit */ }
  }
}
