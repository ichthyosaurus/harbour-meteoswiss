import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


Item {
    id: forecast
    property int day
    property var rain
    property var temp
    property bool loaded: false

    height: chart.height
    width: parent.width
    clip: true

    SilicaFlickable {
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick

        contentHeight: row.height
        contentWidth: row.width

        Row {
            id: row
            width: chart.width + (2 * spacing)
            height: chart.height
            spacing: Theme.paddingLarge

            Column {
                id: chart
                property int calcWidth: (Screen.height - 4*(Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium))
                height: tempHeight + spacing + rainHeight
                width: calcWidth < 1840 ? 1840 : calcWidth
                spacing: Theme.paddingLarge

                visible: forecast.loaded
                Behavior on opacity { NumberAnimation { duration: 500 } }
                opacity: forecast.loaded ? 1 : 0

                property int tempHeight: 500
                property int rainHeight: 290

                Loader {
                    id: tempLoader
                    // onLoaded: forecast.loaded = true // ignore because rainfall has to be finished first
                }

                Loader {
                    id: rainLoader
                    onLoaded: forecast.loaded = true
                }
            }

            Column {
                id: waitingForData
                width: forecast.width
                height: 700
                anchors.verticalCenter: parent.verticalCenter

                Behavior on opacity { NumberAnimation { duration: 500 } }
                opacity: forecast.loaded ? 0 : 1
                visible: forecast.loaded ? false : true

                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: !forecast.loaded
                    size: BusyIndicatorSize.Medium
                }
            }
        }
    }

    Loader {
        id: tempScaleLoader
        x: tempLoader.x
        y: tempLoader.y

        visible: forecast.loaded
        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: forecast.loaded ? 1 : 0
    }

    Loader {
        id: rainScaleLoader
        x: rainLoader.x
        y: rainLoader.y

        visible: forecast.loaded
        Behavior on opacity { NumberAnimation { duration: 500 } }
        opacity: forecast.loaded ? 1 : 0
    }

    function loadCharts() {
        if (day === null) return

        if (meteoApp.dataIsReady[locationId]) {
            console.log("loading charts for day " + day + "...")
            temp = meteoApp.forecastData[day].temperature
            rain = meteoApp.forecastData[day].rainfall
            tempLoader.setSource("TemperatureChart.qml", { height: chart.tempHeight, width: chart.width, scaleOnly: false })
            tempScaleLoader.setSource("TemperatureChart.qml", { height: chart.tempHeight, width: Screen.width, scaleOnly: true })
            rainLoader.setSource("RainChart.qml", { height: chart.rainHeight, width: chart.width, scaleOnly: false })
            rainScaleLoader.setSource("RainChart.qml", { height: chart.rainHeight, width: Screen.width, scaleOnly: true })
        } else {
            console.log("chart for day", day, "(" + locationId + ") not updated: data is not ready")
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(loadCharts)
        meteoApp.dataIsLoading.connect(function(){ if (forecast) forecast.loaded = false })
    }

    property var appState: Qt.application.state

    onAppStateChanged: {
        if (Qt.application.state === Qt.ApplicationActive) {
            loadCharts();
        }
    }
}
