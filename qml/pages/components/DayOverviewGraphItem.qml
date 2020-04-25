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

import QtQuick 2.6
import Sailfish.Silica 1.0

import "../../js/storage.js" as Storage

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
