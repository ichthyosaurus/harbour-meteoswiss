import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../js/strings.js" as Strings

Column {
    id: forecast
    property string title: meteoApp.dataIsReady[locationId] ? formatTitleDate() : qsTr('Loading...')
    property bool active
    property int dayId

    width: parent.width

    Column {
        width: parent.width

        BackgroundItem {
            width: parent.width
            height: Theme.itemSizeSmall

            onClicked: active ? (
                meteoApp.dataIsReady[locationId] ? pageStack.push(
                    Qt.resolvedUrl("../TablePage.qml"), { name: title, day: dayId }
                ) : console.log("table locked")
            ) : mainPage.activateGraph(dayId)

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width-x-moreImage.width-moreImage.anchors.rightMargin
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

            Rectangle {
                anchors.fill: parent
                z: -1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }
    }

    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    Column {
        x: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
        width: parent.width - 2*x
        height: summary1.height + descriptionLabel.height

        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: graph.loaded ? 1 : 0
        visible: active

        Row {
            width: parent.width
            ForecastSummaryItem { id: summary1; visible: graph.loaded; hour: 2; day: dayId }
            ForecastSummaryItem { id: summary2; visible: graph.loaded; hour: 5; day: dayId }
            ForecastSummaryItem { id: summary3; visible: graph.loaded; hour: 8; day: dayId }
            ForecastSummaryItem { id: summary4; visible: graph.loaded; hour: 11; day: dayId }
            ForecastSummaryItem { id: summary5; visible: graph.loaded; hour: 14; day: dayId }
            ForecastSummaryItem { id: summary6; visible: graph.loaded; hour: 17; day: dayId }
            ForecastSummaryItem { id: summary7; visible: graph.loaded; hour: 20; day: dayId }
            ForecastSummaryItem { id: summary8; visible: graph.loaded; hour: 23; day: dayId }
        }

        Label {
            id: descriptionLabel
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.primaryColor
            horizontalAlignment: Text.AlignHCenter
            width: parent.width - 4*parent.x
            wrapMode: Text.WordWrap
            x: (parent.x + parent.width/2) - (width/2)

            Component.onCompleted: {
                var callback = function(hour, symbol) {
                    text = String(qsTr("%1: %2", "time (1) with weather description (2)")).arg(hour).arg(Strings.MeteoLang.weatherSymbolDescription[symbol])
                }

                summary1.summaryClicked.connect(callback);
                summary2.summaryClicked.connect(callback);
                summary3.summaryClicked.connect(callback);
                summary4.summaryClicked.connect(callback);
                summary5.summaryClicked.connect(callback);
                summary6.summaryClicked.connect(callback);
                summary7.summaryClicked.connect(callback);
                summary8.summaryClicked.connect(callback);
            }
        }
    }


    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    ForecastGraphItem {
        id: graph
        visible: active
        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: active ? 1 : 0
        day: dayId
    }

    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    Row {
        id: statusRow
        x: titleLabel.x
        visible: active ? (meteoApp.dataIsReady[locationId] ? true : false) : false

        Label {
            text: qsTr("status: ")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeTiny
        }

        Label {
            id: statusLabel
            text: meteoApp.dataTimestamp.toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeTiny
        }

        Label {
            text: " – " + qsTr("now: ")
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeTiny
        }

        Label {
            id: clockLabel
            text: new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeTiny
        }
    }

    Item { // vertical spacing
        height: Theme.paddingMedium
        width: parent.width
        visible: active
    }

    function formatTitleDate() {
        return new Date(meteoApp.forecastData[dayId].date).toLocaleString(Qt.locale(), meteoApp.fullDateFormat);
    }

    function refreshTitle(data) {
        title = meteoApp ? (meteoApp.forecastData[dayId].date ? formatTitleDate() : qsTr('Failed...')) : qsTr('Failed...')

        if (statusRow) {
            statusLabel.text = (meteoApp ?
                (meteoApp.forecastData[dayId].date ?
                    meteoApp.dataTimestamp.toLocaleString(Qt.locale(), meteoApp.dateTimeFormat) : qsTr('unknown')) : qsTr('unknown'))
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(refreshTitle)
        meteoApp.dataIsLoading.connect(function(){
            title = qsTr("Loading...");

            if (statusRow) {
                statusLabel.text = qsTr("unknown")
            }
        })
    }

    Timer {
        id: clockTimer
        interval: 15*1000
        repeat: true
        running: true
        onTriggered: {
            clockLabel.text = new Date().toLocaleString(Qt.locale(), meteoApp.dateTimeFormat)
        }
    }
}
