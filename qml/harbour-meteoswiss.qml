import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "pages"

import "js/forecast.js" as Forecast
import "js/storage.js" as Storage


ApplicationWindow {
    id: meteoApp
    initialPage: entryPage
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    signal dataLoaded(var data, var locationId)
    signal dataIsLoading(var locationId)
    signal refreshData(var location, var force)
    signal locationAdded(var locationData)
    signal weekSummaryUpdated()

    // ===============================
    // ATTENTION UPDATE BEFORE RELEASE
    // -------------------------------
    property string version: "1.2.0-dev"
    property bool debug:     true
    // ===============================

    property var forecastData: Forecast.fullData
    property var dataIsReady: ({})
    property var dataTimestamp
    property var overviewTimestamp

    property var sourceBasePath: ""
    property var sourcePathUpdated: new Date("1970-01-01T00:00:00.000Z")

    property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
    property string timeFormat: qsTr("hh':'mm")
    property string fullDateFormat: qsTr("ddd d MMM yyyy")

    property string tempUnit: "°C"
    property string rainUnit: "mm/h"
    property string rainUnitShort: "mm"
    property string windUnit: "km/h"

    property var symbolHours: [2,5,8,11,14,17,20,23]
    property int noonHour: symbolHours[((symbolHours.length - symbolHours.length%2)/2)-1]

    Component {
        id: entryPage
        OverviewPage { }
    }

    WorkerScript {
        id: dataLoader
        source: "js/forecast.js"
        onMessage: {
            if (messageObject.type == 'path') {
                meteoApp.sourceBasePath = messageObject.source
                meteoApp.sourcePathUpdated = messageObject.age
            } else if (messageObject.type == 'weekOverview') {
                meteoApp.overviewTimestamp = messageObject.age;

                for (var i = 0; i < messageObject.data.length; i++) {
                    var d = messageObject.data[i];
                    Storage.setDaySummary(d.locationId, d.dayString, d.symbol, d.precipitation, d.tempMin, d.tempMax);
                }

                weekSummaryUpdated();
            } else {
                meteoApp.dataTimestamp = new Date(messageObject.timestamp)
                meteoApp.forecastData = messageObject.data
                Storage.setData(messageObject.timestamp, messageObject.locationId, messageObject.data)
                meteoApp.dataIsReady[messageObject.locationId] = true
                dataLoaded(messageObject.data, messageObject.locationId)
            }
        }
    }

    function doRefreshData(locationId, force) {
        if (!overviewTimestamp) {
            overviewTimestamp = Storage.getDaySummaryAge();
        }

        if (Date.now() - overviewTimestamp.getTime() > 60*60*1000) {
            overviewTimestamp = new Date()
            var locs = Storage.getLocationsList();
            dataLoader.sendMessage({
                type: "weekOverview",
                locations: locs,
            });
        }

        if (locationId) {
            console.log("refreshing " + locationId + "...")
            meteoApp.dataIsReady[locationId] = false
            dataIsLoading(locationId)

            var archived = [];
            if (!force) {
                archived = Storage.getData(locationId, true)
            }

            dataLoader.sendMessage({
                type: "forecast",
                data: archived.length > 0 ? archived[0] : null,
                locationId: locationId,
                source: meteoApp.sourceBasePath,
                sourceAge: meteoApp.sourcePathUpdated,
            })
        } else {
            console.log("refreshing all known locations...")
            var locs = Storage.getLocationData()
            for (var i = 0; i < locs.length; i++) {
                doRefreshData(locs[i].locationId, force)
            }
        }
    }

    Component.onCompleted: {
        doRefreshData()
        refreshData.connect(doRefreshData)
    }
}
