import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Wayland

import "./modules" as Modules

Variants {
  model: Quickshell.screens;

  delegate: Component {
    PanelWindow {
      // the screen from the screens list will be injected into this
      // property
      required property var modelData

      // we can then set the window's screen to the injected property
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      Modules.Clock {}
    }
  }
}
