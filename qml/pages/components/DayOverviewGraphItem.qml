import QtQuick 2.6
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0

import "../../js/storage.js" as Storage

Column {
    id: forecast

    property int day: 0
    property var location
    property bool dataReady: false
    property bool loaded: false

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

    function loadChart(newData, newLocation) {
        if (   day === null
            || (newLocation !== undefined && newLocation != location)
            || pageStack.busy
            || !forecast.visible
            || forecast.loaded) {
            return
        }

        var data = Storage.getData(location);

        if (data.length == 0 || data[0].data.dayCount <= day) {
            console.log("failed to retrieve valid data")
            return
        }

        data = JSON.parse(data[0].data)
        dataReady = true;

        if (dataReady) {
            console.log("loading overview chart for day " + day + " of " + location+ "...")

            var isToday = true;
            temp = data[day].temperature
            rain = data[day].rainfall

            tempLoader.setSource("TemperatureChart.qml", { data: temp, asOverview: true })
            rainLoader.setSource("RainChart.qml",        { data: rain, asOverview: true })
            forecast.loaded = true
        } else {
            console.log("overview chart for day", day, "(" + location + ") not updated: data is not ready")
        }
    }

    Component.onCompleted: {
        meteoApp.dataLoaded.connect(loadChart)
    }

    onVisibleChanged: {
        loadChart();
    }

    property var appState: Qt.application.state

    onAppStateChanged: {
        if (Qt.application.state === Qt.ApplicationActive) {
            forecast.loaded = false;
            loadChart();
        }
    }
}
