import QtQuick 2.0
import Sailfish.Silica 1.0


Column {
    id: forecast
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

            onClicked: active ? pageStack.push(Qt.resolvedUrl("../Table.qml"), { name: title, rainData: dataRain, tempData: dataTemp }) : mainPage.activateGraph(dayId)

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
        visible: active
        rain: dataRain
        temp: dataTemp
    }
}
