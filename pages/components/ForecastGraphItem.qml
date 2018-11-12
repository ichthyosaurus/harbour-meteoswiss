import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


Item {
    id: forecast
    property int day
    property var rain: main.data[day].rainfall
    property var temp: main.data[day].temperature
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

                visible: forecast.loaded
                Behavior on opacity { NumberAnimation { duration: 500 } }
                opacity: forecast.loaded ? 1 : 0

                property int tempHeight: 500
                property int rainHeight: 290

                height: tempHeight + spacing + rainHeight
                width: 2000
                spacing: Theme.paddingLarge

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
        console.log("loading charts...")
        tempLoader.setSource("TemperatureChart.qml", { height: chart.tempHeight, width: chart.width })
        rainLoader.setSource("RainChart.qml", { height: chart.rainHeight, width: chart.width })
    }

    Component.onCompleted: {
        main.dataLoaded.connect(loadCharts)
        main.dataIsLoading.connect(function(){ forecast.loaded = false })
    }
}
