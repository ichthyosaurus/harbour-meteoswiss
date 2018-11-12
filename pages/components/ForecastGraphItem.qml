import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


Item {
    property int day
    property var rain: main.data[day].rainfall
    property var temp: main.data[day].temperature

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

                property int tempHeight: 500
                property int rainHeight: 290

                height: tempHeight + spacing + rainHeight
                width: 2000
                spacing: Theme.paddingLarge

                Loader {
                    id: tempLoader
                    asynchronous: true
                    visible: status == Loader.Ready
                }

                Loader {
                    id: rainLoader
                    asynchronous: true
                    visible: status == Loader.Ready
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
    }
}
