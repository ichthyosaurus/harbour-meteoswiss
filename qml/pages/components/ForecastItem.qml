import QtQuick 2.0
import Sailfish.Silica 1.0


Column {
    id: forecast
    property string title: meteoApp.dataIsReady ? meteoApp.forecastData[dayId].dateString : 'Loading...'
    property bool active
    property int dayId

    width: parent.width - (Theme.horizontalPageMargin * 2)
    x: Theme.horizontalPageMargin

    Column {
        width: forecast.width

        BackgroundItem {
            width: parent.width
            height: Theme.itemSizeSmall

            onClicked: active ? (meteoApp.dataIsReady ? pageStack.push(Qt.resolvedUrl("../TablePage.qml"), { name: title, day: dayId }) : console.log("table locked")) : mainPage.activateGraph(dayId)

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
        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: active ? 1 : 0
        day: dayId
    }

    function refreshTitle(data) {
        title = meteoApp.forecastData[dayId].dateString ? meteoApp.forecastData[dayId].dateString : 'Failed...'
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(refreshTitle)
        meteoApp.dataIsLoading.connect(function(){ title = "Loading..." })
    }
}
