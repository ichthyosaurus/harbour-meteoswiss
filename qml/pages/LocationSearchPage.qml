import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            PageHeader {
                title: qsTrId("Add Location")
            }

            width: parent.width
            spacing: Theme.paddingLarge

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Not implemented yet"
                font.pixelSize: Theme.fontSizeMedium
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
