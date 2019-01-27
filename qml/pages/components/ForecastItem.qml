import QtQuick 2.0
import Sailfish.Silica 1.0


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

    Row {
        width: parent.width - 2*x
        x: Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium
        height: summary.height
        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: graph.loaded ? 1 : 0
        visible: active

        ForecastSummaryItem { visible: graph.loaded; id: summary; hour: 2; day: dayId }
        ForecastSummaryItem { visible: graph.loaded; hour: 5; day: dayId }
        ForecastSummaryItem { visible: graph.loaded; hour: 8; day: dayId }
        ForecastSummaryItem { visible: graph.loaded; hour: 11; day: dayId }
        ForecastSummaryItem { visible: graph.loaded; hour: 14; day: dayId }
        ForecastSummaryItem { visible: graph.loaded; hour: 17; day: dayId }
        ForecastSummaryItem { visible: graph.loaded; hour: 20; day: dayId }
        ForecastSummaryItem { visible: graph.loaded; hour: 23; day: dayId }
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

    Label {
        id: statusLabel
        x: titleLabel.x
        visible: active
        text: qsTr("status: ") + meteoApp.dataTimestamp.toLocaleString(Qt.locale(), Locale.ShortFormat) + " – " + qsTr("current: ") + new Date().toLocaleString(Qt.locale(), Locale.ShortFormat) // TODO improve, translate, add status, make dynamic, etc.
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny
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
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(refreshTitle)
        meteoApp.dataIsLoading.connect(function(){ title = qsTr("Loading...") })
    }
}
