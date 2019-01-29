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

    property var forecastData: Forecast.fullData
    property var dataIsReady: ({})
    property var dataTimestamp

    property string dateTimeFormat: qsTr("d MMM yyyy '('hh':'mm')'")
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
            dataTimestamp = new Date(messageObject.timestamp)
            meteoApp.forecastData = messageObject.data
            Storage.setData(messageObject.timestamp, messageObject.locationId, JSON.stringify(messageObject.data))
            meteoApp.dataIsReady[messageObject.locationId] = true
            dataLoaded(messageObject.data, messageObject.locationId)
        }
    }

    function doRefreshData(locationId, force) {
        if (locationId) {
            console.log("refreshing " + locationId + "...")
            meteoApp.dataIsReady[locationId] = false
            dataIsLoading(locationId)

            var archived = [];
            if (!force) {
                archived = Storage.getData(locationId, true)
            }

            dataLoader.sendMessage({
                data: archived.length > 0 ? archived[0] : null,
                locationId: locationId,
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
