import QtQuick

Item {
  id: root
  implicitWidth: content.implicitWidth + 14
  implicitHeight: 30
  default property alias contentData: content.data

  Row {
    id: content
    anchors.centerIn: parent
    spacing: 0
  }
}
