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
                height: tempHeight + spacing + rainHeight
                width: 1740
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

    function loadCharts() {
        if (day === null) return

        if (meteoApp.dataIsReady[locationId]) {
            console.log("loading charts for day " + day + "...")
            temp = meteoApp.forecastData[day].temperature
            rain = meteoApp.forecastData[day].rainfall
            tempLoader.setSource("TemperatureChart.qml", { height: chart.tempHeight, width: chart.width })
            rainLoader.setSource("RainChart.qml", { height: chart.rainHeight, width: chart.width })
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
