/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.0
import Sailfish.Silica 1.0

import "../qchart/"
import "../qchart/QChart.js" as Charts


Item {
    id: forecast
    property int day
    property var rain
    property var temp
    property var sun
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
                height: 7*spacing + tempTitle.height + tempHeight + rainTitle.height + rainColumn.height + sunTitle.height + sunHeight + windTitle.height + rainColumn.height
                width: calcWidth < 1840 ? 1840 : calcWidth

                spacing: Theme.paddingLarge

                visible: forecast.loaded
                Behavior on opacity { NumberAnimation { duration: 50 } }
                opacity: forecast.loaded ? 1 : 0

                // TODO add some space for symbols above the charts
                property int tempHeight: 350
                property int rainHeight: 350
                property int sunHeight: 350
                property int windHeight: 350

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

                Column {
                    id: rainColumn
                    width: parent.width
                    height: childrenRect.height
                    spacing: Theme.paddingSmall

                    Row {
                        id: rainPercentage
                        width: parent.width - 2*x
                        x: !!rainLoader.item ? rainLoader.item.chartStartX : 0

                        Repeater {
                            model: !!rain ? rain.datasets[0].symbols : 0

                            Label {
                                width: !!rainLoader.item ? rainLoader.item.chartValueHop : 10
                                text: modelData !== null ? "%1%".arg(modelData) : ""
                                font.pixelSize: Theme.fontSizeExtraSmall
                                horizontalAlignment: Text.AlignHCenter
                                color: Qt.tint(Theme.primaryColor, "#900000FF")
                                opacity: (modelData || 0) / 100 + 0.3
                            }
                        }
                    }

                    Loader {
                        id: rainLoader
                        asynchronous: true
                        width: parent.width
                        height: chart.rainHeight
                        // onLoaded: forecast.loaded = true // ignore because the others have to be finished first
                    }
                }

                Item { // placeholder
                    id: sunTitlePlace
                    height: sunTitle.height
                    width: parent.width
                }

                Loader {
                    id: sunLoader
                    onLoaded: forecast.loaded = true
                    asynchronous: true
                }

                Item { // placeholder
                    id: windTitlePlace
                    height: windTitle.height
                    width: parent.width
                }

                Column {
                    id: windColumn
                    width: parent.width
                    height: childrenRect.height
                    spacing: Theme.paddingSmall

                    Row {
                        id: windDirection
                        width: parent.width - 2*x
                        x: !!windLoader.item ? windLoader.item.chartStartX : 0

                        Repeater {
                            model: !!wind ? wind.datasets[0].symbols : 0

                            Column {
                                width: !!windLoader.item ? windLoader.item.chartValueHop : 10
                                height: childrenRect.height

                                Label {
                                    visible: modelData !== null
                                    width: Theme.fontSizeMedium
                                    height: width
                                    font.family: "monospace"
                                    text: "↑"
                                    color: Theme.secondaryColor
                                    rotation: 180+(modelData || 0.0)
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                Label {
                                    visible: modelData !== null
                                    text: modelData + "°"
                                    font.pixelSize: Theme.fontSizeExtraSmall
                                    horizontalAlignment: Text.AlignHCenter
                                    color: Theme.secondaryColor
                                }
                            }

                        }
                    }

                    Loader {
                        id: windLoader
                        onLoaded: forecast.loaded = true
                        width: parent.width
                        height: chart.windHeight
                        asynchronous: true
                    }
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
        id: sunTitle
        place: sunTitlePlace
        text: qsTr("Sunshine")
        unit: meteoApp.sunUnit
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
        x: rainColumn.x + rainLoader.x
        y: rainColumn.y + rainLoader.y
        asynchronous: true

        visible: forecast.loaded
        Behavior on opacity { NumberAnimation { duration: 50 } }
        opacity: forecast.loaded ? 1 : 0
    }

    Loader {
        id: sunScaleLoader
        x: sunLoader.x
        y: sunLoader.y
        asynchronous: true

        visible: forecast.loaded
        Behavior on opacity { NumberAnimation { duration: 50 } }
        opacity: forecast.loaded ? 1 : 0
    }

    Loader {
        id: windScaleLoader
        x: windColumn.x + windLoader.x
        y: windColumn.y + windLoader.y
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
            sun = meteoApp.forecastData[day].sun
            wind = meteoApp.forecastData[day].wind

            var isToday = (new Date(meteoApp.forecastData[day].date).toDateString() == new Date().toDateString());

            tempLoader.setSource("TemperatureChart.qml",      { height: chart.tempHeight, width: chart.width,  scaleOnly: false, isToday: isToday })
            tempScaleLoader.setSource("TemperatureChart.qml", { height: chart.tempHeight, width: Screen.width, scaleOnly: true,  isToday: isToday })

            rainLoader.setSource("RainChart.qml",      { height: chart.rainHeight, width: chart.width,  scaleOnly: false, isToday: isToday })
            rainScaleLoader.setSource("RainChart.qml", { height: chart.rainHeight, width: Screen.width, scaleOnly: true,  isToday: isToday })

            sunLoader.setSource("SunChart.qml",      { height: chart.sunHeight, width: chart.width,  scaleOnly: false, isToday: isToday })
            sunScaleLoader.setSource("SunChart.qml", { height: chart.sunHeight, width: Screen.width, scaleOnly: true,  isToday: isToday })

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
