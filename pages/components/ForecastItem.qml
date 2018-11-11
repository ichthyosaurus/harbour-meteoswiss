import QtQuick 2.0
import Sailfish.Silica 1.0


Column {
    property var dataRain
    property var dataTemp
    property string title
    property bool active
    property int dayId

    width: parent.width - (Theme.horizontalPageMargin * 2)
    x: Theme.horizontalPageMargin

    Column {
        width: parent.width

        BackgroundItem {
            width: parent.width
            height: Theme.itemSizeSmall

            onClicked: active ? pageStack.push(Qt.resolvedUrl("../Table.qml"), {}) : pageStack.replace(Qt.resolvedUrl("../Main.qml"), { activeDay: dayId })

            Label {
                id: titleLabel
                anchors {
                    rightMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                text: title
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }

            Image {
                id: moreImage
                anchors {
                    left: titleLabel.right
                    rightMargin: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
                source: "image://theme/icon-m-right?" + Theme.highlightColor
            }
        }
    }

    ForecastGraphItem {
        rain: dataRain
        temp: dataTemp
    }
}
