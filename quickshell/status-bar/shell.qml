import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import "./modules" as Modules

Variants {
  model: Quickshell.screens

  delegate: Component {
    PanelWindow {
      required property var modelData
      screen: modelData

      property var monitor: Hyprland.monitorFor(modelData)

      anchors {
        top: true
        left: true
        right: true
      }
      exclusiveZone: 30
      implicitHeight: 30

      Item {
        id: bar
        anchors.fill: parent

        // Left: workspaces
        Row {
          id: leftRow
          anchors.left: parent.left
          anchors.leftMargin: 7
          anchors.verticalCenter: parent.verticalCenter
          spacing: 7

          Modules.Workspaces {
            monitor: bar.parent.monitor
          }
        }

        // Right: modules (expand, privacy, screen-recording, updates, wireplumber, bluetooth, network, swaync, battery, clock)
        Row {
          id: rightRow
          anchors.right: parent.right
          anchors.rightMargin: 7
          anchors.verticalCenter: parent.verticalCenter
          spacing: 7

          Modules.Expand {}
          Modules.Privacy {}
          Modules.ScreenRecording {}
          Modules.Updates {}
          Modules.Wireplumber {}
          Modules.Bluetooth {}
          Modules.Network {}
          Modules.Swaync {}
          Modules.Battery {}
          Modules.Clock {}
        }

        // Center: media (centered between left and right)
        Item {
          anchors.left: leftRow.right
          anchors.right: rightRow.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom

          Modules.Media {
            anchors.centerIn: parent
          }
        }
      }
    }
  }
}
