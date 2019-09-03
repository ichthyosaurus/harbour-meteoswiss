/*
 * This file is part of harbour-meteoswiss.
 * Copyright (C) 2018-2019  Mirian Margiani
 *
 * harbour-meteoswiss is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * harbour-meteoswiss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with harbour-meteoswiss.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../../qchart/"
import "../../qchart/QChart.js" as Charts


Item {
    id: forecast
    property int day
    property var rain
    property var temp
    property var wind
    property bool loaded: false

    height: chart.height
    width: parent.width
    clip: true

    SilicaFlickable {
        anchors.fill: parent
        flickableDirection: Flickable.HorizontalFlick

        contentHeight: waitingForData.visible ? waitingForData.height : row.height
        contentWidth: row.width

        Row {
            id: row
            width: chart.width + (2 * spacing)
            height: chart.height
            spacing: Theme.paddingLarge

            Column {
                id: chart
                property int calcWidth: (Screen.height - 4*(Screen.sizeCategory > Screen.Medium ? Theme.horizontalPageMargin : Theme.paddingMedium))
                height: 5*spacing + tempTitle.height + tempHeight + rainTitle.height + rainHeight + windTitle.height + windHeight
                width: calcWidth < 1840 ? 1840 : calcWidth

                spacing: Theme.paddingLarge

                visible: forecast.loaded
                Behavior on opacity { NumberAnimation { duration: 50 } }
                opacity: forecast.loaded ? 1 : 0

                property int tempHeight: 500
                property int rainHeight: 290
                property int windHeight: 200

                Item { // placeholder
                    id: tempTitlePlace
                    height: tempTitle.height
                    width: parent.width
                }

                Loader {
                    id: tempLoader
                    asynchronous: true
                    // onLoaded: forecast.loaded = true // ignore because the others have to be finished first
                }

                Item { // placeholder
                    id: rainTitlePlace
                    height: rainTitle.height
                    width: parent.width
                }

                Loader {
                    id: rainLoader
                    asynchronous: true
                    // onLoaded: forecast.loaded = true // ignore because the others have to be finished first
                }

                Item { // placeholder
                    id: windTitlePlace
                    height: windTitle.height
                    width: parent.width
                }

                Loader {
                    id: windLoader
                    onLoaded: forecast.loaded = true
                    asynchronous: true
                }
            }
        }
    }

    Column {
        id: waitingForData
        width: forecast.width
        height: Screen.width
        anchors.verticalCenter: parent.verticalCenter

        Behavior on opacity { NumberAnimation { duration: 50 } }
        opacity: forecast.loaded ? 0 : 1
        visible: forecast.loaded ? false : true

        BusyIndicator {
            anchors.horizontalCenter: parent.horizontalCenter
            running: !forecast.loaded
            size: BusyIndicatorSize.Medium
        }
    }

    ForecastGraphTitle {
        id: tempTitle
        place: tempTitlePlace
        text: qsTr("Temperature")
        unit: meteoApp.tempUnit
    }

    ForecastGraphTitle {
        id: rainTitle
        place: rainTitlePlace
        text: qsTr("Precipitation")
        unit: meteoApp.rainUnit
    }

    ForecastGraphTitle {
        id: windTitle
        place: windTitlePlace
        text: qsTr("Wind")
        unit: meteoApp.windUnit
    }

    Loader {
        id: tempScaleLoader
        x: tempLoader.x
        y: tempLoader.y
        asynchronous: true

        visible: forecast.loaded
        Behavior on opacity { NumberAnimation { duration: 50 } }
        opacity: forecast.loaded ? 1 : 0
    }

    Loader {
        id: rainScaleLoader
        x: rainLoader.x
        y: rainLoader.y
        asynchronous: true

        visible: forecast.loaded
        Behavior on opacity { NumberAnimation { duration: 50 } }
        opacity: forecast.loaded ? 1 : 0
    }

    Loader {
        id: windScaleLoader
        x: windLoader.x
        y: windLoader.y
        asynchronous: true

        visible: forecast.loaded
        Behavior on opacity { NumberAnimation { duration: 50 } }
        opacity: forecast.loaded ? 1 : 0
    }

    function loadCharts() {
        if (   day === null
            || !forecast.visible
            || forecast.loaded) {
            return
        }

        if (meteoApp.dataIsReady[locationId]) {
            console.log("loading charts for day " + day + "...")

            temp = meteoApp.forecastData[day].temperature
            rain = meteoApp.forecastData[day].rainfall
            wind = meteoApp.forecastData[day].wind

            var isToday = (new Date(meteoApp.forecastData[day].date).toDateString() == new Date().toDateString());

            tempLoader.setSource("TemperatureChart.qml",      { height: chart.tempHeight, width: chart.width,  scaleOnly: false, isToday: isToday })
            tempScaleLoader.setSource("TemperatureChart.qml", { height: chart.tempHeight, width: Screen.width, scaleOnly: true,  isToday: isToday })

            rainLoader.setSource("RainChart.qml",      { height: chart.rainHeight, width: chart.width,  scaleOnly: false, isToday: isToday })
            rainScaleLoader.setSource("RainChart.qml", { height: chart.rainHeight, width: Screen.width, scaleOnly: true,  isToday: isToday })

            windLoader.setSource("WindChart.qml",      { height: chart.windHeight, width: chart.width,  scaleOnly: false, isToday: isToday })
            windScaleLoader.setSource("WindChart.qml", { height: chart.windHeight, width: Screen.width, scaleOnly: true,  isToday: isToday })
        } else {
            console.log("chart for day", day, "(" + locationId + ") not updated: data is not ready")
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(loadCharts)
        meteoApp.dataIsLoading.connect(function(){ if (forecast) forecast.loaded = false })
    }

    onVisibleChanged: {
        loadCharts();
    }

    property var appState: Qt.application.state

    onAppStateChanged: {
        if (Qt.application.state === Qt.ApplicationActive) {
            forecast.loaded = false;
            loadCharts();
        }
    }
}
