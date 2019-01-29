import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            PageHeader {
                title: qsTr("About MeteoSwiss")
            }

            width: parent.width
            spacing: Theme.paddingLarge

            Image {
                x: (parent.width/2)-(Theme.itemSizeExtraLarge/2)
                width: Theme.itemSizeExtraLarge
                height: Theme.itemSizeExtraLarge
                source: "../weather-icons/harbour-meteoswiss.svg"
                verticalAlignment: Image.AlignVCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: String(qsTr("Version %1")).arg("1.1.1")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeMedium
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Author")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Mirian Margiani (2018-2019)"
                font.pixelSize: Theme.fontSizeMedium
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Data")
                color: Theme.secondaryHighlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Text {
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                wrapMode: Text.Wrap
                text: qsTr("Copyright, Federal Office of Meteorology and Climatology MeteoSwiss.")
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.primaryColor
                horizontalAlignment: Text.AlignHCenter
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Website")
                onClicked: { Qt.openUrlExternally(qsTr('https://www.meteoschweiz.admin.ch/')) }
            }
        }
    }
}
