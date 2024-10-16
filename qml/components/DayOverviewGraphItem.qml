/*
 * This file is part of harbour-meteoswiss.
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2018-2024 Mirian Margiani
 */

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../js/storage.js" as Storage

Column {
    id: forecast

    property int day: 0
    property var location
    property bool dataReady: false

    property var temp
    property var rain

    Item {
        Loader {
            id: rainLoader
            height: forecast.height
            width: forecast.width
            anchors.bottom: tempLoader.bottom
            asynchronous: true
        }

        Loader {
            id: tempLoader
            height: forecast.height
            width: forecast.width
            asynchronous: true
        }
    }

    function loadChart(forDay) {
        if (   day === null
            || pageStack.busy
            || !forecast.visible
            || (forDay === undefined && day < 0)) {
            return
        }

        if (forDay !== undefined) day = forDay;

        if (forDay < 0) {
            tempLoader.source = undefined;
            rainLoader.source = undefined;
        }

        var data = Storage.getData(location);

        if (data.length === 0 || data[0].data.dayCount <= day) {
            console.log("failed to retrieve valid data")
            return
        }

        data = JSON.parse(data[0].data)
        dataReady = true;

        if (dataReady) {
            console.log("loading overview chart for day " + day + " of " + location+ "...")

            temp = data[day].temperature
            rain = data[day].rainfall

            tempLoader.setSource("TemperatureChart.qml", { data: temp, asOverview: true })
            rainLoader.setSource("RainChart.qml",        { data: rain, asOverview: true })
        } else {
            console.log("overview chart for day", day, "(" + location + ") not updated: data is not ready")
        }
    }

    onVisibleChanged: loadChart()

    property var appState: Qt.application.state
    onAppStateChanged: {
        if (Qt.application.state === Qt.ApplicationActive) {
            loadChart();
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(function(newData, newLocation) {
            if (newLocation !== undefined && newLocation !== location) return
            else loadChart()
        })
    }
}
